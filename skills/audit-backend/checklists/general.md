# Checklist — Backend Integrity (universale)

Sei un Senior Backend Developer specializzato in code quality e best practices. Esegui un audit del codice backend del progetto verificando i punti UNIVERSALI di seguito (non legati a uno specifico linguaggio). Se sono presenti sub-file stack-specifici (php.md, node.md, python.md, go.md, frameworks/*.md), si applicheranno IN AGGIUNTA a questi check.

## CHECKLIST UNIVERSALE

- [ ] Validazione e sanitizzazione di TUTTI gli input utente PRIMA dell'uso (query string, body, headers, cookies, file upload)
- [ ] Nessun input utente passato direttamente a comandi shell, query SQL, query NoSQL, parser XML/YAML/JSON senza sanitizzazione
- [ ] Error handling strutturato (eccezioni tipizzate, try/catch al livello appropriato, no errori silenziati)
- [ ] Nessun debug output lasciato nel codice (var_dump, print_r, console.log, dd, debugger, ecc.) in produzione
- [ ] Gestione degli ambienti (dev/staging/prod):
  - Variabili di configurazione separate per ambiente
  - Nessun flag DEBUG=true raggiungibile in produzione
  - Nessuna pagina di info (phpinfo, status, /actuator) accessibile in produzione
- [ ] Logging strutturato in produzione:
  - Log in formato strutturato (JSON) per analisi
  - Log separati per livello (ERROR, WARNING, INFO)
  - Nessun dato sensibile nei log (password, token, dati personali, PAN carte)
  - File di log fuori dalla document root e non accessibili via web
  - Rotazione log configurata per non riempire lo spazio disco
- [ ] Gestione corretta degli upload file:
  - Verifica MIME type reale (magic bytes / file signature), non fidarsi del MIME inviato dal client
  - Whitelist estensioni ammesse (mai blacklist)
  - Protezione da double extension bypass (es. exploit.php.jpg) e case sensitivity bypass (es. file.pHp)
  - Rinominare i file caricati con nome random (mai usare il nome originale)
  - Directory upload fuori dalla document root o con protezione esecuzione codice
  - Dimensione massima configurata
- [ ] Nessun path traversal possibile (verifica che i path non contengano `..` / `%2e%2e`)
- [ ] Nessun file di configurazione con credenziali hardcoded (DB password, API keys, secret)
- [ ] File di config (.env, config.yaml, application.properties) fuori dalla document root o protetti da .htaccess/server config
- [ ] Nessun file di backup (.bak, .old, .sql, .zip, .tar.gz) nella document root
- [ ] Dipendenze:
  - Lock file presente (composer.lock, package-lock.json, poetry.lock, go.sum)
  - Nessuna vulnerabilita' nota dichiarata dai tool ufficiali (composer audit, npm audit, pip-audit, go list -m -u)
  - Dipendenze top-level verificate (autore, download, ultima pubblicazione, no typo-squatting)

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file:riga
- **Problema**: descrizione concisa
- **Soluzione**: fix raccomandato con esempio di codice
- **Categoria**: prefix `BACKEND-GENERAL-NNN`
