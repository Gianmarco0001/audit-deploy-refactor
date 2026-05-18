# Checklist — Backend Laravel 13.x (framework-specific)

Sei un Senior Laravel Developer specializzato in security e best practices Laravel 13.x con note di retrocompat per L10/L11/L12. Questa checklist e' applicata in AGGIUNTA a `php.md` e `general.md` quando `composer.json` contiene `laravel/framework`.

**Nota architettura**: Laravel 11+ ha eliminato `app/Http/Kernel.php`, `app/Console/Kernel.php`, le middleware class `App\Http\Middleware\VerifyCsrfToken`, `TrustProxies`, `TrustHosts`. La configurazione vive ora in `bootstrap/app.php` via `withMiddleware()`, `withRouting()`, `withSchedule()`, `withBroadcasting()`. Le voci di seguito sono per L13 con marker `[L10/legacy]` dove l'API differiva.

## CHECKLIST LARAVEL 13.x

### 1. Routes (`routes/web.php`, `routes/api.php`, `routes/console.php`)

- [ ] Tutte le rotte protette hanno middleware appropriato: `auth:sanctum` (API/SPA), `auth` (web), `verified` (email verification richiesta)
- [ ] Rate limiting custom via `RateLimiter::for(...)` in `AppServiceProvider::boot()`. Esempio login: limite globale 500/min + per-email 3/min con `Limit::perMinute(3)->by($request->input('email'))`
- [ ] Azioni one-shot (verify email, password reset, download) usano `signed` middleware + `URL::signedRoute(...)` (default validita' 60 min)
- [ ] **Nested route model binding** con `->scopeBindings()` per prevenire IDOR: `Route::get('/users/{user}/posts/{post}', ...)->scopeBindings()` valida che `$post->user_id == $user->id` automaticamente (L13 feature)
- [ ] Custom key binding via `{post:slug}` per non esporre ID numerici sequenziali
- [ ] **Where helpers L13** per validare parametri: `->whereNumber('id')`, `->whereAlpha('slug')`, `->whereUuid('id')` — sempre presenti per evitare input arbitrari nei parametri
- [ ] Soft-deleted models default ESCLUSI; per includere usare `->withTrashed()` esplicito sulla rotta
- [ ] Missing model handler: `->missing(fn() => redirect()->route('home'))` per redirect graceful invece di 404 secco
- [ ] Route caching compatibile: nessuna closure in `routes/*.php` per consentire `php artisan route:cache`
- [ ] Webhook esterni: CSRF-exempt SOLO se firmati (Stripe signature, GitHub HMAC verificato lato server)
- [ ] `Route::fallback()` definita LAST per gestire 404 senza esporre stack trace
- [ ] Response-based rate limiting (anti-enumeration): `Limit::perMinute(10)->by($ip)->after(fn($r) => $r->status() === 404)` per contare solo i 404
- [ ] Sub-domain routing protetto da `->domain(...)` quando multi-tenant
- [ ] API routes auto-prefisse `/api` e ricevono middleware group `api` (no session, no CSRF — token-based)
- [ ] Resource controller registrati con Policy via `authorizeResource(Model::class, 'model')` nel costruttore

### 2. Middleware

- [ ] **[L11+/L13]** Configurazione in `bootstrap/app.php` via `withMiddleware(function (Middleware $middleware) { ... })`
- [ ] **[L11+/L13]** CSRF exceptions: `$middleware->validateCsrfTokens(except: ['stripe/webhook', 'github/webhook'])` — array minimo, solo webhook con firma HMAC verificata
- [ ] **[L11+/L13]** TrustProxies: `$middleware->trustProxies(at: '*')` SOLO se hosting dietro reverse proxy noto (Cloudflare, Vercel) — altrimenti spoofing X-Forwarded-For/X-Forwarded-Proto
- [ ] **[L11+/L13]** TrustHosts: `$middleware->trustHosts(at: ['example.com', '*.example.com'])` per prevenire host header injection
- [ ] **[L11+/L13]** Sanctum SPA: `$middleware->statefulApi()` registrato per abilitare `EnsureFrontendRequestsAreStateful`
- [ ] **[L11+/L13]** Sanctum abilities middleware: `$middleware->alias(['abilities' => CheckAbilities::class, 'ability' => CheckForAnyAbility::class])`
- [ ] **[L10/legacy]** Ordine in `$middlewareGroups['web']` di `app/Http/Kernel.php`: EncryptCookies → AddQueuedCookiesToResponse → StartSession → ShareErrorsFromSession → VerifyCsrfToken → SubstituteBindings — NON modificare
- [ ] **[L10/legacy]** `App\Http\Middleware\VerifyCsrfToken::$except` array minimo
- [ ] Middleware applicati globalmente (`$middleware->append(...)` o `$middleware` array L10) minimi — impatta ogni request
- [ ] Custom middleware in `app/Http/Middleware/` con signature `handle(Request $request, Closure $next): Response` che ritorna SEMPRE `$next($request)` (mai dimenticare il return)
- [ ] Middleware `auth.basic` MAI in produzione senza HTTPS forzato (credenziali in chiaro)

### 3. Authorization — Policies (`app/Policies/`) e Gates

- [ ] Tutti i model con dati sensibili hanno una Policy associata
- [ ] Policy auto-discovery attivo (default L11+) o registrazione esplicita in `AuthServiceProvider::$policies`
- [ ] Policy implementa metodi standard: `viewAny`, `view`, `create`, `update`, `delete`, `restore`, `forceDelete`
- [ ] Controller chiama `$this->authorize('action', $model)` PRIMA di operazioni sensibili (resource controller usa `authorizeResource()` nel costruttore)
- [ ] View Blade usa `@can('action', $model)` / `@cannot(...)` per nascondere UI non autorizzata (defense in depth, NON sicurezza primaria)
- [ ] API resource: `Gate::authorize()` o `if ($request->user()->cannot(...)) abort(403);` invece di `authorize()` quando si vuole formato JSON
- [ ] `Gate::define()` in `AppServiceProvider` per logica custom non legata a model
- [ ] `Gate::before()` usato CON CAUTELA per super-admin: `if ($user->is_admin) return true;` apre tutto — valutare se va dietro audit log
- [ ] Policy methods con type-hinting esplicito (`public function update(User $user, Post $post): bool`) per intercettare bug di binding
- [ ] Nessuna policy che fa `return true;` di default su tutti i metodi (privilege escalation silenziosa)
- [ ] Se usa spatie/laravel-permission:
  - Ruoli/permessi sincronizzati in seeder, no `assignRole()` da input utente non sanitizzato
  - Cache permessi invalidata su update (`PermissionRegistrar::forgetCachedPermissions()`)
  - Middleware `role:admin`, `permission:edit-posts` su rotte sensibili

### 4. Form Requests (`app/Http/Requests/`)

- [ ] Validation centralizzata in Form Request, non `$request->validate()` sparso nei controller per logiche non triviali
- [ ] Metodo `authorize()` esplicito (Laravel 10+ default = false; `return true` solo se autorizzazione gestita altrove via Policy)
- [ ] Rules con regex auditate per ReDoS (no regex con backtracking catastrofico tipo `(a+)+$`)
- [ ] Custom rules in `app/Rules/` con `__invoke()` o `Rule` class, testabili
- [ ] `$request->validated()` o `safe()->only([...])` usato per passare dati a Eloquent (mai `$request->all()` su model con `$guarded = []`)
- [ ] File upload validation:
  - `'file' => ['required', 'file', 'mimes:jpg,png,pdf', 'max:2048', 'mimetypes:image/jpeg,image/png,application/pdf']` — sia `mimes` (estensione) sia `mimetypes` (magic bytes)
- [ ] Password rules: `Password::min(12)->mixedCase()->numbers()->symbols()->uncompromised()` (uncompromised = check HIBP)
- [ ] Email validation: `'email' => ['required', 'email:rfc,dns,spoof']` per check DNS reale e omoglyph
- [ ] `prepareForValidation()` per normalizzazione input (lowercase email, trim) prima di rules

### 5. Traits di autorizzazione e patterns

- [ ] `Authorizable` trait su User (default Laravel) abilita `$user->can()`/`$user->cannot()`
- [ ] `HasApiTokens` (Sanctum) su User per API: token con `abilities` esplicite (`createToken('name', ['posts:read'])`), MAI abilities `['*']` per token user-facing
- [ ] `HasRoles` (spatie/laravel-permission) su User se usato: cache permission invalidata in `boot()` di User model dopo assegnazioni
- [ ] Custom trait `BelongsToTenant` con global scope per multi-tenancy: scope applicato in `booted()`, mai bypassabile via `withoutGlobalScopes()` nei controller user-facing
- [ ] `TwoFactorAuthenticatable` (Fortify) su User per 2FA
- [ ] `MustVerifyEmail` interface su User se app richiede verifica email (`implements MustVerifyEmail`, non solo trait)

### 6. Eloquent ORM (Laravel 13.x)

- [ ] **Mass assignment** — `protected $fillable = ['name', 'email', 'password']` definito esplicitamente su OGNI model (oppure attributo PHP 8 `#[Fillable([...])]` su L13)
- [ ] **Default `$guarded = []` E' PERICOLOSO** (tutti gli attributi mass-assignable) — flag CRITICO
- [ ] **Mai `#[Unguarded]`** in produzione (audit grep: blocca commit)
- [ ] In `AppServiceProvider::boot()`: `Model::preventSilentlyDiscardingAttributes($this->app->isLocal())` per intercettare in dev attributi non in `$fillable` che vengono silenziosamente scartati
- [ ] **Hidden attributes** — `protected $hidden = ['password', 'remember_token', 'api_token', 'two_factor_secret', 'two_factor_recovery_codes']`. Test: `User::find(1)->toJson()` non deve esporre nulla di sensibile
- [ ] **Casts** — `protected $casts = ['ssn' => 'encrypted', 'preferences' => 'encrypted:array', 'email_verified_at' => 'datetime', 'metadata' => 'json']`. Cast `encrypted` OBBLIGATORIO per compliance GDPR/PCI-DSS su PII a riposo
- [ ] **Eager loading** sistematico: `User::with('posts', 'comments.author')->get()` per nested. Flag esplicito audit: ricerca pattern `foreach (...) { $item->relation }` senza `with()`/`load()` precedente — segnala come N+1
- [ ] **Lazy loading prevention**: `Model::preventLazyLoading(! $this->app->isProduction())` in `AppServiceProvider::boot()` — fallisce hard in dev su lazy load accidentale
- [ ] **Soft deletes** (trait `SoftDeletes` + migration `$table->softDeletes()`): `restore()` SEMPRE dietro `authorize('restore', $model)`, `forceDelete()` SEMPRE dietro conferma esplicita + audit log
- [ ] **Local scopes** — pattern `scopeXxx(Builder $query)`. L13 supporta anche attributo `#[Scope]`. Audit: i scope non devono esporre dati non autorizzati
- [ ] **Global scopes** per multi-tenancy: `addGlobalScope(new TenantScope)` in `booted()` (oppure attributo `#[ScopedBy([TenantScope::class])]` su L13). **CRITICAL**: `withoutGlobalScopes()` puo' essere usato come bypass — audit grep di tutte le chiamate, nessuna deve dipendere da input utente
- [ ] **Observer** — `app/Observers/UserObserver.php` con metodi `creating/updating/deleted` per audit log. Attenzione a `$user->saveQuietly()` / `Model::withoutEvents()` che bypassano eventi (audit grep)
- [ ] **Migrations** — foreign keys: `$table->foreignId('user_id')->constrained('users')->restrictOnDelete()` (default safest). `cascadeOnDelete()` solo con audit log esplicito. `nullOnDelete()` se colonna nullable. Indici su FK obbligatori. Charset `utf8mb4_unicode_ci`
- [ ] **Query Builder SQL injection** — UNSAFE: `User::whereRaw("email = '$email'")`, `DB::select("SELECT * FROM users WHERE id = " . $id)`. SAFE: bindings con `?` o named: `User::whereRaw("email = ?", [$email])`. Audit grep `whereRaw|DB::raw|DB::select|DB::statement` deve avere SEMPRE placeholder, mai concat
- [ ] **Mass operations**: `Model::query()->delete()` triggera eventi, `DB::table()->delete()` no — conoscere differenza per audit log
- [ ] Rollback delle migration testato (`down()` implementato e funzionante)

### 7. Authentication, Sessions & Sanctum (Laravel 13.x)

**Auth base** (`config/auth.php`):

- [ ] Guards configurati: `web` (session), `sanctum` (API/SPA), provider `users` con Eloquent
- [ ] Password reset token: scadenza 60 min (default ok)
- [ ] `'password_timeout' => 10800` (3h) per re-conferma password su azioni sensibili
- [ ] Two-factor obbligatorio per admin (Fortify `Features::twoFactorAuthentication(['confirm' => true])`)
- [ ] Email verification: User implementa `MustVerifyEmail`, route protette da middleware `verified`
- [ ] `Auth::logoutOtherDevices($password)` esposto nell'UI utente
- [ ] `Auth::attempt(..., $remember = false)` di default; `remember=true` solo con consenso esplicito
- [ ] Password rules: `Password::min(12)->mixedCase()->numbers()->symbols()->uncompromised()`

**Sanctum SPA stateful (cookie-based, same-domain)**:

- [ ] Setup CSRF cookie automatico via `axios.get('/sanctum/csrf-cookie')` PRIMA del POST login
- [ ] `bootstrap/app.php`: `$middleware->statefulApi()` registrato (L13 convention)
- [ ] `config/session.php`: `'domain' => '.example.com'` (wildcard subdomini), `'secure' => true` (HTTPS only), `'http_only' => true`, `'same_site' => 'lax'` minimo
- [ ] `config/cors.php`: `'supports_credentials' => true` OBBLIGATORIO, `allowed_origins` whitelist esplicita (MAI `['*']` con `supports_credentials`)
- [ ] Client JS: `axios.defaults.withCredentials = true; axios.defaults.withXSRFToken = true`
- [ ] **MAI usare API token per la propria SPA** — i token in localStorage sono XSS-leakable; cookie HttpOnly invece no

**Sanctum API token (mobile/third-party)**:

- [ ] Generazione SEMPRE con abilities specifiche: `$user->createToken('mobile-app', ['server:read', 'server:update'])->plainTextToken`
- [ ] **MAI `['*']`** per token user-facing (audit grep blocking)
- [ ] Per-token expiration: `$user->createToken('temp', ['server:read'], now()->addWeeks(1))->plainTextToken`
- [ ] Default expiration in `config/sanctum.php`: ridurre da default `525600` (1 anno) per app sensibili
- [ ] Pruning automatico: `Schedule::command('sanctum:prune-expired --hours=24')->daily()` in `routes/console.php` (L11+) o `app/Console/Kernel.php::schedule()` (L10)
- [ ] Token hashati SHA-256 in `personal_access_tokens` table; **plaintext disponibile SOLO subito dopo `createToken()`** via `->plainTextToken`
- [ ] **MAI loggare `plainTextToken`** in log/file (audit grep `plainTextToken` deve apparire solo in response API, mai in `Log::`/`info(...)`)
- [ ] Check abilities nel controller: `if ($request->user()->tokenCan('server:update')) { ... }`
- [ ] Middleware abilities (L13): uso `Route::put('/servers/{id}', UpdateServer::class)->middleware(['auth:sanctum', 'abilities:server:update'])`
- [ ] Mobile client: token in **Keychain (iOS) / Keystore (Android)**, MAI in SharedPreferences / NSUserDefaults / file plain
- [ ] Revoca: endpoint `/api/logout` revoca almeno il token corrente (`$request->user()->currentAccessToken()->delete()`); endpoint "logout from all devices" usa `$user->tokens()->delete()`

**Passport** (se usato in alternativa a Sanctum):

- [ ] `php artisan passport:keys` eseguito, chiavi NOT committed (gitignore: `storage/oauth-*.key`)
- [ ] Scope espliciti su client OAuth, mai scope wildcard

**Session** (`config/session.php`):

- [ ] `'driver' => 'database'` o `'redis'` (file su shared hosting causa problemi I/O concorrenti)
- [ ] `'encrypt' => true` se contiene dati sensibili
- [ ] `'secure' => env('SESSION_SECURE_COOKIE', true)` (cookie solo HTTPS)
- [ ] `'same_site' => 'lax'` minimo (`'strict'` per banking/finance)
- [ ] `'lifetime' => 120` minuti default ok; ridurre per app sensibili

### 8. CSRF & Security Headers

- [ ] `@csrf` in TUTTI i form Blade (audit grep: ogni `<form method="POST"|"PUT"|"DELETE"` deve avere `@csrf` adiacente)
- [ ] Axios/Fetch in JS legge cookie `XSRF-TOKEN` e invia `X-XSRF-TOKEN` header (Laravel default in `resources/js/bootstrap.js`)
- [ ] CSRF exceptions in `bootstrap/app.php::withMiddleware()` (L11+) o `VerifyCsrfToken::$except` (L10) minime — solo webhook con firma HMAC server-side
- [ ] Security headers via middleware custom o pacchetto come `spatie/laravel-csp` / `bepsvpt/secure-headers` (Laravel non li imposta di default):
  - `X-Content-Type-Options: nosniff`
  - `X-Frame-Options: DENY` o `SAMEORIGIN`
  - `Strict-Transport-Security: max-age=31536000; includeSubDomains`
  - `Content-Security-Policy` (vedi `audit-security/checklists/owasp.md` per dettagli)
  - `Referrer-Policy: strict-origin-when-cross-origin`
  - `Permissions-Policy` (disabilitare feature non usate: camera, mic, geolocation)
- [ ] HTTPS forced in `AppServiceProvider::boot()`: `if ($this->app->environment('production')) URL::forceScheme('https');`

### 9. Storage, Queue, Mail (Laravel-specific cross-axis)

**Storage** (`config/filesystems.php`):

- [ ] Disk separation: `local` (privato), `public` (asset utente con symlink), `s3`/`cloud` (file pesanti / scalabilita')
- [ ] `Storage::temporaryUrl($path, now()->addMinutes(15))` per accesso temporaneo a file privati
- [ ] Upload utente MAI in `public/` direttamente — usare disk `public` + `php artisan storage:link`
- [ ] Path traversal: `Storage::disk('public')->putFileAs($dir, $file, $hashedName)` con nome generato server-side, mai usare nome originale
- [ ] `php artisan storage:link` documentato in deploy script

**Queue** (`config/queue.php`):

- [ ] Driver in produzione: `database` o `redis` (mai `sync` che blocca request)
- [ ] `failed_jobs` table presente (migration `php artisan queue:failed-table`)
- [ ] `$tries`, `$backoff`, `$timeout` definiti su ogni Job class
- [ ] `ShouldBeEncrypted` interface su Job che maneggia dati sensibili (payload cifrato in DB)
- [ ] Worker supervisor: Supervisor (VPS) o Horizon (Redis). Su shared hosting Netsons → cron `* * * * * php artisan queue:work --stop-when-empty --max-time=50`

**Mail** (`config/mail.php`):

- [ ] Mailable class (`app/Mail/`) per ogni tipo email, no `Mail::raw()` se possibile
- [ ] `implements ShouldQueue` su Mailable per non bloccare HTTP request
- [ ] Configurazione SMTP da `.env`, mai hardcoded
- [ ] Cross-ref con `audit-email/checklists/general.md` per SPF/DKIM/DMARC

### 10. Configuration & Deploy (Laravel 13.x)

- [ ] `APP_DEBUG=false` in produzione (CRITICO — espone stack trace + .env values su errore)
- [ ] `APP_KEY` generato con `php artisan key:generate`, mai vuoto, mai committed (`.env` in `.gitignore`)
- [ ] `APP_ENV=production`
- [ ] Cache deploy script: `php artisan config:cache && php artisan route:cache && php artisan view:cache && php artisan event:cache`
- [ ] **No closure in `config/*.php`** — blocca `config:cache` (audit grep `fn(` o `function` in config/)
- [ ] `bootstrap/app.php` con `withRouting()`, `withMiddleware()`, `withExceptions()`, `withSchedule()`, `withBroadcasting()` — broadcasting SEPARATO da routing (breaking change da L10)
- [ ] `composer install --no-dev --optimize-autoloader --classmap-authoritative` in produzione
- [ ] `.env` con permessi 600, fuori da `public/`
- [ ] `storage/` e `bootstrap/cache/` writable (chmod -R 775 o adatto al webserver user)
- [ ] Logging (`config/logging.php`): channel `stack` con `single` o `daily` + `slack`/`papertrail`/`sentry` per WARNING+
- [ ] `LOG_LEVEL=warning` in produzione (info+ e' rumore e costa I/O)
- [ ] `composer audit` nel CI/CD per CVE noti
- [ ] Estensioni PHP richieste L13: mbstring, xml, ctype, json, openssl, pdo, tokenizer, fileinfo, bcmath, curl, dom (PHP 8.2+ minimo, 8.3+ consigliato)
- [ ] Versione Laravel supportata: 13.x (latest), 12.x (bug fix), 11.x (security only fino aug 2026), 10.x (security only fino feb 2026), <10 EOL → upgrade obbligatorio
- [ ] `routes/console.php` (L11+) per `Schedule::command(...)` invece di `Console/Kernel::schedule()` legacy

### 11. Cross-axis impact (cose che altre skill devono sapere su Laravel)

Quando il pre-check rileva Laravel, il flag `framework: laravel` viene propagato e altre skill applicano sezioni specifiche:

- **`audit-security/checklists/owasp.md`**: verificare CSRF middleware ordine, Sanctum token expiration, `Gate::before()` per super-admin
- **`audit-database/checklists/general.md`**: verificare `$fillable`/`$guarded`, eager loading per N+1, scope multi-tenancy
- **`audit-hosting/checklists/netsons.md`**: Laravel queue worker NON daemon su Netsons → usa cron + `queue:work --stop-when-empty --max-time=50`. `storage/` deve essere writable. `bootstrap/cache/` deve essere writable
- **`audit-email/checklists/general.md`**: Laravel Mail con Mailable + ShouldQueue per non bloccare HTTP request

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file.php:riga (oppure config/auth.php:42 / bootstrap/app.php:18)
- **Versione Laravel applicabile**: L13.x / L11+/L13 / L10/legacy / tutte
- **Problema**: descrizione concisa
- **Soluzione**: fix raccomandato con esempio di codice
- **Categoria**: prefix specifici per sezione, es. `LARAVEL-ROUTE-001`, `LARAVEL-MIDDLEWARE-CSRF-002`, `LARAVEL-AUTHZ-POLICY-003`, `LARAVEL-FORM-REQ-004`, `LARAVEL-ELOQUENT-MASS-ASSIGN-005`, `LARAVEL-SANCTUM-ABILITY-006`, `LARAVEL-CSRF-007`, `LARAVEL-QUEUE-008`, `LARAVEL-DEPLOY-CONFIG-009`

## RIFERIMENTI

- Laravel 13.x Routing: <https://laravel.com/docs/13.x/routing>
- Laravel 13.x Eloquent: <https://laravel.com/docs/13.x/eloquent>
- Laravel 13.x Sanctum: <https://laravel.com/docs/13.x/sanctum>
- Laravel 13.x Authorization: <https://laravel.com/docs/13.x/authorization>
- Laravel 13.x Validation: <https://laravel.com/docs/13.x/validation>
- Laravel 13.x Deployment: <https://laravel.com/docs/13.x/deployment>
