# Checklist — Backend Node.js (stack-specific) — STUB

> **TODO**: contributi benvenuti — vedi [CONTRIBUTING.md](../../../../CONTRIBUTING.md).

Questa checklist e' attualmente vuota. La detection in `audit-backend/SKILL.md` la attiva quando rileva `package.json` (senza marker Next.js/Nuxt che hanno proprio sub-file in futuro).

## Topic suggeriti per la prima versione

- Express / Fastify / Hono / NestJS detection e best-practice specifiche
- Async error handling (Promise rejection, unhandledRejection)
- Stream processing (backpressure, memory leak)
- Body parser limits (JSON, URL-encoded, multipart)
- CORS configurato (mai `*` con credentials)
- Helmet.js per security headers
- Environment validation con Zod/Joi all'avvio
- Versione Node.js (LTS supportata, no EOL)
- `npm ci` / `pnpm install --frozen-lockfile` in CI
- `npm audit` nel CI/CD
- Vulnerabilita' transitive (npm ls --all)
- Process management (PM2 / systemd / Node `--watch` no in prod)
- Cluster mode / Worker threads
- Memory limits (Node `--max-old-space-size`)

## Riferimenti utili

- Node.js best practices: <https://github.com/goldbergyoni/nodebestpractices>
- OWASP Node.js Security Cheat Sheet
- Express Security Best Practices: <https://expressjs.com/en/advanced/best-practice-security.html>

## FORMATO REPORT

Per ogni finding (quando la checklist sara' popolata):

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file.js:riga
- **Problema**: descrizione
- **Soluzione**: fix con esempio
- **Categoria**: prefix `BACKEND-NODE-NNN`
