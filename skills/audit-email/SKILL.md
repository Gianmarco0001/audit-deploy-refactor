---
name: audit-email
description: |
  Audit di email deliverability, SMTP, SPF/DKIM/DMARC, transport-aware (PHPMailer/Nodemailer/
  SES/SendGrid/Mailgun/Postmark). Detect automatico via dipendenze. Verifica header injection,
  rate limiting, template, bounce handling. Invocabile da sola (/audit-email) o tramite
  orchestrator (/audit-deploy).
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash(ls *), Bash(cat *), Bash(find *), Bash(grep *), Bash(test *)
argument-hint: [percorso-progetto]
---

# Audit Email — Skill granulare transport-aware

Sei un esperto di Email Deliverability e configurazione SMTP per applicazioni web.

## Transport detection

Mailer library/provider rilevati nelle dipendenze:

!`(test -f ${ARGUMENTS:-.}/composer.json && grep -oE '"(phpmailer/phpmailer|symfony/mailer|illuminate/mail)"' ${ARGUMENTS:-.}/composer.json) 2>/dev/null; (test -f ${ARGUMENTS:-.}/package.json && grep -oE '"(nodemailer|@sendgrid/mail|@aws-sdk/client-ses|mailgun\.js|postmark)"' ${ARGUMENTS:-.}/package.json) 2>/dev/null; (test -f ${ARGUMENTS:-.}/requirements.txt && grep -iE '^(sendgrid|boto3|mailgun|postmark)' ${ARGUMENTS:-.}/requirements.txt) 2>/dev/null; echo "---"`

Pattern di invio email nel codice:

!`grep -rE '(mail\(|sendmail|->send\(|sendMail|smtplib)' ${ARGUMENTS:-.} --include='*.php' --include='*.js' --include='*.ts' --include='*.py' -l 2>/dev/null | head -3 || echo "NO-MAIL-CODE"`

Se nessun transport ne' pattern di invio rilevato, restituisci JSON vuoto con messaggio *"audit-email skipped: nessun mailer rilevato"*.

## Carica checklist universale

!`cat "${CLAUDE_SKILL_DIR}/checklists/general.md"`

## Sub-file da caricare on-demand

Usa il tool **Read** per i sub-file dei transport rilevati:

- `phpmailer/phpmailer` o `symfony/mailer` o pattern PHP `mail()` → Read `${CLAUDE_SKILL_DIR}/checklists/php-phpmailer.md`
- `nodemailer` → Read `${CLAUDE_SKILL_DIR}/checklists/node-nodemailer.md`
- Provider esterno (`@sendgrid/mail`, `@aws-sdk/client-ses`, `mailgun.js`, `boto3` ses, `postmark`) → Read `${CLAUDE_SKILL_DIR}/checklists/smtp-external.md`

Per Laravel (`illuminate/mail` presente) usa il sub-file `php-phpmailer.md` (PHP underlying) + applica anche sezione 9 di `${CLAUDE_SKILL_DIR}/../audit-backend/checklists/frameworks/laravel.md` per Mailable+ShouldQueue.

## Esecuzione

Applica le checklist. Categoria prefix: `EMAIL-GENERAL-NNN`, `EMAIL-PHP-NNN`, `EMAIL-NODEMAILER-NNN`, `EMAIL-EXTERNAL-NNN`.

NON modificare file. Output = JSON findings.
