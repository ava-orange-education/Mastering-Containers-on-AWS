# Chapter 12 — Migrating Applications to Containers on AWS

## Files

| File | Description |
|------|-------------|
| `strangler-fig/monolith-deployment.yaml` | Containerized monolith with Istio sidecar injection for incremental decomposition. |
| `strangler-fig/istio-virtualservice.yaml` | Istio VirtualService for progressive traffic routing: path-based + weighted split between monolith and microservices. |
| `stateful-workloads/postgresql-statefulset.yaml` | 3-replica PostgreSQL StatefulSet with headless service, PVC templates, and ordered pod management. |
| `stateful-workloads/storage-class-gp3.yaml` | gp3 encrypted StorageClass with volume expansion enabled. |
| `cluster-migration/velero-backup-restore.sh` | Velero backup/restore workflow: install, backup source cluster, restore to target EKS cluster. |
| `ecs-to-eks/ecs-task-definition.json` | Original ECS task definition (source for migration). |
| `ecs-to-eks/eks-equivalent.yaml` | Translated Kubernetes Deployment + Service with detailed mapping comments. |
| `windows-containers/mixed-mode-cluster.yaml` | eksctl config with Linux + Windows node groups for mixed workloads. |
| `windows-containers/windows-deployment.yaml` | .NET application deployment with Windows nodeSelector and toleration. |
| `cicd-modernization/argocd-application.yaml` | ArgoCD Application with Kustomize image override for modernized CI/CD. |

## Usage

```bash
# Deploy strangler fig pattern
kubectl apply -f strangler-fig/monolith-deployment.yaml
kubectl apply -f strangler-fig/istio-virtualservice.yaml

# Deploy PostgreSQL StatefulSet
kubectl apply -f stateful-workloads/storage-class-gp3.yaml
kubectl apply -f stateful-workloads/postgresql-statefulset.yaml

# Run Velero migration
chmod +x cluster-migration/velero-backup-restore.sh
./cluster-migration/velero-backup-restore.sh
```
