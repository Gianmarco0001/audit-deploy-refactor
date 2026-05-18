---
name: audit-database
description: |
  Audit di sicurezza database e prevenzione SQL/NoSQL injection, engine-aware
  (MySQL/MariaDB/Postgres/SQLite/Mongo). Detect automatico via driver/connection string in deps.
  Per Laravel applica anche check Eloquent-specific (mass assignment, eager loading, scopes).
  Invocabile da sola (/audit-database) o tramite orchestrator (/audit-deploy).
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash(ls *), Bash(cat *), Bash(find *), Bash(grep *), Bash(test *)
argument-hint: [percorso-progetto]
---

# Audit Database — Skill granulare engine-aware

Sei un Database Security Expert.

## Engine detection

Driver/marker presenti nelle dipendenze:

!`(test -f ${ARGUMENTS:-.}/composer.json && grep -oE '"(doctrine/dbal|illuminate/database|pdo_mysql)"' ${ARGUMENTS:-.}/composer.json) 2>/dev/null; (test -f ${ARGUMENTS:-.}/package.json && grep -oE '"(mysql2|pg|better-sqlite3|sqlite3|mongoose|mongodb|ioredis|redis)"' ${ARGUMENTS:-.}/package.json) 2>/dev/null; (test -f ${ARGUMENTS:-.}/requirements.txt && grep -E '^(psycopg2|asyncpg|pymongo|redis|mysqlclient)' ${ARGUMENTS:-.}/requirements.txt) 2>/dev/null; echo "---"`

Connection string in .env (se presente):

!`test -f ${ARGUMENTS:-.}/.env && grep -E '^(DB_CONNECTION|DATABASE_URL|MONGO_URI|REDIS_URL)=' ${ARGUMENTS:-.}/.env 2>/dev/null | sed 's/=.*/=<redacted>/' || echo "no-env"`

File DB locali (SQLite):

!`find ${ARGUMENTS:-.} -maxdepth 3 -type f \( -name '*.db' -o -name '*.sqlite' -o -name '*.sqlite3' \) 2>/dev/null | head -3 || echo "no-sqlite-files"`

## Carica checklist universale

!`cat "${CLAUDE_SKILL_DIR}/checklists/general.md"`

## Sub-file da caricare on-demand

Usa il tool **Read** per caricare i sub-file degli engine effettivamente usati:

- mysql / mariadb / `DB_CONNECTION=mysql` → Read `${CLAUDE_SKILL_DIR}/checklists/mysql.md`
- postgres / postgresql / psycopg2 / asyncpg → Read `${CLAUDE_SKILL_DIR}/checklists/postgres.md`
- sqlite / better-sqlite3 / `*.db` files → Read `${CLAUDE_SKILL_DIR}/checklists/sqlite.md`
- mongodb / mongoose / `MONGO_URI` → Read `${CLAUDE_SKILL_DIR}/checklists/mongo.md`

Se nessun engine rilevato: solo `general.md` + warning.

## Cross-axis Laravel

Se il progetto e' Laravel (`composer.json` contiene `laravel/framework`), applica anche la sezione "Eloquent ORM" di `${CLAUDE_SKILL_DIR}/../audit-backend/checklists/frameworks/laravel.md` (sezione 6).

## Esecuzione

Applica le checklist. Restituisci findings JSON. Categoria prefix: `DATABASE-GENERAL-NNN`, `DATABASE-MYSQL-NNN`, `DATABASE-POSTGRES-NNN`, ecc.

NON modificare file. Output = JSON findings.
