# Chapter 7 — CI/CD for Containers on AWS

## Files

| File | Description |
|------|-------------|
| `codepipeline/buildspec.yml` | CodeBuild buildspec: ECR login, Docker build, Trivy scan, push, generate imagedefinitions.json. |
| `codepipeline/appspec.yml` | CodeDeploy blue/green deployment for ECS with lifecycle hooks. |
| `github-actions/build-push-ecr.yml` | GitHub Actions: OIDC authentication, ECR push, Trivy vulnerability scan. |
| `github-actions/deploy-eks.yml` | GitHub Actions: deploy to EKS with kubectl (staging → production). |
| `gitops-flux/flux-bootstrap.sh` | Flux bootstrap script for GitHub integration. |
| `gitops-flux/gitrepository.yaml` | Flux GitRepository source pointing to your config repo. |
| `gitops-flux/kustomization.yaml` | Flux Kustomization for applying manifests from Git. |
| `gitops-argocd/argocd-install.sh` | ArgoCD installation script with Helm. |
| `gitops-argocd/application.yaml` | ArgoCD Application manifest with auto-sync and self-heal. |
| `progressive-delivery/argo-rollout.yaml` | Argo Rollouts canary strategy with AnalysisTemplate (Prometheus success-rate query). |
| `security-scanning/trivy-scan.sh` | Trivy container image scanning with severity gating. |
| `security-scanning/cosign-sign.sh` | Cosign image signing with AWS KMS key. |
| `security-scanning/kyverno-image-policy.yaml` | Kyverno policy to verify image signatures before admission. |

## Usage

```bash
# Install Flux
chmod +x gitops-flux/flux-bootstrap.sh
./gitops-flux/flux-bootstrap.sh

# Install ArgoCD
chmod +x gitops-argocd/argocd-install.sh
./gitops-argocd/argocd-install.sh

# Apply ArgoCD application
kubectl apply -f gitops-argocd/application.yaml

# Scan an image
chmod +x security-scanning/trivy-scan.sh
./security-scanning/trivy-scan.sh myapp:latest
```
