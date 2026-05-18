# Audit Deploy Pack — Plugin Claude Code

Audit pre-deploy modulare e stack-aware per progetti web. Lancia 10 agenti specializzati in parallelo (oppure invoca singolarmente le skill granulari) per verificare backend, frontend, mobile UX, database, sicurezza OWASP, algoritmica, SEO, GDPR, hosting e email.

## Cosa fa

| # | Skill | Cosa controlla | Comando |
|---|-------|----------------|---------|
| 1 | Backend | Code quality stack-aware (PHP, Laravel, Node, Python, Go) | `/audit-backend` |
| 2 | Frontend | HTML semantico, WCAG 2.1, responsive, performance | `/audit-frontend` |
| 3 | Mobile UX | Touch interface, thumb zone, form mobile, viewport | `/audit-mobile-ux` |
| 4 | Database | Prepared statements, schema, prevenzione injection (MySQL/Postgres/SQLite/Mongo) | `/audit-database` |
| 5 | Security | OWASP Top 10:2025, security headers, CSRF, login sicuro | `/audit-security` |
| 6 | Algorithms | Logica, edge cases, race conditions, N+1, ReDoS | `/audit-algorithms` |
| 7 | SEO | Meta tags, structured data, sitemap, Core Web Vitals | `/audit-seo` |
| 8 | GDPR | Garante italiano, cookie banner, privacy policy art.13 | `/audit-gdpr` |
| 9 | Hosting | Limiti hosting stack-specific (Netsons/Vercel/Railway/AWS) | `/audit-hosting` |
| 10 | Email | SPF/DKIM/DMARC, deliverability, transport (PHPMailer/Nodemailer/SES/SendGrid) | `/audit-email` |

Tutti insieme via orchestrator: `/audit-deploy`

## Profili supportati

### Linguaggio backend

| Marker | Stack | Status v2.1 |
|--------|-------|-------------|
| `composer.json` | PHP | ✅ Completo |
| `composer.json` + `laravel/framework` | Laravel 13.x (+ L10/L11/L12) | ✅ Completo |
| `composer.json` + `symfony/framework-bundle` | Symfony 7.x | ✅ Completo |
| `composer.json` + `codeigniter4/framework` | CodeIgniter 4.x | ✅ Completo |
| `package.json` | Node.js (LTS 22.x / 20.x) | ✅ Completo |
| `pyproject.toml` / `requirements.txt` | Python (Django / FastAPI / Flask) | ✅ Completo |
| `go.mod` | Go (latest minor) | ✅ Completo |

### Database engine

| Marker | Engine | Status v2.1 |
|--------|--------|-------------|
| `pdo_mysql`, `mysqli`, `mysql` in deps, `DB_CONNECTION=mysql` | MySQL/MariaDB | ✅ Completo |
| `pg`, `psycopg2`, `asyncpg`, postgresql string | PostgreSQL 17.x | ✅ Completo |
| `better-sqlite3`, `sqlite3`, `.db` files | SQLite | ✅ Completo |
| `mongoose`, `mongodb`, `MONGO_URI` | MongoDB 8.x | ✅ Completo |

### Hosting profile

| Marker | Profile | Status v2.1 |
|--------|---------|-------------|
| `.htaccess` + cPanel hints (default fallback) | Netsons (cPanel shared hosting) | ✅ Completo |
| `.htaccess` + Plesk indicators (`httpdocs/`) | Aruba (Plesk shared hosting) | ✅ Completo |
| `vercel.json` | Vercel | ✅ Completo |
| `railway.json` o `nixpacks.toml` | Railway | ✅ Completo |

### Transport email

| Marker | Transport | Status v2.1 |
|--------|-----------|-------------|
| `phpmailer/phpmailer` / `symfony/mailer` in composer | PHPMailer / Symfony Mailer | ✅ Completo |
| `nodemailer` in package.json | Nodemailer | ✅ Completo |
| `@aws-sdk/client-sesv2` / `boto3` SES | AWS SES | ✅ Completo |
| `@sendgrid/mail` | SendGrid (Twilio) | ✅ Completo |
| `mailgun.js` / `mailgun-python` | Mailgun (EU/US) | ✅ Completo |
| `postmark` SDK | Postmark | ✅ Completo |
| Brevo (ex Sendinblue) SDK | Brevo | ✅ Completo |

## Pipeline intelligente (risparmio token)

| Fase | Modello | Scopo |
|------|---------|-------|
| Pre-check | Haiku | Scansione struttura, detect stack/engine/hosting, skip skill non rilevanti |
| Audit | Sonnet | Skill rilevanti in parallelo (1-10) |
| Scoring | Haiku | Confidenza 0-100, filtra falsi positivi, genera report |

Opus resta libero per il lavoro principale.

## Installazione

### Metodo 1 — Clone da GitHub (consigliato)

```bash
git clone https://github.com/Gianmarco0001/audit-deploy-plugin.git
cp -r audit-deploy-plugin/audit-deploy-pack/skills/* ~/.claude/skills/
cp -r audit-deploy-plugin/audit-deploy-pack/commands/* ~/.claude/commands/
```

### Metodo 2 — Plugin marketplace (se disponibile)

```bash
# In Claude Code:
/plugin marketplace add Gianmarco0001/audit-deploy-plugin
/plugin install audit-deploy-pack@Gianmarco0001
```

## Uso

### Audit completo (tutte le skill rilevanti)

```
/audit-deploy
```

Oppure con percorso specifico e configurazione:

```
/audit-deploy /percorso/al/progetto --max-iter=5 --approve-from=critical
```

Argomenti:

- `--max-iter=N` (default 3): numero massimo iterazioni del fix loop
- `--approve-from=low|medium|high|critical` (default high): da quale severity in su chiedere conferma utente prima di applicare fix

### Audit parziale (skill singola)

```
/audit-security
/audit-seo
/audit-database
```

Ogni skill carica solo il proprio contesto e produce findings per la propria area.

## Ciclo iterativo

Dopo il primo audit, l'orchestrator:

1. Risolve automaticamente i finding LOW/MEDIUM
2. Per HIGH/CRITICAL e per path protetti (`.env`, `composer.json`, ecc.) chiede conferma all'utente prima di applicare
3. Rilancia solo le skill toccate dai fix (non tutte)
4. Genera `AUDIT-REPORT-v{N}.md`
5. Se restano finding o si raggiunge `max_iterations`: `FINAL-AUDIT-REPORT.md`

## Quando usare e quando NO

**Usa il plugin quando**:

- Il progetto è in pre-deploy e vuoi un check di sicurezza/qualità
- Hai concluso una sessione di vibe-coding e vuoi un audit oggettivo
- Verifica periodica (mensile/trimestrale) di sicurezza e compliance
- Vuoi un singolo audit verticale (solo security, solo SEO, ecc.) senza pagare gli altri

**NON usare il plugin quando**:

- Il progetto è < 5 file (overhead non giustificato)
- Vuoi un'analisi di business logic o feature work (fuori scope: il plugin fa security/perf/compliance/best-practices)
- Hai bisogno di un audit di un linguaggio non ancora supportato (Node/Python/Go: in v2.0 ci sono solo gli scheletri — contribuisci!)

## Personalizzazione e contributi

Vedi [CONTRIBUTING.md](CONTRIBUTING.md) per aggiungere supporto a un nuovo stack, framework, DB engine, hosting profile o transport email.

## Fonti

- [OWASP Top 10:2025](https://owasp.org/Top10/2025/)
- [Garante italiano — Cookie Guidelines](https://www.didomi.io/blog/italian-garante-new-guidelines)
- [Laravel 13.x Documentation](https://laravel.com/docs/13.x/)
- [Netsons Hosting](https://www.netsons.com/en/piani-hosting)
- [WCAG 2.1](https://www.w3.org/WAI/WCAG21/quickref/)
- [Mobile UX Best Practices 2026](https://inkbotdesign.com/mobile-ux/)

## Changelog

Vedi [CHANGELOG.md](CHANGELOG.md). v2.0.0 introduce skill granulari, supporto Laravel 13, detection stack-aware, approval gate.
