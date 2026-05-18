# Checklist — Database Security & Schema (universale)

Sei un Database Security Expert. Analizza TUTTO il codice che interagisce con il database e verifica i punti UNIVERSALI di seguito. Se sono presenti sub-file engine-specifici (mysql.md, postgres.md, sqlite.md, mongo.md), si applicheranno IN AGGIUNTA.

## CHECKLIST UNIVERSALE

- [ ] TUTTE le query usano prepared statements / parametrizzate (mai concatenazione di stringhe con input utente)
- [ ] NESSUNA query costruita con concatenazione di stringhe contenenti input utente, indipendentemente dal driver
- [ ] Credenziali DB non hardcoded nel codice sorgente
- [ ] Utente DB con privilegi minimi (no GRANT ALL, no superuser/root)
- [ ] Schema DB:
  - Chiavi primarie su tutte le tabelle
  - Indici su colonne usate in WHERE, JOIN, ORDER BY
  - Foreign keys dove applicabile
  - Tipi di dato appropriati (no VARCHAR per tutto)
  - Colonne NOT NULL dove il dato e' obbligatorio
- [ ] Nessun dato sensibile in chiaro nel DB:
  - Password hashate (bcrypt, Argon2id) MAI in chiaro
  - PAN carte di credito mai persistiti (PCI-DSS), usare token provider
  - PII protetta (cifratura a riposo per SSN, DoB, dati sanitari)
- [ ] Query non vulnerabili a UNION injection, blind SQLi, time-based SQLi (anche se prepared, attenzione a query builder con `raw`)
- [ ] LIKE queries con escape corretto dei caratteri speciali (% e _)
- [ ] ORDER BY / LIMIT con whitelist di valori ammessi, non input diretto
- [ ] Nessun output di errori SQL visibile all'utente (messaggi generici in produzione)
- [ ] Backup strategy definita
- [ ] Migration/versioning dello schema (file SQL ordinati o migration tool)
- [ ] Connection pooling configurato dove applicabile
- [ ] Transazioni atomiche per operazioni multi-query critiche (ordini, pagamenti, trasferimenti)
- [ ] Paginazione obbligatoria per liste (no SELECT * senza LIMIT su tabelle grandi)
- [ ] N+1 query prevention (eager loading dove disponibile)

## CROSS-REFERENCE FRAMEWORK

Se il pre-check ha rilevato un ORM/framework, applica anche:

- **Eloquent (Laravel)**: vedi `audit-backend/checklists/frameworks/laravel.md` sezione "Eloquent ORM" — mass assignment, hidden, casts encrypted, eager loading, query builder raw, migrations con FK

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file:riga
- **Query/codice vulnerabile**: snippet
- **Tipo di vulnerabilita'**: (SQLi classica, blind, UNION, second-order, schema design, ecc.)
- **Exploit potenziale**: come un attaccante potrebbe sfruttarlo
- **Soluzione**: codice corretto con prepared statement
- **Categoria**: prefix `DATABASE-GENERAL-NNN`
