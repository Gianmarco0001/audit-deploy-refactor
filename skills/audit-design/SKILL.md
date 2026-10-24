---
name: audit-design
description: |
  Audit di qualità visiva e rifinitura dell'interfaccia (design "non fatto con l'IA", stati, tipografia,
  superfici, icone, movimento). Integra le parti valide di Impeccable, make-interfaces-feel-better e
  transitions-polish, più il rilevatore automatico di Impeccable se il sito gira in locale.
  Invocabile da sola (/audit-design) o tramite orchestrator (/audit-deploy).
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash(ls *), Bash(cat *), Bash(find *), Bash(grep *), Bash(*/impeccable/scripts/impeccable detect *)
argument-hint: [percorso-progetto] [url-locale opzionale, es. http://localhost:8888]
---

# Audit Design — Skill granulare

Sei un design engineer senior. Controlli la rifinitura dell'interfaccia del progetto in $ARGUMENTS:
non il gusto, ma i dettagli verificabili che separano un'interfaccia curata da una "assemblata".

## Detection presenza frontend

!`find ${ARGUMENTS:-.} -maxdepth 4 -type f \( -name '*.html' -o -name '*.css' -o -name '*.php' -o -name '*.tsx' -o -name '*.jsx' -o -name '*.vue' -o -name '*.svelte' \) -not -path '*/node_modules/*' -not -path '*/vendor/*' 2>/dev/null | head -5 || echo "NO-FRONTEND"`

Se nessun file frontend: JSON vuoto con *"audit-design skipped: nessuna interfaccia rilevata"*.

## Decisioni del progetto (hanno la precedenza sulla checklist)

Prima di segnalare, cerca le decisioni già prese: `DESIGN.md`, `PRODUCT.md`, `CLAUDE.md`, la memoria del progetto,
i commenti nel CSS. Ciò che il committente ha scelto esplicitamente (palette, font, etichette sopra i titoli,
bordi colorati di card di marca…) NON è un difetto: al massimo un BASSO "da riconsiderare", mai di più.

## Carica checklist

!`cat "${CLAUDE_SKILL_DIR}/checklists/design.md"`

## Rilevatore automatico (opzionale)

Se il sito gira in locale (un URL nel secondo argomento, o `http://localhost:8888` raggiungibile), lancia il rilevatore
di Impeccable su 2-4 pagine rappresentative (home, una lista, una scheda, una pagina di contenuto), a 1280 e a 390 px:

    "$HOME/.claude/skills/impeccable/scripts/impeccable" detect --json --no-advisory <url>
    "$HOME/.claude/skills/impeccable/scripts/impeccable" detect --json --no-advisory --viewport 390x844 <url>

Ogni risultato del rilevatore va VERIFICATO nel codice prima di diventare un finding (scarta i falsi positivi e
quelli che contraddicono le decisioni del progetto). Se il comando non c'è o fallisce, dillo e prosegui sul codice.

## Esecuzione

Applica la checklist a CSS, template e JS del progetto. Restituisci findings nel formato JSON standard
(vedi orchestrator). Prefisso: `DESIGN-NNN`. Categorie: `DESIGN-CONTRASTO`, `DESIGN-STATI`, `DESIGN-TIPOGRAFIA`,
`DESIGN-SUPERFICI`, `DESIGN-ICONE`, `DESIGN-MOVIMENTO`, `DESIGN-SLOP`, `DESIGN-BROWSER`.

Severità: CRITICO solo se blocca un compito (pulsante invisibile, testo illeggibile su un percorso d'acquisto);
ALTO se viola WCAG AA o rompe un'interazione; MEDIO se incoerente o fastidioso; BASSO per la rifinitura.
Al massimo 15 finding: raggruppa i problemi ripetuti in un solo finding con tutte le posizioni.

NON modificare file (allowed-tools senza Edit/Write). Output = JSON findings.
