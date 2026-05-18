# Checklist — Email Provider Esterni (transport-specific) — STUB

> **TODO**: contributi benvenuti — vedi [CONTRIBUTING.md](../../../../CONTRIBUTING.md).

Questa checklist e' attualmente vuota. La detection in `audit-email/SKILL.md` la attiva quando rileva SDK provider esterni: `@aws-sdk/client-ses`, `boto3` ses, `@sendgrid/mail`, `sendgrid` (python), `mailgun.js`, `mailgun-python`, `postmark`.

## Topic suggeriti per la prima versione

### AWS SES

- IAM policy minima (solo `ses:SendEmail`, mai `ses:*`)
- Sandbox vs Production access (richiesta esplicita ad AWS per uscire dalla sandbox)
- Verified domains/identities configurati
- Configuration Set per tracking bounces/complaints via SNS
- AWS Region scelta sensata per latency (eu-west-1 per IT)
- Suppression list dedicata vs account-level

### SendGrid

- API Key con scope minimo (Mail Send only, no Full Access)
- Sender Authentication (Domain Authentication + Link Branding)
- Event Webhook configurato per bounces/spam reports
- Versione SDK aggiornata

### Mailgun

- API Key (non Private API Key se non serve), regione EU per GDPR
- Sender domain DNS records (SPF, DKIM, MX, CNAME tracking)
- Webhook per events

### Postmark

- Server token vs Account token (scope appropriato)
- Message Streams (Transactional vs Broadcast separati)
- Bounce/SpamComplaint webhook

### Universali

- Provider scelto in base a volume + compliance richiesta (GDPR: SES Frankfurt o Mailgun EU)
- DPA (Data Processing Agreement) firmato
- Webhook signature verification (HMAC) PRIMA di processare eventi
- Failover/fallback transport se principale fallisce

## FORMATO REPORT

- **Categoria**: prefix `EMAIL-EXTERNAL-NNN` (poi `-SES-`, `-SENDGRID-`, ecc.)
