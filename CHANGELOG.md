# Changelog

Tutti i cambiamenti notevoli del plugin sono documentati qui.

Il formato si basa su [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) e il versioning segue [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
