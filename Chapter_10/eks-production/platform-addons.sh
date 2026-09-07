#!/bin/bash
# Install Essential EKS Platform Add-ons
# Book: Mastering Container Architectures on AWS - Chapter 10
set -euo pipefail

CLUSTER_NAME="${1:-production-platform}"
REGION="${AWS_REGION:-us-east-1}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "=== Installing Platform Add-ons for $CLUSTER_NAME ==="

# 1. AWS Load Balancer Controller
echo "1. Installing AWS Load Balancer Controller..."
helm repo add eks https://aws.github.io/eks-charts
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName="$CLUSTER_NAME" \
    --set serviceAccount.create=true \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::${ACCOUNT_ID}:role/${CLUSTER_NAME}-lb-controller"

# 2. Metrics Server
echo "2. Installing Metrics Server..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 3. Karpenter (Node Autoscaler)
echo "3. Installing Karpenter..."
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
    -n kube-system \
    --set "settings.clusterName=$CLUSTER_NAME" \
    --set "settings.interruptionQueue=${CLUSTER_NAME}-karpenter" \
    --wait

# 4. External Secrets Operator
echo "4. Installing External Secrets Operator..."
helm repo add external-secrets https://charts.external-secrets.io
helm upgrade --install external-secrets external-secrets/external-secrets \
    -n external-secrets --create-namespace

# 5. Cert Manager
echo "5. Installing cert-manager..."
helm repo add jetstack https://charts.jetstack.io
helm upgrade --install cert-manager jetstack/cert-manager \
    -n cert-manager --create-namespace \
    --set installCRDs=true

echo ""
echo "=== All platform add-ons installed ==="
