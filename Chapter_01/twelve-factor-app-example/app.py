#!/usr/bin/env python3
"""
Twelve-Factor App Example - Cloud-Native Microservice
Book: Mastering Container Architectures on AWS
Chapter 1: Foundations of Containers and Cloud-Native on AWS

This Flask application demonstrates all 12 factors of the Twelve-Factor App
methodology (https://12factor.net), which is foundational to cloud-native
architecture on AWS container platforms.

Twelve Factors Demonstrated:
  I.    Codebase      - One codebase tracked in Git, many deploys
  II.   Dependencies  - Explicitly declare via requirements.txt
  III.  Config        - Store config in environment variables
  IV.   Backing Services - Treat databases as attached resources (URL-based)
  V.    Build/Release/Run - Strict separation (Dockerfile + CI/CD)
  VI.   Processes     - Stateless processes (no local session state)
  VII.  Port Binding  - Export services via port binding
  VIII. Concurrency   - Scale out via process model (container replicas)
  IX.   Disposability - Fast startup, graceful shutdown (SIGTERM handling)
  X.    Dev/Prod Parity - Same container image across environments
  XI.   Logs          - Treat logs as event streams (stdout/stderr)
  XII.  Admin Processes - Run admin tasks as one-off containers
"""

import os
import sys
import signal
import logging
import json
import time
from datetime import datetime, timezone

from flask import Flask, jsonify, request

# ---------------------------------------------------------------------------
# Factor XI: Logs - Write structured JSON logs to stdout
# ---------------------------------------------------------------------------
logging.basicConfig(
    stream=sys.stdout,
    level=logging.INFO,
    format='%(message)s'
)
logger = logging.getLogger(__name__)

def log_json(level, message, **kwargs):
    """Emit structured JSON log entry to stdout."""
    entry = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "level": level,
        "service": os.environ.get("SERVICE_NAME", "twelve-factor-app"),
        "version": os.environ.get("APP_VERSION", "1.0.0"),
        "message": message,
        **kwargs
    }
    logger.info(json.dumps(entry))

# ---------------------------------------------------------------------------
# Factor III: Config - All configuration from environment variables
# ---------------------------------------------------------------------------
SERVICE_NAME = os.environ.get("SERVICE_NAME", "twelve-factor-app")
APP_VERSION = os.environ.get("APP_VERSION", "1.0.0")
PORT = int(os.environ.get("PORT", "8080"))
ENVIRONMENT = os.environ.get("ENVIRONMENT", "development")
DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///local.db")
CACHE_URL = os.environ.get("CACHE_URL", "redis://localhost:6379")
LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO")

# ---------------------------------------------------------------------------
# Factor IX: Disposability - Graceful shutdown on SIGTERM
# ---------------------------------------------------------------------------
def graceful_shutdown(signum, frame):
    """Handle SIGTERM for graceful shutdown (container orchestrator sends this)."""
    log_json("INFO", "Received shutdown signal, cleaning up...", signal=signum)
    # Close database connections, finish in-flight requests, flush buffers
    time.sleep(1)  # Allow in-flight requests to complete
    log_json("INFO", "Graceful shutdown complete")
    sys.exit(0)

signal.signal(signal.SIGTERM, graceful_shutdown)
signal.signal(signal.SIGINT, graceful_shutdown)

# ---------------------------------------------------------------------------
# Factor VII: Port Binding - Export HTTP service via port
# ---------------------------------------------------------------------------
app = Flask(__name__)

# ---------------------------------------------------------------------------
# Factor VI: Processes - Stateless request handling (no local session storage)
# ---------------------------------------------------------------------------
# Note: No in-memory session state. All state in backing services.

@app.route("/")
def index():
    """Service information endpoint."""
    return jsonify({
        "service": SERVICE_NAME,
        "version": APP_VERSION,
        "environment": ENVIRONMENT,
        "status": "running",
        "factors": "https://12factor.net"
    })

@app.route("/health")
def health():
    """
    Health check endpoint for container orchestrator probes.
    ECS health checks and Kubernetes liveness/readiness probes call this.
    """
    health_status = {
        "status": "healthy",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "service": SERVICE_NAME,
        "version": APP_VERSION,
        "checks": {
            "app": "ok",
            # Factor IV: Backing services checked via URL configuration
            "database": _check_database(),
            "cache": _check_cache()
        }
    }
    status_code = 200 if health_status["checks"]["app"] == "ok" else 503
    return jsonify(health_status), status_code

@app.route("/ready")
def readiness():
    """Readiness probe - indicates the service can accept traffic."""
    return jsonify({"ready": True}), 200

@app.route("/api/items", methods=["GET"])
def list_items():
    """Example API endpoint demonstrating stateless request handling."""
    log_json("INFO", "Listing items",
             method=request.method,
             path=request.path,
             request_id=request.headers.get("X-Request-ID", "unknown"))

    # In production, this reads from a backing service (database)
    items = [
        {"id": 1, "name": "Container Image", "type": "artifact"},
        {"id": 2, "name": "Task Definition", "type": "config"},
        {"id": 3, "name": "Service Mesh", "type": "infrastructure"}
    ]
    return jsonify({"items": items, "count": len(items)})

@app.route("/api/items", methods=["POST"])
def create_item():
    """Create endpoint - state persisted to backing service, not locally."""
    data = request.get_json()
    log_json("INFO", "Creating item",
             item_name=data.get("name", "unknown"),
             request_id=request.headers.get("X-Request-ID", "unknown"))

    # Would write to database (backing service), not local state
    return jsonify({"created": True, "item": data}), 201

# ---------------------------------------------------------------------------
# Factor IV: Backing Services - Treat as attached resources via URLs
# ---------------------------------------------------------------------------
def _check_database():
    """Check database connectivity (backing service via DATABASE_URL)."""
    try:
        # In production: connect using DATABASE_URL environment variable
        # from sqlalchemy import create_engine
        # engine = create_engine(DATABASE_URL)
        # engine.connect()
        return "ok"
    except Exception as e:
        log_json("ERROR", "Database health check failed", error=str(e))
        return "unavailable"

def _check_cache():
    """Check cache connectivity (backing service via CACHE_URL)."""
    try:
        # In production: connect using CACHE_URL environment variable
        # import redis
        # r = redis.from_url(CACHE_URL)
        # r.ping()
        return "ok"
    except Exception as e:
        log_json("ERROR", "Cache health check failed", error=str(e))
        return "unavailable"

# ---------------------------------------------------------------------------
# Factor XII: Admin Processes - Run as one-off commands
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    # Check for admin commands (Factor XII)
    if len(sys.argv) > 1:
        command = sys.argv[1]
        if command == "migrate":
            log_json("INFO", "Running database migrations (admin process)")
            # run_migrations(DATABASE_URL)
            print("Migrations complete")
            sys.exit(0)
        elif command == "seed":
            log_json("INFO", "Seeding database (admin process)")
            # seed_database(DATABASE_URL)
            print("Database seeded")
            sys.exit(0)
        elif command == "healthcheck":
            # Can be used as Docker HEALTHCHECK command
            import urllib.request
            try:
                response = urllib.request.urlopen(f"http://localhost:{PORT}/health")
                sys.exit(0 if response.status == 200 else 1)
            except Exception:
                sys.exit(1)

    # Factor VII: Port Binding - Self-contained HTTP service
    log_json("INFO", "Starting service",
             port=PORT, environment=ENVIRONMENT, version=APP_VERSION)

    # Factor VIII: Concurrency - Scale via container replicas, not threads
    # Use gunicorn in production: gunicorn -w 4 -b 0.0.0.0:8080 app:app
    app.run(host="0.0.0.0", port=PORT, debug=(ENVIRONMENT == "development"))
