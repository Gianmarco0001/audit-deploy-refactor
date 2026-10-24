# Detection rules — audit-deploy-pack

Tabelle marker → stack/framework/engine/hosting/transport usate dall'orchestrator (FASE 1 pre-check Haiku) e dalle skill granulari (auto-routing interno). Estendibile via PR: vedi [CONTRIBUTING.md](../../CONTRIBUTING.md).

## Linguaggio backend

| Marker (presenti nella root del progetto)                        | Stack rilevato |
|------------------------------------------------------------------|----------------|
| `composer.json`                                                  | php            |
| `package.json` (con `engines.node` OR `pnpm-lock.yaml` OR `yarn.lock` OR `package-lock.json`) | node |
| `pyproject.toml` OR `requirements.txt` OR `Pipfile`              | python         |
| `go.mod`                                                         | go             |
| `Cargo.toml` (con `[package]`)                                   | rust (stub)    |
| `Gemfile`                                                        | ruby (stub)    |
| `*.csproj` OR `*.sln`                                            | dotnet (stub)  |

## Framework PHP (richiede già `composer.json`)

| Marker (in `composer.json` chiave `require`)         | Framework      | Action                                     |
|------------------------------------------------------|----------------|--------------------------------------------|
| `laravel/framework`                                  | laravel        | Load `php.md` + `frameworks/laravel.md`    |
| `symfony/framework-bundle`                           | symfony        | Load `php.md` + `frameworks/symfony.md`    |
| `codeigniter4/framework`                             | codeigniter    | Load `php.md` + `frameworks/codeigniter.md`|
| `slim/slim`                                          | slim (stub)    | Load `php.md` solo (no stub creato)        |
| nessun framework PHP                                 | vanilla        | Load `php.md` solo                         |

## Versione Laravel (architettura differente)

| Marker                                                        | Versione        | Note architetturali                     |
|---------------------------------------------------------------|-----------------|-----------------------------------------|
| `composer.lock` con `"laravel/framework": "v13.*"`            | 13.x            | `bootstrap/app.php`, attribute syntax   |
| `composer.lock` con `"laravel/framework": "v12.*"`            | 12.x            | `bootstrap/app.php`                     |
| `composer.lock` con `"laravel/framework": "v11.*"`            | 11.x            | `bootstrap/app.php` (introduzione)      |
| `composer.lock` con `"laravel/framework": "v10.*"`            | 10.x            | `app/Http/Kernel.php`, legacy structure |
| `composer.lock` con `"laravel/framework": "v9.*"` o inferiore | LEGACY (EOL)    | Flag CRITICO upgrade necessario         |
| Presenza `app/Http/Kernel.php`                                | conferma L10/legacy | architettura pre-L11               |
| Presenza `bootstrap/app.php` con `withMiddleware()`           | conferma L11+/L13   | architettura nuova                 |

## Database engine

| Marker                                                                   | Engine    |
|--------------------------------------------------------------------------|-----------|
| `pdo_mysql` OR `mysqli` in deps OR connection string `mysql://`          | mysql     |
| `illuminate/database` in composer + `DB_CONNECTION=mysql` in `.env`      | mysql (via Eloquent) |
| `pg` OR `psycopg2` OR `asyncpg` in deps OR connection string `postgresql://` | postgres |
| `better-sqlite3` OR `sqlite3` in deps OR `*.db` / `*.sqlite` file in repo | sqlite    |
| `mongoose` OR `mongodb` in deps OR env `MONGO_URI`                       | mongodb   |
| `ioredis` OR `redis` in deps OR env `REDIS_URL`                          | redis     |

## Hosting profile

| Marker                                              | Profile         |
|-----------------------------------------------------|-----------------|
| `vercel.json` presente                              | vercel          |
| `railway.json` OR `nixpacks.toml` OR `railway.toml` | railway         |
| `netlify.toml` presente                             | netlify (stub)  |
| `serverless.yml` presente                           | aws-lambda (stub) |
| `Dockerfile` + `docker-compose.yml` presenti        | self-hosted (stub) |
| `app.yaml` (Google Cloud) presente                  | gae (stub)      |
| `.htaccess` + cPanel-like indicators                | shared hosting → prompt utente "Quale shared hosting? [netsons/aruba/siteground/altro]"; default `netsons` se nessuna scelta |
| Nessun marker hosting + `.htaccess` presente        | netsons (default fallback per retrocompat v1) |
| Nessun marker e nessun `.htaccess`                  | unknown → solo `general.md`, warning utente |

## Mailer transport

| Marker                                                        | Transport         |
|---------------------------------------------------------------|-------------------|
| `phpmailer/phpmailer` in composer.json                        | phpmailer         |
| `symfony/mailer` in composer.json                             | symfony-mailer    |
| `nodemailer` in package.json                                  | nodemailer        |
| `smtplib` import in Python OR `django-mailer` in deps         | python-email      |
| `@sendgrid/mail` OR `sendgrid` (python SDK)                   | provider:sendgrid |
| `@aws-sdk/client-ses` OR `boto3` (con uso ses) OR PHP AWS SDK | provider:ses      |
| `mailgun.js` OR `mailgun-python` OR `mailgun` PHP SDK         | provider:mailgun  |
| `postmark` SDK                                                | provider:postmark |
| `Mail::` o `Mailer::` patterns in codice Laravel/Symfony      | framework-mailer  |

## Frontend / UI

| Marker                                                  | Frontend rilevato      |
|---------------------------------------------------------|------------------------|
| Presenza di `<html>` files / template engine output     | web frontend           |
| Pure-API (no `<html>`, solo route `/api/*`)             | no frontend → skip `audit-frontend`, `audit-mobile-ux`, `audit-seo`, `audit-design` |
| Presenza `next.config.js` / `nuxt.config.ts` / `vite.config.*` | SPA / SSR framework |

## Skill applicabili — decision tree

Pseudo-logica usata dall'orchestrator dopo la pre-check:

```
skills_to_run = []
if profile.backend:           skills_to_run += [audit-backend]
if profile.database:          skills_to_run += [audit-database]
if profile.has_frontend:      skills_to_run += [audit-frontend, audit-mobile-ux, audit-seo, audit-design]
if profile.has_user_data:     skills_to_run += [audit-security, audit-gdpr]
                              # has_user_data = login forms || user-table || cookies || analytics
if profile.email_transport:   skills_to_run += [audit-email]
if profile.hosting:           skills_to_run += [audit-hosting]
skills_to_run += [audit-algorithms]   # sempre
skills_to_run += [audit-security]     # sempre (anche su API pure)
```

Le skill saltate sono loggate esplicitamente con motivo (es. *"audit-email skipped: nessun mailer rilevato"*) per trasparenza utente.

## Cookie / GDPR rilevanza

| Marker                                                       | Skill applicabile         |
|--------------------------------------------------------------|---------------------------|
| `<input>`, form action, login UI, user-related DB tables     | audit-gdpr (priorità normale) |
| Cookie banner script presente OR `Set-Cookie` usage manuale  | audit-gdpr (priorità alta) |
| Pure-API senza UI utente e senza cookie                      | audit-gdpr **skip**       |
| Google Analytics / Tag Manager presenti                      | audit-gdpr (verifica consenso prior) |
