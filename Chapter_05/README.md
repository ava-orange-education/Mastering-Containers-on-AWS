# Chapter 5 — Running Containers with Amazon EKS

## Files

| File | Description |
|------|-------------|
| `cluster-setup/eksctl-cluster.yaml` | Production eksctl config: OIDC, HA NAT, managed node groups (app + system with taint), add-ons, CloudWatch logging. |
| `cluster-setup/terraform/main.tf` | Terraform using terraform-aws-modules for VPC + EKS with managed node groups and EBS CSI IRSA. |
| `cluster-setup/terraform/variables.tf` | Terraform variables for cluster configuration. |
| `cluster-setup/terraform/outputs.tf` | Terraform outputs (cluster endpoint, certificate, name). |
| `kubernetes-manifests/namespace.yaml` | Namespace with ResourceQuota and LimitRange for resource governance. |
| `kubernetes-manifests/deployment.yaml` | Production deployment with topologySpreadConstraints, securityContext, probes, and resource requests/limits. |
| `kubernetes-manifests/service.yaml` | ClusterIP service for internal traffic routing. |
| `kubernetes-manifests/ingress.yaml` | ALB Ingress with AWS annotations (internet-facing, TLS, health checks). |
| `kubernetes-manifests/hpa.yaml` | HorizontalPodAutoscaler with CPU/memory targets and scale behavior. |
| `kubernetes-manifests/service-account.yaml` | ServiceAccount with IRSA annotation for AWS API access. |
| `kubernetes-manifests/configmap.yaml` | ConfigMap for application configuration. |
| `rbac/namespace-role.yaml` | Role + RoleBinding for developer team namespace access. |
| `network-policies/default-deny.yaml` | Default deny-all ingress/egress network policy. |
| `network-policies/allow-app-traffic.yaml` | Allow specific app traffic + DNS egress. |
| `troubleshooting-commands.sh` | kubectl troubleshooting reference: pods, events, logs, resource usage, common issues. |

## Usage

```bash
# Create cluster with eksctl
eksctl create cluster -f cluster-setup/eksctl-cluster.yaml

# Or with Terraform
cd cluster-setup/terraform
terraform init && terraform plan && terraform apply

# Deploy the application stack
kubectl apply -f kubernetes-manifests/namespace.yaml
kubectl apply -f kubernetes-manifests/
kubectl apply -f rbac/
kubectl apply -f network-policies/
```
