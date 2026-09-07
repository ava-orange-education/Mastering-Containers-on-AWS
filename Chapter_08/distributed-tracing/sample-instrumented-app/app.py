"""
Flask Application Instrumented with OpenTelemetry
Book: Mastering Container Architectures on AWS - Chapter 8

Sends traces to ADOT Collector which forwards to AWS X-Ray.
"""
import os
from flask import Flask, jsonify
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.resources import Resource

# Configure OpenTelemetry
resource = Resource.create({
    "service.name": os.environ.get("SERVICE_NAME", "web-api"),
    "service.version": os.environ.get("APP_VERSION", "1.0.0"),
    "deployment.environment": os.environ.get("ENVIRONMENT", "production"),
})

provider = TracerProvider(resource=resource)
otlp_exporter = OTLPSpanExporter(
    endpoint=os.environ.get("OTEL_EXPORTER_OTLP_ENDPOINT", "http://adot-collector:4317"),
    insecure=True,
)
provider.add_span_processor(BatchSpanProcessor(otlp_exporter))
trace.set_tracer_provider(provider)

tracer = trace.get_tracer(__name__)

app = Flask(__name__)
FlaskInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()

@app.route("/api/orders")
def list_orders():
    with tracer.start_as_current_span("fetch-orders") as span:
        span.set_attribute("orders.count", 5)
        orders = [{"id": i, "status": "completed"} for i in range(1, 6)]
        return jsonify({"orders": orders})

@app.route("/health")
def health():
    return jsonify({"status": "healthy"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
