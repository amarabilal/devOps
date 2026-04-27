# ── Stage 1: build ───────────────────────────────────────────────────────────
# Python 3.12 slim — image minimale sans outils inutiles
FROM python:3.12-slim AS builder

WORKDIR /build

COPY requirements.txt .

# Installe dans un prefix isolé pour le COPY final (pas de cache pip gardé)
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Stage 2: runtime durci ────────────────────────────────────────────────────
FROM python:3.12-slim AS runtime

# Bonnes pratiques sécurité :
# - pas de root
# - pas de shell inutile
# - répertoire en lecture seule autant que possible

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/install/bin:$PATH" \
    PYTHONPATH="/install/lib/python3.12/site-packages"

# Crée un utilisateur non-root dédié
RUN groupadd --gid 1001 appgroup && \
    useradd --uid 1001 --gid appgroup --shell /bin/false --no-create-home appuser

WORKDIR /app

# Copie les dépendances depuis le stage builder
COPY --from=builder /install /install

# Copie uniquement le code applicatif (pas les tests, pas la CI)
COPY app/ ./app/

# Change le propriétaire — appuser ne peut pas modifier /install
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"

# Gunicorn : serveur WSGI de production (pas le serveur de dev Flask)
CMD ["python", "-m", "gunicorn", \
     "--bind", "0.0.0.0:5000", \
     "--workers", "2", \
     "--threads", "2", \
     "--timeout", "60", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "app.main:app"]
