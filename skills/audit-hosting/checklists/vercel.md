# Checklist — Hosting Vercel (profile-specific) — STUB

> **TODO**: contributi benvenuti — vedi [CONTRIBUTING.md](../../../../CONTRIBUTING.md).

Questa checklist e' attualmente vuota. La detection in `audit-hosting/SKILL.md` la attiva quando rileva `vercel.json` o build target Next.js.

## Topic suggeriti per la prima versione

- Edge Runtime vs Node.js Runtime: scelta per ogni route, gotchas (no Node APIs in Edge)
- `runtime: 'edge'` quando ha senso (latency, cold start), `nodejs20.x` quando serve filesystem/native
- Env vars per environment (Production / Preview / Development) in Vercel dashboard
- `.env.production` NON committato; valori in dashboard
- Secrets sensibili: NON in `NEXT_PUBLIC_*` (vengono bundlati nel client)
- Build cache: turbocache, output build size limit
- Serverless function size limit (50MB compressed, 250MB uncompressed)
- Function memory / max duration (Hobby vs Pro plan)
- ISR (Incremental Static Regeneration): revalidate tempi corretti, on-demand revalidation
- Image Optimization: domini whitelist, formats permessi
- Middleware: limiti (1MB code, 50ms duration), no Node APIs
- Edge Config / KV Storage: per stato condiviso (no global state in serverless)
- Custom domains: SSL automatico, DNS configuration
- CVE-2025-29927 Next.js middleware bypass: versione >= 15.2.3 / 14.2.25 / 13.5.9 / 12.3.5
- Cron jobs via Vercel Cron (limiti piano)
- Analytics & Speed Insights configurati

## FORMATO REPORT

- **Categoria**: prefix `HOSTING-VERCEL-NNN`
