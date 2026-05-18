# Checklist — Database PostgreSQL 17.x (engine-specific)

Sei un Database Security Expert specializzato in PostgreSQL. Questa checklist e' applicata in AGGIUNTA a `general.md`. Validata su PostgreSQL 17 ufficiale (postgresql.org/docs/current/).

## CHECKLIST POSTGRESQL 17.x

### 1. Connessioni & network

- [ ] `listen_addresses` esplicito (es. `'localhost,10.0.0.5'`), **MAI** `'*'` aperto a internet
- [ ] `max_connections` dimensionato a pool size app + 5% headroom (default 100 spesso basso/alto)
- [ ] `tcp_keepalives_idle = 900` (15 min), `tcp_keepalives_interval = 30` per dropping connection zombie
- [ ] `tcp_user_timeout = 5000ms` per chiudere socket morti
- [ ] Firewall lato OS: porta 5432 chiusa a internet, aperta solo a app server IPs

### 2. SSL/TLS obbligatorio

- [ ] `ssl = on` in `postgresql.conf`
- [ ] `ssl_cert_file` e `ssl_key_file` configurati (Let's Encrypt o internal CA)
- [ ] Key file permission `0600`, owner `postgres`
- [ ] Client connstring con `sslmode=require` o `verify-full` (verify cert)
- [ ] `ssl_ciphers`: escludere NULL, DES, RC4 (default moderni gia' OK)
- [ ] `ssl_min_protocol_version = 'TLSv1.2'`

### 3. Autenticazione (`pg_hba.conf`)

- [ ] **`scram-sha-256`** OBBLIGATORIO (no `md5`, no `trust`, no `password` cleartext)
- [ ] `password_encryption = scram-sha-256` in `postgresql.conf`
- [ ] Riga `host all all 0.0.0.0/0 trust` BLOCKING (audit grep per esistenza)
- [ ] `log_connections = on`, `log_disconnections = on` per audit trail
- [ ] Custom `password_validation_function` se enforce password policy

### 4. Ruoli & autorizzazioni (least privilege)

- [ ] **NO superuser per app**: dedicated role con grant specifici
  ```sql
  CREATE ROLE app_user WITH LOGIN ENCRYPTED PASSWORD '...';
  GRANT USAGE ON SCHEMA public TO app_user;
  GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
  ```
- [ ] Default privileges configurati: `ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly`
- [ ] `REVOKE ALL ON SCHEMA public FROM PUBLIC` (deny default public schema access)
- [ ] No `CREATEDB`, `CREATEROLE`, `BYPASSRLS` su ruoli app
- [ ] Read-only role separato per analytics/reporting

### 5. Database isolation

- [ ] Separate DB per tenant/environment: `CREATE DATABASE tenant_x OWNER tenant_owner`
- [ ] `search_path` esplicito per evitare schema injection: `SET search_path = "$user", public`
- [ ] Schema per modulo logico se monolite (es. `auth`, `billing`, `audit`)

### 6. Row-Level Security (RLS) per multi-tenancy

- [ ] `ALTER TABLE x ENABLE ROW LEVEL SECURITY` su tabelle tenant-scoped
- [ ] Policy esplicita: `CREATE POLICY tenant_isolation ON x USING (tenant_id = current_setting('app.current_tenant')::int)`
- [ ] Test: query da ruolo non-superuser deve vedere solo righe del proprio tenant
- [ ] Audit grep app code: nessun `SET ROLE postgres` o bypass RLS

### 7. Memoria & cache

- [ ] `shared_buffers = 0.25 * RAM` (es. 8GB → 2GB)
- [ ] `effective_cache_size = 0.5 * RAM`
- [ ] `work_mem = shared_buffers / max_connections` (cap 256MB per evitare OOM on sort)
- [ ] `maintenance_work_mem = 256MB` per VACUUM/CREATE INDEX veloci

### 8. WAL & archive

- [ ] `wal_level = replica` (minimo) o `logical` se logical replication
- [ ] `max_wal_size = 4GB` (default 1GB spesso basso per write-heavy)
- [ ] `checkpoint_completion_target = 0.9` per spread I/O
- [ ] `wal_compression = on` per ridurre WAL size (CPU vs disk trade)
- [ ] `archive_mode = on`, `archive_command` verso S3/SFTP per PITR

### 9. Autovacuum & maintenance

- [ ] **`autovacuum = on`** (mai disabilitare!)
- [ ] `autovacuum_vacuum_scale_factor = 0.01` su tabelle high-write (default 0.2 troppo tardivo)
- [ ] `autovacuum_analyze_scale_factor = 0.005`
- [ ] `autovacuum_max_workers = 3` per sistemi busy
- [ ] Manual VACUUM ANALYZE post-load massivo (`pg_restore` o bulk import)

### 10. Logging & slow query

- [ ] `log_destination = 'stderr,jsonlog'` (Postgres 15+) per ingest ELK/Datadog
- [ ] `log_min_duration_statement = 1000` (slow query > 1s)
- [ ] `log_statement = 'ddl'` minimo, `'all'` in staging per audit
- [ ] `log_lock_waits = on` per deadlock detection
- [ ] **`pg_stat_statements`** extension installata: `shared_preload_libraries = 'pg_stat_statements'`
  - Top-N slow query: `SELECT query, total_exec_time, calls FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 10`

### 11. Timeouts & query killer

- [ ] `statement_timeout = 300000` ms (5 min, app-specific cap)
- [ ] `idle_in_transaction_session_timeout = 600000` ms (10 min, killa zombie tx)
- [ ] `lock_timeout = 30000` ms (30s su acquisizione lock)

### 12. Connection pooling

- [ ] **PgBouncer** davanti a Postgres per app stateless (Rails/Django/Express/Laravel)
- [ ] Pool mode: `transaction` per app stateless, `session` se uso prepared stmts/temp tables
- [ ] `max_db_connections = max_connections / 4` per evitare saturation backend
- [ ] PgCat o Odyssey come alternative moderne

### 13. Encryption & crypto

- [ ] `pgcrypto` extension per `pgp_sym_encrypt()` / `pgp_pub_encrypt()` su PII at-rest
- [ ] `digest()` / `hmac()` per hashing application-level
- [ ] Encryption at filesystem level: LUKS (Linux) o RDS/Cloud SQL gestito

### 14. Backup & DR

- [ ] **PITR** (Point-In-Time Recovery): WAL archiving continuo + base backup daily
- [ ] **`pg_basebackup`** per physical backup, **`pg_dump`** per logical
- [ ] Tools production: WAL-G, Barman, pgBackRest
- [ ] Test restore mensile su staging
- [ ] RPO < 1h, RTO definito esplicitamente
- [ ] Backup off-site (S3 con `aws s3 cp --sse AES256`)

### 15. JSONB best-practice

- [ ] Indici GIN su colonne JSONB cercate: `CREATE INDEX ON tbl USING GIN (data jsonb_path_ops)`
- [ ] `@>` (contains) e `?` (has key) operatori usati al posto di `->>` per indexing
- [ ] No `WHERE data->>'field' = 'value'` su grandi tabelle senza expression index

### 16. Versione & patching

- [ ] PostgreSQL 17.x latest in nuovi deploy
- [ ] **EOL timeline**: v13 EOL nov 2025, v14 EOL nov 2026, v15 nov 2027
- [ ] Minor version timely patching (security fix release quarterly)
- [ ] Subscribe `pgsql-announce` mailing list

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: `postgresql.conf` / `pg_hba.conf` / `path/to/migration.sql:riga`
- **Problema**: descrizione
- **Soluzione**: fix con config snippet o SQL
- **Categoria**: prefix `DATABASE-POSTGRES-NNN`

## RIFERIMENTI

- PostgreSQL Runtime Config: <https://www.postgresql.org/docs/current/runtime-config.html>
- PostgreSQL Security: <https://www.postgresql.org/docs/current/runtime-config-security.html>
- pg_stat_statements: <https://www.postgresql.org/docs/current/pgstatstatements.html>
- PostgreSQL Don't Do This: <https://wiki.postgresql.org/wiki/Don%27t_Do_This>
- PostgreSQL Release Schedule: <https://www.postgresql.org/support/versioning/>
