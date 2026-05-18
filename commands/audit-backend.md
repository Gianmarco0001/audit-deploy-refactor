---
description: Audit di code quality e best practices backend (stack-aware PHP/Laravel/Node/Python/Go).
argument-hint: [percorso-progetto]
---

Esegui le istruzioni della skill **audit-backend** applicandole al progetto in $ARGUMENTS (o cwd).

Carica la baseline universale + i sub-file rilevanti allo stack rilevato dai marker (composer.json, package.json, requirements.txt, pyproject.toml, go.mod). Per PHP, applica anche il sub-file framework-specific se Laravel/Symfony/CodeIgniter sono rilevati.

Output: JSON dei finding con categoria prefix `BACKEND-*`.
