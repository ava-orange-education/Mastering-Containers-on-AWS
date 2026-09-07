#!/bin/bash
# ECR Enhanced Scanning - Enable and Check Results
# Book: Mastering Container Architectures on AWS - Chapter 9
set -euo pipefail

REPO="${1:?Usage: $0 <repository-name> [image-tag]}"
TAG="${2:-latest}"
REGION="${AWS_REGION:-us-east-1}"

echo "=== ECR Image Scanning ==="

# Enable scan-on-push for the repository
aws ecr put-image-scanning-configuration \
    --repository-name "$REPO" \
    --image-scanning-configuration scanOnPush=true \
    --region "$REGION"

echo "Scan-on-push enabled for $REPO"

# Trigger manual scan
aws ecr start-image-scan \
    --repository-name "$REPO" \
    --image-id imageTag="$TAG" \
    --region "$REGION" 2>/dev/null || echo "Scan already in progress"

echo "Waiting for scan to complete..."
aws ecr wait image-scan-complete \
    --repository-name "$REPO" \
    --image-id imageTag="$TAG" \
    --region "$REGION"

# Get scan results
echo ""
echo "=== Scan Results ==="
aws ecr describe-image-scan-findings \
    --repository-name "$REPO" \
    --image-id imageTag="$TAG" \
    --region "$REGION" \
    --query 'imageScanFindings.findingSeverityCounts' \
    --output table

# Check for critical/high vulnerabilities
CRITICAL=$(aws ecr describe-image-scan-findings \
    --repository-name "$REPO" \
    --image-id imageTag="$TAG" \
    --region "$REGION" \
    --query 'imageScanFindings.findingSeverityCounts.CRITICAL' \
    --output text 2>/dev/null || echo "0")

HIGH=$(aws ecr describe-image-scan-findings \
    --repository-name "$REPO" \
    --image-id imageTag="$TAG" \
    --region "$REGION" \
    --query 'imageScanFindings.findingSeverityCounts.HIGH' \
    --output text 2>/dev/null || echo "0")

echo ""
if [ "$CRITICAL" != "0" ] && [ "$CRITICAL" != "None" ]; then
    echo "FAIL: $CRITICAL CRITICAL vulnerabilities found"
    exit 1
elif [ "$HIGH" != "0" ] && [ "$HIGH" != "None" ]; then
    echo "WARNING: $HIGH HIGH vulnerabilities found"
fi
echo "PASS: No critical vulnerabilities"
