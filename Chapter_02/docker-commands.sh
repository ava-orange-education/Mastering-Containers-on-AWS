#!/bin/bash
# ============================================================================
# Docker CLI Commands Reference
# Book: Mastering Container Architectures on AWS - Chapter 2
#
# Comprehensive reference of essential Docker commands organized by workflow.
# ============================================================================

# ---- IMAGE MANAGEMENT ----

# Build an image from Dockerfile in current directory
docker build -t myapp:1.0.0 .

# Build with specific Dockerfile and build arguments
docker build -f Dockerfile.prod -t myapp:1.0.0 --build-arg APP_VERSION=1.0.0 .

# List local images
docker images

# Remove an image
docker rmi myapp:1.0.0

# Remove dangling (untagged) images
docker image prune

# Remove all unused images
docker image prune -a

# Inspect image layers and metadata
docker inspect myapp:1.0.0

# View image layer history (see which instruction created each layer)
docker history myapp:1.0.0

# ---- CONTAINER LIFECYCLE ----

# Run a container (detached mode, with port mapping and name)
docker run -d --name myapp -p 8080:5000 myapp:1.0.0

# Run with environment variables
docker run -d --name myapp \
    -e DATABASE_URL=postgresql://db:5432/app \
    -e LOG_LEVEL=DEBUG \
    -p 8080:5000 myapp:1.0.0

# Run with resource limits (CPU and memory)
docker run -d --name myapp \
    --memory=512m --cpus=0.5 \
    -p 8080:5000 myapp:1.0.0

# Run with a volume mount (persistent data)
docker run -d --name mydb \
    -v pgdata:/var/lib/postgresql/data \
    -p 5432:5432 postgres:16

# Run with a bind mount (development)
docker run -d --name myapp \
    -v $(pwd)/src:/app/src \
    -p 8080:5000 myapp:1.0.0

# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop a container gracefully (SIGTERM, then SIGKILL after 10s)
docker stop myapp

# Start a stopped container
docker start myapp

# Restart a container
docker restart myapp

# Remove a container
docker rm myapp

# Force remove a running container
docker rm -f myapp

# ---- DEBUGGING AND TROUBLESHOOTING ----

# View container logs
docker logs myapp

# Follow logs in real-time
docker logs -f myapp

# View last 100 lines with timestamps
docker logs --tail 100 --timestamps myapp

# Execute a command inside a running container
docker exec -it myapp /bin/bash

# Execute a one-off command
docker exec myapp cat /etc/os-release

# View container resource usage (CPU, memory, network)
docker stats myapp

# Inspect container configuration and state
docker inspect myapp

# View container processes
docker top myapp

# Copy files between host and container
docker cp myapp:/app/logs/error.log ./error.log
docker cp ./config.json myapp:/app/config.json

# ---- NETWORKING ----

# List networks
docker network ls

# Create a custom bridge network
docker network create myapp-network

# Run containers on the same network (they can reach each other by name)
docker run -d --name api --network myapp-network myapp:1.0.0
docker run -d --name db --network myapp-network postgres:16

# Inspect network details
docker network inspect myapp-network

# ---- VOLUMES ----

# List volumes
docker volume ls

# Create a named volume
docker volume create mydata

# Inspect volume
docker volume inspect mydata

# Remove unused volumes
docker volume prune

# ---- CLEANUP ----

# Remove all stopped containers, unused networks, dangling images, and build cache
docker system prune

# Full cleanup (WARNING: removes all unused images, not just dangling)
docker system prune -a --volumes

# View disk usage
docker system df
