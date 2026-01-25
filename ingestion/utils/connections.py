import os
import boto3
from botocore.client import Config
from dotenv import load_dotenv

load_dotenv()

def get_s3_client_minio():
    """Cliente para ler da VPS (Origem)"""
    return boto3.client(
        "s3",
        endpoint_url=os.getenv("MINIO_ENDPOINT"), 
        aws_access_key_id=os.getenv("MINIO_ACCESS_KEY"),
        aws_secret_access_key=os.getenv("MINIO_SECRET_KEY"),
        region_name="us-east-1"
    )

def get_s3_client_oci():
    """Cliente para escrever na OCI (Destino)"""
    return boto3.client(
        "s3",
        endpoint_url=os.getenv("OCI_S3_ENDPOINT"), 
        aws_access_key_id=os.getenv("OCI_ACCESS_KEY"),
        aws_secret_access_key=os.getenv("OCI_SECRET_KEY"),
        region_name=os.getenv("OCI_REGION", "sa-saopaulo-1"),
        config=Config(s3={'addressing_style': 'path'}) 
    )