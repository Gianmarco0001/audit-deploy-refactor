# Checklist — Hosting Vercel (profile-specific)

Sei un DevOps/Edge engineer esperto in deployment serverless su Vercel. Questa checklist e' applicata in AGGIUNTA a `general.md` quando rilevato `vercel.json` o build target Next.js. Validata su Vercel ufficiale (vercel.com/docs/security + /docs/limits).

## CHECKLIST VERCEL

### 1. Environment Variables

- [ ] Environment scope corretto: variabili separate per **Production**, **Preview**, **Development** (dashboard Vercel)
- [ ] **Sensitive Environment Variables** (encrypted, hidden post-creation) per secrets server-side
- [ ] **MAI** secrets in `NEXT_PUBLIC_*` / `VITE_*` / `REACT_APP_*` / `PUBLIC_*` (bundlati nel client JS)
- [ ] Pubblici OK in `NEXT_PUBLIC_*`: publishable Stripe key, GA measurement ID, Mapbox key con domain restriction
- [ ] `.env.production` MAI committato; valori solo in dashboard
- [ ] Limite size: **64KB** totale env var per deployment (Node.js/Python/Ruby/Go/Java/.NET)
- [ ] Max **1000** env var per environment per project
- [ ] Riavviare deployment dopo cambio env var (le funzioni non hot-reload)

### 2. Runtime: Edge vs Node.js

- [ ] **Edge Runtime** per latency-critical, geo-distributed (no Node APIs disponibili)
  - NO `fs`, `child_process`, `crypto` Node-specific (usa Web Crypto API)
  - NO `eval()`, `new Function()` (V8 isolate)
  - Streaming response supportato
- [ ] **Node.js Runtime** quando serve filesystem, native modules, dipendenze CPU-heavy
- [ ] Configura `runtime: 'edge'` o `runtime: 'nodejs20.x'` esplicito in route handler

### 3. Functions limits

- [ ] **Size**: 50 MB compressed, 250 MB uncompressed per function
- [ ] **Memory**: Hobby 1024MB (fissa), Pro 1769MB default fino a 3008MB
- [ ] **Max duration** (legacy non-Fluid compute):
  - Hobby: default 10s, max 60s
  - Pro: default 15s, max 300s (5 min)
  - Enterprise: default 15s, max 900s (15 min)
- [ ] Proxied request timeout: **120s** hard limit (rewrites / external destination)
- [ ] **WebSocket non supportato** su Vercel Functions: usa Pusher/Ably/Supabase Realtime
- [ ] Function regions configurate (vicino a utenti/DB) in `vercel.json`

### 4. Middleware (Next.js)

- [ ] Code size limit: **1 MB** bundlato (anche meno per cold start veloce)
- [ ] Duration cap: **50ms** per invocation
- [ ] NO Node APIs (gira in Edge Runtime)
- [ ] **CVE-2025-29927**: Next.js versione minima **15.2.3 / 14.2.25 / 13.5.9 / 12.3.5** (bypass auth middleware via `x-middleware-subrequest` header)
- [ ] Audit `next.config.js` per `experimental.middlewareSourceMaps` (no in prod)

### 5. Vercel Firewall (built-in, free)

- [ ] **DDoS mitigation** automatica attiva (no config richiesta)
- [ ] **Web Application Firewall (WAF)**: custom rules + managed rulesets
- [ ] Project Settings → Firewall → abilitato
- [ ] OWASP CRS managed ruleset attivo (Pro+)
- [ ] Rate limiting via WAF per route critiche (login, API key endpoints)
- [ ] Bot management: challenge automated traffic
- [ ] **Firewall observability**: review logs per attacchi reali

### 6. HTTPS & domini

- [ ] **HTTPS automatico** via Let's Encrypt (zero config) per ogni deployment
- [ ] Custom domains: SSL cert auto-rinnovato
- [ ] HSTS configurabile via `next.config.js` `headers()` o `vercel.json` headers
- [ ] DNS gestito tramite Vercel o esterno (CNAME `cname.vercel-dns.com`)
- [ ] Limit domini: 50 per project (Hobby), unlimited (Pro)

### 7. Image Optimization

- [ ] `next.config.js` → `images.domains` o `images.remotePatterns` whitelist esplicita (no `*` wildcard)
- [ ] Formats raccomandati: `['image/avif', 'image/webp']` per modern browsers
- [ ] Hobby: max 10000 Image Optimization source images / mese (oltre = costo o downgrade qualita')
- [ ] Cache size: 600K cache reads / mese, 200K cache writes / mese (Pro included)

### 8. ISR (Incremental Static Regeneration)

- [ ] `revalidate: N` su page (App Router: `export const revalidate = N`) o getStaticProps (Pages Router)
- [ ] On-demand revalidation via `res.revalidate(path)` (API route) o `revalidateTag(tag)` / `revalidatePath(path)` (App Router)
- [ ] Webhook secret per protect endpoint di revalidation
- [ ] Limit ISR reads/writes: vedi piano (10M reads / 2M writes inclusi su Pro)

### 9. Cron Jobs

- [ ] Max 100 cron jobs per project (tutti i piani)
- [ ] Hobby: max 2 cron in esecuzione contemporanea
- [ ] **Signature validation**: verifica header `Authorization: Bearer ${CRON_SECRET}` (Vercel manda CRON_SECRET impostato in env)
- [ ] Cron NON sostituisce job queue per task pesanti (timeout 5-10 min Pro)
- [ ] Definizione in `vercel.json`:
  ```json
  { "crons": [{ "path": "/api/cleanup", "schedule": "0 3 * * *" }] }
  ```

### 10. Deployment Protection

- [ ] **Password Protection** su preview deployment se contenuto sensibile (Pro)
- [ ] **Vercel Authentication** (SSO) per restringere access a team members
- [ ] **Bypass tokens** per share specifico, mai pubblici
- [ ] **Trusted IPs** allowlist per preview deployment

### 11. Static & build limits

- [ ] Max source files upload via CLI: **15.000** (oltre = build fail)
- [ ] Build time max: **45 min** (oltre = abort)
- [ ] Build cache: 1 GB per cache key, 1 mese retention
- [ ] Static file upload: Hobby 100MB, Pro 1GB
- [ ] **Routes per deployment**: 2048 limit (Hobby/Pro; conta rewrites, redirects, headers, ISR pages)
- [ ] Disk size build: 23 GB (espandibile a 64 GB su Pro)

### 12. Logs & observability

- [ ] **Runtime Logs retention**: 1h (Hobby), 1 day (Pro), 3 days (Enterprise)
- [ ] **Build logs**: storage indefinito per deployment
- [ ] Drain integrations (Pro+) per log forwarding (Datadog, Logtail)
- [ ] **Speed Insights** abilitato per Core Web Vitals monitoring
- [ ] **Web Analytics** abilitato per traffic insights (privacy-first, GDPR friendly)
- [ ] Monitoring events: 250k inclusi (Pro), oltre = costo per million

### 13. Storage integrations

- [ ] Vercel Blob: 5GB/mese inclusi, simple ops 100k, advanced ops 10k
- [ ] Vercel Postgres / KV / Edge Config integrati (no external DB credentials needed)
- [ ] Edge Config: 1M reads/mese inclusi, 1k writes/mese

### 14. Versione Next.js & framework

- [ ] **Next.js 15.x** raccomandato (App Router, React 19, Turbopack)
- [ ] Next 14.x in maintenance, Next 13.x in security-only
- [ ] **Versione minima per CVE-2025-29927**: 15.2.3 / 14.2.25 / 13.5.9 / 12.3.5

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: `vercel.json` / `next.config.js` / `path/to/api-route.ts:riga`
- **Problema**: descrizione
- **Soluzione**: fix con config snippet
- **Categoria**: prefix `HOSTING-VERCEL-NNN`

## RIFERIMENTI

- Vercel Security: <https://vercel.com/docs/security>
- Vercel Limits: <https://vercel.com/docs/limits>
- Vercel Firewall: <https://vercel.com/docs/vercel-firewall>
- Next.js CVE-2025-29927: <https://github.com/vercel/next.js/security/advisories/GHSA-f82v-jwr5-mffw>
