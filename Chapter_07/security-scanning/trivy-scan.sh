#!/bin/bash
# Container Image Vulnerability Scanning with Trivy
# Book: Mastering Container Architectures on AWS - Chapter 7
set -euo pipefail

IMAGE="${1:?Usage: $0 <image:tag>}"

echo "=== Scanning $IMAGE for vulnerabilities ==="
trivy image \
    --severity HIGH,CRITICAL \
    --exit-code 1 \
    --format table \
    --ignore-unfixed \
    "$IMAGE"

echo ""
echo "Generating SBOM..."
trivy image --format spdx-json --output sbom.spdx.json "$IMAGE"
echo "SBOM saved to sbom.spdx.json"
