# Checklist — Hosting Railway (profile-specific) — STUB

> **TODO**: contributi benvenuti — vedi [CONTRIBUTING.md](../../../../CONTRIBUTING.md).

Questa checklist e' attualmente vuota. La detection in `audit-hosting/SKILL.md` la attiva quando rileva `railway.json`, `railway.toml` o `nixpacks.toml`.

## Topic suggeriti per la prima versione

- Volume persistence: mount path corretto, backup strategy
- Healthcheck endpoint configurato (Railway non killa container se health fallisce)
- NIXPACKS build: configurazione `nixpacks.toml`, `providers`, `phases`
- Dockerfile alternative se Nixpacks non basta
- Service variables vs shared variables (project-level)
- Private networking tra service (Railway internal DNS `service.railway.internal`)
- Cron jobs via Railway Cron service
- Replica scaling (Pro plan)
- Resource limits (CPU/RAM): set espliciti per evitare OOM
- Database addon (Postgres, MySQL, Redis): connection string via env
- Logs retention (Hobby vs Pro)
- Deploy: GitHub auto-deploy, branch-based environment
- Rollback: deploy history via dashboard

## FORMATO REPORT

- **Categoria**: prefix `HOSTING-RAILWAY-NNN`
