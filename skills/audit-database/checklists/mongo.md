# Checklist — Database MongoDB (engine-specific) — STUB

> **TODO**: contributi benvenuti — vedi [CONTRIBUTING.md](../../../../CONTRIBUTING.md).

Questa checklist e' attualmente vuota. La detection in `audit-database/SKILL.md` la attiva quando rileva `mongoose`/`mongodb` in deps o env `MONGO_URI`.

## Topic suggeriti per la prima versione

- NoSQL Injection: blocco operatori `$` in body JSON da input utente
- **CVE-2025-23061**: Mongoose < 8.9.5 exploitable via `$where` e `populate()` con input non sanitizzato → forzare upgrade
- Sanitize input con `mongo-sanitize` o validazione schema con Joi/Zod
- Schema validation: Mongoose schema strict, Atlas JSON Schema
- Indici compound su pattern di query frequenti
- `$lookup` vs `populate()`: trade-off costo
- Aggregation pipelines: `$match` first per usare indici, `$project` per ridurre payload
- `populate()` con `select` esplicito per non leakare campi sensibili
- TTL index su sessioni / token expiration
- Replica set: read preference appropriato
- Connection: `mongodb+srv://` con TLS, auth source
- Versione MongoDB: 6.0+ raccomandato, 5.0 EOL ottobre 2024
- Backup: mongodump vs filesystem snapshot

## FORMATO REPORT

- **Categoria**: prefix `DATABASE-MONGO-NNN`
