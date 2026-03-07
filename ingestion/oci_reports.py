import oci
import json
import os
import logging
from datetime import datetime, timedelta
from ingestion.utils.connections import get_s3_client_oci

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def extract_and_upload_reports():
    s3_oci = get_s3_client_oci()
    bucket_destino = os.getenv("OCI_BUCKET_NAME")
    
    cost_file_key = "observability/reports/observability_reports_oci_costs.json"
    status_file_key = "observability/reports/observability_reports_oci_status.json"
    bucket_file_key = "observability/reports/observability_reports_oci_buckets.json"

    try:
        signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
        
        logger.info("Iniciando extração de custos...")
        cost_data = get_cost_report(signer)
        
        logger.info("Iniciando extração de status das instâncias...")
        status_data = get_instance_status_report(signer)

        logger.info("Iniciando extração de informações do bucket 'lake'...")
        bucket_data = get_bucket_report(signer, bucket_name="lake", root_prefix="")

        reports = [
            (cost_file_key, cost_data, "Custos"),
            (status_file_key, status_data, "Status/Shapes"),
            (bucket_file_key, bucket_data, "Buckets")  # novo
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

def get_bucket_report(signer, bucket_name="lake", root_prefix=""):
    """
    Lista subpastas de segundo nível (ex: bronze/atraso) e traz métricas agregadas.
    """

    object_storage = oci.object_storage.ObjectStorageClient(config={}, signer=signer)
    namespace = object_storage.get_namespace().data

    total_bucket_bytes = 0
    start_bucket = None
    logger.info(f"Calculando tamanho total do bucket: {bucket_name}")
    
    while True:
        resp = object_storage.list_objects(namespace, bucket_name, start=start_bucket, fields="size").data
        total_bucket_bytes += sum(obj.size for obj in resp.objects if obj.size is not None)
        if resp.next_start_with:
            start_bucket = resp.next_start_with
        else:
            break

    resp_l1 = object_storage.list_objects(
        namespace,
        bucket_name,
        prefix=root_prefix,
        delimiter="/"
    ).data

    l1_prefixes = getattr(resp_l1, "prefixes", [])
    report_folders = []

    for l1_folder in l1_prefixes:
        resp_l2 = object_storage.list_objects(
            namespace,
            bucket_name,
            prefix=l1_folder,
            delimiter="/"
        ).data
        
        l2_prefixes = getattr(resp_l2, "prefixes", [])
        
        targets = l2_prefixes if l2_prefixes else [l1_folder]

        for target_folder in targets:
            total_bytes = 0
            latest_update = None
            object_count = 0
            maior_arquivo = 0
            start = None

            while True:
                response = object_storage.list_objects(
                    namespace,
                    bucket_name,
                    prefix=target_folder,
                    start=start,
                    fields="size,timeCreated"
                ).data

                for obj in response.objects:
                    size = obj.size if obj.size is not None else 0
                    total_bytes += size
                    object_count += 1
                    
                    if not latest_update or obj.time_created > latest_update:
                        latest_update = obj.time_created
                    if size > maior_arquivo:
                        maior_arquivo = size

                if response.next_start_with:
                    start = response.next_start_with
                else:
                    break

            if object_count == 0:
                continue

            media_tamanho_mb = round((total_bytes / object_count) / (1024**2), 2)
            maior_arquivo_gb = round(maior_arquivo / (1024**3), 2)
            total_size_gb = round(total_bytes / (1024**3), 2)
            percentual_bucket = round((total_bytes / total_bucket_bytes) * 100, 2) if total_bucket_bytes else 0


            display_name = target_folder.replace(l1_folder, "").rstrip("/")
            if not display_name:
                display_name = l1_folder.rstrip("/")

            report_folders.append({
                "folder_path": target_folder,
                "parent_folder": l1_folder.rstrip("/"),
                "folder_name": display_name,
                "total_size_gb": total_size_gb,
                "numero_de_objetos": object_count,
                "media_tamanho_mb": media_tamanho_mb,
                "maior_arquivo_gb": maior_arquivo_gb,
                "ultima_atualizacao": latest_update.isoformat() if latest_update else None,
                "percentual_bucket": percentual_bucket
            })

    return {
        "report_type": "OCI_BUCKET_FOLDER_SUMMARY",
        "updated_at": datetime.utcnow().isoformat(),
        "bucket_report": {
            "bucket_name": bucket_name,
            "total_bucket_size_gb": round(total_bucket_bytes / (1024**3), 2),
            "folders": sorted(report_folders, key=lambda x: x['total_size_gb'], reverse=True)
        }
    }
from datetime import datetime, timedelta

def get_cost_report(signer):
    usage_client = oci.usage_api.UsageapiClient(config={}, signer=signer)
    
    now = datetime.utcnow()
    
    history_start = datetime(now.year, 2, 1, 0, 0, 0)
    
    tomorrow_midnight = (now + timedelta(days=1)).replace(hour=0, minute=0, second=0, microsecond=0)

    str_start = history_start.strftime("%Y-%m-%dT00:00:00Z")
    str_end = tomorrow_midnight.strftime("%Y-%m-%dT00:00:00Z")

    logger.info(f"📊 Extraindo custos OCI desde: {str_start} até {str_end}")

    req_monthly = oci.usage_api.models.RequestSummarizedUsagesDetails(
        tenant_id=signer.tenancy_id,
        time_usage_started=str_start,
        time_usage_ended=str_end,
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
        [{"service": k, "amount": round(v, 2)} for k, v in service_totals.items()],
        key=lambda x: x['amount'], reverse=True
    )

    req_daily = oci.usage_api.models.RequestSummarizedUsagesDetails(
        tenant_id=signer.tenancy_id,
        time_usage_started=str_start,
        time_usage_ended=str_end,
        granularity="DAILY",
        query_type="COST"
    )
    res_daily = usage_client.request_summarized_usages(req_daily)
    
    daily_evolution = [
        {"date": item.time_usage_started.strftime("%Y-%m-%d"), "amount": float(item.computed_amount or 0)}
        for item in res_daily.data.items
    ]

    return {
        "report_type": "OCI_COSTS_SINCE_FEB",
        "updated_at": datetime.utcnow().isoformat(),
        "currency": "BRL",
        "total_period_amount": round(total_acumulado, 2),
        "start_date": str_start,
        "end_date": str_end,
        "items_by_service": items_processed,
        "daily_items": sorted(daily_evolution, key=lambda x: x['date'])
    }