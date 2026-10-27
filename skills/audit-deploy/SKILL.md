---
name: audit-deploy
description: |
  Audit pre-deploy modulare e stack-aware. Orchestratore che rileva automaticamente lo stack
  del progetto (PHP/Laravel/Node/Python/Go, MySQL/Postgres/SQLite/Mongo, Netsons/Vercel/Railway)
  e lancia in parallelo le 11 skill granulari rilevanti (backend, frontend, design, mobile UX, database,
  security OWASP, algorithms, SEO, GDPR, hosting, email). Pipeline tier-mix Haiku→Sonnet→Haiku
  con fix loop iterativo e approval gate sui finding critici. Avvia anche la skill
  security-audit di Cloudflare (profilo quick) e fa verificare ogni finding importante
  da un agente indipendente. Usa quando: il progetto e' pronto
  per il deploy, dopo sessioni di vibe-coding, o per verifica periodica di sicurezza e qualita'.
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Grep, Glob, Bash(ls *), Bash(find *), Bash(cat *), Bash(grep *), Bash(test *), Bash(node *), Bash(mkdir *), Bash(git *), Edit, Write, Task, Skill
argument-hint: [percorso-progetto] [--max-iter=N] [--approve-from=low|medium|high|critical] [--no-cloudflare] [--cf-profile=quick|standard|deep] [--cf-budget=N]
---

# Audit Pre-Deploy Pack — Orchestratore

Sei il Lead Auditor. Devi coordinare un audit completo del progetto nella directory corrente (o in $ARGUMENTS se specificato) prima del deploy, lanciando in parallelo le 11 skill granulari rilevanti (audit-design compresa: rifinitura visiva, movimento, rilevatore Impeccable) in base allo stack rilevato.

## Configurazione (parsing da $ARGUMENTS)

Estrai eventuali argomenti opzionali da $ARGUMENTS:

- `--max-iter=N`: numero massimo di iterazioni del fix loop. **Default: 3** (ridotto da v1's 10 per controllo costi). Override esempio: `--max-iter=5`.
- `--approve-from=LEVEL`: da quale severity in su chiedere conferma utente prima di applicare fix. **Default: `high`** (LOW/MEDIUM auto-applicati, HIGH/CRITICAL approval). Valori: `low|medium|high|critical`.
- `--no-cloudflare`: salta il passaggio con la skill `security-audit` di Cloudflare (FASE 2-bis). **Default: attivo.**
- `--cf-profile=quick|standard|deep`: profilo della skill Cloudflare. **Default: `quick`.**
- `--cf-budget=N`: massimo di agenti per la skill Cloudflare. **Default: 20.**

**Protected paths** (SEMPRE approval, indipendente da severity):

- `.env`, `.env.*`
- `composer.json`, `composer.lock`
- `package.json`, `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`
- `.htaccess`
- `*.sql`
- `.git/*`
- `**/database/migrations/**`
- `tauri.conf.json`, `manifest.json`
- `bootstrap/app.php` (Laravel L11+)

## Strategia modelli (risparmio token)

Pipeline a 3 fasi con modelli diversi:

| Fase | Modello | Scopo |
|------|---------|-------|
| FASE 1: Pre-check | **haiku** | Scansione rapida struttura, detect stack/engine/hosting/framework/transport |
| FASE 2: Audit | **sonnet** | Skill granulari rilevanti in parallelo via Task |
| FASE 2-bis: Cloudflare | orchestratore + agenti della skill | `security-audit` di Cloudflare, profilo quick |
| FASE 3a: Dedup e scoring | **haiku** | Dedup cross-skill, scoring confidenza dei BASSO |
| FASE 3b: Verifica avversaria | **sonnet** | Un agente nuovo prova a smentire ogni CRITICO/ALTO/MEDIO |
| FASE 3c: Report | **haiku** | Generazione report |

Opus resta libero per il lavoro principale dell'utente.

---

## FASE 1 — Pre-check (Haiku)

Lancia UN singolo subagent con `model: haiku` tramite il tool Task. Prompt:

```
Sei l'agente di pre-check per audit-deploy-pack. Scansiona velocemente la
struttura del progetto in $ARGUMENTS (o cwd) usando Read/Grep/Glob/Bash.
Consulta le tabelle marker in ${CLAUDE_SKILL_DIR}/detection-rules.md e
rispondi ESCLUSIVAMENTE in formato JSON valido:

{
  "backend": "php|node|python|go|rust|ruby|dotnet|none",
  "framework": "laravel|symfony|codeigniter|none",
  "framework_version": "13.x|12.x|11.x|10.x|legacy|null",
  "database": ["mysql", "postgres", "sqlite", "mongo", "redis"],
  "hosting": "netsons|aruba|vercel|railway|netlify|aws-lambda|self-hosted|unknown",
  "email_transport": "phpmailer|symfony-mailer|nodemailer|python-email|provider:sendgrid|provider:ses|provider:mailgun|provider:postmark|framework-mailer|none",
  "has_html": true/false,
  "has_login": true/false,
  "has_user_data": true/false,
  "has_forms": true/false,
  "has_cookies": true/false,
  "has_analytics": true/false,
  "has_file_upload": true/false,
  "has_api": true/false,
  "php_version": "8.x" or null,
  "node_version": "X.x" or null,
  "estimated_files": N,
  "critical_paths": ["app/", "src/", "public/"]
}

Se estimated_files < 5 o nessuno stack rilevato: imposta backend="none" e segnala.
```

Se il pre-check restituisce `backend: "none"` e `estimated_files < 5`, FERMATI e avvisa l'utente che il progetto e' troppo piccolo o non rilevato.

---

## FASE 2 — Audit parallelo (Sonnet)

Basandoti sul JSON del pre-check, decidi quali skill granulari attivare seguendo le **skip rules** in [detection-rules.md](detection-rules.md):

```
skills_to_run = []
if backend != "none":          skills_to_run += [audit-backend]
if database non vuoto:         skills_to_run += [audit-database]
if has_html:                   skills_to_run += [audit-frontend, audit-mobile-ux, audit-seo, audit-design]
if has_user_data || has_cookies || has_forms: skills_to_run += [audit-gdpr]
if email_transport != "none":  skills_to_run += [audit-email]
if hosting != "unknown":       skills_to_run += [audit-hosting]
skills_to_run += [audit-security, audit-algorithms]  # SEMPRE
```

Logga esplicitamente le skill saltate con motivo (es. *"audit-email skipped: nessun mailer rilevato"*).

**Lancia in PARALLELO** (single message, multiple Task tool calls) i subagenti delle skill rilevate con `model: sonnet`. Prompt per ogni subagent:

```
Sei un sotto-agente di audit-deploy-pack invocato dall'orchestratore.
Esegui esattamente le istruzioni in ${CLAUDE_SKILL_DIR}/../<skill-name>/SKILL.md
applicandole al progetto in $ARGUMENTS.

Profile stack rilevato dal pre-check:
<incolla qui il JSON del pre-check>

Restituisci ESCLUSIVAMENTE un JSON con questo schema:
{
  "agent": "<skill-name>",
  "findings": [
    {
      "id": "<SKILL_PREFIX>-NNN",
      "severity": "CRITICO|ALTO|MEDIO|BASSO",
      "file": "path/to/file:riga",
      "problema": "descrizione concisa",
      "soluzione": "fix raccomandato",
      "categoria": "categoria specifica (es. OWASP A01, LARAVEL-AUTHZ, WCAG 2.1)"
    }
  ],
  "summary": {
    "critico": N,
    "alto": N,
    "medio": N,
    "basso": N
  }
}
```

I subagenti hanno `allowed-tools` SENZA `Edit` (solo Read/Grep/Glob/Bash): non possono modificare file. Le modifiche le applichi tu nell'orchestrator dopo l'approval gate (FASE 4).

Il sotto-agente di `audit-security` NON avvia la skill di Cloudflare: la avvii tu nella FASE 2-bis.

---

## FASE 2-bis — Cloudflare security-audit (salvo `--no-cloudflare`)

La skill si installa a parte (`npx skills add https://github.com/cloudflare/security-audit-skill --skill security-audit --global`). **Se il tool Skill non la trova**, salta questa fase e scrivi in `$CLOUDFLARE_RUN` «non installata: passaggio saltato».

Dopo che i subagenti della FASE 2 hanno risposto, invoca tu (orchestratore) la skill `security-audit` con il tool Skill. Sei tu il «parent» del suo flusso: i suoi agenti li lanci tu con Task, come descrive la skill. Questa invocazione È la richiesta esplicita di **full audit mode**: non chiedere di nuovo quale modalità.

- **Profilo:** `--cf-profile` (default `quick`). **Budget:** `--cf-budget` (default 20 invocazioni di agenti). Se il budget non basta, la skill lo dice e si ferma: riportalo nel report invece di alzarlo da solo.
- **Target:** la radice del repository. **Output:** `~/security-audit-skill/<nome-repo>/run-<N>`, fuori dal repository. I run precedenti vengono riletti (le passate si sommano).
- **Companion** per app web PHP/Laravel: WEB-PROTOCOL-AND-AUTH, CLIENT-SIDE, DATA-ISOLATION-AND-LIFECYCLE, SUPPLY-CHAIN-AND-RELEASE, RESOURCE-EXHAUSTION-AND-AVAILABILITY. Aggiungi CLOUD-AND-DEPLOYMENT se `has_api` o ci sono file di deploy, AI-AND-LLM solo se il progetto chiama un modello linguistico. Altri stack: scegli secondo `RECONNAISSANCE.md` della skill.
- **Sandbox:** senza sandbox di sistema senza rete, NON eseguire codice del progetto; quei casi restano `needs_validation`.
- **Prima dei suoi hunter**, passa alla skill la lista dei finding di `audit-security` della FASE 2 come «candidati già noti da validare», così la sua fase di validazione li conferma o li smentisce senza ricacciarli.

Converti il suo `findings.json` nel formato della FASE 2, con `"agent": "cloudflare-security-audit"`:

- `confirmed` → severity tradotta (critical→CRITICO, high→ALTO, medium→MEDIO, low e informational→BASSO), `categoria: "CF-<attack-class>"`, campo `"verificato": true`;
- `needs_validation` → `"severity": "DA-VERIFICARE"` con il fatto da controllare;
- `rejected` → non riportarli; se smentiscono un finding di `audit-security`, quel finding va tolto (annotalo nel log).

---

## FASE 3a — Dedup e scoring (Haiku)

Dopo la FASE 2 e la FASE 2-bis, lancia UN agente con `model: haiku` via Task. Prompt:

```
Sei l'agente di dedup per audit-deploy-pack. Ricevi i finding aggregati di
tutte le skill granulari e di Cloudflare (input JSON sotto).

1. DEDUPLICAZIONE CROSS-SKILL: se piu' skill hanno segnalato lo stesso problema
   sullo stesso file:riga, unificali (preferisci la categoria piu' specifica).
   Esempio: SQLi visto da audit-security E audit-database -> tienine 1 sola con
   categoria del piu' specifico (audit-database). Se uno dei due e' di
   cloudflare-security-audit con "verificato": true, tieni quello.

2. SCORING solo per i finding BASSO: confidenza 0-100 (0 falso positivo certo,
   25 possibile, 50 reale ma minore, 75 reale e importante, 100 certo e grave).
   Rimuovi i BASSO con confidenza < 60.

3. Lascia invariati i CRITICO/ALTO/MEDIO e i DA-VERIFICARE: li verifica la FASE 3b.

Restituisci il JSON dei finding rimasti, nello stesso schema.
```

## FASE 3b — Verifica avversaria (Sonnet)

Per ogni finding CRITICO, ALTO o MEDIO **non** marcato `"verificato": true`, lancia un agente NUOVO con `model: sonnet` (mai lo stesso che l'ha trovato), in parallelo, al massimo uno per finding. Prompt:

```
Sei un verificatore avversario per audit-deploy-pack. Il tuo compito e'
SMENTIRE questo finding leggendo il codice, non confermarlo.

<finding JSON>

1. Apri il file e la riga indicati e segui il percorso reale: chi puo' arrivare
   a quel codice, con quali controlli prima (middleware, policy, validazione,
   escape, configurazione nel repository).
2. Se un controllo blocca gia' l'attacco, il finding e' smentito o e' solo
   irrobustimento.
3. Se il danno dipende da configurazione fuori dal repository (hosting,
   Cloudflare, servizi esterni), il verdetto e' DA-VERIFICARE con il fatto preciso.
4. Non eseguire nulla contro servizi esterni o siti in produzione.

Rispondi SOLO con JSON:
{"id": "...", "verdetto": "confermato|smentito|declassato|da-verificare",
 "severity_corretta": "CRITICO|ALTO|MEDIO|BASSO|null",
 "motivo": "percorso nel codice che lo dimostra (file:riga)",
 "da_verificare": "fatto preciso, solo se da-verificare"}
```

Applica i verdetti: `smentito` → togli il finding; `declassato` → usa `severity_corretta`; `da-verificare` → sposta nei DA-VERIFICARE; `confermato` → resta, con `"verificato": true`.

## FASE 3c — Report (Haiku)

Lancia UN agente con `model: haiku` via Task. Prompt:

```
Sei l'agente di report per audit-deploy-pack. Ricevi i finding verificati
(input JSON sotto). Genera AUDIT-REPORT.md (o AUDIT-REPORT-v$N.md per
iterazioni > 1) nella root del progetto, usando il template:
!`cat "${CLAUDE_SKILL_DIR}/templates/report-template.md"`

Popola i placeholder ($PROJECT_NAME, $DATE, $STACK, $ITERATION, $SKILLS_RUN,
$SKILLS_SKIPPED, $CLOUDFLARE_RUN) e tutte le sezioni con i dati reali. I
DA-VERIFICARE vanno nella loro sezione, senza gravita'. Per ogni finding indica
se e' stato verificato da un agente indipendente.

Restituisci il path del report generato + numero totale finding finali.
```

---

## FASE 4 — Fix loop con approval gate (Sonnet, max N iter)

Dopo il primo report, leggi AUDIT-REPORT.md e applica fix:

1. **LOW/MEDIUM**: applica direttamente con tool Edit. Commenta ogni fix con `// AUDIT-FIX: [descrizione]` (o equivalente per il linguaggio: `// AUDIT-FIX:`, `# AUDIT-FIX:`, `<!-- AUDIT-FIX: -->`).

2. **HIGH/CRITICAL** (se `--approve-from=high` o superiore): mostra il diff proposto all'utente e ATTENDI conferma esplicita prima di applicare. Non procedere senza approvazione.

3. **Protected paths** (vedi configurazione sopra): SEMPRE approval, indipendente da severity. Mostra il diff e attendi conferma.

4. **Re-run incrementale**: dopo aver applicato fix, identifica quali skill sono state toccate (file modificati appartengono al loro scope) e re-invoca SOLO quelle skill in FASE 2 (non tutte). Se i fix toccano codice di sicurezza, rilancia anche la FASE 2-bis come **scoped run** sui soli file modificati (la skill Cloudflare rilegge il run precedente). Riesegui FASE 3a-3c sui nuovi finding.

5. **Iterazione**: ripeti fino a 0 finding rilevanti o fino a raggiungere `max_iterations` (default 3).

6. Se 0 finding restanti: genera `FINAL-AUDIT-REPORT.md`.
7. Se ancora finding al raggiungimento di `max_iterations`: genera `FINAL-AUDIT-REPORT.md` con sezione "Finding non risolti — RICHIEDONO INTERVENTO MANUALE" e raccomandazioni.

**Regole di fix**:

- NON toccare logica di business. Solo fix di sicurezza, performance, compliance, best practices.
- Se serve modifica architetturale, segnala come `RICHIEDE INTERVENTO MANUALE` nel report e non auto-fixare.
- Mai applicare fix senza che il finding abbia confidenza ≥ 60 (FASE 3 li ha già filtrati).
- Non applicare fix ai DA-VERIFICARE: prima va controllato il fatto indicato.
- Su un finding ambiguo: chiedi all'utente prima di applicare.

---

## Compatibilita' retro v1 (PHP+MySQL+Netsons)

Su un progetto PHP+MySQL+Netsons:

- Pre-check rileva: `backend=php`, `framework=none`, `database=[mysql]`, `hosting=netsons`, `email_transport=phpmailer` (se PHPMailer presente).
- Skill attivate: tutte le 10.
- Sub-file caricati: `audit-backend/checklists/{general.md, php.md}`, `audit-database/checklists/{general.md, mysql.md}`, `audit-hosting/checklists/{general.md, netsons.md}`, `audit-email/checklists/{general.md, php-phpmailer.md}`, le altre 6 skill caricano la propria `general.md`/`desktop.md`/`owasp.md`.
- Risultato: equivalente funzionale del v1 (concatenazione dei sub-file = vecchie checklist v1, verificato da `tests/non-regression/check-bundle-equivalence.sh`).

## Fonti e riferimenti

- OWASP Top 10:2025 — <https://owasp.org/Top10/2025/>
- Garante italiano cookie guidelines (giugno 2021)
- Laravel 13.x Documentation — <https://laravel.com/docs/13.x/>
- WCAG 2.1 Level AA
- Mobile UX Best Practices 2026
- Detection rules: [detection-rules.md](detection-rules.md)
- Report template: [templates/report-template.md](templates/report-template.md)
- Cloudflare security-audit (MIT, da installare a parte): <https://github.com/cloudflare/security-audit-skill>

