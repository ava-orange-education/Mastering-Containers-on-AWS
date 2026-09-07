# Chapter 10 — Architecting Production-Grade Container Platforms

## Files

| File | Description |
|------|-------------|
| `eks-production/eks-platform.yaml` | Production eksctl config: system node group (tainted), application node group, spot node group, all add-ons enabled. |
| `eks-production/platform-addons.sh` | Install essential platform add-ons: AWS ALB Controller, Metrics Server, Karpenter, External Secrets Operator, cert-manager. |
| `eks-production/karpenter-nodepool.yaml` | Cost-optimized Karpenter NodePool + EC2NodeClass: multi-arch (amd64/arm64), consolidation policy, Spot + On-Demand. |
| `multi-region/active-passive-failover.yaml` | Route 53 failover record sets with health checks for active-passive multi-region setup. |
| `resilience/pod-disruption-budget.yaml` | PDB examples: minAvailable (for stateful) and maxUnavailable (for stateless) patterns. |
| `resilience/topology-spread.yaml` | Deployment with zone and node topology spread constraints for maximum availability. |
| `slo-monitoring/sli-definitions.yaml` | Prometheus recording rules for availability and latency SLIs, plus multi-window error budget burn rate alerts. |

## Usage

```bash
# Create production cluster
eksctl create cluster -f eks-production/eks-platform.yaml

# Install platform add-ons
chmod +x eks-production/platform-addons.sh
./eks-production/platform-addons.sh my-cluster us-east-1

# Apply Karpenter NodePool
kubectl apply -f eks-production/karpenter-nodepool.yaml

# Apply resilience patterns
kubectl apply -f resilience/

# Apply SLO monitoring
kubectl apply -f slo-monitoring/sli-definitions.yaml
```
