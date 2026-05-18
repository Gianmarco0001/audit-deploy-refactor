# Checklist — Hosting Netsons (profile-specific)

Sei un DevOps/Systems Engineer esperto in ottimizzazione di applicazioni PHP/JS su hosting condiviso Netsons (cPanel, PHP 8.x, MySQL/MariaDB, storage SSD, risorse limitate CPU/RAM/I/O). Questa checklist e' applicata in AGGIUNTA a `general.md`.

## CHECKLIST NETSONS-SPECIFIC

- [ ] Configurazione PHP (php.ini / .user.ini ottimizzato per produzione):
  - OPcache abilitato e configurato (opcache.enable=1, memory_consumption adeguato)
  - Nessun modulo PHP non necessario caricato
  - memory_limit impostato al minimo necessario
  - max_execution_time ragionevole (no script lunghi su shared hosting)
  - upload_max_filesize e post_max_size configurati
  - session.gc_maxlifetime configurato
- [ ] .htaccess ottimizzato:
  - Compressione gzip abilitata
  - Browser caching configurato (Expires/Cache-Control per asset statici)
  - URL rewriting se necessario (mod_rewrite)
  - Protezione directory sensibili (deny from all su /config, /vendor, ecc.)
  - Blocco accesso a file sensibili (.env, .git, composer.json, .sql)
  - ETag configurati correttamente
- [ ] Database performance MySQL su shared hosting:
  - Query ottimizzate (no SELECT *, solo colonne necessarie)
  - Connessioni DB chiuse/rilasciate dopo l'uso
  - Nessuna query pesante senza LIMIT
  - Indici appropriati (verificare con EXPLAIN su query principali)
- [ ] Cache applicativa:
  - File-based o APCu se disponibile
  - Redis/Memcached NON disponibili tipicamente su shared Netsons (valutare alternative file-based)
- [ ] Compatibilita' Netsons:
  - Nessuna dipendenza da servizi non disponibili su shared hosting (Redis, Memcached, queue workers daemon, WebSocket, cron personalizzati oltre cPanel)
  - Verifica versione PHP compatibile col piano Netsons (CRITICO: PHP 8.1 EOL dicembre 2025, usare minimo PHP 8.2, consigliato 8.3+)
  - Spazio disco stimato vs disponibile
  - Nessun uso di funzioni PHP disabilitate su shared hosting (pcntl_*, socket_create, ecc.)
  - Verifica MultiPHP Manager: versione PHP selezionata corretta per il dominio
  - Verificare limiti Netsons specifici: max I/O, entry processes, nproc via cPanel > Resource Usage
- [ ] Cron job:
  - cron configurato via cPanel > Cron jobs
  - Nessun cron pesante durante orari di punta
  - Cron output redirect a `/dev/null` o file di log dedicato per non riempire mailbox
- [ ] Backup & Disaster Recovery Netsons-specific:
  - Script di backup automatico del database (mysqldump via cron cPanel)
  - Verificare se il piano Netsons include backup automatici e relativa retention
  - Backup conservato in location separata (non solo sul server Netsons)
- [ ] Errore 500 prevention (errore piu' comune su Netsons):
  - .htaccess sintatticamente corretto (errore .htaccess = 500 immediato)
  - Permessi file corretti (644 file, 755 directory)
  - memory_limit sufficiente per le operazioni piu' pesanti
  - Nessun timeout PHP su operazioni normali
  - Error log attivo per diagnostica via cPanel > Errors
- [ ] Monitoraggio Netsons:
  - Monitoraggio risorse cPanel impostato per alert
  - Email log errori configurate

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file
- **Problema**: descrizione
- **Impatto su Netsons**: come influisce su limiti del piano (CPU/RAM/I/O/entry processes)
- **Soluzione**: fix con codice/configurazione di esempio
- **Categoria**: prefix `HOSTING-NETSONS-NNN`
