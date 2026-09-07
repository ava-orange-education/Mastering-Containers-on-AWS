#!/bin/bash
# CIS Kubernetes Benchmark Scan using kube-bench
# Book: Mastering Container Architectures on AWS - Chapter 9
set -euo pipefail

echo "=== CIS Kubernetes Benchmark Scan ==="
echo "Running kube-bench for EKS..."

kubectl apply -f - << 'EOF'
apiVersion: batch/v1
kind: Job
metadata:
  name: kube-bench
  namespace: default
spec:
  template:
    spec:
      hostPID: true
      containers:
        - name: kube-bench
          image: aquasec/kube-bench:latest
          command: ["kube-bench", "run", "--targets", "node", "--benchmark", "eks-1.4.0"]
          volumeMounts:
            - name: var-lib-kubelet
              mountPath: /var/lib/kubelet
              readOnly: true
            - name: etc-systemd
              mountPath: /etc/systemd
              readOnly: true
            - name: etc-kubernetes
              mountPath: /etc/kubernetes
              readOnly: true
      restartPolicy: Never
      volumes:
        - name: var-lib-kubelet
          hostPath: { path: /var/lib/kubelet }
        - name: etc-systemd
          hostPath: { path: /etc/systemd }
        - name: etc-kubernetes
          hostPath: { path: /etc/kubernetes }
  backoffLimit: 0
EOF

echo "Waiting for scan to complete..."
kubectl wait --for=condition=complete job/kube-bench --timeout=120s

echo ""
echo "=== Results ==="
kubectl logs job/kube-bench
kubectl delete job kube-bench
