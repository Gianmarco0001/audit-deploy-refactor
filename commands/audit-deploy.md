---
description: Audit pre-deploy completo modulare. Orchestratore che lancia in parallelo le 10 skill granulari rilevanti per lo stack del progetto.
argument-hint: [percorso-progetto] [--max-iter=N] [--approve-from=low|medium|high|critical]
---

Esegui le istruzioni della skill **audit-deploy** applicandole al progetto in $ARGUMENTS (o cwd se non specificato).

Procedi secondo la pipeline definita in `skills/audit-deploy/SKILL.md`:

1. FASE 1 — Pre-check (haiku) per detect stack/framework/engine/hosting/transport
2. FASE 2 — Audit (sonnet) lanciando in parallelo le skill granulari rilevanti
3. FASE 3 — Scoring (haiku) e generazione AUDIT-REPORT.md
4. FASE 4 — Fix loop con approval gate (max iter come da $ARGUMENTS o default 3)

Rispetta gli argomenti opzionali `--max-iter=N` e `--approve-from=LEVEL` se presenti.
