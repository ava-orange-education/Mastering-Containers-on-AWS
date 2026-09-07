#!/bin/bash
# ============================================================================
# ECS Exec - Interactive Container Debugging
# Book: Mastering Container Architectures on AWS - Chapter 4
#
# ECS Exec enables you to run commands inside running containers, similar to
# kubectl exec for Kubernetes. Requires: enable-execute-command on the service.
# ============================================================================
set -euo pipefail

CLUSTER="${1:-production-cluster}"
SERVICE="${2:-web-api-service}"

echo "=== ECS Exec Debugging Tool ==="
echo "Cluster: $CLUSTER"
echo "Service: $SERVICE"
echo ""

# Step 1: Find a running task
echo "Finding running tasks..."
TASK_ARN=$(aws ecs list-tasks \
    --cluster "$CLUSTER" \
    --service-name "$SERVICE" \
    --desired-status RUNNING \
    --query 'taskArns[0]' \
    --output text)

if [ "$TASK_ARN" = "None" ] || [ -z "$TASK_ARN" ]; then
    echo "ERROR: No running tasks found for service $SERVICE"
    exit 1
fi

echo "Task: $TASK_ARN"
echo ""

# Step 2: Get container name
CONTAINER=$(aws ecs describe-tasks \
    --cluster "$CLUSTER" \
    --tasks "$TASK_ARN" \
    --query 'tasks[0].containers[0].name' \
    --output text)

echo "Container: $CONTAINER"
echo ""

# Step 3: Start interactive session
echo "Starting interactive session..."
echo "(Type 'exit' to disconnect)"
echo ""

aws ecs execute-command \
    --cluster "$CLUSTER" \
    --task "$TASK_ARN" \
    --container "$CONTAINER" \
    --interactive \
    --command "/bin/sh"
