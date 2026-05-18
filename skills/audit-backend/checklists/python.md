# Checklist — Backend Python (stack-specific) — STUB

> **TODO**: contributi benvenuti — vedi [CONTRIBUTING.md](../../../../CONTRIBUTING.md).

Questa checklist e' attualmente vuota. La detection in `audit-backend/SKILL.md` la attiva quando rileva `pyproject.toml` o `requirements.txt`.

## Topic suggeriti per la prima versione

- Flask / Django / FastAPI / Starlette detection e best-practice specifiche
- Type hints + mypy/pyright check
- `async`/`await` corretto (no blocking call in async path, asyncio.gather, asyncio gotchas)
- Gunicorn / Uvicorn workers dimensionamento
- GIL implications (non usare threading per CPU-bound)
- SQLAlchemy N+1 (eager loading `joinedload`, `selectinload`)
- Pydantic validation in FastAPI
- Dependency pinning (poetry.lock / pip-tools requirements.txt)
- virtualenv leak (no installazione globale in produzione)
- Logging configuration (structlog, JSON formatter)
- Secrets via env / dynaconf / pydantic-settings
- `pip-audit` nel CI/CD per CVE
- Versione Python (CPython 3.11+ raccomandato, 3.10 EOL ottobre 2026)
- Django: SECRET_KEY in env, DEBUG=False, ALLOWED_HOSTS configurato, MIDDLEWARE order

## Riferimenti utili

- Python Security: <https://pyca.io/>
- OWASP Python Top 10
- Django Deployment Checklist: <https://docs.djangoproject.com/en/stable/howto/deployment/checklist/>

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file.py:riga
- **Problema**: descrizione
- **Soluzione**: fix con esempio
- **Categoria**: prefix `BACKEND-PYTHON-NNN`
