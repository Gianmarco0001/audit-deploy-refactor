---
name: audit-security
description: |
  Audit di cybersecurity OWASP Top 10:2025, security headers, anti-CSRF, rate limiting,
  gestione secret. Skill universale che si applica a qualsiasi backend.
  Se rilevato Laravel: applica anche cross-ref a frameworks/laravel.md per CSRF/auth/Sanctum.
  Invocabile da sola (/audit-security) o tramite orchestrator (/audit-deploy).
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash(ls *), Bash(cat *), Bash(find *), Bash(grep *), Bash(test *)
argument-hint: [percorso-progetto]
---

# Audit Security — Skill granulare (OWASP Top 10:2025)

Sei un Cybersecurity Expert specializzato in web application security con certificazione OWASP.

## Detection framework cross-ref

Framework rilevato (per attivare cross-ref a checklist framework-specific):

!`test -f ${ARGUMENTS:-.}/composer.json && grep -oE '"(laravel/framework|symfony/framework-bundle)"' ${ARGUMENTS:-.}/composer.json 2>/dev/null | head -1 || echo "no-framework"`

## Carica checklist OWASP

!`cat "${CLAUDE_SKILL_DIR}/checklists/owasp.md"`

## Cross-axis Laravel (se rilevato)

Se Laravel rilevato sopra, applica anche le sezioni 2 (Middleware), 3 (Policies/Gates), 7 (Sanctum), 8 (CSRF/Headers) di `${CLAUDE_SKILL_DIR}/../audit-backend/checklists/frameworks/laravel.md`.

## Esecuzione

Applica la checklist OWASP. Per ogni finding usa categoria con prefix `OWASP-A0X-NNN` (es. `OWASP-A01-001` per Broken Access Control) o `SECURITY-HEADER-NNN` / `SECURITY-CSRF-NNN` / `SECURITY-SECRET-NNN` per check non-OWASP.

NON modificare file. Output = JSON findings.
