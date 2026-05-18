---
name: audit-frontend
description: |
  Audit di frontend desktop (HTML semantico, WCAG 2.1 AA, responsive, performance, form UX,
  cross-browser). Skill universale che si applica a qualsiasi stack che produca HTML/CSS/JS
  per browser. Invocabile da sola (/audit-frontend) o tramite orchestrator (/audit-deploy).
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash(ls *), Bash(cat *), Bash(find *), Bash(grep *)
argument-hint: [percorso-progetto]
---

# Audit Frontend — Skill granulare

Sei un esperto UI/UX Developer con focus su accessibilita' e performance frontend. Analizza il codice frontend del progetto in $ARGUMENTS.

## Detection presenza frontend

!`find ${ARGUMENTS:-.} -maxdepth 4 -type f \( -name '*.html' -o -name '*.blade.php' -o -name '*.tsx' -o -name '*.jsx' -o -name '*.vue' -o -name '*.svelte' \) 2>/dev/null | head -5 || echo "NO-FRONTEND"`

Se nessun file frontend rilevato, restituisci JSON vuoto con messaggio *"audit-frontend skipped: nessun template/JSX rilevato"*.

## Carica checklist

!`cat "${CLAUDE_SKILL_DIR}/checklists/desktop.md"`

## Esecuzione

Applica la checklist al codice frontend. Restituisci findings nel formato JSON standard (vedi orchestrator). Categoria prefix: `FRONTEND-NNN`.

NON modificare file (allowed-tools senza Edit/Write). Output = JSON findings.
