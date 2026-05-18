# Checklist — Email Nodemailer (transport-specific) — STUB

> **TODO**: contributi benvenuti — vedi [CONTRIBUTING.md](../../../../CONTRIBUTING.md).

Questa checklist e' attualmente vuota. La detection in `audit-email/SKILL.md` la attiva quando `package.json` contiene `nodemailer`.

## Topic suggeriti per la prima versione

- `createTransport` con `pool: true` per riuso connessione SMTP
- Auth: `user`/`pass` da env, mai hardcoded
- `secure: true` per porta 465, `requireTLS: true` per 587 (STARTTLS)
- `tls.rejectUnauthorized: true` in produzione (mai disabilitare cert verify)
- Versione Nodemailer (>= 6.10 per fix recenti)
- Rate limiting interno: `maxConnections`, `maxMessages`
- Errori SMTP gestiti con try/catch + retry su 4xx, no retry su 5xx
- Async/await coretto, no fire-and-forget di `transport.sendMail`
- Template: nodemailer-handlebars o email-templates per HTML+text version
- DKIM signing inline (`opts.dkim`) opzionale se non firmato dal MTA

## FORMATO REPORT

- **Categoria**: prefix `EMAIL-NODEMAILER-NNN`
