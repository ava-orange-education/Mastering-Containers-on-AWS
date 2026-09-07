#!/bin/bash
# ============================================================================
# Build, Tag, and Push Docker Image to Amazon ECR
# Book: Mastering Container Architectures on AWS - Chapter 2
#
# This script demonstrates the complete workflow for pushing a container
# image to Amazon Elastic Container Registry (ECR).
#
# Prerequisites:
#   - AWS CLI configured with appropriate permissions
#   - Docker installed and running
#   - IAM permissions: ecr:GetAuthorizationToken, ecr:BatchCheckLayerAvailability,
#     ecr:PutImage, ecr:InitiateLayerUpload, ecr:UploadLayerPart,
#     ecr:CompleteLayerUpload, ecr:CreateRepository
# ============================================================================

set -euo pipefail

# Configuration - modify these for your environment
AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}"
REPOSITORY_NAME="${1:-my-application}"
IMAGE_TAG="${2:-latest}"
DOCKERFILE_PATH="${3:-.}"

ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
FULL_IMAGE_URI="${ECR_URI}/${REPOSITORY_NAME}:${IMAGE_TAG}"

echo "============================================"
echo "  ECR Push Workflow"
echo "============================================"
echo "  Repository: ${REPOSITORY_NAME}"
echo "  Tag:        ${IMAGE_TAG}"
echo "  ECR URI:    ${FULL_IMAGE_URI}"
echo "============================================"

# Step 1: Create ECR repository if it doesn't exist
echo ""
echo "Step 1: Ensuring ECR repository exists..."
aws ecr describe-repositories \
    --repository-names "${REPOSITORY_NAME}" \
    --region "${AWS_REGION}" 2>/dev/null || \
aws ecr create-repository \
    --repository-name "${REPOSITORY_NAME}" \
    --region "${AWS_REGION}" \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=KMS

# Step 2: Authenticate Docker with ECR
echo ""
echo "Step 2: Authenticating Docker with ECR..."
aws ecr get-login-password --region "${AWS_REGION}" | \
    docker login --username AWS --password-stdin "${ECR_URI}"

# Step 3: Build the Docker image
echo ""
echo "Step 3: Building Docker image..."
docker build -t "${REPOSITORY_NAME}:${IMAGE_TAG}" "${DOCKERFILE_PATH}"

# Step 4: Tag the image for ECR
echo ""
echo "Step 4: Tagging image for ECR..."
docker tag "${REPOSITORY_NAME}:${IMAGE_TAG}" "${FULL_IMAGE_URI}"

# Also tag with git SHA if in a git repository
if git rev-parse HEAD &>/dev/null; then
    GIT_SHA=$(git rev-parse --short HEAD)
    docker tag "${REPOSITORY_NAME}:${IMAGE_TAG}" \
        "${ECR_URI}/${REPOSITORY_NAME}:${GIT_SHA}"
    echo "  Also tagged as: ${GIT_SHA}"
fi

# Step 5: Push to ECR
echo ""
echo "Step 5: Pushing image to ECR..."
docker push "${FULL_IMAGE_URI}"

if [ -n "${GIT_SHA:-}" ]; then
    docker push "${ECR_URI}/${REPOSITORY_NAME}:${GIT_SHA}"
fi

# Step 6: Verify the push and check scan results
echo ""
echo "Step 6: Verifying push..."
aws ecr describe-images \
    --repository-name "${REPOSITORY_NAME}" \
    --image-ids imageTag="${IMAGE_TAG}" \
    --region "${AWS_REGION}" \
    --query 'imageDetails[0].{Size:imageSizeInBytes,Pushed:imagePushedAt,Digest:imageDigest}' \
    --output table

echo ""
echo "Image successfully pushed to: ${FULL_IMAGE_URI}"
echo ""
echo "To pull this image:"
echo "  docker pull ${FULL_IMAGE_URI}"
