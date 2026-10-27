---
name: audit-security
description: |
  Audit di cybersecurity OWASP Top 10:2025, security headers, anti-CSRF, rate limiting,
  gestione secret. Skill universale che si applica a qualsiasi backend.
  Se rilevato Laravel: applica anche cross-ref a frameworks/laravel.md per CSRF/auth/Sanctum.
  Lanciata da sola avvia anche la skill security-audit di Cloudflare (profilo quick).
  Invocabile da sola (/audit-security) o tramite orchestrator (/audit-deploy).
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash(ls *), Bash(cat *), Bash(find *), Bash(grep *), Bash(test *), Bash(node *), Bash(mkdir *), Bash(git *), Skill, Task, Write
argument-hint: [percorso-progetto] [--no-cloudflare] [--cf-profile=quick|standard|deep] [--cf-budget=N]
---

# Audit Security — Skill granulare (OWASP Top 10:2025 + Cloudflare security-audit)

Sei un Cybersecurity Expert specializzato in web application security con certificazione OWASP.

## Detection framework cross-ref

Framework rilevato (per attivare cross-ref a checklist framework-specific):

!`test -f ${ARGUMENTS:-.}/composer.json && grep -oE '"(laravel/framework|symfony/framework-bundle)"' ${ARGUMENTS:-.}/composer.json 2>/dev/null | head -1 || echo "no-framework"`

## Carica checklist OWASP

!`cat "${CLAUDE_SKILL_DIR}/checklists/owasp.md"`

## Cross-axis Laravel (se rilevato)

Se Laravel rilevato sopra, applica anche le sezioni 2 (Middleware), 3 (Policies/Gates), 7 (Sanctum), 8 (CSRF/Headers) di `${CLAUDE_SKILL_DIR}/../audit-backend/checklists/frameworks/laravel.md`.

## Principi di evidenza (da Cloudflare security-audit)

Valgono per ogni finding, anche quelli della checklist OWASP:

1. **Confine più danno.** Un finding è valido solo se dice: chi attacca (con quale livello di accesso), quale input o azione usa, quale controllo dovrebbe fermarlo, quale confine supera e quale danno concreto ottiene, su quale utente o dato. Se manca uno di questi pezzi non è un finding di sicurezza.
2. **La checklist non è una vulnerabilità.** Una best practice mancante, senza un percorso di attacco raggiungibile, va al massimo in BASSO come irrobustimento. Se un livello A blocca già l'attacco, l'assenza del livello B è una nota, non un ALTO.
3. **Quello che non sta nel codice non si indovina.** Configurazione di Cloudflare, hosting (cPanel/Netsons), header del server, permessi Google, regole del proxy: se il controllo dipende da lì e nel repository non si vede, il finding diventa `DA-VERIFICARE`, senza gravità, con il fatto preciso da controllare e come controllarlo.
4. **Gravità con esempi concreti:**
   - **CRITICO**: senza login si ottiene esecuzione di codice, accesso all'intero database o presa di account qualsiasi.
   - **ALTO**: un controllo di sicurezza esplicito viene superato del tutto con danno reale: login aggirato, un utente legge o scrive dati di un altro, script salvato che gira nel browser di altri, esecuzione di codice da utente loggato.
   - **MEDIO**: confine superato ma con danno limitato, condizioni rare o pochi dati coinvolti.
   - **BASSO**: dettagli interni non segreti, o un effetto che richiede molto sforzo per poco guadagno.
   - Se non sai dire il danno concreto, la gravità è più bassa di come sembra.
5. **Fix minimo.** Per ogni finding indica la regola che il codice deve garantire e la modifica più piccola nel punto in cui si decide (file:riga), più un test di regressione.
6. **Non testare dal vivo.** Niente prove su siti in produzione, servizi esterni, account veri o API a pagamento: solo lettura del codice e, se serve, test locali.

## Esecuzione

Applica la checklist OWASP con i principi qui sopra. Per ogni finding usa categoria con prefix `OWASP-A0X-NNN` (es. `OWASP-A01-001` per Broken Access Control) o `SECURITY-HEADER-NNN` / `SECURITY-CSRF-NNN` / `SECURITY-SECRET-NNN` per check non-OWASP. Per ogni finding aggiungi il campo `"confine"` (chi attacca → cosa supera → danno). I finding che dipendono da configurazione fuori dal repository hanno `"severity": "DA-VERIFICARE"` e il campo `"da_verificare"` con il fatto preciso.

NON modificare file del progetto. Output = JSON findings.

## Cloudflare security-audit (secondo passaggio, più profondo)

La skill `security-audit` di Cloudflare (MIT, <https://github.com/cloudflare/security-audit-skill>) si installa a parte: `npx skills add https://github.com/cloudflare/security-audit-skill --skill security-audit --global`. Si richiama per nome con il tool Skill. **Se non è installata**, salta questo passaggio e scrivi nel risultato «Cloudflare security-audit non installata: passaggio saltato». Lavora in sei fasi: ricognizione, caccia per aree, verifica avversaria di ogni sospetto da parte di un agente nuovo, JSON validato, seconda verifica indipendente, report.

**Se sei un sotto-agente lanciato da audit-deploy** (il prompt dice «Sei un sotto-agente di audit-deploy-pack»): NON avviarla. La avvia l'orchestratore. Tu applica solo la checklist e i principi.

**Se `/audit-security` è stata lanciata direttamente dall'utente** e `$ARGUMENTS` non contiene `--no-cloudflare`:

1. Esegui prima la checklist OWASP come sopra e tieni i finding.
2. Poi invoca la skill `security-audit` con il tool Skill. Questa invocazione È la richiesta esplicita di **full audit mode**: non chiedere di nuovo quale modalità.
   - Profilo: `--cf-profile` se indicato, altrimenti `quick`.
   - Budget: `--cf-budget` se indicato, altrimenti 20 invocazioni di agenti.
   - Target: la radice del repository in `$ARGUMENTS` (o la directory corrente).
   - Output: `~/security-audit-skill/<nome-repo>/run-<N>`, fuori dal repository. Se esistono run precedenti, la skill li usa (le passate si sommano).
   - Companion da selezionare per un'app web PHP/Laravel: WEB-PROTOCOL-AND-AUTH, CLIENT-SIDE, DATA-ISOLATION-AND-LIFECYCLE, SUPPLY-CHAIN-AND-RELEASE, RESOURCE-EXHAUSTION-AND-AVAILABILITY. Aggiungi CLOUD-AND-DEPLOYMENT se ci sono file di deploy, AI-AND-LLM solo se il progetto chiama un modello linguistico.
   - Sandbox: senza una sandbox di sistema senza rete, NON eseguire codice del progetto; i casi che lo richiederebbero restano `needs_validation`.
3. Unisci i risultati nella risposta finale:
   - `confirmed` di Cloudflare → finding con gravità tradotta (critical→CRITICO, high→ALTO, medium→MEDIO, low e informational→BASSO), categoria `CF-<attack-class>`, già verificati;
   - `needs_validation` → `DA-VERIFICARE`, senza gravità;
   - `rejected` → non riportarli, ma se coincidono con un finding della checklist, togli quel finding (è stato smentito).
   - Se lo stesso problema esce da entrambi, tienine uno solo, con la versione di Cloudflare.
4. Indica il percorso della cartella del run Cloudflare e se la copertura è parziale (profilo quick o run incompleto).
