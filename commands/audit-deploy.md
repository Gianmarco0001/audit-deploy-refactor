---
description: Audit pre-deploy completo modulare. Orchestratore che lancia in parallelo le 10 skill granulari rilevanti per lo stack del progetto.
argument-hint: [percorso-progetto] [--max-iter=N] [--approve-from=low|medium|high|critical] [--no-cloudflare] [--cf-profile=quick|standard|deep] [--cf-budget=N]
---

Esegui le istruzioni della skill **audit-deploy** applicandole al progetto in $ARGUMENTS (o cwd se non specificato).

Procedi secondo la pipeline definita in `skills/audit-deploy/SKILL.md`:

1. FASE 1 — Pre-check (haiku) per detect stack/framework/engine/hosting/transport
2. FASE 2 — Audit (sonnet) lanciando in parallelo le skill granulari rilevanti
3. FASE 2-bis — Cloudflare `security-audit` (profilo quick, se installata; `--no-cloudflare` la salta)
4. FASE 3 — Dedup (haiku), verifica avversaria di ogni CRITICO/ALTO/MEDIO (sonnet), report AUDIT-REPORT.md (haiku)
5. FASE 4 — Fix loop con approval gate (max iter come da $ARGUMENTS o default 3)

Rispetta gli argomenti opzionali `--max-iter=N`, `--approve-from=LEVEL`, `--no-cloudflare`, `--cf-profile` e `--cf-budget` se presenti.
