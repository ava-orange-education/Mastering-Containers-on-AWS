#!/bin/bash
# Complete IRSA (IAM Roles for Service Accounts) Setup
# Book: Mastering Container Architectures on AWS - Chapter 9
set -euo pipefail

CLUSTER_NAME="${1:?Usage: $0 <cluster-name> <namespace> <service-account> <policy-arn>}"
NAMESPACE="${2:?}"
SA_NAME="${3:?}"
POLICY_ARN="${4:?}"
REGION="${AWS_REGION:-us-east-1}"

ROLE_NAME="${CLUSTER_NAME}-${NAMESPACE}-${SA_NAME}"

echo "=== IRSA Setup ==="
echo "Cluster: $CLUSTER_NAME"
echo "Namespace: $NAMESPACE"
echo "Service Account: $SA_NAME"
echo "IAM Role: $ROLE_NAME"
echo ""

# Step 1: Associate OIDC provider (idempotent)
echo "Step 1: Associating OIDC provider..."
eksctl utils associate-iam-oidc-provider \
    --cluster "$CLUSTER_NAME" \
    --region "$REGION" \
    --approve

# Step 2: Create IAM role and Kubernetes service account
echo "Step 2: Creating IAM service account..."
eksctl create iamserviceaccount \
    --cluster "$CLUSTER_NAME" \
    --namespace "$NAMESPACE" \
    --name "$SA_NAME" \
    --role-name "$ROLE_NAME" \
    --attach-policy-arn "$POLICY_ARN" \
    --region "$REGION" \
    --approve \
    --override-existing-serviceaccounts

echo ""
echo "IRSA setup complete."
echo "Pods using ServiceAccount '$SA_NAME' in namespace '$NAMESPACE'"
echo "will now have access to AWS APIs defined in the attached policy."
echo ""
echo "Verify: kubectl describe sa $SA_NAME -n $NAMESPACE"
