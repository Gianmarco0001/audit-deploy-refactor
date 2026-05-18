# Checklist — Database MongoDB 8.x (engine-specific)

Sei un Database Security Expert specializzato in MongoDB. Questa checklist e' applicata in AGGIUNTA a `general.md`. Validata su MongoDB Security Checklist ufficiale (mongodb.com/docs/manual/administration/security-checklist/).

## CHECKLIST MONGODB 8.x

### 1. Authentication & Access Control

- [ ] **`security.authorization: enabled`** in `mongod.conf` (no `--noauth` flag)
- [ ] **SCRAM-SHA-256** come default authentication mechanism
- [ ] User admin creato PRIMA degli application user
- [ ] X.509 client certificate authentication per cluster nodes
- [ ] Enterprise: LDAP / Kerberos integration per SSO

### 2. Authorization (RBAC) — least privilege

- [ ] Application user con role minimo: `readWrite` su specifico DB, no `dbAdmin`/`clusterAdmin`
- [ ] **MAI** role `__system` su utenti applicativi
- [ ] **MAI** role `root` o `userAdminAnyDatabase` su utenti applicativi
- [ ] Custom role se built-in troppo permissivi: `db.createRole({...})`
- [ ] Single user per multi-DB access se necessario (evita duplicazione credenziali)
- [ ] Audit periodico: `db.getUsers()` su ogni DB

### 3. Network isolation

- [ ] `net.bindIp` esplicito (IP specifici), **MAI** `0.0.0.0`:
  ```yaml
  net:
    bindIp: 10.0.1.5,127.0.0.1
    port: 27017
  ```
- [ ] `clusterIpSourceAllowlist` per replica set communication
- [ ] Firewall / security group: porta 27017 chiusa a internet
- [ ] VPC / private network per cluster
- [ ] `authenticationRestrictions` per IP allowlist per-user:
  ```javascript
  db.createUser({ ..., authenticationRestrictions: [{clientSource: ["10.0.0.0/8"]}] })
  ```

### 4. Encryption in transit (TLS/SSL)

- [ ] `net.tls.mode: requireTLS` (no `allowTLS` o `preferTLS` in prod)
- [ ] `tls.certificateKeyFile` e `tls.CAFile` configurati
- [ ] Connection string driver: `mongodb+srv://user:pass@host/?tls=true&retryWrites=true`
- [ ] No `tlsAllowInvalidCertificates=true` in prod

### 5. Encryption at rest

- [ ] **Enterprise / Atlas**: WiredTiger encryption engine
  ```yaml
  security:
    encryptionAtRest:
      enabled: true
      kmip: { serverCAFile, keyFile }
  ```
- [ ] **Community**: OS-level encryption (dm-crypt/LUKS Linux, BitLocker Windows)
- [ ] File permission: `0600` su key files, `0700` su data directory
- [ ] Owner: utente `mongodb`, MAI root

### 6. Server-side JavaScript

- [ ] `--noscripting` o `security.javascriptEnabled: false` se non usi `mapReduce`, `$where`, `$accumulator`, `$function`
- [ ] Riduce attack surface per code injection

### 7. NoSQL Injection prevention (lato driver)

- [ ] Input validation lato driver: blocca operatori con prefisso `$` e chiavi con `.` se non intenzionali
- [ ] Sanitize JSON body request: pacchetti `mongo-sanitize` (Node), `bson_sanitize`, custom middleware
- [ ] Schema validation lato app: Joi, Zod, Yup PRIMA di passare a query
- [ ] MAI `$where` con input utente (eval-equivalent server-side)
- [ ] **Mongoose**: upgrade a **>= 8.9.5** (CVE-2025-23061: `$where` + `populate()` injection)

### 8. Schema validation lato DB

- [ ] **`$jsonSchema`** validator su collection critiche:
  ```javascript
  db.createCollection("users", {
    validator: {
      $jsonSchema: {
        bsonType: "object",
        required: ["email", "createdAt"],
        properties: {
          email: { bsonType: "string", pattern: "^[^@]+@[^@]+$" }
        }
      }
    }
  })
  ```
- [ ] `validationLevel: "strict"`, `validationAction: "error"` (non `"warn"`)

### 9. Driver hardening

- [ ] Connection pool: `maxPoolSize: 50`, `minPoolSize: 5`
- [ ] Retry policy: `retryWrites: true`, `retryReads: true`
- [ ] Driver versione recente con CVE fix
- [ ] Timeout: `serverSelectionTimeoutMS`, `connectTimeoutMS`, `socketTimeoutMS` espliciti

### 10. Resource constraints

- [ ] `net.maxIncomingConnections` dimensionato (default ~65k, ridurre per evitare exhaustion)
- [ ] `replication.oplogSizeMB` adeguato per finestra recovery
- [ ] `storage.wiredTiger.engineConfig.cacheSizeGB` ~50% RAM disponibile

### 11. Auditing (Enterprise)

- [ ] `auditLog.destination: file`, `format: JSON`
- [ ] Filter su eventi critici: `authenticate`, `authCheck`, `createUser`, `dropUser`, `dropDatabase`
- [ ] Centralizzazione log esterna (ELK, Splunk)
- [ ] Retention conforme a compliance (GDPR, PCI-DSS, HIPAA)

### 12. Antivirus / EDR exclusions

- [ ] Escludere `storage.dbPath` da scanning (data files compressed/encrypted, scan = performance kill)
- [ ] Escludere `systemLog.path` da scanning

### 13. Versione & patching

- [ ] **MongoDB 8.x** latest in nuovi deploy
- [ ] **7.x** stable, **6.x** in maintenance, **5.x** EOL → upgrade obbligatorio
- [ ] Subscribe MongoDB CVE alerts: <https://www.mongodb.com/alerts>
- [ ] Patch OS mensile, review firewall trimestrale
- [ ] Rotazione password / certificate ogni 90 giorni

### 14. Queryable Encryption (8.0+)

- [ ] Per dati altamente sensibili (PII, financial), considera Queryable Encryption (encrypted query)
- [ ] Compaction metadata collections mensile (maintenance task)

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: `mongod.conf` / `path/to/file:riga` (codice app)
- **Problema**: descrizione
- **Soluzione**: fix con config snippet o codice driver
- **Categoria**: prefix `DATABASE-MONGO-NNN`

## RIFERIMENTI

- MongoDB Security Checklist: <https://www.mongodb.com/docs/manual/administration/security-checklist/>
- MongoDB CVE Alerts: <https://www.mongodb.com/alerts>
- Mongoose CVE-2025-23061: <https://github.com/Automattic/mongoose/security/advisories>
- MongoDB Release Lifecycle: <https://www.mongodb.com/support-policy/lifecycles>
