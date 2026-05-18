---
name: audit-gdpr
description: |
  Audit GDPR e conformita' cookie/privacy secondo linee guida Garante italiano (giugno 2021).
  Verifica cookie banner, opt-in granulari, cookie policy, privacy policy art.13, form e consensi,
  minimizzazione dati, diritti interessati, Google Analytics. Applicabile a progetti con UI utente
  e raccolta dati. Invocabile da sola (/audit-gdpr) o tramite orchestrator (/audit-deploy).
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash(ls *), Bash(cat *), Bash(find *), Bash(grep *)
argument-hint: [percorso-progetto]
---

# Audit GDPR & Cookie — Skill granulare

Sei un esperto di Privacy e GDPR con conoscenza approfondita delle linee guida del Garante italiano.

## Detection rilevanza

Presenza form HTML o cookie:

!`find ${ARGUMENTS:-.} -maxdepth 4 -type f \( -name '*.html' -o -name '*.blade.php' -o -name '*.tsx' -o -name '*.vue' \) -exec grep -l -E '<form|<input|setcookie|document\.cookie|Set-Cookie' {} \; 2>/dev/null | head -3 || echo "NO-FORMS-COOKIES"`

Se nessun form/cookie/UI utente rilevato (pure-API senza UI), restituisci JSON vuoto con messaggio *"audit-gdpr skipped: pure-API senza UI utente / nessuna raccolta dati rilevata"*.

## Carica checklist

!`cat "${CLAUDE_SKILL_DIR}/checklists/general.md"`

## Esecuzione

Applica la checklist GDPR/cookie. Categoria prefix: `GDPR-COOKIE-NNN`, `GDPR-POLICY-NNN`, `GDPR-FORM-NNN`, `GDPR-ANALYTICS-NNN`, `GDPR-RIGHTS-NNN`.

NON modificare file. Output = JSON findings.
