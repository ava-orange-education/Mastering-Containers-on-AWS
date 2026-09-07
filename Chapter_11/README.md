# Chapter 11 — AI/ML Workloads on Amazon EKS

## Files

| File | Description |
|------|-------------|
| `gpu-cluster-setup/karpenter-gpu-nodepool.yaml` | Karpenter NodePool for GPU instances: p4d.24xlarge, p5.48xlarge, g5 family, with Spot support and EFA networking. |
| `gpu-cluster-setup/gpu-operator-install.sh` | NVIDIA GPU Operator Helm installation (device plugin, DCGM exporter, driver, container toolkit). |
| `gpu-cluster-setup/gpu-test-pod.yaml` | nvidia-smi test pod to verify GPU availability on nodes. |
| `distributed-training/pytorchjob.yaml` | Multi-worker PyTorchJob with elastic training policy, GPU resources, EFS checkpoints, and NCCL environment. |
| `distributed-training/checkpoint-example.py` | PyTorch checkpoint save/restore with atomic rename pattern for crash safety. |
| `inference/kserve-inferenceservice.yaml` | KServe InferenceService with GPU, autoscaling on concurrency, and canary rollout. |
| `inference/vllm-rayserve.yaml` | RayService running vLLM for LLM serving with PagedAttention and tensor parallelism. |
| `ml-pipelines/argo-workflow.yaml` | Argo Workflows DAG: preprocess → train → evaluate → conditional deploy. |
| `observability/gpu-alerts.yaml` | Prometheus alerts for GPU temperature, memory, idle GPUs, and XID hardware errors. |

## Usage

```bash
# Install GPU Operator
chmod +x gpu-cluster-setup/gpu-operator-install.sh
./gpu-cluster-setup/gpu-operator-install.sh

# Test GPU availability
kubectl apply -f gpu-cluster-setup/gpu-test-pod.yaml
kubectl logs gpu-test

# Launch distributed training
kubectl apply -f distributed-training/pytorchjob.yaml

# Deploy model serving
kubectl apply -f inference/kserve-inferenceservice.yaml

# Apply GPU monitoring alerts
kubectl apply -f observability/gpu-alerts.yaml
```
