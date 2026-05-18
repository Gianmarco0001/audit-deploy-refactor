# Checklist — Hosting Aruba (profile-specific, Plesk-based)

Sei un DevOps engineer esperto in hosting condiviso Aruba (che usa **Plesk** come pannello di controllo, a differenza di Netsons che usa cPanel). Questa checklist e' applicata in AGGIUNTA a `general.md` quando rilevato `.htaccess` + indicatori Plesk (es. struttura `httpdocs/` invece di `public_html/`, presenza pannello Plesk).

Validata su Plesk Administrator Guide ufficiale + Plesk Customer Guide.

## CHECKLIST ARUBA (PLESK)

### 1. Configurazione PHP (`Hosting → [Domain] → PHP Settings`)

- [ ] **`display_errors = Off`** (disabilita esposizione errori in produzione)
- [ ] **`expose_php = Off`** (nasconde versione PHP da header `X-Powered-By`)
- [ ] **`allow_url_fopen = Off`** (disabilita apertura URL remote in `fopen`/`include`)
- [ ] **`allow_url_include = Off`** (disabilita include remoto RFI/LFI)
- [ ] **`memory_limit`** appropriato (64M-256M in base ad app, no troppo aperto)
- [ ] **`max_execution_time`** ragionevole (30s default, aumentare solo se necessario)
- [ ] `post_max_size` e `upload_max_filesize` allineati (es. 20M)
- [ ] **`open_basedir`** restrizione attiva (limita accesso filesystem al docroot)
- [ ] **`disable_functions`** include: `exec`, `passthru`, `shell_exec`, `system`, `proc_open`, `popen`, `curl_exec`, `curl_multi_exec` (se non necessari)
- [ ] **`opcache.enable = On`** (acceleratore bytecode abilitato)
- [ ] Multi-PHP Manager: versione PHP selezionata corretta per il dominio (PHP 8.2+ minimo, 8.3+ raccomandato)
- [ ] `php_admin_value` lock-down: utente NON puo' overridare via .htaccess

### 2. SSL/TLS (`Hosting → [Domain] → SSL/TLS Certificates`)

- [ ] **Let's Encrypt** abilitato (gratuito, auto-renewal) per il dominio
- [ ] **"Redirect HTTP to HTTPS"** attivo
- [ ] **HSTS** abilitato con `max-age >= 31536000` (1 anno)
- [ ] **HSTS preload** se possibile (submission a hstspreload.org)
- [ ] Certificato NON self-signed in produzione
- [ ] Plesk panel stesso accessibile via HTTPS (`Server Administration → Securing Plesk`)
- [ ] **TLS 1.2+** obbligatorio, disabilitare TLS 1.0/1.1 (`Tools & Settings → SSL/TLS`)
- [ ] **SSL It!** extension installato per management certificati avanzato

### 3. Web Application Firewall (`Server Administration → ModSecurity`)

- [ ] **ModSecurity** abilitato per il dominio
- [ ] **Atomic Rule Sets** attivati (OWASP CRS)
- [ ] **Modalita' "Block"** (non solo log)
- [ ] Rules custom escluse / whitelist per false-positive verificate

### 4. Brute force protection (`Server Administration → Protection Against Brute Force Attacks`)

- [ ] **Fail2Ban** abilitato
- [ ] IP whitelist configurata (es. ufficio, VPN aziendale)
- [ ] Limiti default: 5 tentativi falliti → ban 600s (regolabili)
- [ ] Jails attivate: SSH, Plesk panel, WordPress login, mail (Postfix/Dovecot)
- [ ] **Plesk Firewall** extension abilitata (se piano hosting Aruba lo include)

### 5. Backup (`Backup Manager` Plesk)

- [ ] **Backup schedule** configurato (giornaliero, ore notturne 2-4 AM)
- [ ] **Incremental backup** abilitato (riduce storage e tempo)
- [ ] **Remote storage** configurato: S3, Google Drive, OneDrive (NON solo backup locale)
- [ ] Backup include: **Websites + Database + Mail**
- [ ] **Retention policy**: es. 30 backup giornalieri, 12 mensili
- [ ] **Test restore** mensile per verificare integrita'
- [ ] Backup encrypted se contiene PII / dati sensibili (PCI-DSS, GDPR)

### 6. Email — Antispam (`Mail → Antispam Tools`)

- [ ] **SpamAssassin** abilitato server-wide
- [ ] Score soglia configurato (es. 5.0 = spam, action = move to spam folder o quarantine)
- [ ] **DKIM** abilitato (`Mail → DKIM`); verifica DNS record DKIM presente
- [ ] **SPF** record DNS: `v=spf1 a mx include:_spf.aruba.it ~all` (o include specifico Aruba)
- [ ] **DMARC** record DNS: `v=DMARC1; p=quarantine; rua=mailto:dmarc@example.com` (almeno `p=none` per monitoring iniziale)
- [ ] **Greylisting** abilitato per ridurre spam (Linux)
- [ ] **Outbound Spam Protection**: rate limit per account (es. 100 email/ora, dipende piano Aruba)
- [ ] Black/Whitelist IP configurate

### 7. Mail transport (`Mail → Server-Wide Mail Settings`)

- [ ] **Postfix** configurato correttamente
- [ ] **Smart Host/Relay Host** se SMTP esterno richiesto (es. SendGrid, Brevo)
- [ ] **TLS SMTP obbligatorio** per connessioni in uscita
- [ ] **Submission port 587** (STARTTLS) abilitata, port 465 (SMTPS) opzionale
- [ ] Port 25 outbound: tipicamente bloccata (uscita relay solo via submission)

### 8. Database (`Database Servers` + `Hosting → Databases`)

- [ ] Password admin database **>= 12 caratteri**, mix maiusc/minusc/numero/special
- [ ] DB user con password **>= 8 chars**, NON admin root per l'applicazione
- [ ] **Remote Access to Databases** disabilitato se non necessario
- [ ] Se accesso remoto necessario: limitato a IP specifici via firewall
- [ ] **Secure connection (SSL)** per MySQL remoto
- [ ] **NO wildcard user** per database (es. `user@'%'`); usa `user@'localhost'` se possibile
- [ ] Backup DB incluso nei backup automatici (escludi `mysql`, `information_schema`)
- [ ] Versione MySQL/MariaDB recente (8.0+ / 10.6+); Plesk supporta multi-version

### 9. File permissions & hardening

- [ ] **Hosting ownership**: admin account dedicato (NON `www-data`/`apache` shared)
- [ ] **`.htaccess`**: `Options -Indexes` per disabilitare directory listing
- [ ] **Account Isolation** verificata (ogni account isolato in chroot)
- [ ] Permessi: 644 file, 755 directory, 600 config con credentials
- [ ] **`Tools & Settings → Security → Fix file permissions`** dopo migrazione

### 10. Web Server hardening (`Web Servers` Plesk)

- [ ] **Apache**: ModRewrite abilitato per `.htaccess`
- [ ] **Apache Settings**: `ServerTokens Prod` (no Apache version in header)
- [ ] **Trace method** disabilitato (`Options -Trace` o `TraceEnable off`)
- [ ] **nginx** (se usato come proxy davanti ad Apache): `server_tokens off`
- [ ] **HTTP/2** abilitato per performance (se Aruba supporta)
- [ ] Custom security headers configurati via `.htaccess` o nginx vhost:
  - `Strict-Transport-Security: max-age=31536000`
  - `X-Content-Type-Options: nosniff`
  - `X-Frame-Options: DENY` o `SAMEORIGIN`
  - `Content-Security-Policy` configurato

### 11. DNS (`Tools & Settings → DNS Template Settings`)

- [ ] **DNSSEC** abilitato per dominio (se supportato dal piano Aruba)
- [ ] DNS records: A, AAAA, MX, SPF, DKIM, DMARC, CAA configurati
- [ ] **CAA record**: `0 issue "letsencrypt.org"` (autorizza solo Let's Encrypt)
- [ ] **Zone transfer (AXFR)** ristretto (non aperto a `*`)
- [ ] TTL ragionevoli (300-3600s per record critici, no troppo lunghi)

### 12. Cron / Scheduled Tasks (`Tools & Settings → Scheduled Tasks`)

- [ ] Cron user corretto (NON root, dedicato al dominio)
- [ ] **Absolute path** per script (es. `/var/www/vhosts/example.com/httpdocs/cron.php`)
- [ ] Cron output redirect a log file: `>> /var/log/cron-example.log 2>&1` (evita spam mailbox)
- [ ] Cron stagger / not all-on-the-hour (evita load spike)
- [ ] PHP path corretto: `/opt/plesk/php/8.2/bin/php` (NON `/usr/bin/php` che e' default OS)

### 13. Logging (`Hosting → [Domain] → Logs`)

- [ ] Access log e error log abilitati
- [ ] **Log Rotation** giornaliera con compress vecchi log
- [ ] Log level **error/warning** per produzione (no `debug`)
- [ ] Log accessibili via FTP/SSH o Plesk File Manager
- [ ] Centralizzazione esterna se compliance richiede (rsyslog, Datadog agent)

### 14. Plesk Admin Security (`Tools & Settings → Security`)

- [ ] **Default admin username** cambiato (non `admin`)
- [ ] **Password Strength Policy**: minimo 12 chars, complesso (maiusc+numero+special)
- [ ] **MFA (Multi-Factor Authentication)** abilitato per admin account
- [ ] **Restricting Admin Access**: IP allowlist per pannello admin se possibile
- [ ] **Session timeout**: auto-logout dopo 30 min inattivita'
- [ ] Plesk update automatico abilitato (security patch timely)

### 15. Compliance & GDPR

- [ ] **PCI DSS Compliance**: se applicabile (ecommerce), segui Plesk PCI checklist
- [ ] Backup **encrypted** se contengono dati sensibili (credit card, PII)
- [ ] **Log retention** conforme GDPR (6-12 mesi, no oltre)
- [ ] Privacy: Plesk Server Region scelta consapevolmente (data residency)
- [ ] Aruba **DPA (Data Processing Agreement)** firmato per GDPR art.28

### 16. Differenze rispetto a Netsons (cPanel)

| Funzione | Aruba (Plesk) | Netsons (cPanel) |
|----------|---------------|------------------|
| Pannello | Plesk | cPanel |
| Docroot default | `httpdocs/` | `public_html/` |
| PHP per-domain | Multi-PHP via Plesk | MultiPHP Manager |
| Cron | Scheduled Tasks | Cron jobs |
| Backup | Backup Manager (con remote storage) | JetBackup / Backup Wizard |
| Firewall | Plesk Firewall ext + Fail2Ban | CSF (ConfigServer Firewall) |
| WAF | ModSecurity (built-in) | ModSecurity + Imunify360 |
| DB management | Plesk → Databases | phpMyAdmin via cPanel |
| File Manager | Plesk File Manager | cPanel File Manager |

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File / Setting**: path/to/file o `Plesk → Sezione → Impostazione`
- **Problema**: descrizione
- **Soluzione**: passi specifici nel pannello Plesk o file di config
- **Categoria**: prefix `HOSTING-ARUBA-NNN`

## RIFERIMENTI

- Plesk Administrator Guide: <https://docs.plesk.com/en-US/obsidian/administrator-guide/>
- Plesk Customer Guide: <https://docs.plesk.com/en-US/obsidian/customer-guide/>
- Aruba Hosting Linux: <https://hosting.aruba.it/hosting-linux.aspx>
- Plesk SSL It! Extension: <https://www.plesk.com/extensions/ssl-it/>
- PCI Compliance Plesk Guide: <https://docs.plesk.com/en-US/obsidian/administrator-guide/securing-plesk.74095/>
