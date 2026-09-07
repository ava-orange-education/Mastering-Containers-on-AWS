# ============================================================================
# Twelve-Factor App Container Image
# Book: Mastering Container Architectures on AWS - Chapter 1
#
# Demonstrates Factor V (Build, Release, Run) and Factor X (Dev/Prod Parity):
# Same image used across all environments, configuration via env vars.
# ============================================================================

FROM python:3.12-slim AS base

# Security: Run as non-root user
RUN groupadd -r appuser && useradd -r -g appuser -d /app -s /sbin/nologin appuser

WORKDIR /app

# Factor II: Dependencies - Install from explicit declaration
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Security: Switch to non-root user
USER appuser

# Factor VII: Port Binding - Expose the service port
EXPOSE 8080

# Factor III: Config - Default environment variables (overridden at runtime)
ENV PORT=8080 \
    ENVIRONMENT=production \
    SERVICE_NAME=twelve-factor-app \
    APP_VERSION=1.0.0 \
    LOG_LEVEL=INFO

# Health check using admin process (Factor XII)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python app.py healthcheck

# Factor VIII: Concurrency - Use gunicorn for production process management
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", \
     "--access-logfile", "-", "--error-logfile", "-", "app:app"]
