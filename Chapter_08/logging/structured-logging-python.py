"""
Structured JSON Logging for Containerized Applications
Book: Mastering Container Architectures on AWS - Chapter 8

Structured logs enable efficient querying in CloudWatch Logs Insights,
Grafana Loki, and Elasticsearch.
"""
import json
import logging
import sys
import os
import uuid
from datetime import datetime, timezone

class JSONFormatter(logging.Formatter):
    """Format log records as JSON for structured log aggregation."""

    def format(self, record):
        log_entry = {
            "@timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "service": os.environ.get("SERVICE_NAME", "unknown"),
            "version": os.environ.get("APP_VERSION", "unknown"),
            "environment": os.environ.get("ENVIRONMENT", "unknown"),
        }

        # Add request context if available
        if hasattr(record, "request_id"):
            log_entry["request_id"] = record.request_id
        if hasattr(record, "trace_id"):
            log_entry["trace_id"] = record.trace_id

        # Add exception info if present
        if record.exc_info:
            log_entry["exception"] = self.formatException(record.exc_info)

        # Add any extra fields
        for key, value in record.__dict__.items():
            if key not in ("msg", "args", "exc_info", "exc_text", "stack_info",
                          "name", "levelname", "levelno", "pathname", "filename",
                          "module", "lineno", "funcName", "created", "msecs",
                          "relativeCreated", "thread", "threadName", "processName",
                          "process", "message", "request_id", "trace_id"):
                if not key.startswith("_"):
                    log_entry[key] = value

        return json.dumps(log_entry)

def setup_logging():
    """Configure structured JSON logging to stdout."""
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JSONFormatter())
    logging.root.handlers = [handler]
    logging.root.setLevel(os.environ.get("LOG_LEVEL", "INFO"))

# Usage example
if __name__ == "__main__":
    setup_logging()
    logger = logging.getLogger("web-api")

    logger.info("Application started", extra={"port": 8080})
    logger.info("Processing request", extra={
        "request_id": str(uuid.uuid4()),
        "method": "GET",
        "path": "/api/items",
        "duration_ms": 45
    })
    logger.warning("High memory usage", extra={"memory_percent": 85.5})

    try:
        raise ValueError("Invalid input")
    except Exception:
        logger.exception("Request processing failed", extra={"request_id": "abc-123"})
