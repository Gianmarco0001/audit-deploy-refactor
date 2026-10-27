---
description: Audit di cybersecurity OWASP Top 10:2025, security headers, anti-CSRF, rate limiting, gestione secret.
argument-hint: [percorso-progetto] [--no-cloudflare] [--cf-profile=quick|standard|deep] [--cf-budget=N]
---

Esegui le istruzioni della skill **audit-security** applicandole al progetto in $ARGUMENTS (o cwd).

Per Laravel, applica anche cross-ref alle sezioni Middleware/Policies/Sanctum/CSRF di `frameworks/laravel.md`.

Lanciata da sola, dopo la checklist avvia anche la skill `security-audit` di Cloudflare (se installata; profilo `quick`, max 20 agenti) e ne unisce i risultati. `--no-cloudflare` la salta.

Output: JSON dei finding con categoria prefix `OWASP-A0X-*`, `SECURITY-*` o `CF-*`; i finding che dipendono da configurazione fuori dal repository sono `DA-VERIFICARE`, senza gravità.
