#!/bin/bash
# Install ArgoCD on EKS
# Book: Mastering Container Architectures on AWS - Chapter 7
set -euo pipefail

echo "Installing ArgoCD..."
kubectl create namespace argocd 2>/dev/null || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

echo ""
echo "ArgoCD installed. Get initial admin password:"
echo "  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo ""
echo "Port-forward the ArgoCD UI:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
