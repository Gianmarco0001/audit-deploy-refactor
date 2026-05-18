# Checklist — Email Nodemailer (transport-specific)

Sei un esperto di email deliverability con focus su Node.js. Questa checklist e' applicata in AGGIUNTA a `general.md` quando `package.json` contiene `nodemailer`. Validata su Nodemailer ufficiale (nodemailer.com).

## CHECKLIST NODEMAILER

### 1. Transport creation

- [ ] **`pool: true`** per riutilizzo connessione SMTP (evita overhead handshake per ogni email):
  ```js
  const transport = nodemailer.createTransport({
    pool: true,
    host: 'smtp.example.com',
    port: 587,
    secure: false,
    requireTLS: true,
    auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS }
  });
  ```
- [ ] **`maxConnections`** configurato (default 5; tipicamente 5-10 per server SMTP normali)
- [ ] **`maxMessages`** (default 100 per connessione) → forza reconnect dopo N messaggi

### 2. Authentication

- [ ] Credenziali SMTP da **env vars** (`process.env.SMTP_USER`, `process.env.SMTP_PASS`), MAI hardcoded
- [ ] Login type: `'login'` (PLAIN/LOGIN AUTH); altri: `'oauth2'` per Gmail / M365, `'cram-md5'` legacy
- [ ] OAuth2: refresh token / access token gestiti separatamente, no client secret hardcoded

### 3. Encryption & TLS

- [ ] **Porta 465**: `secure: true` (implicit TLS dalla connessione)
- [ ] **Porta 587**: `secure: false` + `requireTLS: true` (STARTTLS upgrade dopo handshake)
- [ ] **MAI** porta 25 (no encryption, spesso bloccata dai provider) in produzione
- [ ] **`tls.rejectUnauthorized: true`** OBBLIGATORIO in produzione (verifica certificato)
- [ ] **MAI** `tls.rejectUnauthorized: false` (apre a MITM)
- [ ] `tls.minVersion: 'TLSv1.2'` minimo

### 4. Verifica connessione al boot

- [ ] **`transport.verify()`** al startup app → fail-fast se SMTP non raggiungibile:
  ```js
  transport.verify().then(() => console.log('SMTP ready'))
    .catch(err => { console.error('SMTP unreachable', err); process.exit(1); });
  ```
- [ ] Healthcheck periodico (cron / healthz endpoint) per rilevare degradazione

### 5. Send email — async patterns

- [ ] **`await transport.sendMail(...)`** o `.then().catch()`, **MAI** fire-and-forget
- [ ] Try/catch esplicito attorno a `sendMail`:
  ```js
  try {
    const info = await transport.sendMail({...});
    logger.info({messageId: info.messageId}, 'sent');
  } catch (err) {
    logger.error({err}, 'send failed');
    // retry logic, dead-letter queue
  }
  ```
- [ ] **Retry**: su error 4xx (temporanei: 421 timeout, 450 mailbox unavailable, 451 local error) con backoff esponenziale
- [ ] **NO retry**: su error 5xx (permanenti: 550 invalid recipient, 551 not local, 553 syntax)
- [ ] Queue async (BullMQ, BeeQueue, AWS SQS) per high-volume → no blocking HTTP request handler

### 6. Header injection prevention

- [ ] Input utente nei campi `from`/`to`/`cc`/`bcc`/`subject` validato:
  - NO `\r`, `\n` nei valori (header injection)
  - Validazione email lato app (regex o `validator` package)
- [ ] **MAI** concatenare input utente nel raw header

### 7. Templates email

- [ ] **HTML + text/plain** fallback obbligatorio (gmail spam score, accessibility)
- [ ] Engine: `nodemailer-handlebars`, `email-templates`, `mjml` (per design responsive)
- [ ] Variabili template sanitizzate (HTML escape per HTML version, no HTML in text version)
- [ ] Link nel body: HTTPS only, no http:// links
- [ ] **`List-Unsubscribe` header** per email marketing (RFC 2369, requisito Gmail/Yahoo bulk sender 2024+)
- [ ] **`List-Unsubscribe-Post`** per one-click unsubscribe (RFC 8058)

### 8. DKIM signing inline (opzionale)

- [ ] Se MTA esterno non firma DKIM, configurare DKIM in Nodemailer:
  ```js
  dkim: {
    domainName: 'example.com',
    keySelector: '2024',
    privateKey: process.env.DKIM_PRIVATE_KEY
  }
  ```
- [ ] Chiave DKIM in env var / secret manager, mai committed
- [ ] **DNS record DKIM** pubblicato: `2024._domainkey.example.com TXT "v=DKIM1; k=rsa; p=..."`

### 9. From/Sender alignment

- [ ] `from` header con dominio **autorizzato da SPF**: include `_spf.example.com TXT "v=spf1 include:sendgrid.net ~all"`
- [ ] `Reply-To` opzionale ma raccomandato se `from` e' no-reply
- [ ] `envelope.from` (Return-Path) puo' differire da `from` header (DMARC alignment loose ok)

### 10. Direct transport vs SMTP relay

- [ ] **MAI** direct transport (`direct: true`, MX direct lookup) in produzione: deliverability terribile, IP non whitelisted
- [ ] **SMTP relay** con servizio reputazione gestita (SES, SendGrid, Mailgun, Postmark, Brevo)
- [ ] Cross-ref: `audit-email/checklists/smtp-external.md` per provider esterni

### 11. AWS SES integration (alternativa SMTP)

- [ ] Se app su AWS, usa **`@aws-sdk/client-sesv2`** invece di Nodemailer SMTP (no SMTP credentials, IAM-based)
- [ ] Nodemailer + SES SMTP: ok ma duplicazione credenziali
- [ ] IAM policy minimo: solo `ses:SendEmail`, `ses:SendRawEmail`

### 12. Dependency & versioning

- [ ] Nodemailer >= **6.10** (security patch recenti)
- [ ] `npm audit` clean nel CI/CD
- [ ] Monitor changelog Nodemailer per breaking changes / CVE

### 13. Logging & monitoring

- [ ] Log `info.messageId`, `info.accepted`, `info.rejected`, `info.response` per audit trail
- [ ] **NO** log di body email (PII, conformita' GDPR)
- [ ] Metriche: send count, error rate, latency p99 → Prometheus / Datadog
- [ ] Alerting su error rate > 5% (provider down o config rotta)

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: `path/to/mail-service.js:riga`
- **Problema**: descrizione
- **Soluzione**: fix con esempio
- **Categoria**: prefix `EMAIL-NODEMAILER-NNN`

## RIFERIMENTI

- Nodemailer: <https://nodemailer.com/>
- Nodemailer SMTP options: <https://nodemailer.com/smtp/>
- Gmail bulk sender requirements: <https://support.google.com/mail/answer/81126>
- Yahoo sender best practices: <https://senders.yahooinc.com/best-practices/>
