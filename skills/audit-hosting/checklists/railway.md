# Checklist — Hosting Railway (profile-specific)

Sei un DevOps engineer esperto in deployment containerizzato su Railway. Questa checklist e' applicata in AGGIUNTA a `general.md` quando rilevato `railway.json` / `railway.toml` / `nixpacks.toml`. Validata su Railway ufficiale (docs.railway.com).

## CHECKLIST RAILWAY

### 1. Variables management

- [ ] **Service variables** (scope service-level) per config specifica del servizio
- [ ] **Shared variables** (project-level) per config condivisa tra servizi del progetto
- [ ] **Reference variables**: `${{ Service.VAR }}` per collegare servizi dinamicamente (no hardcode)
- [ ] **Private domain references**: usa `RAILWAY_PRIVATE_DOMAIN` per comunicazione inter-service
- [ ] **DATABASE_URL** generata automaticamente dagli addon, referenziata via `${{ Postgres.DATABASE_URL }}`
- [ ] Secrets sensibili (API key, JWT secret) flaggati come "secret" nel dashboard (mascherati nei log)
- [ ] **MAI** committare `.env` con credenziali: Railway sostituisce env al build/runtime

### 2. Environments

- [ ] **Production** environment isolato da staging/development
- [ ] **PR environments** (preview) configurati se serve test pre-merge
- [ ] Variables scope per environment (production secrets ≠ preview secrets)
- [ ] **Trigger deploy** configurato per branch specifici (`main` → production, `develop` → staging)

### 3. Healthcheck

- [ ] **Healthcheck path** configurato in service settings (es. `/health`, `/healthz`)
- [ ] Healthcheck deve rispondere 2xx entro **timeout** configurato
- [ ] **Retry** count e interval settati ragionevoli (default OK per la maggior parte)
- [ ] Healthcheck NON deve dipendere da DB esterno (false negative su DB lento)
- [ ] Endpoint healthcheck NON deve esporre info sensibili (no DB version, no version interna)

### 4. Build configuration

- [ ] **Nixpacks** auto-detect linguaggio se non specificato: Node, Python, Go, Rust, PHP, Ruby
- [ ] `nixpacks.toml` esplicito se serve customizzazione:
  ```toml
  [phases.build]
  cmds = ["npm run build"]
  [start]
  cmd = "node dist/server.js"
  ```
- [ ] **Dockerfile** alternativo se Nixpacks non basta (custom system deps, multi-stage)
- [ ] `.dockerignore` per ridurre context size (node_modules, .git, *.test.*)
- [ ] Build cache abilitata: layer Docker o Nixpacks layers

### 5. Resource limits

- [ ] **CPU & RAM limits** espliciti per evitare OOM kill (default vagueness)
- [ ] Pro plan: resource scaling dinamico
- [ ] Hobby/free: dyno limiti contenuti, app pesanti vanno su Pro
- [ ] Monitor `Metrics` panel post-deploy per dimensionare correttamente

### 6. Private networking

- [ ] **`<service>.railway.internal`** DNS per inter-service communication (no egress cost)
- [ ] Database NON esposto pubblicamente: connessione via `RAILWAY_PRIVATE_DOMAIN` o `*.railway.internal`
- [ ] Public domain solo per servizio HTTP utente-facing
- [ ] Egress costs eliminati per traffico interno (private network)
- [ ] **Scope private network**: singolo environment in singolo progetto (no cross-project)

### 7. Project organization

- [ ] **Servizi correlati** nello stesso progetto Railway (sfrutta networking privato)
- [ ] **EVITA** progetti separati per servizio (es. DB come progetto autonomo) → networking privato non disponibile
- [ ] Variable inheritance: definisci shared variables a project-level per ridurre duplicazione

### 8. Database addons

- [ ] **Postgres / MySQL / MongoDB / Redis** addon nativi via "Add Service" → Database
- [ ] Connection string via `DATABASE_URL` (Postgres), `MONGO_URL`, `REDIS_URL`
- [ ] **Backup automatici** abilitati per Postgres (Pro feature)
- [ ] Versioning DB: aggiornamento minor auto, major manuale
- [ ] Connessione SSL forzata (config `sslmode=require` lato app)

### 9. Volume persistence

- [ ] **Volume mount** per dati persistenti (uploads, cache, db file SQLite)
- [ ] Mount path: tipicamente `/data` o `/var/lib/app-name`
- [ ] **Volume backup**: snapshot automatici (verifica piano)
- [ ] Volume size dimensionato (espansione possibile, ma non shrink retroattivo)

### 10. Cron jobs

- [ ] **Cron service** dedicato (separato da web service)
- [ ] Sintassi cron standard: `0 3 * * *` (3am daily)
- [ ] Script idempotente (cron puo' essere eseguito 2x in caso di retry)
- [ ] Log cron output review per fail silenti

### 11. Custom domains & SSL

- [ ] Custom domain configurato in service settings
- [ ] **SSL automatico** via Let's Encrypt (zero config)
- [ ] CNAME record verso `*.up.railway.app`
- [ ] HTTPS-only (no fallback HTTP)

### 12. Deploy strategy

- [ ] **GitHub auto-deploy** abilitato su branch corretto
- [ ] Deploy trigger su push specifico (es. solo `main`)
- [ ] **Pre-deploy checks**: build success + healthcheck pass prima di switch
- [ ] **Zero-downtime deploy** (Railway switcha automaticamente quando new instance healthy)
- [ ] **Rollback**: dashboard → Deployments → Re-deploy precedente

### 13. Replica scaling

- [ ] **Replica count** > 1 per produzione (Pro feature)
- [ ] Verifica app sia stateless (no in-memory session, no file cache locale)
- [ ] Session storage esterno (Redis, DB)
- [ ] Sticky sessions NOT supported di default

### 14. Static IP (Pro)

- [ ] Static outbound IP se servizi esterni richiedono allowlist (es. webhook receiver, DB esterno con firewall)
- [ ] **Egress IP** documentata per partner che fanno IP-based auth

### 15. Logs & monitoring

- [ ] Logs **retention**: 30 giorni (Pro), meno su Hobby
- [ ] Log streaming via Railway dashboard o CLI: `railway logs --tail`
- [ ] **Log drains** per export esterno (Datadog, Better Stack)
- [ ] Structured logging (JSON) raccomandato

### 16. Sleep policy (free/Hobby)

- [ ] Su free/Hobby: servizi dormono dopo inattività (cold start)
- [ ] Pro plan: no sleep, always-on
- [ ] Cold start time dipende da runtime: Node ~500ms, Python ~1s, JVM ~3-5s

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: `railway.json` / `railway.toml` / `nixpacks.toml` / config service Railway dashboard
- **Problema**: descrizione
- **Soluzione**: fix con config snippet
- **Categoria**: prefix `HOSTING-RAILWAY-NNN`

## RIFERIMENTI

- Railway Docs: <https://docs.railway.com/>
- Railway Best Practices: <https://docs.railway.com/overview/best-practices>
- Nixpacks: <https://nixpacks.com/docs>
- Railway Pricing & Plans: <https://railway.com/pricing>
