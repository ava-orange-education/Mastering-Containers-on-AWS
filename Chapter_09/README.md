# Chapter 9 — Container Security on AWS

## Files

| File | Description |
|------|-------------|
| `image-security/Dockerfile.secure` | Hardened multi-stage Dockerfile: distroless base, non-root user, no secrets in layers, minimal attack surface. |
| `image-security/Dockerfile.insecure` | Annotated insecure Dockerfile showing common anti-patterns (for comparison). |
| `image-security/ecr-scanning.sh` | ECR enhanced scanning script with vulnerability gate (blocks deployment if CRITICAL CVEs found). |
| `iam-rbac/irsa-setup.sh` | Complete IRSA setup: create OIDC provider, IAM role with trust policy, annotated ServiceAccount. |
| `secrets-management/secret-provider-class.yaml` | Secrets Store CSI Driver SecretProviderClass for mounting AWS Secrets Manager secrets as volumes. |
| `pod-security/pod-security-admission.yaml` | Namespace with Pod Security Admission labels enforcing the restricted profile. |
| `pod-security/restricted-pod.yaml` | PSS-compliant Pod spec: non-root, read-only rootfs, drop ALL capabilities, seccomp. |
| `network-security/microsegmentation.yaml` | Fine-grained NetworkPolicies: default-deny + per-service allow rules for frontend, API, and database. |
| `runtime-security/falco-values.yaml` | Falco Helm values with Falcosidekick outputs (Slack, CloudWatch) and custom rules for crypto mining, shell access. |
| `admission-control/kyverno-policies/require-image-tag.yaml` | Kyverno ClusterPolicy: block images using `:latest` tag. |
| `compliance/cis-benchmark-scan.sh` | Run kube-bench CIS Kubernetes Benchmark as a Kubernetes Job and collect results. |

## Usage

```bash
# Compare secure vs insecure Dockerfile
diff image-security/Dockerfile.insecure image-security/Dockerfile.secure

# Set up IRSA
chmod +x iam-rbac/irsa-setup.sh
./iam-rbac/irsa-setup.sh my-cluster my-namespace my-service-account

# Install Falco
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm install falco falcosecurity/falco -f runtime-security/falco-values.yaml -n falco --create-namespace

# Apply Kyverno policy
kubectl apply -f admission-control/kyverno-policies/require-image-tag.yaml

# Run CIS benchmark
chmod +x compliance/cis-benchmark-scan.sh
./compliance/cis-benchmark-scan.sh
```
