# ── Stage 1: build ───────────────────────────────────────────────────────────
# Standard Python slim for building dependencies (pip available)
FROM python:3.12-slim AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Stage 2: runtime — Docker Hardened Image ──────────────────────────────────
# Docker Hardened Image — minimal, rootless, CVE-patched by Docker
# Registry: dhi.io | Docs: https://docs.docker.com/dhi/get-started/
FROM dhi.io/python:3.12 AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/install/bin:$PATH" \
    PYTHONPATH="/install/lib/python3.12/site-packages"

WORKDIR /app

COPY --from=builder /install /install
COPY app/ ./app/

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"

# DHI images already run as non-root — no useradd needed
CMD ["python", "-m", "gunicorn", \
     "--bind", "0.0.0.0:5000", \
     "--workers", "2", \
     "--threads", "2", \
     "--timeout", "60", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "app.main:app"]
