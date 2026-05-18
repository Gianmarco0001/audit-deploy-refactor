---
description: Audit di email deliverability transport-aware (PHPMailer/Nodemailer/SES/SendGrid/Mailgun).
argument-hint: [percorso-progetto]
---

Esegui le istruzioni della skill **audit-email** applicandole al progetto in $ARGUMENTS (o cwd).

Carica `general.md` + sub-file transport-specific in base alle dipendenze rilevate. Per Laravel applica anche sezione Mail di `frameworks/laravel.md`.

Output: JSON dei finding con categoria prefix `EMAIL-*`.
