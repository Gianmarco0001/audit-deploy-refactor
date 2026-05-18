# Checklist — Backend Node.js (stack-specific)

Sei un Senior Node.js Developer specializzato in security e performance backend. Questa checklist e' applicata in AGGIUNTA a `general.md` quando il progetto e' un'applicazione Node.js (Express/Fastify/Hono/NestJS). Validata su Node.js Security Best Practices ufficiali (nodejs.org/en/learn/getting-started/security-best-practices) e Express Security Best Practices.

## CHECKLIST NODE.JS

### 1. Runtime & versione

- [ ] Node.js LTS in produzione (v22.x attiva, v20.x in maintenance fino Apr 2026, v18.x EOL Apr 2025 → upgrade obbligatorio)
- [ ] Versione Node pinned in `.nvmrc`, `Dockerfile`, e `package.json` field `engines.node`
- [ ] NO experimental features in produzione (es. `--frozen-intrinsics`, sperimentali al boot)
- [ ] Subscribe a `nodejs-sec@googlegroups.com` per security pre-announce

### 2. HTTP Server hardening (anti-DoS)

- [ ] `server.headersTimeout` configurato (default 60s spesso troppo lungo) → 30-40s consigliato
- [ ] `server.requestTimeout` impostato (30-60s) per prevenire Slowloris
- [ ] `server.keepAliveTimeout` ≈ 65s (oltre RFC default)
- [ ] `server.timeout` come fallback (max 120s)
- [ ] Limiti connessioni: `server.maxConnections`, `agent.maxSockets`
- [ ] Socket errors gestiti: `socket.on('error', handler)` per prevenire crash su connection reset
- [ ] **MAI** `insecureHTTPParser: true` (rischio HTTP request smuggling)
- [ ] Reverse proxy davanti (nginx, Cloudflare) per DDoS L3/L4 mitigation

### 3. Debug Inspector

- [ ] `--inspect` / `--inspect-brk` DISATTIVATI in produzione (porta 9229 espone V8 debug protocol)
- [ ] Se inspector necessario: solo via SIGUSR1 + bind a 127.0.0.1 (no 0.0.0.0)
- [ ] Protezione DNS rebinding su localhost:9229 (con reverse proxy o firewall)

### 4. Error handling

- [ ] `process.on('unhandledRejection', handler)` registrato con logging strutturato
- [ ] `process.on('uncaughtException', handler)` → graceful shutdown (non `process.exit(0)` silent)
- [ ] Errori in stream/socket handler intercettati con `.on('error', ...)`
- [ ] Process supervisor (PM2, systemd) per auto-restart su crash

### 5. Dependencies & supply chain

- [ ] `npm audit` nel CI/CD; build fallisce su `high`/`critical`
- [ ] **`npm ci`** (NON `npm install`) in produzione/CI per rispettare lockfile
- [ ] `package-lock.json` / `yarn.lock` / `pnpm-lock.yaml` committato
- [ ] **`npm install --ignore-scripts`** per bloccare `postinstall`/`preinstall` attacks
- [ ] Audit tools alternativi/integrativi: Socket.dev, Snyk, Semgrep
- [ ] `package.json` review per typo-squatting (`react` vs `rect`, `lodash` vs `lodassh`)
- [ ] Versioni esatte (no `^1.0.0` range) per dipendenze critiche di security
- [ ] `npm ls --all` per ispezionare albero dipendenze transitive

### 6. Secrets & environment variables

- [ ] `.env` mai committato; `.env.example` documenta le variabili
- [ ] **NO secrets** in `NEXT_PUBLIC_*`, `VITE_*`, `REACT_APP_*`, `PUBLIC_*` (bundlati nel client)
- [ ] Validazione `process.env` al boot con Zod/Joi/`envalid`; fail-fast se richieste mancano
- [ ] Secrets manager esterno per ambienti production (AWS Secrets Manager, HashiCorp Vault, Doppler)
- [ ] Rotazione secrets periodica + audit access logs

### 7. Cryptographic security

- [ ] Confronti su token/password con `crypto.timingSafeEqual()` (no `===` su buffer)
- [ ] Password hashing con `crypto.scrypt`, bcrypt, o argon2 (mai plain, mai MD5/SHA1)
- [ ] No branching time-sensitive su segreti (evita timing attacks)
- [ ] TLS solo (HTTPS forced), nessun HTTP plain in prod

### 8. Memory & Buffer safety

- [ ] `Buffer.alloc(size)` (zeroed) invece di `Buffer.allocUnsafe(size)`
- [ ] `--secure-heap=N` per limit heap massimo (no su Windows)
- [ ] Limiti payload espliciti su body parser (vedi sezione middleware)

### 9. Prototype Pollution defense

- [ ] `--disable-proto=delete` o `--disable-proto=throw` flag in produzione
- [ ] `Object.freeze(MyObject.prototype)` su classi critiche
- [ ] `Object.create(null)` per oggetti popolati da dati non fidati
- [ ] `Object.hasOwn(obj, key)` invece di `obj.prop` su input utente
- [ ] Schema validation JSON con Zod/Joi PRIMA di assegnare a oggetti

### 10. Permission Model (Node.js 20.10+)

- [ ] Run con `--permission` per capability restrictions
- [ ] FS restriction: `--allow-fs-read=/app/public`, `--allow-fs-write=/tmp`
- [ ] Net restriction: `--allow-net=localhost:3000,api.example.com`
- [ ] Child process: `--allow-child-process` (default deny in strict mode)
- [ ] Native addons: `--allow-addons` (default deny)

### 11. Express / Fastify / NestJS — middleware essenziali

- [ ] **`helmet`** registrato: `app.use(helmet())` (CSP, HSTS, X-Frame-Options, X-Content-Type-Options)
- [ ] **`compression`** con filter selettivo (no su response gia' compresse, no su `x-no-compress`)
- [ ] **Body parser limits**: `express.json({ limit: '10kb' })`, `express.urlencoded({ limit: '10kb' })`
- [ ] **CORS** con origin whitelist esplicita (MAI `*` con `credentials: true`)
- [ ] **`express-rate-limit`** su route sensibili (login, register, password-reset, API key endpoints)
- [ ] HTTPS forced (`req.secure` check + redirect; o gestito dal reverse proxy)
- [ ] Schema validation server-side: Joi, Zod, `express-validator`, AJV
- [ ] Mai trust client-side validation only

### 12. Logging & monitoring

- [ ] NO password/token nei log (redact via `pino.redact` o middleware sanitization)
- [ ] Log eventi security: failed auth, rate-limit hit, suspicious headers
- [ ] Log strutturato JSON (`pino`, `winston`) per analisi
- [ ] Centralizzazione (ELK, Datadog, CloudWatch) e alerting su WARN+
- [ ] Process supervisor (PM2/systemd) con restart policy

### 13. Build & deploy

- [ ] `NODE_ENV=production` al boot in produzione
- [ ] `npm publish --dry-run` se pubblichi pacchetto (verifica file inclusi)
- [ ] `.npmignore` + `files` in `package.json` per allowlist file pubblicati (no `.env`, no chiavi)
- [ ] 2FA su account npm
- [ ] Container scan con Trivy/Grype/Snyk Container

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file.js:riga
- **Problema**: descrizione
- **Soluzione**: fix con esempio
- **Categoria**: prefix `BACKEND-NODE-NNN`

## RIFERIMENTI

- Node.js Security Best Practices: <https://nodejs.org/en/learn/getting-started/security-best-practices>
- Express Security Best Practices: <https://expressjs.com/en/advanced/best-practice-security.html>
- Node.js Release Schedule: <https://nodejs.org/en/about/previous-releases>
