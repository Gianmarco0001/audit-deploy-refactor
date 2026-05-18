# Checklist — Symfony 7.x (framework-specific)

Sei un Senior Symfony Developer specializzato in security. Questa checklist e' applicata in AGGIUNTA a `php.md` e `general.md` quando `composer.json` contiene `symfony/framework-bundle`. Validata su Symfony 7.x ufficiale (symfony.com/doc/current/security.html). Note di retrocompat per 6.4 LTS.

## CHECKLIST SYMFONY 7.x

### 1. Firewalls (`config/packages/security.yaml`)

- [ ] `dev` firewall con `security: false` per `/_profiler`, `/_wdt`, `/assets`, `/build` (no auth in tooling)
- [ ] `main` firewall con `pattern` esplicito o nessuno (= default), `lazy: true` per cache HTTP
- [ ] Un solo firewall attivo per request (ordine importa: non-pattern deve essere LAST)
- [ ] Provider assegnato a ogni firewall: `provider: app_user_provider`
- [ ] Audit `php bin/console security:debug` per verificare config

### 2. Password hashing

- [ ] `password_hashers`: usa `'auto'` per bcrypt/argon2id automatic migration (Symfony 5.3+)
- [ ] **MAI** plaintext password: `User::getPassword()` deve ritornare hash
- [ ] Algoritmo esplicito: `algorithm: 'argon2id'` raccomandato, `bcrypt` accettabile
- [ ] `UserPasswordHasherInterface` usato in registration/reset, mai chiamate dirette legacy
- [ ] Test rapido: `php bin/console security:hash-password`

### 3. User Provider

- [ ] Entity provider con `class: App\Entity\User` e `property: email` (o username)
- [ ] User implementa `UserInterface` + `PasswordAuthenticatedUserInterface`
- [ ] `getRoles()` ritorna array con almeno `ROLE_USER` di default
- [ ] Chain provider se multiple sorgenti (LDAP + DB)

### 4. Authentication methods

- [ ] **Form Login**: `form_login: { login_path: app_login, check_path: app_login, enable_csrf: true }`
  - Template: `<input name="_username">`, `<input name="_password">`, CSRF token
  - `AuthenticationUtils::getLastAuthenticationError()` per error messaging
- [ ] **JSON Login**: `json_login: { check_path: api_login }` + `#[CurrentUser]` attribute
- [ ] **HTTP Basic**: **SOLO HTTPS** in produzione, mai senza TLS
- [ ] **Login Link** (passwordless): TTL breve, single-use, signed URL
- [ ] **Access Tokens** (API): expiration esplicita, revocabili
- [ ] **X.509 / Remote User**: vincolato da reverse proxy fidato
- [ ] NO multiple authenticator senza test (priorita' non ovvia)

### 5. Login throttling (anti brute-force)

- [ ] `login_throttling: { max_attempts: 5, interval: '15 minutes' }` minimo
- [ ] Pacchetto `symfony/rate-limiter` installato
- [ ] Limiti consigliati: 3 failed per IP+username, 15 failed per IP solo
- [ ] `cache_pool` custom se serve persistence cross-instance (Redis)

### 6. Access Control & Authorization

- [ ] `access_control`: regole regex `^/path` in ordine (first match wins):
  ```yaml
  - { path: '^/admin/users', roles: ROLE_SUPER_ADMIN }
  - { path: '^/admin', roles: ROLE_ADMIN }
  - { path: '^/login', roles: PUBLIC_ACCESS }
  ```
- [ ] `role_hierarchy`: `ROLE_SUPER_ADMIN: [ROLE_ADMIN]`, `ROLE_ADMIN: [ROLE_USER]`
- [ ] Controller con `#[IsGranted('ROLE_ADMIN')]` (Symfony 6.2+) o `denyAccessUnlessGranted(...)`
- [ ] Twig con `{% if is_granted('ROLE_ADMIN') %}` (defense in depth UI)
- [ ] **MAI** `in_array('ROLE_X', $user->getRoles())` — usa `isGranted()`
- [ ] Special attributes: `IS_AUTHENTICATED_FULLY`, `IS_AUTHENTICATED_REMEMBERED`, `IS_IMPERSONATOR`

### 7. Custom Voters (per-resource authorization)

- [ ] Implementare `Voter` per logiche autorizzazione complesse (es. ownership)
- [ ] `voteOnAttribute(string $attribute, $subject, TokenInterface $token): bool`
- [ ] Check `$token->getUser() instanceof UserInterface` per anonymous
- [ ] Service registrato con tag `security.voter` (auto-detected con autowiring)

### 8. CSRF Protection

- [ ] Form Login: `enable_csrf: true`
- [ ] Template: `<input type="hidden" name="_csrf_token" value="{{ csrf_token('authenticate') }}">`
- [ ] Form builder Twig: `{{ form() }}` auto-include token
- [ ] Form custom: `csrf_token_id` e `csrf_parameter` configurabili

### 9. Session security

- [ ] `config/packages/framework.yaml`:
  ```yaml
  framework:
    session:
      cookie_secure: true
      cookie_httponly: true
      cookie_samesite: 'lax'   # o 'strict' per banking
      gc_maxlifetime: 7200
  ```
- [ ] Serializzazione User: `__serialize()` per escludere password dal session token
- [ ] `EquatableInterface` se custom equality logic su user

### 10. Security headers

- [ ] Symfony **NON** imposta security headers di default
- [ ] Pacchetto `nelmio/security-bundle` raccomandato per:
  - X-Content-Type-Options: nosniff
  - X-Frame-Options: DENY
  - Content-Security-Policy
  - Strict-Transport-Security
  - Referrer-Policy
- [ ] HTTPS forced in produzione (vedi `framework.trusted_proxies` se dietro reverse proxy)

### 11. Events & customization

- [ ] `CheckPassportEvent`: post-passport creation, validazione custom
- [ ] `LoginSuccessEvent`: modifica response post-login (es. add JWT)
- [ ] `LoginFailureEvent`: custom error response (no info leak)
- [ ] `LogoutEvent`: cleanup custom (revoke tokens, clear cache)
- [ ] Listener registrato con tag `kernel.event_subscriber` o autoconfigure

### 12. Logout

- [ ] `logout: { path: /logout, target: app_homepage }`
- [ ] Programmaticamente: `Security::logout(false)` (false = no redirect, controller gestisce)
- [ ] Token revocation listener se uso API token

### 13. Switch User (impersonation)

- [ ] **SOLO se necessario** (admin support): `switch_user: { role: ROLE_ALLOWED_TO_SWITCH }`
- [ ] Audit log obbligatorio su impersonation (`SwitchUserEvent`)
- [ ] Exit impersonation visibile in UI (banner)

### 14. Doctrine ORM (cross-axis)

- [ ] Query Builder con parameter binding (`$qb->where('u.id = :id')->setParameter('id', $id)`)
- [ ] Repository per logica DB, no `$em->createQuery()` con concat input
- [ ] N+1: usare `fetch="EAGER"` o `setFetchMode` esplicito su relazioni; profile via Symfony Profiler
- [ ] Cross-ref con `audit-database/checklists/general.md`

### 15. Configuration & deploy

- [ ] `APP_ENV=prod`, `APP_DEBUG=0` in `.env.prod` (o env vars del provider)
- [ ] `APP_SECRET` rigenerato e in env (`composer dump-env prod`)
- [ ] `composer install --no-dev --optimize-autoloader --classmap-authoritative`
- [ ] Cache warm-up: `php bin/console cache:clear --env=prod && cache:warmup --env=prod`
- [ ] **Doctrine cache**: APCu/Redis abilitato in prod
- [ ] Versione: 7.x stable, 6.4 LTS (security fix fino Nov 2027), 5.4 security-only

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file.php:riga o config/packages/security.yaml:riga
- **Versione Symfony applicabile**: 7.x / 6.4 LTS / tutte
- **Problema**: descrizione
- **Soluzione**: fix con esempio
- **Categoria**: prefix `SYMFONY-FIREWALL-NNN`, `SYMFONY-AUTHZ-NNN`, `SYMFONY-CSRF-NNN`, ecc.

## RIFERIMENTI

- Symfony Security: <https://symfony.com/doc/current/security.html>
- Symfony Deployment: <https://symfony.com/doc/current/deployment.html>
- Nelmio Security Bundle: <https://github.com/nelmio/NelmioSecurityBundle>
- Symfony Releases: <https://symfony.com/releases>
