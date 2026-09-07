# Chapter 6 — Serverless Containers with AWS Fargate and App Runner

## Files

| File | Description |
|------|-------------|
| `fargate-ecs/task-definition.json` | Fargate task definition with ARM64 runtime platform (Graviton). |
| `fargate-ecs/capacity-provider-strategy.json` | Mixed capacity provider: Fargate (base=2, weight=1) + Fargate Spot (weight=3) for cost optimization. |
| `fargate-eks/fargate-profile.yaml` | eksctl Fargate profile with namespace and label selectors. |
| `fargate-eks/deployment.yaml` | Fargate-optimized Kubernetes deployment with matching labels. |
| `app-runner/apprunner.yaml` | App Runner configuration file for source-based deployment with auto-scaling settings. |
| `cost-comparison-calculator.py` | Python calculator comparing monthly costs across EC2, Fargate, Fargate Spot, and App Runner for given workloads. |

## Usage

```bash
# Run the cost comparison calculator
python3 cost-comparison-calculator.py

# Register Fargate task definition
aws ecs register-task-definition --cli-input-json file://fargate-ecs/task-definition.json

# Create Fargate profile for EKS
eksctl create fargateprofile -f fargate-eks/fargate-profile.yaml
```
