# Contribuire ad audit-deploy-pack

Grazie per voler estendere il plugin. Le aggiunte tipiche sono:

1. **Nuovo linguaggio backend** (Node, Python, Go, Ruby, Rust, …)
2. **Nuovo framework PHP** (Symfony, CodeIgniter, Slim, …)
3. **Nuovo engine database** (Postgres, SQLite, Mongo, Redis, …)
4. **Nuovo hosting profile** (Vercel, Railway, Heroku, Netlify, Aruba, SiteGround, …)
5. **Nuovo transport email** (Nodemailer, SES, SendGrid, Mailgun, …)

Tutte queste sono **contributi separati**, non richiedono modifiche al core. La logica di routing è già in posto.

## Convenzione di naming

| Tipo aggiunta | Dove va | Esempio file |
|---------------|---------|--------------|
| Linguaggio backend | `skills/audit-backend/checklists/<lang>.md` | `node.md`, `python.md`, `go.md` |
| Framework PHP | `skills/audit-backend/checklists/frameworks/<framework>.md` | `symfony.md`, `codeigniter.md` |
| Database engine | `skills/audit-database/checklists/<engine>.md` | `postgres.md`, `sqlite.md`, `mongo.md` |
| Hosting profile | `skills/audit-hosting/checklists/<profile>.md` | `vercel.md`, `railway.md`, `heroku.md` |
| Transport email | `skills/audit-email/checklists/<transport>.md` | `node-nodemailer.md`, `smtp-external.md` |

I file usano kebab-case e estensione `.md`.

## Esempio end-to-end: aggiungere supporto a Python+Postgres+Heroku

### Step 1 — Aggiorna detection rules

Apri `skills/audit-deploy/detection-rules.md` e verifica che i marker per Python, Postgres e Heroku siano presenti. Se mancano, aggiungili alle tabelle:

```
| Marker                            | Stack          |
| pyproject.toml OR requirements.txt | python        |
| psycopg2 OR asyncpg in deps        | postgres      |
| Procfile (formato Heroku)          | heroku        |
```

### Step 2 — Crea i sub-file

```bash
# Backend Python
touch skills/audit-backend/checklists/python.md
# Compila con: type hints, async/await, gunicorn workers, GIL,
# asyncio gotchas, SQLAlchemy N+1, Flask/Django/FastAPI patterns,
# dependency pinning (poetry/pip-tools), virtualenv leak,
# logging configuration, secrets in env

# Database Postgres
# (se non esiste già)
touch skills/audit-database/checklists/postgres.md
# Compila con: EXPLAIN ANALYZE, VACUUM, autovacuum tuning,
# pg_stat_statements, JSONB indexing (GIN), prepared statement
# deallocation, connection pooling (PgBouncer), partitioning,
# replication lag, row-level security

# Hosting Heroku
touch skills/audit-hosting/checklists/heroku.md
# Compila con: dyno sleep (free tier), env config via heroku config,
# Procfile (web: gunicorn ...), buildpack order, addon limits
# (Postgres row limit, Redis memory), slug size limit (500MB),
# release phase, scheduler addon
```

### Step 3 — Aggiorna lo SKILL.md della skill ospitante

Esempio per `skills/audit-backend/SKILL.md`:

```markdown
Sub-file da caricare in base ai marker rilevati sopra:
- composer.json → Read ${CLAUDE_SKILL_DIR}/checklists/php.md
- ...
- requirements.txt | pyproject.toml → Read ${CLAUDE_SKILL_DIR}/checklists/python.md   # ← AGGIUNTA
```

### Step 4 — Testa su un progetto reale

```bash
cd /path/to/your/python-postgres-heroku-app
/audit-deploy
```

Verifica nell'output che:

- Il pre-check rilevi correttamente `python`, `postgres`, `heroku`
- I sub-file caricati siano i tuoi (e non `php.md`/`mysql.md`/`netsons.md`)
- I finding siano specifici al contesto Python/Postgres/Heroku

### Step 5 — PR

Apri una PR con:

- I sub-file nuovi
- L'eventuale aggiornamento a `detection-rules.md`
- L'eventuale aggiunta nel routing di `SKILL.md` della skill ospitante
- Un esempio di output `/audit-deploy` su un progetto reale (anonimizzato) nel corpo della PR

## Struttura di un sub-file checklist

Ogni sub-file segue questo template:

```markdown
# Checklist — <Area> <Stack/Engine/Framework/Profile>

Sei un Senior <Ruolo> specializzato in <Area>. Verifica ogni punto della
seguente checklist applicato al contesto <stack>.

## CHECKLIST

- [ ] Punto specifico 1
- [ ] Punto specifico 2
- [ ] Sezione con sotto-punti:
  - Sotto-punto a
  - Sotto-punto b

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file:riga
- **Problema**: descrizione concisa
- **Soluzione**: fix raccomandato con esempio di codice
- **Categoria**: prefix specifico (es. PYTHON-ASYNC-001, POSTGRES-VACUUM-001)
```

Mantieni il file:

- **Conciso** (40-80 bullet point max, oltre satura il contesto)
- **Stack-specific** (no contenuto universale che già vive in `general.md`)
- **Actionable** (ogni check deve essere verificabile sul codice)
- **In italiano** per testo user-facing

## Quando NON è un contributo separato

Modifiche al **core logic** (orchestrator, pipeline tier-mix, fix loop, approval gate, scoring) NON sono contributi separati: aprire prima una issue per discussione.

Modifiche alle **6 checklist universali** già esistenti (frontend, mobile-ux, owasp, algorithms, seo, gdpr) accettate ma richiedono revisione: queste sono pattern di lunga data, modifiche devono essere giustificate da reference autorevoli (OWASP, WCAG, Garante, ecc.).

## Stub esistenti che cercano contributi

Vedi i file con header "TODO: contributi benvenuti" in:

- `skills/audit-backend/checklists/{node,python,go}.md`
- `skills/audit-backend/checklists/frameworks/{symfony,codeigniter}.md`
- `skills/audit-database/checklists/{postgres,sqlite,mongo}.md`
- `skills/audit-hosting/checklists/{aruba,vercel,railway}.md`
- `skills/audit-email/checklists/{node-nodemailer,smtp-external}.md`
