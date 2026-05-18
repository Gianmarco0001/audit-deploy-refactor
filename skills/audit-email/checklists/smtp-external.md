# Checklist — Email Provider Esterni (transport-specific)

Sei un esperto di email deliverability con focus su provider transactional/marketing (AWS SES, SendGrid, Mailgun, Postmark, Brevo). Questa checklist e' applicata in AGGIUNTA a `general.md` quando il progetto integra un provider email esterno. Sezione SES validata su AWS doc ufficiale (docs.aws.amazon.com/ses/latest/dg/security-best-practices.html).

## CHECKLIST UNIVERSALE PROVIDER ESTERNI

### Setup base (qualsiasi provider)

- [ ] **API Key / SMTP credentials** in env vars / secrets manager, **MAI** hardcoded
- [ ] **API Key scope minimo**: solo "Mail Send" permission, NO "Full Access" / `admin:*`
- [ ] Rotazione API key periodica (90 giorni raccomandato)
- [ ] **Sender Domain Authentication** (DKIM + SPF) configurata via DNS, NON solo email verification
- [ ] **DMARC** record pubblicato: minimo `p=none` per monitoring, target `p=quarantine` / `p=reject`
- [ ] **Webhook signature verification** (HMAC) PRIMA di processare eventi bounce/complaint
- [ ] DPA (Data Processing Agreement) firmato per compliance GDPR
- [ ] **Sandbox** vs **Production** mode chiaramente identificato (testing isolato da prod)

---

## AWS SES

### 1. IAM & permissions (least privilege)

- [ ] Policy con `ses:SendEmail` + `ses:SendRawEmail` SOLO
- [ ] **MAI** `ses:*` o wildcard `*`
- [ ] Resource ARN ristretto a verified identity specifica:
  ```json
  {
    "Effect": "Allow",
    "Action": ["ses:SendEmail", "ses:SendRawEmail"],
    "Resource": "arn:aws:ses:eu-west-1:123:identity/example.com"
  }
  ```
- [ ] Cross-account: STS AssumeRole con trust policy esplicita
- [ ] IAM role per EC2/Lambda/ECS, no IAM user con access key persistente (se possibile)

### 2. Account & sandbox

- [ ] Sandbox: max 1 msg/s, recipient devono essere verified
- [ ] **Production access** richiesto via AWS Support Console (motivare use case)
- [ ] Verifica `GetAccount` API: `ProductionAccessEnabled: true`

### 3. Verified identities

- [ ] **Domain verification** preferita a email verification (singola)
- [ ] DNS TXT record di verifica preservato in produzione
- [ ] **Easy DKIM**: CNAME records auto-managed (3 record)
- [ ] BYODKIM solo se serve key rotation custom

### 4. DNS records

- [ ] **SPF**: `v=spf1 include:amazonses.com ~all`
- [ ] **DKIM**: 3 CNAME record da SES → DNS (Easy DKIM)
- [ ] **DMARC**: `v=DMARC1; p=quarantine; rua=mailto:dmarc-reports@example.com`
- [ ] **MAIL FROM domain custom**: subdomain dedicato (es. `bounce.example.com`) per alignment Return-Path
  - MX record verso `feedback-smtp.<region>.amazonses.com`

### 5. Configuration Set & event tracking

- [ ] Configuration Set creato per ogni invio category (transactional, marketing, system)
- [ ] Event publishing abilitato per: `bounces`, `complaints`, `deliveries`, `opens`, `clicks`, `rejections`
- [ ] Destination: SNS topic → Lambda function (gestione bounce DB-side) o Firehose → S3 (analytics)
- [ ] CloudWatch metrics per monitoring real-time

### 6. Bounce & complaint handling

- [ ] **Hard bounce** (5xx): sopprimere utente nel DB, **NO retry**
- [ ] **Soft bounce** (4xx): retry con backoff esponenziale, max 3 retry in 24h
- [ ] **Complaint** (spam report): sopprimere IMMEDIATAMENTE, audit log
- [ ] Sincronizza DB applicativo con SES **Suppression List** (account-level)

### 7. Sending limits & monitoring

- [ ] Sending quota: default 14 msg/s, 50k msg/giorno; request increase tramite AWS Support
- [ ] Rate limiter applicativo (Redis bucket) per non superare quota
- [ ] **Reputation Dashboard**: bounce rate < 5%, complaint rate < 0.1%
- [ ] CloudWatch Alarm su bounce/complaint rate threshold
- [ ] Region scelta: `eu-west-1` (Ireland) o `eu-central-1` (Frankfurt) per IT/GDPR

### 8. SDK

- [ ] **`@aws-sdk/client-sesv2`** (Node.js) o `boto3` (Python) — usa **SESv2** API, non SES classic
- [ ] No SMTP credentials per app AWS: usa IAM role (no Access Key in env)
- [ ] X-Ray tracing per end-to-end diagnostics

---

## SendGrid (Twilio)

> Validata su docs ufficiali Twilio SendGrid: `twilio.com/docs/sendgrid/ui/account-and-settings/api-keys`, `.../how-to-set-up-domain-authentication`, `.../for-developers/tracking-events/event`.

### 1. API Key types & scope (least privilege)

- [ ] **3 tipi API Key**: Full Access, Restricted Access (custom scopes), Billing Access
- [ ] **Scope minimo "Mail Send"** SOLO per app sending (least privilege)
- [ ] Permission granulari: "No Access", "Read Access", "Full Access" per ogni categoria endpoint
- [ ] **Billing API key** SEPARATA da sending API key (compartmentalizzazione)
- [ ] **Limit 100 API Key per account** — monitor sprawl, dedup periodico

### 2. API Key lifecycle

- [ ] **One-time visibility**: la chiave viene mostrata UNA volta, salvata subito in secret manager
- [ ] **No recovery post-creation**: chiave dimenticata → delete + nuova
- [ ] **Delete = permanent**: API call con chiave deleted ritornano errore (no riattivazione)
- [ ] **Rotation workflow**: create new key → replace in code → delete old (NO inversione di ordine)
- [ ] Edit name/permissions post-creation possibile senza regenerare chiave
- [ ] **Length 69 caratteri**: verifica che secret manager / Vault supporti la lunghezza (alcuni hanno cap)

### 3. Storage & accesso

- [ ] **MAI** API Key in client-side JavaScript / `NEXT_PUBLIC_*` / bundle frontend
- [ ] **Env vars** server-side (no hardcoded, no version control)
- [ ] Sub-User: **2FA** obbligatorio + **IP Access Management** se feature disponibile
- [ ] **Audit trail**: log creazione / modifica / deletion API key per compliance
- [ ] **Staging vs Production keys SEPARATE** con permission diverse per environment
- [ ] **No permission escalation**: utente non puo' creare API key con permission > propri (limit nativo SendGrid)
- [ ] **Quarterly review**: audit chiavi attive, deletion delle inutilizzate

### 4. Sender Authentication

- [ ] **Domain Authentication** OBBLIGATORIA per produzione (verifica legittimita' server mail via DNS)
- [ ] **Automated Security** (default): SendGrid gestisce DKIM/SPF via CNAME (richiede DNS provider con supporto underscore)
- [ ] **DNS records minimi (4)**: 1 CNAME mail routing `em####.domain.com`, 2 CNAME DKIM (`s1._domainkey`, `s2._domainkey`), 1 TXT DMARC
- [ ] **Manual Security alternative** (se DNS provider non supporta underscore): MX + 3 TXT (SPF/DKIM/DMARC), update manuale su aggiunta IP
- [ ] **Propagation DNS**: fino a 48h, verifica records PRIMA di sending production
- [ ] **Link Branding**: 2 CNAME aggiuntivi per click tracking domain custom (rimuove "via sendgrid.net" nei link)
- [ ] **Single Sender Verification**: SOLO per dev/test (limit 100 email/giorno), **MAI** in produzione
- [ ] **Custom return-path subdomain** per bounce/unsubscribe handling
- [ ] **Reverse DNS (PTR)** per IP dedicato (configurazione separata)
- [ ] **EU-pinned domain** se compliance EU richiede storage/processing in EU
- [ ] Custom DKIM selector se altro servizio occupa default `s` selector (3 char identifier)
- [ ] **Limiti account**: max 3000 authenticated domains, 3000 link brandings per user/subuser

### 5. Event Webhook (signed)

- [ ] Webhook configurato per eventi: `processed`, `dropped`, `delivered`, `deferred`, `bounce`, `open`, `click`, `spamreport`, `unsubscribe`, `group_unsubscribe`, `group_resubscribe`
- [ ] **Signed Event Webhook** con **ECDSA verification key** in produzione (non solo plaintext POST)
- [ ] **Signature validation**: header `X-Twilio-Email-Event-Webhook-Signature` (HMAC ECDSA)
- [ ] **Timestamp validation**: header `X-Twilio-Email-Event-Webhook-Timestamp` per prevenire replay attack
- [ ] **Endpoint idempotente**: dedup via campo `sg_event_id` (URL-safe, max 100 chars)
- [ ] **Auto-retry**: SendGrid riprova su response non-2xx (gestione side effect)
- [ ] **Bounce types**: distinguere `Invalid Address`, `Technical`, `Content`, `Reputation`, `Frequency/Volume`, `Mailbox Unavailable`, `Unclassified`
- [ ] **Hard vs Soft**: `"type": "bounce"` (hard), `"type": "blocked"` (soft)
- [ ] **Message correlation**: usa `sg_message_id` (da `smtp-id`); bounce ritardati possono mancare di questo campo
- [ ] **PII protection**: MAI memorizzare PII in `custom_args` / `unique_args` (SendGrid NON li tratta come PII)
- [ ] **Machine opens**: flag `sg_machine_open: true` per identificare Apple Mail Privacy Protection (no real engagement)
- [ ] **Account status events**: monitor `account_status_change` con type `compliance_suspend`/`compliance_deactivate`/`compliance_ban`/`reactivate`

### 6. IP Pool & deliverability

- [ ] **Dedicated IP** (Pro+) per high-volume sender; warmup graduale 3 settimane
- [ ] **Shared IP**: ok per low volume (<10k/mese), no controllo reputazione
- [ ] IP allowlist su API Key per restringere uso da IP server applicativo
- [ ] Reverse DNS (PTR) configurato per IP dedicato

### 7. Compliance & API

- [ ] `List-Unsubscribe` header automatico per marketing email (RFC 8058 one-click)
- [ ] **Unsubscribe groups** configurati per categorie (transactional/marketing/newsletter)
- [ ] **Suppression management API** per sync DB applicativo ↔ SendGrid
- [ ] **Mail Send API v3** (REST JSON) preferita a SMTP relay legacy
- [ ] **Dynamic Templates** con sanitization PRIMA del send (no input utente non sanitizzato in variabili)
- [ ] Versione library SDK aggiornata (`@sendgrid/mail` v8+, `sendgrid-python` v6+)
- [ ] **Test pre-deploy**: cURL con Bearer token, verifica `202 Accepted` response

---

## Mailgun

### 1. API Key & domains

- [ ] **Private API Key** (admin) NON usata per send (usa "Sending API Key" se disponibile)
- [ ] **Region**: scegliere **EU** (`api.eu.mailgun.net`) per GDPR (storage in EU)
- [ ] Domain registered e DNS records (SPF + DKIM + MX + tracking CNAME) propagati
- [ ] **API v3 vs v4**: verificare versione endpoint in uso (v3 legacy vs v4 modern, impatto su retry/error handling)
- [ ] **Sending domain vs tracking domain**: configurati SEPARATI; tracking domain CNAME per click/open analytics
- [ ] **Region API endpoint** hardcoded coerente: prod EU → `api.eu.mailgun.net`, US → `api.mailgun.net`

### 2. Webhook & events

- [ ] Webhook URL configurato per: `permanent_fail`, `temporary_fail`, `complained`, `unsubscribed`, `delivered`
- [ ] **HMAC verification**: `X-Mailgun-Signature` header validato
- [ ] Webhook idempotency: deduplicare per `event-id`
- [ ] **Webhook retry policy**: Mailgun retry per 48h con backoff → endpoint MUST essere idempotente
- [ ] Inbound routes (se usate): valida security (parsing email, spam evasion via reply injection)
- [ ] SMTP credentials inbound separate dalla Sending API Key, rotation periodica

### 3. Sending limits, IP pool & analytics

- [ ] **Sending limits**: default illimitato business plan, verificare throttle su account free; implementare rate limiter applicativo
- [ ] **Inactive recipients**: account inattivi (90+ giorni) disabilitati automaticamente, monitorare bounce rate
- [ ] **IP pool**: dedicato vs shared; se dedicato → warmup graduale 2-3 settimane
- [ ] **Reputation monitoring** via Mailgun dashboard (bounce/complaint rate)
- [ ] **Tag strategy**: assegnare tags per categoria (transactional, marketing, system) per segmentare analytics

### 4. Suppression & validation

- [ ] Bounces / Unsubscribes / Complaints accessibili via API
- [ ] Sync DB applicativo con Mailgun suppression via cron job (almeno 1x/giorno)
- [ ] Manual unsubscribe rimozione possibile (per supporto utente)
- [ ] **Email list validation**: endpoint `/v4/address/validate` (freemium) PRE-send per bounce prevention
- [ ] **Compliance**: `List-Unsubscribe` header NON aggiunto automaticamente, va implementato app-side per bulk
- [ ] **Data residency**: EU tier → storage + processing in EU, DPA firmato per GDPR art.28

### 5. Templates

- [ ] **Template syntax**: variabili `{{varName}}`; **escape HTML obbligatorio** per input utente nelle variabili (prevenzione XSS in email)
- [ ] **Template versioning**: Mailgun NON ha versioning nativo → gestire schema versioned nel DB applicativo

---

## Postmark

### 1. Server token vs Account token

- [ ] **Server Token**: per send transactional (scope server) — 1 server = 1 token, limite 100 req/s
- [ ] **Account Token**: solo per management (creare server, gestire signatures), **MAI** per send
- [ ] Token in env var, mai committed
- [ ] **Rate limits**: 100 req/s per Server Token, **batch API** (100 msg/batch) per bulk send

### 2. Message Streams

- [ ] **Transactional** stream (1:1, triggered) separato da **Broadcast** stream (bulk marketing)
- [ ] Transactional **MAI** usato per marketing (Postmark **blocca account** su abuse)
- [ ] Broadcast richiede approval Postmark per uso
- [ ] **Stream selection esplicita** in ogni `MessageStream: 'outbound'` API call (no default implicito)
- [ ] Audit: stream assignment coerente con il tipo di traffico

### 3. Sender Signatures & DKIM

- [ ] **Sender Signature** per ogni dominio sender (DKIM auto-managed da Postmark)
- [ ] **Una signature per stream** (Transactional ≠ Broadcast → signatures separate)
- [ ] **DKIM key rotation**: Postmark supporta auto-rotation, pianifica rotazione (es. ogni 6 mesi)
- [ ] **Return-Path domain** separato da `From` per allineamento DMARC `p=reject`

### 4. Templates & Layouts

- [ ] **Template versions**: Postmark NON versiona templates → mantieni JSON schema versioned in DB per rollback
- [ ] **Template layouts**: shared base layout per branding (parent-child relationship)
- [ ] **Template variables**: object nesting supportato; **sanitize input** PRIMA di render (no template injection / XSS)
- [ ] Test su staging stream prima di promote a prod template

### 5. Bounce / SpamComplaint webhook

- [ ] Webhook endpoint con HMAC signature verification
- [ ] Auto-suppression su `HardBounce`, `SpamComplaint`
- [ ] **Bounce types**: `HardBounce` (invalid → sopprimere), `Transient` (temp fail → retry), `Subscribed` (feedback loop), `SpamComplaint` (sopprimere immediato), `ChallengeVerification`
- [ ] **Spam complaint threshold**: Postmark auto-stops account se complaint rate supera soglia → monitor dashboard
- [ ] **Suppression list scope**: account-wide; server-specific suppression sync via API

### 6. Inbound processing

- [ ] **Inbound domain config**: MX record verso Postmark
- [ ] Webhook parsing JSON email content (no SMTP)
- [ ] **Inbound rules (triggers)**: regex-based filtering PRE webhook dispatch, testare su sample
- [ ] Validazione origin IP / shared secret se inbound auth richiesta

### 7. Activity API & monitoring

- [ ] **Activity API**: stats per message stream (bounces, opens, clicks, spam complaints)
- [ ] **Outbound message search**: debug via API MessageID; **retention 45 giorni**
- [ ] **Webhook payload retention**: 24h se delivery fallisce → implementare retry + dead-letter handling
- [ ] **Webhook delivery retry**: exponential backoff 24h, idempotency key per deduplicazione

---

## Brevo (ex Sendinblue) — provider IT-friendly

> Validata su developers.brevo.com/docs/getting-started.

### 1. Authentication & API key

- [ ] **API Key** generata da account admin Brevo, scope minimo, rotation periodica
- [ ] **REST API v3** preferita a SMTP legacy per email transazionali
- [ ] **MAI** API Key committed in repo, sempre da env var / secret manager
- [ ] SMTP credentials separate da API key (se usi entrambi)

### 2. Sender Authentication

- [ ] **SPF / DKIM / DMARC** configurati su dominio mittente (verifica in dashboard Brevo)
- [ ] **Dedicated IP** valutato se volume > 100k email/mese (isolare reputazione)
- [ ] **Sender Authentication** completata e verificata in dashboard PRIMA del go-live

### 3. Webhook events

- [ ] Webhook abilitato per: `bounces` (hard/soft), `complaints`, `unsubscribes`, eventi transazionali (`delivered`, `opened`, `clicked`)
- [ ] Endpoint webhook **HTTPS** obbligatorio + timeout 15-30s
- [ ] Retry logic Brevo configurato (settings panel)
- [ ] **Signature verification** webhook (se supportata) per validare origine
- [ ] Endpoint idempotente (dedup per event ID)

### 4. Suppression list & compliance

- [ ] **Suppression List API** sincronizzata con DB applicativo (bounce/complaint auto-managed)
- [ ] Unsubscribe list rispettata: NO re-invio a contatti opt-out
- [ ] **DPA (Data Processing Agreement)** firmato con Brevo per dati UE (GDPR art.28)
- [ ] **Data residency EU**: Brevo storage su server europei (verifica in account settings)

### 5. Templates & rate limits

- [ ] **Templating API** usata per contenuti dinamici (variabili `{tags}`, condizionali)
- [ ] Test template rendering pre-deploy con dati reali (no template injection / XSS)
- [ ] **Rate limit handling**: backoff esponenziale su HTTP 429
- [ ] Monitor quota residua via response headers
- [ ] Free tier: 300 email/giorno, scalabile a piani higher-volume
- [ ] **Monitoring**: bounce rate < 5%, complaint rate < 0.1% (dashboard Brevo)

---

## CRITERI DI SCELTA PROVIDER

| Use case | Provider raccomandato |
|----------|----------------------|
| App su AWS, costo basso, technical setup | AWS SES |
| Email transazionali alto volume, semplicita' | Postmark, SendGrid |
| Marketing + automation | SendGrid, Mailgun, Brevo |
| GDPR strict (storage EU) | AWS SES EU, Mailgun EU, Brevo |
| Failover / multi-provider | combinazione 2 provider con fallback (resilienza) |

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: `path/to/mail-service.js:riga` o config (env, terraform)
- **Provider**: SES / SendGrid / Mailgun / Postmark / Brevo
- **Problema**: descrizione
- **Soluzione**: fix con esempio
- **Categoria**: prefix `EMAIL-SES-NNN`, `EMAIL-SENDGRID-NNN`, `EMAIL-MAILGUN-NNN`, `EMAIL-POSTMARK-NNN`, `EMAIL-BREVO-NNN`

## RIFERIMENTI

- AWS SES Security Best Practices: <https://docs.aws.amazon.com/ses/latest/dg/security-best-practices.html>
- SendGrid Sender Authentication: <https://www.twilio.com/docs/sendgrid/ui/account-and-settings/how-to-set-up-domain-authentication>
- Mailgun Best Practices: <https://www.mailgun.com/blog/email/email-best-practices/>
- Postmark Streams: <https://postmarkapp.com/developer/user-guide/message-streams>
- Brevo (Sendinblue) API: <https://developers.brevo.com/>
