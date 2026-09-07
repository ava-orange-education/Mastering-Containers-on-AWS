#!/bin/bash
# Bootstrap Flux on EKS cluster
# Book: Mastering Container Architectures on AWS - Chapter 7
set -euo pipefail

GITHUB_USER="${1:?Usage: $0 <github-user> <github-repo>}"
GITHUB_REPO="${2:?Usage: $0 <github-user> <github-repo>}"

echo "Bootstrapping Flux on the current Kubernetes cluster..."
flux bootstrap github \
  --owner="$GITHUB_USER" \
  --repository="$GITHUB_REPO" \
  --branch=main \
  --path=clusters/production \
  --personal

echo ""
echo "Flux bootstrapped successfully."
echo "Flux will now sync manifests from: $GITHUB_REPO/clusters/production/"
