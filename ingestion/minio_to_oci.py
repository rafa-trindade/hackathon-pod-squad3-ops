import os
import logging
import sys
from pathlib import Path
from dotenv import load_dotenv

env_path = Path(__file__).parent.parent / "orchestrator" / ".env"
if env_path.exists():
    load_dotenv(env_path)
else:
    load_dotenv()

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from ingestion.utils.connections import (
    get_s3_client_minio,
    get_s3_client_oci,
)

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def sync_minio_to_oci():
    s3_minio = get_s3_client_minio()
    s3_oci = get_s3_client_oci()
    
    bucket_origem = os.getenv("MINIO_BUCKET_NAME")
    prefixo_origem = os.getenv("MINIO_PATH_PREFIX", "raw/") 
    bucket_destino = os.getenv("OCI_BUCKET_NAME")

    try:
        logger.info(f"Listando prefixo '{prefixo_origem}' no bucket '{bucket_origem}'...")
        
        response = s3_minio.list_objects_v2(
            Bucket=bucket_origem, 
            Prefix=prefixo_origem
        )
        
        if 'Contents' not in response:
            logger.warning(f"Nenhum objeto encontrado com o prefixo {prefixo_origem}")
            return

        for obj in response['Contents']:
            file_key = obj['Key']
            
            if file_key.endswith('/'):
                continue

            logger.info(f"Transferindo objeto: {file_key}")

            minio_obj = s3_minio.get_object(Bucket=bucket_origem, Key=file_key)
            
            s3_oci.upload_fileobj(
                Fileobj=minio_obj['Body'],
                Bucket=bucket_destino,
                Key=file_key
            )
            
            logger.info(f"✅ Sucesso: {file_key} migrado para {bucket_destino}")

    except Exception as e:
        logger.error(f"❌ Erro crítico na migração: {str(e)}")
        raise 

if __name__ == "__main__":
    sync_minio_to_oci()