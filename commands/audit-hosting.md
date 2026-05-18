---
description: Audit di ingegnerizzazione hosting profile-aware (Netsons/Aruba/Vercel/Railway/...).
argument-hint: [percorso-progetto]
---

Esegui le istruzioni della skill **audit-hosting** applicandole al progetto in $ARGUMENTS (o cwd).

Carica `general.md` + sub-file profile-specific in base ai marker (vercel.json, railway.json, .htaccess, Dockerfile). Default fallback: profilo Netsons per retrocompat.

Output: JSON dei finding con categoria prefix `HOSTING-*`.
