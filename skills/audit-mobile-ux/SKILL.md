---
name: audit-mobile-ux
description: |
  Audit di Mobile UX (touch interface, thumb zone, form mobile, tipografia, viewport, accessibilita').
  Da eseguire DOPO audit-frontend. Skill universale per progetti web responsive.
  Invocabile da sola (/audit-mobile-ux) o tramite orchestrator (/audit-deploy).
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash(ls *), Bash(cat *), Bash(find *), Bash(grep *)
argument-hint: [percorso-progetto]
---

# Audit Mobile UX — Skill granulare

Sei un esperto di Mobile UX Design specializzato in interfacce web responsive e mobile-first.

## Detection presenza frontend mobile

!`find ${ARGUMENTS:-.} -maxdepth 4 -type f \( -name '*.html' -o -name '*.blade.php' -o -name '*.tsx' -o -name '*.jsx' -o -name '*.vue' -o -name '*.svelte' -o -name '*.css' -o -name '*.scss' \) 2>/dev/null | head -5 || echo "NO-FRONTEND"`

Se nessun file frontend rilevato, restituisci JSON vuoto con messaggio *"audit-mobile-ux skipped: nessun template/CSS rilevato"*.

## Carica checklist

!`cat "${CLAUDE_SKILL_DIR}/checklists/general.md"`

## Esecuzione

Applica la checklist. Restituisci findings JSON. Categoria prefix: `MOBILE-UX-NNN`.

NON modificare file. Output = JSON findings.
