# Chapter 13 — Containers at the Edge with AWS

## Files

| File | Description |
|------|-------------|
| `local-zones/local-zone-eks.yaml` | eksctl config with Local Zone node group (us-east-1-bos-1a) for low-latency edge compute. |
| `local-zones/local-zone-deployment.yaml` | Deployment with location-based nodeSelector targeting Local Zone nodes. |
| `hybrid-nodes/cloud-bursting-deployment.yaml` | Deployment with prefer-on-prem affinity and cloud burst: schedules on-prem first, overflows to cloud. |
| `eks-anywhere/cluster-config.yaml` | EKS Anywhere bare metal cluster configuration with control plane and worker node hardware selectors. |
| `greengrass/edge-data-pipeline.py` | IoT Greengrass edge data processing pipeline: filtering, aggregation, anomaly detection — reduces bandwidth 90%+. |
| `edge-observability/prometheus-remote-write.yaml` | Prometheus with AMP remote write and metric relabeling for bandwidth-efficient edge monitoring. |
| `fleet-management/argocd-applicationset-edge.yaml` | ArgoCD ApplicationSet for multi-cluster edge fleet with staged rollout (canary → regional → global). |

## Usage

```bash
# Create cluster with Local Zone support
eksctl create cluster -f local-zones/local-zone-eks.yaml

# Deploy to Local Zone nodes
kubectl apply -f local-zones/local-zone-deployment.yaml

# Apply fleet management
kubectl apply -f fleet-management/argocd-applicationset-edge.yaml

# Run the edge pipeline locally (for testing)
python3 greengrass/edge-data-pipeline.py
```
