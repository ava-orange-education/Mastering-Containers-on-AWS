# Chapter 14 — Cost Optimization and Future Trends

## Files

| File | Description |
|------|-------------|
| `rightsizing/vpa-deployment.yaml` | Vertical Pod Autoscaler in recommendation mode — suggests optimal CPU/memory requests. |
| `autoscaling/keda-sqs-scaledobject.yaml` | KEDA SQS scaler: scales workers based on queue depth, supports scale-to-zero. |
| `autoscaling/karpenter-cost-nodepool.yaml` | Cost-optimized Karpenter NodePool: Graviton preference, Spot instances, aggressive consolidation. |
| `autoscaling/scale-to-zero-schedule.yaml` | CronJobs to scale non-production environments down at 8PM and up at 8AM (saves ~50% compute). |
| `pricing-models/spot-best-practices.yaml` | Spot-tolerant deployment: zone spread, multiple instance types, graceful shutdown on interruption. |
| `tco-calculator/tco-calculator.py` | Python TCO calculator comparing ECS vs EKS vs Fargate across 3 workload scenarios (startup, growing, enterprise). |
| `cost-visibility/budget-alerts.yaml` | CloudFormation for AWS Budgets with alerts at 80%, 100%, and 120% forecast thresholds. |
| `emerging-tech/wasm-container-demo/hello.rs` | Rust WebAssembly demo: "Hello from Wasm" compiled to WASI target. |
| `emerging-tech/wasm-container-demo/wasm-runtime-class.yaml` | Kubernetes RuntimeClass + Deployment for running Wasm workloads alongside containers. |
| `emerging-tech/eks-auto-mode.yaml` | EKS Auto Mode cluster config — fully managed node groups, networking, and add-ons. |

## Usage

```bash
# Run the TCO calculator
python3 tco-calculator/tco-calculator.py

# Apply VPA in recommendation mode
kubectl apply -f rightsizing/vpa-deployment.yaml

# Set up KEDA SQS scaler
kubectl apply -f autoscaling/keda-sqs-scaledobject.yaml

# Deploy cost-optimized Karpenter NodePool
kubectl apply -f autoscaling/karpenter-cost-nodepool.yaml

# Deploy budget alerts (update email in template)
aws cloudformation deploy \
  --template-file cost-visibility/budget-alerts.yaml \
  --stack-name container-budgets
```
