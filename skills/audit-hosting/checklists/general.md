# Checklist — Ingegnerizzazione & Hosting (universale)

Sei un DevOps/Systems Engineer. Verifica i punti UNIVERSALI di seguito (validi su qualsiasi hosting). Se sono presenti sub-file di profile-specifici (netsons.md, vercel.md, railway.md, aruba.md), si applicheranno IN AGGIUNTA.

## CHECKLIST UNIVERSALE

- [ ] HTTPS configurato e funzionante (certificato valido, no mixed content)
- [ ] Redirect HTTP -> HTTPS attivo
- [ ] Redirect www <-> non-www coerente (preferenza esplicita, no doppio canonical)
- [ ] Configurazione runtime ottimizzata per produzione:
  - Memory limit appropriato
  - Timeout di esecuzione ragionevole
  - Concurrency / workers dimensionati al carico atteso
- [ ] Caching:
  - Cache applicativa per dati frequentemente acceduti
  - Cache HTTP correttamente configurata (ETag, Cache-Control, Expires)
  - Cache invalidation strategy chiara
- [ ] Compressione e minificazione:
  - Gzip/Brotli abilitato per HTML, CSS, JS, JSON, XML, SVG
  - CSS minificato per produzione
  - JavaScript minificato per produzione
  - Immagini ottimizzate (WebP, AVIF dove supportato)
  - Nessun asset inutilizzato caricato
- [ ] Struttura file:
  - Document root contiene solo file pubblici
  - Vendor, config, log fuori dalla document root (o protetti)
  - Nessun file di sviluppo in produzione (test, fixtures, .git, README, CHANGELOG)
  - .gitignore appropriato
  - Protezione esplicita accesso a file sensibili (.env, .git, composer.json, .sql)
- [ ] Performance generale:
  - Nessuno script lungo che blocca request handling (>30s)
  - Paginazione implementata per liste di dati
  - Lazy loading per contenuti non immediatamente visibili
  - Nessun polling frequente (preferire long-polling, SSE, WebSocket)
  - Background job per operazioni pesanti (no inline su HTTP request)
- [ ] Healthcheck endpoint pubblico (es. `/health`, `/healthz`) per monitoring
- [ ] Monitoring:
  - Error logging configurato e raggiungibile
  - Alert su anomalie (errori 5xx, latenza alta, disco pieno)
- [ ] Deploy:
  - Procedura di deploy documentata e riproducibile
  - Configurazione produzione separata da sviluppo
  - Variabili di ambiente caricate da provider (no .env committato in produzione)
  - Rollback procedure testata
- [ ] Backup & Disaster Recovery:
  - Backup automatico del database
  - Backup file applicativi pianificato
  - Procedura di restore testata e documentata
  - Backup conservato in location separata
  - RTO (Recovery Time Objective) e RPO (Recovery Point Objective) definiti

## CROSS-REFERENCE FRAMEWORK

Se il pre-check ha rilevato un framework con peculiarita' di hosting:

- **Laravel**: vedi `audit-backend/checklists/frameworks/laravel.md` sezione 10 "Configuration & Deploy" — bootstrap/app.php, config:cache, queue worker, no-dev, opcache compatibilita'

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file
- **Problema**: descrizione
- **Impatto performance**: come influisce su CPU/RAM/I/O/latenza
- **Soluzione**: fix con codice/configurazione di esempio
- **Categoria**: prefix `HOSTING-GENERAL-NNN`
