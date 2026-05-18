# Checklist — CodeIgniter 4.x (framework-specific)

Sei un Senior CodeIgniter Developer specializzato in security. Questa checklist e' applicata in AGGIUNTA a `php.md` e `general.md` quando `composer.json` contiene `codeigniter4/framework`. Validata su CI4 ufficiale (codeigniter4.github.io/userguide/concepts/security.html).

## CHECKLIST CODEIGNITER 4.x

### 1. CSRF Protection

- [ ] `Config\Security::$csrfProtection` abilitato (modalita': `'cookie'` o `'session'`)
- [ ] `csrf_field()` helper in tutti i form POST/PUT/DELETE
- [ ] `Config\Security::$csrfExcludeUris` minimo (solo webhook firmati)
- [ ] `Config\Security::$tokenRandomize = true` per token rotation per-request
- [ ] CSRF token sempre validato server-side (filter `csrf` su rotte non-API)

### 2. XSS / Output escaping

- [ ] **`esc($var)`** helper applicato in TUTTE le view che renderizzano variabili
- [ ] Context-specific escaping: `esc($var, 'html')`, `'js'`, `'css'`, `'attr'`, `'url'`, `'raw'` (no escape)
- [ ] **MAI** `echo $userInput` o `<?= $userInput ?>` senza `esc()`
- [ ] Twig/Plates engine esterni: verifica auto-escape ON

### 3. SQL Injection prevention

- [ ] Query Builder con parametri: `$db->table('users')->where('id', $id)->get()`
- [ ] **MAI** `$db->query("SELECT * FROM users WHERE id = $id")` raw concat
- [ ] Se `query()` necessario: bind esplicito `$db->query("... WHERE id = ?", [$id])`
- [ ] Model `useSoftDeletes`, `allowedFields` esplicito (no mass assignment)
- [ ] `validationRules` definiti in Model per validation pre-save

### 4. Input validation

- [ ] **Validation Library** sempre attiva su input utente:
  - Controller: `$validation->setRules([...])`, `$validation->withRequest($request)->run()`
  - Config: `app/Config/Validation.php` per rules riutilizzabili
- [ ] Rules: `required`, `valid_email`, `min_length[8]`, `regex_match[...]`, `is_unique[users.email]`
- [ ] Form Request pattern: `app/Filters/` filter custom per validation centralizzata
- [ ] `Services::request()` invece di `$_POST` raw

### 5. Encryption & secrets

- [ ] `Config\Encryption::$key` impostata in `.env` (formato `hex2bin:...` o `base64:...`)
- [ ] **MAI** chiave hardcoded in `app/Config/Encryption.php`
- [ ] **MAI** `encryption.key` con valore default (`DEFAULT_KEY` non deve apparire)
- [ ] Algoritmo: `'OpenSSL'` (moderno), non `'Sodium'`/`'MCrypt'` deprecato
- [ ] DB password e API key in `.env`, mai in config files committati
- [ ] `.env` in `.gitignore` (verifica esplicita)

### 6. Authentication & Authorization

- [ ] **CodeIgniter Shield** (pacchetto ufficiale CI4 auth) raccomandato per progetti nuovi
- [ ] Password hashing: `password_hash($pw, PASSWORD_DEFAULT)` (bcrypt/argon2id automatic), MAI MD5/SHA1
- [ ] **NO** default credentials nel codice (audit grep `admin`/`password`)
- [ ] Session ID rigenerato dopo login: `$session->regenerate(true)`
- [ ] Multi-factor authentication via Shield o pacchetto esterno per ruoli admin
- [ ] Throttler library per rate limiting login: `$throttler->check($key, $capacity, MINUTE)`

### 7. Session security

- [ ] `Config\App::$sessionDriver`:
  - **Preferito**: `\CodeIgniter\Session\Handlers\DatabaseHandler` o `\CodeIgniter\Session\Handlers\RedisHandler`
  - **EVITARE**: `\CodeIgniter\Session\Handlers\FileHandler` su shared hosting (lock contention I/O)
- [ ] `$sessionCookieName` univoco per app (non `ci_session` default)
- [ ] `$sessionExpiration = 7200` (2h) ragionevole; ridurre per app sensibili
- [ ] `$sessionMatchIP = true` solo se rete stabile (puo' rompere mobile)
- [ ] `$sessionTimeToUpdate = 300` per rotazione session ID

### 8. Cookies

- [ ] `Config\Cookie`:
  - `'secure' => true` (HTTPS only)
  - `'httponly' => true`
  - `'samesite' => 'Lax'` minimo, `'Strict'` per banking
  - `'prefix'` univoco se multi-app stesso dominio

### 9. Security Headers

- [ ] Filter `\CodeIgniter\Filters\SecureHeaders` registrato in `Config\Filters::$globals['before']`
- [ ] `Config\ContentSecurityPolicy` configurato (Content-Security-Policy):
  - `defaultSrc = "'self'"`
  - `scriptSrc` whitelist esplicita (no `'unsafe-inline'`)
  - `imgSrc`, `fontSrc`, `connectSrc` configurati
- [ ] HSTS: `strict-transport-security: max-age=31536000; includeSubDomains` (via web server o filter)
- [ ] `X-Content-Type-Options: nosniff` (default in `SecureHeaders` filter)
- [ ] `X-Frame-Options: DENY` o `SAMEORIGIN`

### 10. Filters & routing

- [ ] Custom auth filters: `app/Filters/AuthFilter.php` registrato in `Config\Filters`
- [ ] Throttler filter applicato a `/login`, `/register`, `/reset-password`, API endpoints
- [ ] `\CodeIgniter\Filters\InvalidChars` filter abilitato (blocca pattern URI malevoli)
- [ ] **Routes definite esplicite** preferite ad **auto-routing** (auto-routing legacy, security risk)
- [ ] Admin routes con gruppo + filter dedicato: `$routes->group('admin', ['filter' => 'auth:admin'], ...)`

### 11. Configuration & deploy

- [ ] **`CI_ENVIRONMENT=production`** in `.env` (default `development` espone debug)
- [ ] `Config\App::$baseURL` da env: `app.baseURL = env('app.baseURL')`
- [ ] `php.ini`: `display_errors=0` in produzione
- [ ] CI Debug toolbar disabilitato in produzione: `Config\Toolbar` o `CI_DEBUG=false`
- [ ] `Config\App::$forceGlobalSecureRequests = true` per forzare HTTPS
- [ ] `composer install --no-dev --optimize-autoloader --classmap-authoritative`
- [ ] Permessi: `writable/` chmod 775, `public/` 755, file PHP 644

### 12. Logging

- [ ] `Config\Logger::$threshold = 5` (warning) o `4` (notice) in produzione (no debug)
- [ ] Log path fuori da `public/`: default `WRITEPATH . 'logs/'` ok
- [ ] Rotation log: `Config\Logger::$dateFormat`, rotation via cron o logrotate OS
- [ ] **NO** dati sensibili nei log (password, token, PAN)

### 13. Dependencies

- [ ] `composer audit` clean nel CI/CD
- [ ] CodeIgniter 4.5+ in produzione (security patch current)
- [ ] PHP 8.1+ minimo per CI 4.5, PHP 8.2+ raccomandato

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file.php:riga o `app/Config/*.php`
- **Problema**: descrizione
- **Soluzione**: fix con esempio
- **Categoria**: prefix `CODEIGNITER-CSRF-NNN`, `CODEIGNITER-AUTHZ-NNN`, `CODEIGNITER-CONFIG-NNN`, ecc.

## RIFERIMENTI

- CodeIgniter 4 Security: <https://codeigniter4.github.io/userguide/concepts/security.html>
- CodeIgniter Shield (auth): <https://shield.codeigniter.com/>
- CodeIgniter Releases: <https://codeigniter.com/user_guide/installation/upgrading.html>
