import logging
import os
import random
import time

from flask import Flask, Response, request
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

# ---- Logging (to stdout so kubectl logs works) ----
class SafeFormatter(logging.Formatter):
    def format(self, record):
        # provide defaults for fields that might be missing
        for k, v in {"path": "-", "status": "-", "latency_ms": "-"}.items():
            if not hasattr(record, k):
                setattr(record, k, v)
        return super().format(record)

handler = logging.StreamHandler()
handler.setFormatter(
    SafeFormatter(
        fmt="%(asctime)s level=%(levelname)s msg=%(message)s path=%(path)s status=%(status)s latency_ms=%(latency_ms)s"
    )
)

root = logging.getLogger()
root.handlers = []              # avoid duplicate handlers
root.addHandler(handler)
root.setLevel(os.getenv("LOG_LEVEL", "INFO"))

app = Flask(__name__)

# ---- Prometheus metrics ----
REQUESTS_TOTAL = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "path", "status"],
)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "Request latency in seconds",
    ["path"],
    buckets=(0.01, 0.05, 0.1, 0.25, 0.5, 1, 2, 5),
)


def log_request(path: str, status: int, latency_ms: int):
    logging.info(
        "request_handled",
        extra={"path": path, "status": status, "latency_ms": latency_ms},
    )


@app.get("/")
def home():
    start = time.time()
    status = 200
    time.sleep(random.uniform(0.01, 0.05))

    latency = time.time() - start
    REQUESTS_TOTAL.labels("GET", "/", str(status)).inc()
    REQUEST_LATENCY.labels("/").observe(latency)
    log_request("/", status, int(latency * 1000))
    return "hello from metrics+logs demo\n", status


@app.get("/work")
def work():
    # /work?ms=200
    ms = int(request.args.get("ms", "100"))
    start = time.time()
    status = 200

    time.sleep(ms / 1000.0)

    latency = time.time() - start
    REQUESTS_TOTAL.labels("GET", "/work", str(status)).inc()
    REQUEST_LATENCY.labels("/work").observe(latency)
    log_request("/work", status, int(latency * 1000))
    return f"did work for {ms}ms\n", status


@app.get("/fail")
def fail():
    start = time.time()
    status = 500
    time.sleep(random.uniform(0.01, 0.03))

    latency = time.time() - start
    REQUESTS_TOTAL.labels("GET", "/fail", str(status)).inc()
    REQUEST_LATENCY.labels("/fail").observe(latency)
    log_request("/fail", status, int(latency * 1000))
    return "simulated failure\n", status


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


if __name__ == "__main__":
    # Flask dev server is fine for a lab
    app.run(host="0.0.0.0", port=8080)
