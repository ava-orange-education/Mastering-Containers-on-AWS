#!/bin/bash
# ============================================================================
# Docker Security Best Practices and Scanning
# Book: Mastering Container Architectures on AWS - Chapter 2
#
# Demonstrates container security practices including:
#   - Image vulnerability scanning with Trivy
#   - Dockerfile linting with Hadolint
#   - Security configuration checks
# ============================================================================

set -euo pipefail

IMAGE_NAME="${1:-myapp:latest}"

echo "============================================"
echo "  Docker Security Scan: ${IMAGE_NAME}"
echo "============================================"
echo ""

# ---- 1. Scan for Vulnerabilities with Trivy ----
echo "--- Step 1: Vulnerability Scanning (Trivy) ---"
if command -v trivy &>/dev/null; then
    echo "Scanning image for vulnerabilities..."
    trivy image --severity HIGH,CRITICAL "${IMAGE_NAME}"
else
    echo "Trivy not installed. Running via Docker..."
    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy:latest image \
        --severity HIGH,CRITICAL \
        "${IMAGE_NAME}"
fi
echo ""

# ---- 2. Lint Dockerfile with Hadolint ----
echo "--- Step 2: Dockerfile Linting (Hadolint) ---"
if [ -f Dockerfile ]; then
    docker run --rm -i hadolint/hadolint < Dockerfile || true
    echo ""
else
    echo "No Dockerfile found in current directory. Skipping lint."
fi
echo ""

# ---- 3. Check Image Configuration ----
echo "--- Step 3: Security Configuration Check ---"
echo ""

echo "Checking if image runs as root..."
USER=$(docker inspect --format='{{.Config.User}}' "${IMAGE_NAME}" 2>/dev/null || echo "")
if [ -z "$USER" ] || [ "$USER" = "root" ] || [ "$USER" = "0" ]; then
    echo "  WARNING: Image runs as root. Use USER instruction in Dockerfile."
else
    echo "  OK: Image runs as user '${USER}'"
fi
echo ""

echo "Checking for HEALTHCHECK..."
HC=$(docker inspect --format='{{.Config.Healthcheck}}' "${IMAGE_NAME}" 2>/dev/null || echo "")
if [ -z "$HC" ] || [ "$HC" = "<nil>" ]; then
    echo "  WARNING: No HEALTHCHECK defined. Add one for orchestrator integration."
else
    echo "  OK: HEALTHCHECK is configured"
fi
echo ""

echo "Checking exposed ports..."
docker inspect --format='{{range $p, $conf := .Config.ExposedPorts}}{{$p}} {{end}}' "${IMAGE_NAME}" 2>/dev/null
echo ""

echo "Checking image size..."
docker inspect --format='Image Size: {{.Size}} bytes ({{printf "%.1f" (divf .Size 1048576.0)}} MB)' "${IMAGE_NAME}" 2>/dev/null || \
    docker images "${IMAGE_NAME}" --format "Image Size: {{.Size}}"
echo ""

echo "--- Security Checklist Summary ---"
echo "  [ ] Image uses specific version tags (not :latest)"
echo "  [ ] Running as non-root user"
echo "  [ ] Minimal base image (alpine/slim/distroless)"
echo "  [ ] No secrets baked into the image"
echo "  [ ] HEALTHCHECK defined"
echo "  [ ] .dockerignore excludes sensitive files"
echo "  [ ] Dependencies pinned to specific versions"
echo "  [ ] No unnecessary packages installed"
