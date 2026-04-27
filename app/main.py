from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time

app = Flask(__name__)

REQUEST_COUNT = Counter(
    "app_requests_total",
    "Total number of HTTP requests",
    ["method", "endpoint", "status"]
)
REQUEST_LATENCY = Histogram(
    "app_request_latency_seconds",
    "HTTP request latency in seconds",
    ["endpoint"]
)

@app.before_request
def start_timer():
    request._start_time = time.time()

@app.after_request
def record_metrics(response):
    latency = time.time() - request._start_time
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.path,
        status=response.status_code
    ).inc()
    REQUEST_LATENCY.labels(endpoint=request.path).observe(latency)
    return response

@app.route("/")
def index():
    return jsonify({"status": "ok", "message": "DevOps Project API"})

@app.route("/health")
def health():
    return jsonify({"status": "healthy"})

@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

@app.route("/items", methods=["GET"])
def get_items():
    return jsonify({"items": ["item1", "item2", "item3"]})

@app.route("/items/<int:item_id>", methods=["GET"])
def get_item(item_id):
    if item_id < 1 or item_id > 3:
        return jsonify({"error": "Item not found"}), 404
    return jsonify({"id": item_id, "name": f"item{item_id}"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
