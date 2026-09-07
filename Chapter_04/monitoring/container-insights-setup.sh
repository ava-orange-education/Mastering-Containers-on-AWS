#!/bin/bash
# ============================================================================
# Enable CloudWatch Container Insights for ECS
# Book: Mastering Container Architectures on AWS - Chapter 4
# ============================================================================
set -euo pipefail

CLUSTER_NAME="${1:-production-cluster}"
REGION="${AWS_REGION:-us-east-1}"

echo "Enabling Container Insights for ECS cluster: $CLUSTER_NAME"

# Enable Container Insights on the cluster
aws ecs update-cluster-settings \
    --cluster "$CLUSTER_NAME" \
    --settings name=containerInsights,value=enabled \
    --region "$REGION"

echo "Container Insights enabled."
echo ""
echo "Metrics available in CloudWatch namespace: ECS/ContainerInsights"
echo "  - CpuUtilized, CpuReserved"
echo "  - MemoryUtilized, MemoryReserved"
echo "  - NetworkRxBytes, NetworkTxBytes"
echo "  - StorageReadBytes, StorageWriteBytes"
echo "  - RunningTaskCount, DesiredTaskCount"
echo ""
echo "View at: https://$REGION.console.aws.amazon.com/cloudwatch/home?region=$REGION#container-insights:infrastructure"
