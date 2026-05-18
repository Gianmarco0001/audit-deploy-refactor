# Checklist — Database SQLite (engine-specific) — STUB

> **TODO**: contributi benvenuti — vedi [CONTRIBUTING.md](../../../../CONTRIBUTING.md).

Questa checklist e' attualmente vuota. La detection in `audit-database/SKILL.md` la attiva quando rileva `better-sqlite3`, `sqlite3` in deps, o file `*.db` / `*.sqlite` nel repo.

## Topic suggeriti per la prima versione

- WAL mode (`PRAGMA journal_mode=WAL`) per concorrenza
- `busy_timeout` configurato per evitare SQLITE_BUSY
- Single-writer constraint (SQLite serializza scritture, no scaling orizzontale)
- Backup: `.backup` API o `VACUUM INTO` (no copia file mentre aperto)
- File location: fuori da public/ (SQLite e' file system, raggiungibile via web se nella root)
- Permessi file `.db`: 600
- Encryption: SQLCipher per dati sensibili (richiede binding nativo)
- Foreign keys: `PRAGMA foreign_keys=ON` esplicito (default OFF in SQLite!)
- Versione SQLite (3.40+ raccomandato per JSON1 stabile)
- No setup multi-tenant con SQLite condiviso (file lock contention)

## FORMATO REPORT

- **Categoria**: prefix `DATABASE-SQLITE-NNN`
