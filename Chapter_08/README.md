# Chapter 8 — Monitoring and Observability for Containers

## Files

| File | Description |
|------|-------------|
| `prometheus-grafana/prometheus-values.yaml` | kube-prometheus-stack Helm values: persistent storage, AlertManager config (Slack + PagerDuty), retention settings. |
| `prometheus-grafana/alerting-rules.yaml` | PrometheusRule for pod crashes, OOMKilled, high CPU, error rate > 1%, and p99 latency > 500ms. |
| `distributed-tracing/adot-collector.yaml` | AWS Distro for OpenTelemetry (ADOT) Collector DaemonSet: OTLP receiver → X-Ray exporter + CloudWatch EMF exporter. |
| `distributed-tracing/sample-instrumented-app/app.py` | Flask app instrumented with OpenTelemetry SDK for distributed tracing. |
| `distributed-tracing/sample-instrumented-app/requirements.txt` | Python dependencies for the instrumented app. |
| `logging/fluent-bit-eks.yaml` | Fluent Bit ConfigMap for shipping container logs to CloudWatch Logs with Kubernetes metadata enrichment. |
| `logging/structured-logging-python.py` | Python structured JSON logging with custom JSONFormatter, correlation IDs, and log levels. |
| `cloudwatch/logs-insights-queries.txt` | CloudWatch Logs Insights query collection: error patterns, latency analysis, OOMKilled detection, slow queries. |
| `troubleshooting/debug-toolkit.sh` | Debugging script: find unhealthy pods, recent events, resource usage, CrashLoopBackOff detection. |
| `troubleshooting/network-debug-pod.yaml` | netshoot debug pod with network troubleshooting tools (curl, dig, tcpdump, etc.). |

## Usage

```bash
# Install Prometheus + Grafana stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack \
  -f prometheus-grafana/prometheus-values.yaml -n monitoring --create-namespace

# Apply alerting rules
kubectl apply -f prometheus-grafana/alerting-rules.yaml

# Deploy ADOT Collector
kubectl apply -f distributed-tracing/adot-collector.yaml

# Deploy the network debug pod
kubectl apply -f troubleshooting/network-debug-pod.yaml
kubectl exec -it netshoot -- bash
```
