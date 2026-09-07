# Chapter 4 — Running Containers with Amazon ECS

## Files

| File | Description |
|------|-------------|
| `task-definitions/web-api-task.json` | Fargate task definition with secrets from Secrets Manager/SSM, awslogs driver, healthCheck, readonlyRootFilesystem, and initProcessEnabled. |
| `task-definitions/worker-task.json` | SQS queue worker task definition for background processing. |
| `task-definitions/sidecar-pattern.json` | Sidecar pattern with FireLens log router (aws-for-fluent-bit) for advanced log routing. |
| `autoscaling-policies/target-tracking.json` | CPU-based target tracking autoscaling (70% target with cooldowns). |
| `autoscaling-policies/step-scaling.json` | Step scaling with percentage adjustments at multiple CPU thresholds. |
| `autoscaling-policies/scheduled-scaling.json` | Business hours scaling: scale up Mon-Fri 8AM, scale down at 8PM. |
| `ecs-exec-debug.sh` | Interactive ECS Exec debugging script for troubleshooting running containers. |
| `monitoring/container-insights-setup.sh` | Enable CloudWatch Container Insights on an ECS cluster. |
| `monitoring/cloudwatch-alarms.json` | CloudWatch alarms for CPU, memory, and running task count thresholds. |

## Usage

```bash
# Register a task definition
aws ecs register-task-definition --cli-input-json file://task-definitions/web-api-task.json

# Set up autoscaling
aws application-autoscaling register-scalable-target \
  --service-namespace ecs \
  --resource-id service/my-cluster/my-service \
  --scalable-dimension ecs:service:DesiredCount \
  --min-capacity 2 --max-capacity 10

# Debug a running container
chmod +x ecs-exec-debug.sh
./ecs-exec-debug.sh my-cluster my-service
```
