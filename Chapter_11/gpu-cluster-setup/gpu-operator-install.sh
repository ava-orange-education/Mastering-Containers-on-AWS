#!/bin/bash
# Install NVIDIA GPU Operator on EKS
# Book: Mastering Container Architectures on AWS - Chapter 11
set -euo pipefail

echo "=== Installing NVIDIA GPU Operator ==="

helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update

# Install GPU Operator (manages device plugin, container runtime, DCGM exporter)
helm upgrade --install gpu-operator nvidia/gpu-operator \
    -n gpu-operator --create-namespace \
    --set driver.enabled=false \
    --set toolkit.enabled=false \
    --set devicePlugin.enabled=true \
    --set dcgmExporter.enabled=true \
    --set migManager.enabled=true \
    --wait

echo ""
echo "GPU Operator installed. Verify GPU nodes:"
echo "  kubectl get nodes -l nvidia.com/gpu.present=true"
echo "  kubectl get pods -n gpu-operator"
