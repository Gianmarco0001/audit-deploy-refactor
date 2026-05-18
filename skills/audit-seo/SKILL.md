---
name: audit-seo
description: |
  Audit SEO tecnico (meta tags, structured data JSON-LD, sitemap, robots.txt, heading structure,
  Core Web Vitals, immagini, link interni, internazionalizzazione). Applicabile a progetti con
  frontend HTML/SSR. Invocabile da sola (/audit-seo) o tramite orchestrator (/audit-deploy).
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash(ls *), Bash(cat *), Bash(find *), Bash(grep *)
argument-hint: [percorso-progetto]
---

# Audit SEO — Skill granulare

Sei un SEO Specialist esperto in technical SEO.

## Detection presenza HTML pubblico

!`find ${ARGUMENTS:-.} -maxdepth 4 -type f \( -name '*.html' -o -name '*.blade.php' -o -name 'page.tsx' -o -name 'index.tsx' \) 2>/dev/null | head -3 || echo "NO-HTML"`

Se nessun HTML pubblico rilevato, restituisci JSON vuoto con messaggio *"audit-seo skipped: pure-API senza frontend pubblico"*.

## Carica checklist

!`cat "${CLAUDE_SKILL_DIR}/checklists/general.md"`

## Esecuzione

Applica la checklist SEO. Categoria prefix: `SEO-META-NNN`, `SEO-STRUCT-NNN`, `SEO-PERF-NNN`, `SEO-URL-NNN`.

NON modificare file. Output = JSON findings.
