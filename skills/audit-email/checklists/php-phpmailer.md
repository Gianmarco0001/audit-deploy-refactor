# Checklist — Email PHPMailer / Symfony Mailer (transport-specific)

Sei un esperto di Email per applicazioni PHP. Questa checklist e' applicata in AGGIUNTA a `general.md` quando il transport rilevato e' PHPMailer o Symfony Mailer.

## CHECKLIST PHP TRANSPORT

- [ ] Metodo di invio email:
  - NO uso di `mail()` nativa PHP (inaffidabile, spesso bloccata o limitata su shared hosting, mancanza di SMTP auth)
  - Uso di PHPMailer o libreria equivalente (Symfony Mailer)
  - Libreria installata via Composer (no upload manuale di file PHPMailer)
- [ ] PHPMailer:
  - Versione aggiornata (PHPMailer >= 6.9 per fix CVE storici di email injection)
  - `isSMTP()` configurato (no `isMail()` su shared hosting)
  - `SMTPAuth = true` con username/password
  - `SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS` (porta 587) o `ENCRYPTION_SMTPS` (porta 465)
  - `setFrom()` con dominio coerente al sito
  - `addAddress()` con validazione email lato applicativo
- [ ] Symfony Mailer:
  - DSN configurato da env var: `MAILER_DSN=smtp://user:pass@host:587?encryption=tls`
  - `MessageEvent` listener per logging/audit
- [ ] Configurazione SMTP specifiche:
  - Credenziali in `.env` o config protetto, mai hardcoded
  - Timeout SMTP appropriato
- [ ] Funzionalita' specifiche PHP/Laravel:
  - Queue per invio asincrono (Laravel Queue, Symfony Messenger) per non bloccare la HTTP request
  - In Laravel: `Mail::to(...)->queue(new MyMailable())` invece di `->send()` se possibile
- [ ] Compatibilita' Netsons:
  - Verificare limiti di invio giornalieri/orari del piano hosting
  - Considerare servizio SMTP esterno per volumi elevati (Brevo, Mailgun, SendGrid)
  - Netsons potrebbe bloccare connessioni SMTP verso server esterni non standard: verificare porte aperte

## CROSS-REFERENCE FRAMEWORK

- **Laravel Mail (Mailable + Queue)**: `audit-backend/checklists/frameworks/laravel.md` sezione 9

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file:riga
- **Problema**: descrizione
- **Soluzione**: fix con codice
- **Categoria**: prefix `EMAIL-PHP-NNN`
