import oci
import json
import os
import logging
from datetime import datetime
from ingestion.utils.connections import get_s3_client_oci

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def extract_and_upload_reports():
    s3_oci = get_s3_client_oci()
    bucket_destino = os.getenv("OCI_BUCKET_NAME")
    
    cost_file_key = "observability/reports/observability_reports_oci_costs.json"
    status_file_key = "observability/reports/observability_reports_oci_status.json"

    try:
        signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
        
        logger.info("Iniciando extração de custos...")
        cost_data = get_cost_report(signer)
        
        logger.info("Iniciando extração de status das instâncias...")
        status_data = get_instance_status_report(signer)

        reports = [
            (cost_file_key, cost_data, "Custos"),
            (status_file_key, status_data, "Status/Shapes")
        ]

        for key, data, label in reports:
            s3_oci.put_object(
                Bucket=bucket_destino,
                Key=key,
                Body=json.dumps(data, indent=4, default=str), 
                ContentType='application/json'
            )
            logger.info(f"✅ Sucesso: Relatório de {label} enviado para o Lake.")

    except Exception as e:
        logger.error(f"❌ Erro no processo: {str(e)}")
        raise

def get_instance_status_report(signer):
    """Busca status, shape e nome de todas as instâncias no compartimento raiz (tenancy)"""
    compute_client = oci.core.ComputeClient(config={}, signer=signer)
    
    instances = compute_client.list_instances(compartment_id=signer.tenancy_id).data
    
    instance_list = []
    for ins in instances:
        instance_list.append({
            "display_name": ins.display_name,
            "instance_id": ins.id,
            "lifecycle_state": ins.lifecycle_state, 
            "shape": ins.shape,
            "ocpus": ins.shape_config.ocpus if ins.shape_config else None,
            "memory_gb": ins.shape_config.memory_in_gbs if ins.shape_config else None,
            "region": ins.region,
            "availability_domain": ins.availability_domain,
            "time_created": ins.time_created.isoformat()
        })

    return {
        "report_type": "OCI_INSTANCE_STATUS",
        "updated_at": datetime.utcnow().isoformat(),
        "total_instances": len(instance_list),
        "instances": instance_list
    }

def get_cost_report(signer):
    """Lógica original de extração de custos"""
    usage_client = oci.usage_api.UsageapiClient(config={}, signer=signer)
    now = datetime.utcnow()
    first_day = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    today_midnight = now.replace(hour=0, minute=0, second=0, microsecond=0)

    req_monthly = oci.usage_api.models.RequestSummarizedUsagesDetails(
        tenant_id=signer.tenancy_id,
        time_usage_started=first_day.strftime("%Y-%m-%dT%H:%M:%SZ"),
        time_usage_ended=today_midnight.strftime("%Y-%m-%dT%H:%M:%SZ"),
        granularity="MONTHLY",
        query_type="COST",
        group_by=["service"]
    )
    res_monthly = usage_client.request_summarized_usages(req_monthly)
    
    service_totals = {}
    total_acumulado = 0.0
    for item in res_monthly.data.items:
        val = float(item.computed_amount) if item.computed_amount else 0.0
        if val > 0:
            service_totals[item.service] = service_totals.get(item.service, 0.0) + val
            total_acumulado += val

    items_processed = sorted(
        [{"service": k, "amount": v} for k, v in service_totals.items()],
        key=lambda x: x['amount'], reverse=True
    )

    req_daily = oci.usage_api.models.RequestSummarizedUsagesDetails(
        tenant_id=signer.tenancy_id,
        time_usage_started=first_day.strftime("%Y-%m-%dT%H:%M:%SZ"),
        time_usage_ended=today_midnight.strftime("%Y-%m-%dT%H:%M:%SZ"),
        granularity="DAILY",
        query_type="COST"
    )
    res_daily = usage_client.request_summarized_usages(req_daily)
    
    daily_evolution = [
        {"date": item.time_usage_started.strftime("%Y-%m-%d"), "amount": float(item.computed_amount or 0)}
        for item in res_daily.data.items
    ]

    return {
        "report_type": "OCI_COSTS",
        "updated_at": datetime.utcnow().isoformat(),
        "currency": "BRL",
        "total_amount": round(total_acumulado, 2),
        "period": now.strftime("%m/%Y"),
        "items": items_processed,
        "daily_items": sorted(daily_evolution, key=lambda x: x['date'])
    }