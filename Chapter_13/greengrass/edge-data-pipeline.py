"""
Edge Data Pipeline - IoT Greengrass Component
Book: Mastering Container Architectures on AWS - Chapter 13

Processes sensor data at the edge, filtering and aggregating before
sending to the cloud. Reduces bandwidth by 90%+ through local processing.
"""
import json
import time
import random
from datetime import datetime, timezone

# Simulated sensor thresholds
TEMP_THRESHOLD = 80.0  # Only send if above threshold
VIBRATION_THRESHOLD = 5.0

def read_sensor_data():
    """Simulate reading from industrial sensors."""
    return {
        "sensor_id": f"sensor-{random.randint(1, 10):03d}",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "temperature_c": round(random.uniform(20, 95), 2),
        "vibration_mm_s": round(random.uniform(0, 10), 2),
        "pressure_bar": round(random.uniform(1, 5), 2),
        "rpm": random.randint(1000, 5000),
    }

def should_send_to_cloud(reading):
    """Filter: only send anomalous readings to cloud (saves bandwidth)."""
    if reading["temperature_c"] > TEMP_THRESHOLD:
        return True
    if reading["vibration_mm_s"] > VIBRATION_THRESHOLD:
        return True
    return False

def aggregate_readings(readings, window_seconds=60):
    """Aggregate normal readings into summary (reduces data volume)."""
    if not readings:
        return None
    return {
        "type": "aggregated_summary",
        "window_seconds": window_seconds,
        "count": len(readings),
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "avg_temperature": round(sum(r["temperature_c"] for r in readings) / len(readings), 2),
        "max_temperature": round(max(r["temperature_c"] for r in readings), 2),
        "avg_vibration": round(sum(r["vibration_mm_s"] for r in readings) / len(readings), 2),
        "max_vibration": round(max(r["vibration_mm_s"] for r in readings), 2),
    }

def main():
    """Edge processing loop."""
    print("Edge data pipeline started")
    normal_buffer = []
    window_start = time.time()

    while True:
        reading = read_sensor_data()

        if should_send_to_cloud(reading):
            # Anomaly detected - send immediately
            print(f"ALERT: {json.dumps(reading)}")
            # In production: publish to IoT Core MQTT topic
        else:
            # Normal reading - buffer for aggregation
            normal_buffer.append(reading)

        # Every 60 seconds, send aggregated summary
        if time.time() - window_start >= 60:
            summary = aggregate_readings(normal_buffer)
            if summary:
                print(f"SUMMARY: {json.dumps(summary)}")
                # In production: publish aggregated summary to cloud
            normal_buffer = []
            window_start = time.time()

        time.sleep(1)

if __name__ == "__main__":
    main()
