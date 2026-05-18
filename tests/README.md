# Tests — audit-deploy-pack

Test di non-regressione per garantire compatibilità retro al 100% rispetto al v1 (`audit-deploy-plugin-main/`) e correttezza dello split delle checklist.

## Cosa contiene

- `fixtures/legacy-php-mysql-netsons/` — mini progetto PHP+MySQL+Netsons buggato con difetti noti (SQLi classica, mail() nativo, password hardcoded, no MIME check, no CSRF). Serve da target per test funzionale `/audit-deploy` post-refactor.
- `non-regression/expected-findings.md` — lista scritta a mano dei finding attesi dal v1 sul fixture. Confronta col v2 per verificare zero perdite.
- `non-regression/check-bundle-equivalence.sh` — script bash che verifica che per ogni file v1 splittato in v2, la concatenazione `general.md + <stack>.md` contenga TUTTI i bullet `- [ ]` del file v1 (modulo ordine).

## Come eseguire

### Test 1 — Bundle equivalence (statico, no LLM)

```bash
cd tests/non-regression
bash check-bundle-equivalence.sh
```

Atteso: `OK: zero bullet point del v1 sono andati persi nei bundle v2`.

### Test 2 — Funzionale (richiede installazione + LLM)

```bash
# Installa il plugin v2
cp -r ../skills/* ~/.claude/skills/
cp -r ../commands/* ~/.claude/commands/

# Lancia audit sul fixture
cd fixtures/legacy-php-mysql-netsons/
/audit-deploy
```

Atteso: tutti i finding elencati in `expected-findings.md` sono presenti nel `AUDIT-REPORT.md` generato. Finding aggiuntivi sono accettabili (incremento qualità), perdita di finding NON è accettabile.

## Test fixture: bug noti

Il fixture `legacy-php-mysql-netsons/` contiene intenzionalmente:

| # | File | Bug | Skill che dovrebbe rilevarlo |
|---|------|-----|------------------------------|
| 1 | `login.php` | SQL injection classica (concatenazione `$_POST`) | audit-database, audit-security |
| 2 | `login.php` | Password hardcoded | audit-backend, audit-security |
| 3 | `login.php` | Form senza CSRF token | audit-security |
| 4 | `upload.php` | No MIME check magic bytes, accetta `.php` come immagine | audit-backend, audit-security |
| 5 | `index.php` | `mail()` nativo PHP per inviare email | audit-email |
| 6 | `config.php` | Credenziali DB in chiaro nel codice | audit-backend, audit-security, audit-database |
| 7 | `config.php` | `display_errors = 1` esplicito | audit-backend |
| 8 | `.htaccess` | Non blocca accesso a `.env` o `config.php` | audit-hosting (netsons), audit-security |
| 9 | Tutto | No HTTPS forced, no security headers | audit-security, audit-hosting |
| 10 | Tutto | No charset utf8mb4 nella connessione PDO | audit-database (mysql) |

Totale finding attesi: ~12-15 (alcuni bug sono coperti da più skill via cross-detect, dedup li riduce).
