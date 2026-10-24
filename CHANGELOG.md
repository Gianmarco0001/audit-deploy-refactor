# Changelog

Tutti i cambiamenti notevoli del plugin sono documentati qui.

Il formato si basa su [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) e il versioning segue [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] — 2026-10

### Nuova skill granulare: `audit-design`

Controllo di qualità visiva e rifinitura dell'interfaccia, lanciato dall'orchestrator per ogni progetto con frontend (`has_html`).

- **Checklist** (`skills/audit-design/checklists/design.md`, 8 aree, prefisso `DESIGN-*`): contrasto e leggibilità (anche placeholder e testo su superfici colorate, misura 65–75 caratteri, `text-wrap`), stati e interazioni (hover/focus/disabled/loading/errore/vuoto, area di tocco 44 px, testi dei pulsanti), tipografia (`tabular-nums`, gerarchia, niente testo a gradiente), superfici (raggi concentrici, ombre vs bordi, contorno delle immagini, niente card nidificate), icone (un set, stroke coerente, `currentColor`, niente emoji), movimento (`prefers-reduced-motion` con alternativa, mai `transition: all`, apertura più lenta della chiusura, sfalsamento < 300 ms, `scale(0.96)`), superfici del browser (focus, selezione, caret, scrollbar), segnali di interfaccia "generata".
- **Fonti**, tenute solo le regole verificabili e generali: [Impeccable](https://github.com/pbakaus/impeccable) (craft floor, audit), [make-interfaces-feel-better](https://github.com/jakubkrehel/make-interfaces-feel-better), [transitions.dev / transitions-polish](https://github.com/jakubantalik/transitions.dev). Escluse le regole di gusto assoluto (es. "mai etichette sopra i titoli") che dipendono dal brief: le decisioni del progetto (DESIGN.md, PRODUCT.md, CLAUDE.md) hanno la precedenza.
- **Rilevatore automatico opzionale**: se il sito gira in locale e la skill Impeccable è installata, lancia `impeccable detect --json` su 2-4 pagine a 1280 e 390 px; ogni risultato va verificato nel codice prima di diventare un finding.
- Orchestrator e `detection-rules.md`: `audit-design` aggiunta al gruppo frontend (salta insieme a frontend/mobile-ux/seo sui progetti senza HTML). Ora le skill granulari sono 11.

## [2.1.0] — 2026-05

### Sub-file stub → checklist complete validate su doc ufficiali

I 13 sub-file che in v2.0 erano stub `TODO contributi benvenuti` sono ora **checklist operative complete** (~30-70 bullet ciascuna), validate su documentazione ufficiale ufficiale.

### Filled

**Backend stack-specific** (`skills/audit-backend/checklists/`):

- **`node.md`** — Validato su <https://nodejs.org/en/learn/getting-started/security-best-practices> e Express security best practices. Copre: runtime LTS, HTTP server hardening anti-DoS, debug inspector, dependency supply chain, secrets, crypto timingSafeEqual, Buffer safety, prototype pollution defense, Permission Model (Node 20.10+), middleware essenziali (helmet, compression, body-parser, CORS, rate-limit).
- **`python.md`** — Validato su Django Deployment Checklist ufficiale <https://docs.djangoproject.com/en/stable/howto/deployment/checklist/> + FastAPI/Flask deployment docs. Copre: Django settings (SECRET_KEY, DEBUG, HSTS, secure headers), FastAPI CORS/Pydantic strict, Flask Talisman/Limiter, SQLAlchemy N+1, password hashing argon2.
- **`go.md`** — Validato su <https://go.dev/doc/security/best-practices>. Copre: govulncheck, race detector, http.Server timeouts (ReadHeaderTimeout anti-Slowloris), context propagation, html/template vs text/template, fuzzing Go 1.18+, build flags CGO_ENABLED=0 / -trimpath / -ldflags.
- **`frameworks/symfony.md`** — Validato su <https://symfony.com/doc/current/security.html>. Copre: firewalls, password_hashers, authentication methods (form_login/json_login/HTTP Basic), login_throttling anti-brute-force, access_control + role_hierarchy + #[IsGranted], Voters per-resource, CSRF, session security, security headers via Nelmio bundle, switch_user audit.
- **`frameworks/codeigniter.md`** — Validato su <https://codeigniter4.github.io/userguide/concepts/security.html>. Copre: Security::csrfProtection, esc() helper, Query Builder vs raw, Validation Library, Encryption::$key, Session DatabaseHandler/RedisHandler, Cookies secure/httponly/samesite, SecureHeaders filter, ContentSecurityPolicy config.

**Database engine-specific** (`skills/audit-database/checklists/`):

- **`postgres.md`** — Validato su <https://www.postgresql.org/docs/current/runtime-config.html>. Copre: listen_addresses, ssl=on + scram-sha-256 pg_hba.conf, RBAC least privilege, RLS multi-tenancy, shared_buffers/work_mem tuning, WAL + archive_mode PITR, autovacuum, pg_stat_statements, statement_timeout, PgBouncer, JSONB GIN indexing.
- **`sqlite.md`** — Validato su <https://www.sqlite.org/security.html>. Copre: PRAGMAs essenziali (foreign_keys, journal_mode=WAL, busy_timeout), Defensive mode per untrusted DB, resource limits per anti-DoS su input non fidato, single-writer constraint, backup API, SQLCipher per encryption at rest.
- **`mongo.md`** — Validato su <https://www.mongodb.com/docs/manual/administration/security-checklist/>. Copre: security.authorization, SCRAM-SHA-256, RBAC built-in roles, bindIp + clusterIpSourceAllowlist, requireTLS, encryption at rest WiredTiger, --noscripting, $jsonSchema validation, CVE-2025-23061 Mongoose < 8.9.5, Queryable Encryption 8.0+.

**Hosting profiles** (`skills/audit-hosting/checklists/`):

- **`vercel.md`** — Validato su <https://vercel.com/docs/security> + <https://vercel.com/docs/limits>. Copre: env vars scope, Edge vs Node Runtime, function limits (size 50MB/250MB, memory, duration), Vercel Firewall WAF + DDoS, CVE-2025-29927 Next.js middleware bypass (versioni minime), Image Optimization domains whitelist, ISR revalidation, Cron Jobs signature validation, Deployment Protection, build limits 45min/15k files, log retention.
- **`railway.md`** — Validato su <https://docs.railway.com/overview/best-practices>. Copre: service/shared/reference variables, environments (production/staging/preview), healthcheck, build Nixpacks vs Dockerfile, resource limits, private networking <service>.railway.internal, database addons, volume persistence, cron jobs, custom domains + SSL automatico, replica scaling, static IPs.
- **`aruba.md`** — Validato su Plesk Administrator Guide + Plesk Customer Guide locali. Copre: PHP via Plesk (display_errors, expose_php, open_basedir, disable_functions, opcache), SSL Let's Encrypt + HSTS, ModSecurity + Fail2Ban, Backup Manager + remote storage, Mail antispam (SpamAssassin, DKIM, SPF, DMARC, greylisting), Database (no wildcard user, SSL), File permissions + chroot, Apache/nginx hardening, DNS + DNSSEC + CAA, Cron via Scheduled Tasks, Plesk admin security (MFA, password policy). + tabella confronto Aruba (Plesk) vs Netsons (cPanel).

**Email transports** (`skills/audit-email/checklists/`):

- **`node-nodemailer.md`** — Validato su <https://nodemailer.com/>. Copre: pool transport, auth env vars, secure 465 / requireTLS 587, tls.rejectUnauthorized obbligatorio, transport.verify() boot, async/await pattern, retry 4xx/no-retry 5xx, header injection prevention, DKIM signing inline, direct transport NO in prod, AWS SES alternativa.
- **`smtp-external.md`** — Validato su:
  - AWS SES: <https://docs.aws.amazon.com/ses/latest/dg/security-best-practices.html> (IAM least privilege, sandbox vs prod, Verified Identities, SPF/DKIM/DMARC/MAIL FROM custom, Configuration Set, bounce/complaint webhook SNS, Reputation Dashboard, regions EU per GDPR)
  - SendGrid (Twilio): 3 doc ufficiali — API Keys management (lifecycle, scope, 100 limit, 69 char, no recovery), Domain Authentication (4 CNAME, Automated vs Manual Security, EU-pinned, Link Branding), Event Webhook signed ECDSA (HMAC + timestamp anti-replay, 11 event types, sg_event_id dedup, bounce categorization)
  - Mailgun: doc locale `documentation.mailgun.com` (API v3/v4, EU vs US endpoint, retry policy 48h, IP pool warmup, tags, validate endpoint, List-Unsubscribe app-side)
  - Postmark: doc locale `postmarkapp.com/developer` (Server vs Account Token, rate 100 req/s, Message Streams Transactional vs Broadcast, DKIM rotation, Templates no-versioning, bounce types HardBounce/Transient/Subscribed, Activity API retention 45 giorni)
  - Brevo (ex Sendinblue): <https://developers.brevo.com/docs/getting-started> (REST API v3 vs SMTP, dedicated IP > 100k/mese, DPA GDPR, data residency EU, Suppression List API, free tier 300/giorno)

### Changed

- README aggiornato: rimossi badge `🚧 Stub TODO v2.1` per gli stack ora completi (Node, Python, Go, Symfony, CodeIgniter, Postgres, SQLite, MongoDB, Aruba, Vercel, Railway, Nodemailer, SES/SendGrid/Mailgun/Postmark/Brevo).
- CHANGELOG aggiornato con dettaglio fonte validazione per ogni file.

### Disclaimer di trasparenza

- Date EOL versioni (Node 18 Apr 2025, Postgres 13 Nov 2025, ecc.) sono dalla knowledge cutoff: re-verificate periodicamente.
- Versioni "current latest" indicate al momento della stesura (Postgres 17, Mongo 8, Symfony 7, Django 5.2, Laravel 13.x).
- Le checklist sono derivate da doc ufficiali, NON testate end-to-end su tutti i possibili progetti reali. Spot-check raccomandato su un campione di bullet PRIMA di affidare audit critici al plugin.

---

## [2.0.0] — 2026-05

### Compatibilità retro 100% per utenti PHP+MySQL+Netsons

Chi oggi usa `/audit-deploy` su un progetto PHP+MySQL+Netsons riceve il **medesimo audit funzionale** del v1: stesso set di check, stessa severity, stessa pipeline Haiku→Sonnet→Haiku. Il valore di v1 è preservato 1:1 — è diventato il "profilo di default" del nuovo schema modulare.

### Added

- **Plugin rinominato** `audit-deploy-netsons` → `audit-deploy-pack`. Descrizione neutra, non più hardcoded su Netsons.
- **10 skill granulari invocabili singolarmente**: `/audit-backend`, `/audit-frontend`, `/audit-mobile-ux`, `/audit-database`, `/audit-security`, `/audit-algorithms`, `/audit-seo`, `/audit-gdpr`, `/audit-hosting`, `/audit-email`. Ogni skill è autonoma, con propria detection e checklist. Riduzione 70-90% del costo per audit mirati.
- **Orchestrator `/audit-deploy`** dispatcha le 10 skill in parallelo via Task tool, applicando skip rules in base ai flag pre-check.
- **Asse "tech stack"** sulle checklist con specificità: backend, database, hosting, email hanno `general.md` + sub-file `<stack>.md`.
- **Asse "framework" PHP**: nuovo file `audit-backend/checklists/frameworks/laravel.md` con copertura completa Laravel 13.x (routes, middleware bootstrap/app.php, policies, form requests, eloquent con attribute syntax, sanctum SPA+API, deploy). Note di retrocompat per L10/L11/L12.
- **`detection-rules.md`** dedicato (in `skills/audit-deploy/`): tabelle marker → stack/framework/engine/hosting. Estendibile via PR senza toccare logica core.
- **Approval gate** sui fix HIGH/CRITICAL e su path protetti (`.env`, `composer.json`, `.htaccess`, migrations, ecc.). LOW/MEDIUM applicati in automatico.
- **`max_iterations` configurabile** (default 3, era 10 hardcoded). Override via `--max-iter=N`.
- **CONTRIBUTING.md**: guida step-by-step per aggiungere nuovo stack/framework/engine/hosting.
- **Test fixture + non-regression**: `tests/fixtures/legacy-php-mysql-netsons/` + `expected-findings.md` + `check-bundle-equivalence.sh`.
- **Stub placeholder** per stack non-PHP (Node, Python, Go), framework non-Laravel (Symfony, CodeIgniter), engine non-MySQL (Postgres, SQLite, Mongo), hosting non-Netsons (Aruba, Vercel, Railway), transport non-PHPMailer (Nodemailer, SES/SendGrid/Mailgun). Riempiti via contributi della community in v2.1+.

### Changed

- **Architettura modulare**: ogni skill è una cartella autonoma sotto `skills/`, con propria SKILL.md, checklist e detection. Caricamento sub-file on-demand (progressive disclosure).
- **Le 10 skill granulari hanno `disable-model-invocation: true`** per evitare auto-invocation accidentale. Solo l'orchestrator ha `disable-model-invocation: false`.
- **Le 10 skill granulari NON hanno `Edit` in `allowed-tools`**: solo Read/Grep/Glob/Bash. Modifiche al codice sono fatte dall'orchestrator dopo conferma utente (approval gate).
- **Pipeline tier-mix Haiku→Sonnet→Haiku invariata** (era già ottimale).

### Removed

- **Cartella legacy `checklists/01-backend-php.md`...`09-email-smtp.md`**: contenuti splittati e migrati nelle sub-cartelle delle 10 skill granulari. Nessun bullet di check è andato perso (verifica automatica via `check-bundle-equivalence.sh`).
- **Skill monolitica `audit-deploy` con 10 agenti inline**: ora è un orchestratore che invoca le 10 skill granulari come subagent.

### Migration guide v1 → v2

Per utenti del v1:

```bash
# Rimuovi v1 (opzionale, può convivere ma fa rumore in /plugin list)
rm -rf ~/.claude/skills/audit-deploy

# Installa v2
git clone https://github.com/Gianmarco0001/audit-deploy-plugin.git
cp -r audit-deploy-plugin/audit-deploy-pack/skills/* ~/.claude/skills/
cp -r audit-deploy-plugin/audit-deploy-pack/commands/* ~/.claude/commands/
```

Lancia `/audit-deploy` sul tuo progetto PHP+MySQL+Netsons → ricevi lo stesso audit del v1.

---

## [1.0.0] — 2026-05

### Initial release

- Plugin `audit-deploy-netsons` con 10 agenti specializzati inline (backend-php, frontend-uiux, mobile-ux, database-sqli, cybersec-owasp, algoritmica, seo, gdpr-cookie, ingegnerizzazione, email-smtp).
- Pipeline a 3 fasi (Haiku pre-check → Sonnet audit → Haiku scoring).
- Fix loop max 10 iterazioni.
- Target: PHP 8.x + MySQL + hosting condiviso Netsons.
