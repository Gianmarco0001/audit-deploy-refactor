# Checklist — Email Deliverability & SMTP (universale)

Sei un esperto di Email Deliverability e configurazione SMTP per applicazioni web. Verifica i punti UNIVERSALI di seguito (validi indipendentemente dal linguaggio backend e dal transport). Se sono presenti sub-file transport-specifici (php-phpmailer.md, node-nodemailer.md, smtp-external.md), si applicheranno IN AGGIUNTA.

## CHECKLIST UNIVERSALE

- [ ] Connessione SMTP autenticata con credenziali dedicate
- [ ] Connessione TLS/SSL (porta 587 STARTTLS o 465 implicit TLS, MAI porta 25 in chiaro)
- [ ] Credenziali SMTP non hardcoded nel codice (da env var o secret manager)
- [ ] Timeout SMTP configurato per non bloccare l'esecuzione HTTP request
- [ ] Deliverability:
  - Indirizzo mittente (From) coerente con il dominio del sito
  - Reply-To configurato se diverso dal From
  - SPF record DNS configurato per autorizzare il server a inviare per il dominio
  - DKIM configurato (chiave DNS, firma uscente)
  - DMARC record DNS configurato (almeno `p=none` per monitoraggio iniziale, poi `quarantine` o `reject`)
  - BIMI valutato per brand visibility (richiede DMARC reject + certificato VMC)
  - Nessun invio massivo da hosting condiviso senza permesso del provider
- [ ] Gestione errori email:
  - Errori di invio gestiti con try/catch e logging
  - Utente informato se l'email non e' stata inviata (es. 'Riprova piu' tardi')
  - Nessun dato sensibile nel corpo email in chiaro (password temporanee ok, mai password permanenti)
- [ ] Sicurezza email — header injection:
  - Validare che input utente non contenga `\r\n` nei campi email
  - Campi To, CC, BCC NON manipolabili da input utente
  - Subject/From sanitizzati
- [ ] Rate limiting su funzionalita' che inviano email (reset password, contatto, inviti, registrazione)
- [ ] CAPTCHA su form di contatto per prevenire spam relay
- [ ] Template email:
  - Email in formato HTML con fallback text/plain
  - Nessun contenuto dinamico non sanitizzato nei template email
  - Link nel corpo email con HTTPS
  - List-Unsubscribe header per email di marketing/newsletter (RFC 2369, requisito Gmail/Yahoo bulk sender 2024+)
  - Unsubscribe one-click (RFC 8058) supportato per bulk
- [ ] Funzionalita' email comuni:
  - Se presente registrazione: email di conferma/verifica account
  - Se presente reset password: email con token monouso e scadenza breve
  - Se presente form contatto: email al proprietario + conferma all'utente
  - Se presente newsletter: double opt-in obbligatorio (GDPR)
- [ ] Bounce handling:
  - Indirizzo di Return-Path configurato e monitorato
  - Hard bounce -> sospensione invio futuro a quell'indirizzo
  - Soft bounce -> retry con backoff

## CROSS-REFERENCE FRAMEWORK

- **Laravel Mail**: vedi `audit-backend/checklists/frameworks/laravel.md` sezione 9 "Storage, Queue, Mail" — Mailable class, ShouldQueue per non bloccare HTTP request

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file:riga
- **Problema**: descrizione
- **Impatto**: cosa succede se non risolto (email in spam, mancata consegna, relay abuse, sanzione GDPR su double opt-in mancante)
- **Soluzione**: fix con codice/configurazione di esempio
- **Categoria**: prefix `EMAIL-GENERAL-NNN`
