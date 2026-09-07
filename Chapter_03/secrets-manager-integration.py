"""
AWS Secrets Manager Integration for Containers
Book: Mastering Container Architectures on AWS - Chapter 3

Demonstrates retrieving secrets from AWS Secrets Manager within a container.
This pattern works for both ECS (via task definition secrets) and EKS (via
Secrets Store CSI Driver or application-level access).
"""
import json
import os
import boto3
from botocore.exceptions import ClientError

# Cache secrets to avoid repeated API calls
_secret_cache = {}

def get_secret(secret_name: str, region: str = None) -> dict:
    """
    Retrieve a secret from AWS Secrets Manager with caching.

    Args:
        secret_name: Name or ARN of the secret
        region: AWS region (defaults to AWS_REGION env var or us-east-1)

    Returns:
        dict: Parsed secret key-value pairs
    """
    if secret_name in _secret_cache:
        return _secret_cache[secret_name]

    region = region or os.environ.get("AWS_REGION", "us-east-1")
    client = boto3.client("secretsmanager", region_name=region)

    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret_value = response["SecretString"]
        parsed = json.loads(secret_value)
        _secret_cache[secret_name] = parsed
        return parsed
    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        if error_code == "ResourceNotFoundException":
            raise ValueError(f"Secret '{secret_name}' not found") from e
        elif error_code == "AccessDeniedException":
            raise PermissionError(
                f"Access denied to secret '{secret_name}'. "
                "Ensure the ECS task role or IRSA role has "
                "secretsmanager:GetSecretValue permission."
            ) from e
        raise

def get_database_credentials(secret_name: str = "my-app/database") -> dict:
    """
    Example: Retrieve database credentials for a containerized application.

    Expected secret format in Secrets Manager:
    {
        "host": "mydb.cluster-abc123.us-east-1.rds.amazonaws.com",
        "port": 5432,
        "username": "appuser",
        "password": "s3cur3p@ssw0rd",
        "dbname": "myappdb"
    }
    """
    creds = get_secret(secret_name)
    return {
        "host": creds["host"],
        "port": creds.get("port", 5432),
        "username": creds["username"],
        "password": creds["password"],
        "dbname": creds["dbname"],
        "connection_string": (
            f"postgresql://{creds['username']}:{creds['password']}"
            f"@{creds['host']}:{creds.get('port', 5432)}/{creds['dbname']}"
        )
    }

if __name__ == "__main__":
    # Usage example (requires AWS credentials via IRSA or task role)
    secret_name = os.environ.get("SECRET_NAME", "my-app/database")
    try:
        creds = get_database_credentials(secret_name)
        print(f"Database host: {creds['host']}")
        print(f"Database name: {creds['dbname']}")
        print("Connection string: [REDACTED]")  # Never log passwords
    except Exception as e:
        print(f"Error retrieving secret: {e}")
