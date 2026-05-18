# Checklist — Database PostgreSQL (engine-specific) — STUB

> **TODO**: contributi benvenuti — vedi [CONTRIBUTING.md](../../../../CONTRIBUTING.md).

Questa checklist e' attualmente vuota. La detection in `audit-database/SKILL.md` la attiva quando rileva driver Postgres (`pg`, `psycopg2`, `asyncpg`) o connection string `postgresql://`.

## Topic suggeriti per la prima versione

- `EXPLAIN ANALYZE` per query principali, planner statistics
- VACUUM / autovacuum tuning per evitare table bloat
- `pg_stat_statements` extension per top-N slow query
- JSONB indexing (GIN su `->>`) vs B-tree
- Prepared statement deallocation (driver-specific)
- Connection pooling: PgBouncer (transaction vs session mode)
- Partitioning (range, list) per tabelle grandi
- Replication lag su streaming replica
- Row-Level Security (RLS) per multi-tenancy
- `pgvector` se uso AI/embedding
- Versione: PG 15+ raccomandato, 14 EOL nov 2026
- Backup: `pg_dump` (logical) vs `pg_basebackup` (physical), `wal-g` per PITR

## FORMATO REPORT

- **Categoria**: prefix `DATABASE-POSTGRES-NNN`
