# DevOps Project

[![CI/CD Pipeline](https://github.com/amarabilal/devOps/actions/workflows/ci.yml/badge.svg)](https://github.com/amarabilal/devOps/actions/workflows/ci.yml)
[![Docker Image](https://img.shields.io/docker/v/bamara3/devops-project?label=docker)](https://hub.docker.com/r/bamara3/devops-project)

Application Flask avec pipeline CI/CD complet, observabilité Prometheus/Grafana et image Docker durcie.

**Production** : [devops-project-production-f07e.up.railway.app](https://devops-project-production-f07e.up.railway.app)

## Stack technique

| Composant | Technologie |
|-----------|-------------|
| Application | Python 3.12 / Flask |
| CI/CD | GitHub Actions |
| Conteneurisation | Docker (multi-stage, non-root) |
| Scan vulnérabilités | Trivy + VEX |
| SAST | Bandit |
| Linter | Flake8 |
| Métriques | Prometheus |
| Dashboard | Grafana |

## Lancer la stack complète

```bash
docker compose up --build -d
```

| Service | URL |
|---------|-----|
| Application | http://localhost:5000 |
| Métriques | http://localhost:5000/metrics |
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 (admin / devops2024) |

## Lancer les tests localement

```bash
pip install -r requirements.txt -r requirements-dev.txt
pytest tests/ --cov=app -v
```

## Scanner l'image avec Trivy

```bash
docker build -t devops-project:local .
trivy image devops-project:local --severity CRITICAL,HIGH,MEDIUM
```

## Livrables CI

Chaque run de pipeline produit dans les **artefacts** :
- `test-reports/` — rapport HTML des tests + couverture
- `lint-report/` — rapport Flake8
- `sast-report/` — rapport Bandit (JSON + HTML)
- `trivy-reports/` — rapport Trivy JSON + SARIF + fichier VEX
