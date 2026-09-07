#!/bin/bash
# ============================================================================
# EKS Troubleshooting Commands Reference
# Book: Mastering Container Architectures on AWS - Chapter 5
# ============================================================================

# ---- Cluster Status ----
kubectl get nodes -o wide
kubectl get pods -A --field-selector=status.phase!=Running
kubectl top nodes
kubectl top pods -n production --sort-by=memory

# ---- Pod Debugging ----
kubectl describe pod <pod-name> -n production
kubectl logs <pod-name> -n production
kubectl logs <pod-name> -n production --previous  # Previous container logs
kubectl logs -f <pod-name> -n production           # Follow logs
kubectl logs -l app=web-api -n production          # Logs by label

# ---- Events ----
kubectl get events -n production --sort-by='.lastTimestamp'
kubectl get events -A --field-selector=type=Warning

# ---- Network Debugging ----
kubectl run debug --rm -it --image=nicolaka/netshoot -- /bin/bash
# Inside debug pod: curl, nslookup, dig, traceroute, tcpdump

# ---- Resource Analysis ----
kubectl get pods -n production -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].resources}{"\n"}{end}'

# ---- Node Issues ----
kubectl describe node <node-name>
kubectl get pods --field-selector=spec.nodeName=<node-name>
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
kubectl uncordon <node-name>
