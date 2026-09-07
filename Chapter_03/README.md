# Chapter 3 — AWS Networking and Security Basics for Containers

## Files

| File | Description |
|------|-------------|
| `vpc-setup.yaml` | CloudFormation template for a production VPC: 2 AZs, public/private subnets, IGW, NAT Gateways, route tables, EKS-compatible subnet tags. |
| `iam-policies/ecs-task-role.json` | Least-privilege IAM policy for ECS tasks: S3, DynamoDB, SQS access. |
| `iam-policies/ecs-execution-role.json` | ECR pull + CloudWatch Logs + Secrets Manager access for the ECS execution role. |
| `iam-policies/cross-account-trust.json` | Cross-account trust policy with ExternalId condition for secure delegation. |
| `iam-policies/eks-irsa-policy.json` | IRSA (IAM Roles for Service Accounts) policy scoped to S3 access. |
| `health-check-app/app.py` | Flask app with three health endpoints: `/health` (liveness), `/ready` (readiness with dependency checks), `/startup` (startup probe). |
| `secrets-manager-integration.py` | Python boto3 client for AWS Secrets Manager with caching, error handling, and database credential retrieval pattern. |

## Usage

```bash
# Deploy the VPC (update parameters as needed)
aws cloudformation deploy \
  --template-file vpc-setup.yaml \
  --stack-name container-vpc \
  --parameter-overrides EnvironmentName=production

# Run the health check app
cd health-check-app
pip install flask boto3
python app.py
# Test: curl http://localhost:5000/health
```
