# Installazione e uso — audit-deploy-pack

Guida rapida per installare il plugin in Claude Code e usarlo sui tuoi progetti.

## Requisiti

- [Claude Code](https://docs.claude.com/en/docs/claude-code) installato e configurato
- Una directory `~/.claude/` esistente (la creazione e' automatica al primo uso di Claude Code)
- `git` per il clone

## Installazione

### Metodo 1 — Clone + copy (consigliato, ~30 secondi)

```bash
# 1. Clone il repo
git clone https://github.com/Gianmarco0001/audit-deploy-refactor.git
cd audit-deploy-refactor

# 2. Copia le 11 skill in ~/.claude/skills/
#    Linux/macOS:
cp -r skills/* ~/.claude/skills/
#    Windows (PowerShell):
#    Copy-Item -Recurse skills\* $env:USERPROFILE\.claude\skills\

# 3. Copia gli 11 slash command in ~/.claude/commands/
mkdir -p ~/.claude/commands
cp -r commands/* ~/.claude/commands/
#    Windows (PowerShell):
#    New-Item -ItemType Directory -Force $env:USERPROFILE\.claude\commands | Out-Null
#    Copy-Item -Recurse commands\* $env:USERPROFILE\.claude\commands\

# 4. Verifica installazione
ls ~/.claude/skills/ | grep audit-
ls ~/.claude/commands/ | grep audit-
```

Dovresti vedere 11 skill (`audit-deploy`, `audit-backend`, `audit-frontend`, `audit-mobile-ux`, `audit-database`, `audit-security`, `audit-algorithms`, `audit-seo`, `audit-gdpr`, `audit-hosting`, `audit-email`) e gli 11 corrispondenti slash command `.md`.

### Metodo 2 — One-liner Linux/macOS

```bash
git clone https://github.com/Gianmarco0001/audit-deploy-refactor.git /tmp/adp && \
  cp -r /tmp/adp/skills/* ~/.claude/skills/ && \
  mkdir -p ~/.claude/commands && \
  cp -r /tmp/adp/commands/* ~/.claude/commands/ && \
  rm -rf /tmp/adp && \
  echo "audit-deploy-pack installato"
```

### Metodo 3 — Aggiornamento da versione precedente del plugin

Se hai gia' installato la versione monolitica `audit-deploy-netsons` (v1), prima fai un backup poi reinstalla:

```bash
# Backup v1 (non distruttivo, rollback istantaneo)
mv ~/.claude/skills/audit-deploy ~/.claude/skills/audit-deploy.v1-backup

# Installa v2 (vedi Metodo 1)
cd /path/to/audit-deploy-refactor
cp -r skills/* ~/.claude/skills/
mkdir -p ~/.claude/commands
cp -r commands/* ~/.claude/commands/
```

Per rollback al v1: `rm -rf ~/.claude/skills/audit-deploy && mv ~/.claude/skills/audit-deploy.v1-backup ~/.claude/skills/audit-deploy`.

## Uso

### Audit completo (orchestratore)

Dentro Claude Code, dalla directory del tuo progetto:

```
/audit-deploy
```

L'orchestratore:

1. **Pre-check (Haiku)**: scansiona la struttura, rileva stack (PHP/Laravel/Node/Python/Go), engine DB (MySQL/Postgres/SQLite/Mongo), hosting (Netsons/Vercel/Railway/...), transport email.
2. **Audit (Sonnet, parallelo)**: lancia in parallelo solo le skill rilevanti per il tuo stack. Salta quelle non applicabili con motivazione esplicita.
3. **Scoring (Haiku)**: dedup cross-skill, filtra falsi positivi (confidenza < 60), genera `AUDIT-REPORT.md`.
4. **Fix loop con approval gate**: applica fix LOW/MEDIUM in automatico; per HIGH/CRITICAL e per path protetti (`.env`, `composer.json`, ecc.) chiede conferma prima di modificare.

#### Argomenti opzionali

```
/audit-deploy [percorso] [--max-iter=N] [--approve-from=low|medium|high|critical]
```

Esempi:

```
# Audit della directory corrente, default (max 3 iterazioni, approval da HIGH in su)
/audit-deploy

# Audit di una directory specifica con piu' iterazioni
/audit-deploy /percorso/al/progetto --max-iter=5

# Approvazione manuale anche per MEDIUM (paranoia mode)
/audit-deploy --approve-from=medium

# Auto-fix tutto senza chiedere (solo se ti fidi)
/audit-deploy --approve-from=critical
```

### Audit parziale (skill granulari)

Ogni skill e' invocabile da sola con il proprio slash command. Costo ridotto del 70-90% rispetto al full audit.

```
/audit-backend          # code quality e best practices backend (stack-aware)
/audit-frontend         # HTML semantico, WCAG, performance frontend
/audit-mobile-ux        # touch interface, viewport, form mobile
/audit-database         # SQL/NoSQL injection, schema, prepared statements
/audit-security         # OWASP Top 10:2025, security headers, CSRF, secret
/audit-algorithms       # correttezza logica, edge case, race condition, ReDoS
/audit-seo              # meta tags, structured data, Core Web Vitals
/audit-gdpr             # cookie banner, privacy policy, Garante italiano
/audit-hosting          # ottimizzazione hosting (profile-aware)
/audit-email            # SPF/DKIM/DMARC, deliverability, transport-aware
```

Ognuno accetta come argomento opzionale il `[percorso-progetto]`.

### Esempi pratici di uso

**Scenario 1 — Progetto Laravel su Vercel pronto al deploy**:

```
/audit-deploy
```

Il pre-check rileva `framework=laravel, hosting=vercel, db=mysql`. Vengono caricati i sub-file: `audit-backend/checklists/{general,php,frameworks/laravel}.md`, `audit-database/checklists/{general,mysql}.md`, `audit-hosting/checklists/{general,vercel}.md` (stub TODO ma comunque attiva), e le altre 6 skill universali. Tempo ~2-5 minuti su un progetto medio.

**Scenario 2 — Vuoi solo un check di sicurezza prima di una release**:

```
/audit-security
```

Solo OWASP + security headers + CSRF + secret. Costo ridotto.

**Scenario 3 — Controllo GDPR su sito vetrina**:

```
/audit-gdpr
```

Verifica cookie banner, opt-in granulari, art.13, raccolta dati nei form.

**Scenario 4 — Audit Laravel-specific su un controller appena scritto**:

```
/audit-backend
```

La skill rileva `composer.json` con `laravel/framework`, carica `php.md` + `frameworks/laravel.md` (~250 righe di check Laravel 13.x: routes, middleware, policies, form requests, eloquent mass assignment, sanctum abilities, ecc.).

## Profili supportati nella v2.0

| Asse | Supportati ora | Stub TODO v2.1 (community) |
|------|----------------|----------------------------|
| Backend lang | PHP | Node, Python, Go |
| Framework PHP | Laravel 13.x (+ note L10/L11/L12) | Symfony, CodeIgniter |
| DB engine | MySQL/MariaDB | Postgres, SQLite, Mongo |
| Hosting | Netsons (default) | Aruba, Vercel, Railway, Netlify, AWS |
| Email transport | PHPMailer, Symfony Mailer | Nodemailer, SES, SendGrid, Mailgun |

Vedi [CONTRIBUTING.md](CONTRIBUTING.md) per aggiungere supporto a un nuovo stack.

## Come funziona internamente

Lettura consigliata per capire l'architettura: [CLAUDE.md](CLAUDE.md).

In breve:

- **Pipeline tier-mix**: Haiku (pre-check / scoring) + Sonnet (audit) per ottimizzare costi
- **Progressive disclosure**: ogni skill carica solo i sub-file rilevanti allo stack rilevato
- **Detection rules** formalizzate in [skills/audit-deploy/detection-rules.md](skills/audit-deploy/detection-rules.md)
- **Sicurezza fix**: le 10 skill granulari **non hanno permesso `Edit`** — solo l'orchestrator applica fix dopo approval gate
- **Path protetti**: `.env`, `composer.json`, `package.json`, `.htaccess`, `*.sql`, `**/database/migrations/**`, `bootstrap/app.php` richiedono sempre conferma

## Quando NON usare questo plugin

- Progetti con < 5 file (overhead non giustificato)
- Audit di business logic (fuori scope: il plugin fa security/performance/compliance/best-practices, non valuta scelte funzionali)
- Stack non ancora supportati (Node/Python/Go al momento sono solo stub — contribuisci!)

## Disinstallazione

```bash
# Linux/macOS
rm -rf ~/.claude/skills/audit-{deploy,backend,frontend,mobile-ux,database,security,algorithms,seo,gdpr,hosting,email}
rm -f ~/.claude/commands/audit-{deploy,backend,frontend,mobile-ux,database,security,algorithms,seo,gdpr,hosting,email}.md

# Windows (PowerShell)
'audit-deploy','audit-backend','audit-frontend','audit-mobile-ux','audit-database','audit-security','audit-algorithms','audit-seo','audit-gdpr','audit-hosting','audit-email' | ForEach-Object {
  Remove-Item -Recurse -Force "$env:USERPROFILE\.claude\skills\$_" -ErrorAction SilentlyContinue
  Remove-Item -Force "$env:USERPROFILE\.claude\commands\$_.md" -ErrorAction SilentlyContinue
}
```

## Supporto e contributi

- Issue tracker: <https://github.com/Gianmarco0001/audit-deploy-refactor/issues>
- Contributi: vedi [CONTRIBUTING.md](CONTRIBUTING.md)
- Changelog: [CHANGELOG.md](CHANGELOG.md)
- Architettura: [CLAUDE.md](CLAUDE.md)

## Compatibilita' retro v1

Chi usa il v1 `audit-deploy-netsons` su progetti PHP+MySQL+Netsons ottiene **lo stesso audit funzionale** col v2: stesso set di check, stessa pipeline, stesso output. La compat retro e' verificata automaticamente dal test in [tests/non-regression/](tests/non-regression/).
