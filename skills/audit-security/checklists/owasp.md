# Checklist — Cybersecurity OWASP & Security Headers

Sei un Cybersecurity Expert specializzato in web application security con certificazione OWASP. Esegui un audit di sicurezza completo del progetto verificando l'OWASP Top 10:2025 e la configurazione degli header di sicurezza. Focus particolare su autenticazione e form di login.

## CHECKLIST OWASP TOP 10:2025

### A01:2025 — Broken Access Control

- [ ] Controlli di accesso su OGNI endpoint/pagina protetta
- [ ] Verifica autorizzazione lato server (mai solo lato client)
- [ ] **"Logged in" != "Allowed to"**: l'autenticazione non basta, ogni endpoint deve verificare anche l'autorizzazione sulla risorsa specifica
- [ ] Nessun IDOR (Insecure Direct Object Reference): ID non prevedibili o con verifica ownership
  - Test esplicito: cambia `/post/123` -> `/post/124` / `/user/1/orders` -> `/user/2/orders` e verifica che venga negato
  - **Attenzione alle API generate da AI**: autenticano l'utente ma spesso dimenticano di verificare `resource.userId == session.userId`
- [ ] Se Next.js: versione >= 15.2.3 / 14.2.25 / 13.5.9 / 12.3.5 per **CVE-2025-29927** (bypass totale del middleware di auth tramite header `x-middleware-subrequest`)
- [ ] Principio del minimo privilegio implementato
- [ ] Nessuna directory listing abilitata
- [ ] Rate limiting su endpoint sensibili
- [ ] CORS configurato correttamente:
  - NO Access-Control-Allow-Origin: * (wildcard)
  - NO origin reflection dinamico senza whitelist
  - NO Access-Control-Allow-Origin: null
  - Access-Control-Allow-Credentials: true solo con origin specifici nella whitelist
  - Whitelist di origin ammessi esplicita e verificata lato server
  - Preflight requests (OPTIONS) gestite correttamente

### A02:2025 — Security Misconfiguration

- [ ] Nessun file di default del framework/server esposto
- [ ] Debug mode disabilitato in produzione
- [ ] Directory listing disabilitato
- [ ] Permessi file corretti (644 file, 755 directory, config 600)

### A03:2025 — Software Supply Chain

- [ ] Dipendenze aggiornate e senza CVE note (`npm audit`, `composer audit`)
- [ ] composer.lock e package-lock.json versionati
- [ ] Nessuna libreria da fonti non verificate
- [ ] **Transitive dependencies**: `npm install` di 1 pacchetto ne tira dietro facilmente centinaia (anche 800+). Verifica l'albero reale con `npm ls --all` e rivedi cosa entra davvero nel bundle
- [ ] Gli attacchi supply chain colpiscono pacchetti che si installano automaticamente come dipendenze transitive: per ogni pacchetto top-level verifica autore, numero di download, data ultima pubblicazione, eventuali typo-squatting
- [ ] In produzione/CI usa `npm ci` (non `npm install`) per rispettare strettamente il lockfile
- [ ] Valuta `npm install --ignore-scripts` per bloccare l'esecuzione automatica di `postinstall` / `preinstall` (vettore frequente di attacchi supply chain)

### A04:2025 — Cryptographic Failures

- [ ] HTTPS obbligatorio (redirect HTTP -> HTTPS)
- [ ] Certificato SSL/TLS valido
- [ ] Nessun dato sensibile trasmesso in chiaro
- [ ] Password hashate con bcrypt (password_hash con PASSWORD_BCRYPT o PASSWORD_ARGON2ID)
- [ ] Nessun uso di MD5/SHA1 per password o dati sensibili

### A05:2025 — Injection

- [ ] SQL Injection (coperto dall'Agente 3, conferma)
- [ ] **NoSQL Injection**: input utente MAI passato direttamente a query Mongo/Mongoose
  - **CVE-2025-23061**: Mongoose < 8.9.5 exploitable via `$where` e `populate()` con input utente non sanitizzato
  - Sanitizza con `mongo-sanitize` o valida lo schema con Joi/Zod prima di passare ai metodi del driver
  - Blocca operatori con prefisso `$` e chiavi con `.` nei body JSON quando non sono intenzionali
- [ ] XSS (Cross-Site Scripting):
  - Output encoding con htmlspecialchars($var, ENT_QUOTES, 'UTF-8') su TUTTI gli output
  - Nessun echo diretto di input utente
  - Content-Security-Policy header configurato
- [ ] Command Injection: nessun input utente passato a exec/system/passthru
- [ ] LDAP/XML/Template injection dove applicabile

### A06:2025 — Insecure Design

- [ ] Validazione input sia client-side che server-side
- [ ] Threat modeling sulle funzionalita' critiche

### A07:2025 — Authentication Failures

- [ ] Login:
  - Brute force protection (rate limiting, account lockout temporaneo, CAPTCHA dopo N tentativi)
  - Nessun messaggio che riveli se username o password e' errato ("Credenziali non valide" generico)
  - Password policy (minimo 8 caratteri, mix maiuscole/minuscole/numeri/speciali)
  - Nessuna password di default
- [ ] Sessioni:
  - Session ID rigenerato dopo login (session_regenerate_id(true))
  - Cookie di sessione con flag: Secure, HttpOnly, SameSite=Strict/Lax
  - Session timeout configurato (idle e assoluto)
  - Logout che distrugge completamente la sessione
- [ ] Se presente "Remember me": token sicuro, non basato su dati prevedibili
- [ ] Se presente reset password: token monouso, scadenza breve, inviato solo via email
- [ ] Se presente 2FA: implementazione corretta (TOTP, no SMS se possibile)

### A08:2025 — Software/Data Integrity

- [ ] Nessuna deserializzazione di dati non fidati (unserialize con input utente)
- [ ] Integrita' dei file JS/CSS (SRI - Subresource Integrity per risorse da CDN)

### A09:2025 — Security Logging & Alerting

- [ ] Login falliti loggati con IP e timestamp
- [ ] Azioni amministrative loggate
- [ ] Log non contengono dati sensibili (password, token)
- [ ] Log protetti da accesso non autorizzato

### A10:2025 — Mishandling of Exceptional Conditions

- [ ] Errori gestiti senza esporre stack trace o info di sistema
- [ ] Pagine di errore personalizzate (404, 500)
- [ ] Fail-secure (in caso di errore, nega l'accesso, non lo concede)

## SECURITY HEADERS

- [ ] Content-Security-Policy (CSP): policy restrittiva, no 'unsafe-inline' se possibile
- [ ] X-Content-Type-Options: nosniff
- [ ] X-Frame-Options: DENY o SAMEORIGIN
- [ ] X-XSS-Protection: 0 (deprecato, affidarsi a CSP)
- [ ] Strict-Transport-Security (HSTS): max-age=31536000; includeSubDomains
- [ ] Referrer-Policy: strict-origin-when-cross-origin o no-referrer
- [ ] Permissions-Policy: disabilitare feature non usate (camera, microphone, geolocation, ecc.)
- [ ] Cache-Control: no-store per pagine con dati sensibili
- [ ] X-Permitted-Cross-Domain-Policies: none
- [ ] Cross-Origin-Embedder-Policy (COEP) e Cross-Origin-Opener-Policy (COOP) se applicabili

## ANTI-CSRF

- [ ] Token CSRF su TUTTI i form che modificano dati (POST/PUT/DELETE)
- [ ] Token CSRF validato lato server
- [ ] Token rigenerato per sessione o per richiesta
- [ ] SameSite cookie come difesa aggiuntiva

## PROTEZIONE DDoS & RATE LIMITING

- [ ] Rate limiting applicativo su endpoint critici (login, registrazione, reset password, API)
- [ ] Valutare integrazione Cloudflare (piano gratuito) come reverse proxy:
  - Protezione DDoS layer 3/4/7 inclusa
  - WAF base gratuito
  - Rate limiting su edge (prima che il traffico arrivi al server)
  - Caching CDN per ridurre carico su Netsons / hosting
- [ ] Se Cloudflare attivo: verificare che l'IP reale del server Netsons non sia esposto (no DNS diretto)
- [ ] Throttling su form di contatto/commenti per prevenire spam
- [ ] Protezione da enumeration (user enumeration via login/reset password/registrazione)

## GESTIONE SECRET & ENV VAR

- [ ] **I prefissi "public" NON sono segreti**: variabili con prefisso `NEXT_PUBLIC_*` (Next.js), `VITE_*` (Vite), `REACT_APP_*` (CRA), `PUBLIC_*` (SvelteKit/Astro) vengono **bundlate nel JS client** e arrivano a OGNI browser che carica la pagina
  - Chiavi API private, secret, token di servizio, DB credentials NON vanno MAI in queste variabili
  - Usa questi prefissi solo per valori gia' pubblici per design: publishable key Stripe, endpoint pubblico, Google Analytics ID, chiave Mapbox con domain-restriction lato provider
- [ ] Secret server-side stanno solo in `.env` senza prefisso pubblico, letti via `process.env.X` da codice che gira SOLO server-side (API route / server component / backend PHP)
- [ ] `.env`, `.env.local`, `.env.production` NON committati (verifica `.gitignore`)
- [ ] Nessun secret hardcoded nel codice: grep per `api[_-]?key`, `secret`, `token`, `Bearer `, `password\s*=`
- [ ] Verifica che nel bundle JS finale (`dist/`, `.next/static/`) non compaiano stringhe sospette: esegui `grep -r "sk_" dist/` o simili sulle chiavi che usi
- [ ] Chiavi esposte per errore: considerarle COMPROMESSE. Ruotare immediatamente, non basta rimuoverle dal codice (sono nella storia git e nei bundle gia' distribuiti)

## CROSS-REFERENCE FRAMEWORK-SPECIFIC

Se il pre-check ha rilevato un framework specifico, applica anche i check specifici:

- **Laravel**: vedi `audit-backend/checklists/frameworks/laravel.md` sezioni 1-4, 7-8 (routes auth, middleware, policies, form requests, CSRF/headers)

## CHECK RAPIDO PRE-DEPLOY

Prima di pushare in produzione, verifica esplicitamente questi 6 punti critici (i piu' dimenticati, specialmente in codice generato da AI):

1. **API KEYS** — nessuna chiave privata nei prefissi `NEXT_PUBLIC_*` / `VITE_*` / `REACT_APP_*` / `PUBLIC_*`, ne' hardcoded nel codice client
2. **OWNERSHIP** — ogni GET/PUT/DELETE su risorse per-utente verifica che `resource.userId == session.userId` (non basta che l'utente sia loggato)
3. **RATE LIMIT** — applicato almeno su: login, registrazione, reset password, endpoint che chiamano AI/email/SMS (costi), upload file
4. **AUTH + AUTHZ** — autenticazione E autorizzazione verificate su OGNI endpoint: "logged in" != "allowed to"
5. **INJECTION** — SQL (prepared statements), NoSQL (no operatori `$` da input, Mongoose >= 8.9.5), XSS (escape output), Command (no shell da input utente)
6. **DEPENDENCIES** — `npm audit` / `composer audit` puliti, lockfile committati, nessun `postinstall` sospetto, pacchetti top-level verificati

Se anche uno solo di questi 6 e' incerto, il deploy NON e' pronto.

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **OWASP Category**: A0X:2025
- **File**: path/to/file:riga
- **Problema**: descrizione
- **Rischio**: scenario di attacco concreto
- **Soluzione**: fix con codice di esempio
