---
description: Audit di sicurezza database engine-aware (MySQL/Postgres/SQLite/Mongo) e prevenzione injection.
argument-hint: [percorso-progetto]
---

Esegui le istruzioni della skill **audit-database** applicandole al progetto in $ARGUMENTS (o cwd).

Carica `general.md` + sub-file engine-specific (mysql/postgres/sqlite/mongo) in base ai driver rilevati. Per Laravel, applica anche cross-ref a Eloquent.

Output: JSON dei finding con categoria prefix `DATABASE-*`.
