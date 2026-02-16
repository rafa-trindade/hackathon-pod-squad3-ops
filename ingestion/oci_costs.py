import oci
import json
import os
import logging
from datetime import datetime, timedelta
from ingestion.utils.connections import get_s3_client_oci

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def extract_and_upload_costs():
    s3_oci = get_s3_client_oci()
    bucket_destino = os.getenv("OCI_BUCKET_NAME")
    file_key = "observability/reports/observability_reports_oci_costs.json"

    try:
        logger.info("Iniciando extração completa de custos (Mensal + Diário)...")
        signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
        usage_client = oci.usage_api.UsageapiClient(config={}, signer=signer)
        
        now = datetime.utcnow()
        first_day = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        today_midnight = now.replace(hour=0, minute=0, second=0, microsecond=0)

        # --- 1. Busca Custo Mensal Agrupado por Serviço ---
        req_monthly = oci.usage_api.models.RequestSummarizedUsagesDetails(
            tenant_id=signer.tenancy_id,
            time_usage_started=first_day.strftime("%Y-%m-%dT%H:%M:%SZ"),
            time_usage_ended=today_midnight.strftime("%Y-%m-%dT%H:%M:%SZ"),
            granularity="MONTHLY",
            query_type="COST",
            group_by=["service"]
        )
        res_monthly = usage_client.request_summarized_usages(req_monthly)
        
        # Consolidação de duplicados e filtro de valores zerados
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

        # --- 2. Busca Evolução Diária do Mês ---
        req_daily = oci.usage_api.models.RequestSummarizedUsagesDetails(
            tenant_id=signer.tenancy_id,
            time_usage_started=first_day.strftime("%Y-%m-%dT%H:%M:%SZ"),
            time_usage_ended=today_midnight.strftime("%Y-%m-%dT%H:%M:%SZ"),
            granularity="DAILY",
            query_type="COST"
        )
        res_daily = usage_client.request_summarized_usages(req_daily)
        
        daily_evolution = []
        for item in res_daily.data.items:
            daily_evolution.append({
                "date": item.time_usage_started.strftime("%Y-%m-%d"),
                "amount": float(item.computed_amount) if item.computed_amount else 0.0
            })

        # --- 3. Montagem do JSON Final ---
        cost_data = {
            "report_type": "OCI_COSTS",
            "updated_at": datetime.utcnow().isoformat(),
            "currency": "BRL",
            "total_amount": round(total_acumulado, 2),
            "period": now.strftime("%m/%Y"),
            "items": items_processed,
            "daily_items": sorted(daily_evolution, key=lambda x: x['date'])
        }

        s3_oci.put_object(
            Bucket=bucket_destino,
            Key=file_key,
            Body=json.dumps(cost_data, indent=4),
            ContentType='application/json'
        )
        logger.info("✅ Sucesso: Relatório consolidated (Mensal + Diário) no Lake.")

    except Exception as e:
        logger.error(f"❌ Erro na extração: {str(e)}")
        raise