# Chapter 1 — Foundations of Containers and Cloud-Native on AWS

## Files

| File | Description |
|------|-------------|
| `container-vs-vm-comparison.sh` | Educational shell script demonstrating Linux namespaces, cgroups, and container vs VM architecture. Uses ASCII diagrams to visualize the differences. |
| `aws-service-decision-tree.sh` | Interactive script that asks questions about your workload and recommends the right AWS container service (ECS vs EKS vs Fargate vs App Runner). |
| `twelve-factor-app-example/app.py` | Flask application demonstrating all 12 factors of the twelve-factor methodology: environment-based config, health endpoints, graceful shutdown, structured JSON logging, stateless design, and admin processes. |
| `twelve-factor-app-example/Dockerfile` | Production Dockerfile with non-root user, health check, and gunicorn as the process manager. |
| `twelve-factor-app-example/docker-compose.yml` | Local development environment with PostgreSQL and Redis as backing services. |
| `twelve-factor-app-example/requirements.txt` | Python dependencies for the twelve-factor app. |

## Usage

```bash
# Run the container vs VM comparison (educational, no Docker needed)
chmod +x container-vs-vm-comparison.sh
./container-vs-vm-comparison.sh

# Run the AWS service decision tree
chmod +x aws-service-decision-tree.sh
./aws-service-decision-tree.sh

# Run the twelve-factor app locally
cd twelve-factor-app-example
docker-compose up --build
# Visit http://localhost:5000/health
```
