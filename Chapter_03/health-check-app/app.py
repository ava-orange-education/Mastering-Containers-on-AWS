"""
Comprehensive Health Check Application
Book: Mastering Container Architectures on AWS - Chapter 3

Demonstrates production health check patterns for container platforms:
  - /health      - Liveness probe (is the process alive?)
  - /ready       - Readiness probe (can we accept traffic?)
  - /startup     - Startup probe (has initialization completed?)

Health checks are critical for ALB target group integration and
Kubernetes liveness/readiness probes.
"""
import os
import time
import json
import logging
from datetime import datetime, timezone
from flask import Flask, jsonify

app = Flask(__name__)
logger = logging.getLogger(__name__)

# Track startup time for startup probe
START_TIME = time.time()
STARTUP_DELAY = int(os.environ.get("STARTUP_DELAY_SECONDS", "5"))
_initialized = False

def _check_database():
    """Verify database connectivity."""
    db_url = os.environ.get("DATABASE_URL")
    if not db_url:
        return {"status": "skipped", "message": "DATABASE_URL not configured"}
    try:
        # In production, use your DB client:
        # import psycopg2
        # conn = psycopg2.connect(db_url)
        # conn.execute("SELECT 1")
        # conn.close()
        return {"status": "ok", "latency_ms": 2}
    except Exception as e:
        return {"status": "error", "message": str(e)}

def _check_cache():
    """Verify cache connectivity."""
    cache_url = os.environ.get("CACHE_URL")
    if not cache_url:
        return {"status": "skipped", "message": "CACHE_URL not configured"}
    try:
        # import redis
        # r = redis.from_url(cache_url)
        # r.ping()
        return {"status": "ok", "latency_ms": 1}
    except Exception as e:
        return {"status": "error", "message": str(e)}

def _check_disk():
    """Check available disk space."""
    try:
        statvfs = os.statvfs("/")
        free_gb = (statvfs.f_frsize * statvfs.f_bavail) / (1024**3)
        return {"status": "ok" if free_gb > 1.0 else "warning", "free_gb": round(free_gb, 2)}
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.route("/health")
def liveness():
    """
    Liveness probe endpoint.
    Returns 200 if the process is alive and responsive.
    Used by: ECS health checks, Kubernetes livenessProbe, ALB health checks.
    Keep this lightweight - don't check external dependencies here.
    """
    return jsonify({
        "status": "alive",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "uptime_seconds": round(time.time() - START_TIME, 1)
    }), 200

@app.route("/ready")
def readiness():
    """
    Readiness probe endpoint.
    Returns 200 only if the service can handle requests (dependencies available).
    Used by: Kubernetes readinessProbe, ALB target group health checks.
    """
    checks = {
        "database": _check_database(),
        "cache": _check_cache(),
        "disk": _check_disk()
    }

    all_ok = all(c["status"] in ("ok", "skipped") for c in checks.values())
    status_code = 200 if all_ok else 503

    return jsonify({
        "status": "ready" if all_ok else "not_ready",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "checks": checks
    }), status_code

@app.route("/startup")
def startup():
    """
    Startup probe endpoint.
    Returns 200 once the application has completed initialization.
    Used by: Kubernetes startupProbe (prevents premature liveness checks).
    """
    global _initialized
    elapsed = time.time() - START_TIME

    if not _initialized and elapsed >= STARTUP_DELAY:
        _initialized = True

    if _initialized:
        return jsonify({"status": "started", "startup_time_seconds": round(elapsed, 1)}), 200
    else:
        return jsonify({"status": "starting", "elapsed_seconds": round(elapsed, 1)}), 503

@app.route("/")
def index():
    return jsonify({"service": "health-check-demo", "version": "1.0.0"})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8080"))
    app.run(host="0.0.0.0", port=port)
