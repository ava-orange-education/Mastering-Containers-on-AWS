# ============================================================================
# Production-Ready Dockerfile for Python Flask Application
# Book: Mastering Container Architectures on AWS - Chapter 2
#
# Best Practices Demonstrated:
#   1. Use specific, slim base image (not :latest)
#   2. Install dependencies before copying app code (layer caching)
#   3. Run as non-root user
#   4. Use COPY instead of ADD
#   5. Set proper EXPOSE and environment variables
#   6. Use exec form for CMD (PID 1 signal handling)
# ============================================================================

# Use specific Python version with slim variant (smaller image)
FROM python:3.12-slim

# Set metadata labels
LABEL maintainer="author@example.com" \
      description="Basic Flask REST API" \
      version="1.0.0"

# Set working directory
WORKDIR /app

# Create non-root user for security
RUN groupadd -r appuser && \
    useradd -r -g appuser -d /app -s /sbin/nologin appuser

# Install dependencies first (leverages Docker layer caching)
# This layer only rebuilds when requirements.txt changes
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code (this layer rebuilds on any code change)
COPY app.py .

# Change ownership and switch to non-root user
RUN chown -R appuser:appuser /app
USER appuser

# Document the port the application listens on
EXPOSE 5000

# Set default environment variables
ENV PORT=5000 \
    FLASK_ENV=production

# Health check for container orchestrators
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Use exec form for proper signal handling (SIGTERM from orchestrator)
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", \
     "--access-logfile", "-", "app:app"]
