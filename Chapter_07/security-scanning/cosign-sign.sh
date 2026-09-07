#!/bin/bash
# Sign Container Images with Cosign (Keyless)
# Book: Mastering Container Architectures on AWS - Chapter 7
set -euo pipefail

IMAGE="${1:?Usage: $0 <image@sha256:digest>}"

echo "=== Signing image with Cosign (keyless) ==="
cosign sign --yes "$IMAGE"

echo ""
echo "=== Verifying signature ==="
cosign verify \
    --certificate-identity-regexp=".*@myorg.com" \
    --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
    "$IMAGE"
