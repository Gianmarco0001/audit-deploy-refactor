---
name: audit-backend
description: |
  Audit di code quality e best practices backend, stack-aware. Detect automatico via marker
  (composer.json/package.json/pyproject.toml/go.mod). Per PHP rileva anche il framework
  (Laravel/Symfony/CodeIgniter) e applica la checklist framework-specific in aggiunta.
  Invocabile da sola (/audit-backend) o tramite orchestrator (/audit-deploy).
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash(ls *), Bash(cat *), Bash(find *), Bash(grep *), Bash(test *)
argument-hint: [percorso-progetto]
---

# Audit Backend — Skill granulare stack-aware

Sei un Senior Backend Developer specializzato in code quality, security e best practices. Analizza il codice backend del progetto in $ARGUMENTS (o cwd) seguendo la checklist stack-specifica caricata sotto.

## Stack detection

Marker presenti nella root del progetto:

!`ls -1 ${ARGUMENTS:-.} 2>/dev/null | grep -E '^(composer\.json|package\.json|requirements\.txt|pyproject\.toml|go\.mod|Gemfile|artisan|Pipfile)$' || echo "NONE"`

Framework PHP rilevato (se composer.json presente):

!`test -f ${ARGUMENTS:-.}/composer.json && grep -oE '"(laravel/framework|symfony/framework-bundle|codeigniter4/framework|slim/slim)"' ${ARGUMENTS:-.}/composer.json 2>/dev/null | head -1 || echo "no-framework"`

Versione Laravel (se applicabile):

!`test -f ${ARGUMENTS:-.}/composer.lock && grep -A1 '"name": "laravel/framework"' ${ARGUMENTS:-.}/composer.lock 2>/dev/null | grep -oE '"v[0-9]+\.[0-9]+\.[0-9]+"' | head -1 || echo "no-laravel-lock"`

Marker architettura Laravel:

!`test -f ${ARGUMENTS:-.}/bootstrap/app.php && echo "L11+/L13 architecture (bootstrap/app.php)" || (test -f ${ARGUMENTS:-.}/app/Http/Kernel.php && echo "L10/legacy architecture (Kernel.php)" || echo "no-laravel-arch")`

## Carica baseline universale

!`cat "${CLAUDE_SKILL_DIR}/checklists/general.md"`

## Sub-file da caricare on-demand

In base ai marker rilevati sopra, usa il tool **Read** per caricare i seguenti sub-file. **NON caricare** quelli non rilevanti per il progetto.

- Se `composer.json` rilevato → Read `${CLAUDE_SKILL_DIR}/checklists/php.md`
  - + se framework "laravel/framework" → Read `${CLAUDE_SKILL_DIR}/checklists/frameworks/laravel.md`
  - + se framework "symfony/framework-bundle" → Read `${CLAUDE_SKILL_DIR}/checklists/frameworks/symfony.md`
  - + se framework "codeigniter4/framework" → Read `${CLAUDE_SKILL_DIR}/checklists/frameworks/codeigniter.md`
- Se `package.json` rilevato (escludi se è dipendenza di stack PHP come Laravel Mix) → Read `${CLAUDE_SKILL_DIR}/checklists/node.md`
- Se `requirements.txt` OR `pyproject.toml` rilevato → Read `${CLAUDE_SKILL_DIR}/checklists/python.md`
- Se `go.mod` rilevato → Read `${CLAUDE_SKILL_DIR}/checklists/go.md`

Se NESSUN marker rilevato: applica solo `general.md` + warning *"Stack backend non identificato — applicati solo check universali"*.

## Esecuzione

1. Carica i sub-file rilevanti.
2. Per ogni check della checklist (universal + stack-specific + framework-specific), usa Read/Grep/Glob per verificare il codice del progetto.
3. Concentrati sui pattern PIU' DANNOSI (CRITICO/ALTO prima): SQL injection, mass assignment, secrets hardcoded, debug=true in prod, no input validation.
4. Per Laravel: applica anche le sezioni cross-axis di `frameworks/laravel.md` (sezione 11) — segnala che le altre skill (security, database, hosting, email) ricevano cross-ref appropriati.
5. Restituisci findings nel formato JSON definito dall'orchestrator (vedi FASE 2 in `${CLAUDE_SKILL_DIR}/../audit-deploy/SKILL.md`):

```json
{
  "agent": "audit-backend",
  "findings": [
    {
      "id": "BACKEND-PHP-001",
      "severity": "CRITICO|ALTO|MEDIO|BASSO",
      "file": "path/to/file:riga",
      "problema": "...",
      "soluzione": "...",
      "categoria": "BACKEND-PHP|LARAVEL-ELOQUENT-MASS-ASSIGN|BACKEND-GENERAL|..."
    }
  ],
  "summary": { "critico": N, "alto": N, "medio": N, "basso": N }
}
```

## Note operative

- NON modificare file. La skill ha `allowed-tools` senza Edit/Write — qualsiasi fix viene applicato dall'orchestrator dopo approval gate.
- Se invocata standalone (`/audit-backend` direttamente), scrivi il JSON dei finding come messaggio finale all'utente.
- Se invocata da orchestrator (`/audit-deploy`), restituisci il JSON al chiamante.
