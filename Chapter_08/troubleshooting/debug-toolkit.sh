#!/bin/bash
# Container Platform Debugging Toolkit
# Book: Mastering Container Architectures on AWS - Chapter 8
set -euo pipefail

NAMESPACE="${1:-production}"

echo "=== EKS Debugging Toolkit ==="
echo "Namespace: $NAMESPACE"
echo ""

echo "--- Unhealthy Pods ---"
kubectl get pods -n "$NAMESPACE" --field-selector=status.phase!=Running,status.phase!=Succeeded 2>/dev/null || echo "All pods healthy"

echo ""
echo "--- Recent Warning Events ---"
kubectl get events -n "$NAMESPACE" --field-selector=type=Warning --sort-by='.lastTimestamp' 2>/dev/null | tail -20

echo ""
echo "--- Pod Resource Usage ---"
kubectl top pods -n "$NAMESPACE" --sort-by=memory 2>/dev/null | head -20

echo ""
echo "--- Node Resource Pressure ---"
kubectl get nodes -o custom-columns='NAME:.metadata.name,CPU%:.status.allocatable.cpu,MEM%:.status.allocatable.memory,DISK-PRESSURE:.status.conditions[?(@.type=="DiskPressure")].status,MEM-PRESSURE:.status.conditions[?(@.type=="MemoryPressure")].status'

echo ""
echo "--- Pods in CrashLoopBackOff ---"
kubectl get pods -n "$NAMESPACE" -o json | python3 -c "
import sys, json
data = json.load(sys.stdin)
for pod in data.get('items', []):
    for cs in pod.get('status', {}).get('containerStatuses', []):
        waiting = cs.get('state', {}).get('waiting', {})
        if waiting.get('reason') == 'CrashLoopBackOff':
            print(f\"  {pod['metadata']['name']}: restarts={cs['restartCount']}, reason={waiting.get('message', 'unknown')}\")
" 2>/dev/null || echo "  None found"
