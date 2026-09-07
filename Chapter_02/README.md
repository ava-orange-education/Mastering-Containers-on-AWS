# Chapter 2 — Building Container Images with Docker

## Files

| File | Description |
|------|-------------|
| `basic-flask-app/` | Complete Flask REST API with production Dockerfile (specific base image, layer caching, non-root user, HEALTHCHECK). |
| `multistage-go-app/` | Go HTTP server with multi-stage Dockerfile demonstrating 800MB → 20MB image size reduction (97.5% smaller). |
| `nodejs-containerized/` | Express.js server with proper Node.js Dockerfile (npm ci, node user, graceful SIGTERM handling). |
| `docker-commands.sh` | Comprehensive Docker CLI reference organized by workflow: images, containers, debugging, networking, volumes, cleanup. |
| `ecr-push.sh` | Full ECR workflow: create repo, authenticate, build, tag with git SHA, push, verify. |
| `docker-security-scan.sh` | Security scanning with Trivy, Hadolint Dockerfile linting, and configuration checks (root user, healthcheck, image size). |
| `docker-compose-dev.yml` | Multi-container development environment with API, PostgreSQL, Redis, and Nginx reverse proxy. |

## Usage

```bash
# Build and run the Flask app
cd basic-flask-app
docker build -t flask-app .
docker run -p 5000:5000 flask-app

# Build the Go multi-stage app (see the size difference!)
cd multistage-go-app
docker build -t go-app .
docker images go-app   # ~20MB

# Push to ECR (update ACCOUNT_ID and REGION first)
chmod +x ecr-push.sh
./ecr-push.sh

# Scan an image for vulnerabilities
chmod +x docker-security-scan.sh
./docker-security-scan.sh myapp:latest
```
