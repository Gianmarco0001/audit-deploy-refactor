# Expected findings — fixture `legacy-php-mysql-netsons`

Lista scritta a mano dei finding attesi quando si esegue `/audit-deploy` sulla fixture. Serve da baseline per verificare che il v2 non perda finding rispetto al v1.

**Tolleranza accettabile**: ordine diverso, wording leggermente diverso, finding aggiuntivi (incremento qualità). **NON accettabile**: perdita di uno dei finding qui sotto.

## Stack rilevato atteso

```json
{
  "backend": "php",
  "framework": "none",
  "framework_version": null,
  "database": ["mysql"],
  "hosting": "netsons",
  "email_transport": "phpmailer",
  "has_html": true,
  "has_login": true,
  "has_user_data": true,
  "has_forms": true,
  "has_file_upload": true,
  "php_version": "8.x"
}
```

## Skill eseguite (10/10) — tutte rilevanti

audit-backend, audit-frontend, audit-mobile-ux, audit-database, audit-security, audit-algorithms, audit-seo, audit-gdpr, audit-hosting, audit-email.

## Finding attesi (post-deduplicazione cross-skill)

### CRITICO

1. **SQL Injection in `login.php`** — concatenazione di `$_POST['username']` / `$_POST['password']` nella query. Categoria: `DATABASE-GENERAL` o `OWASP-A03` (injection).
2. **Backdoor password hardcoded in `login.php:13`** — `$ADMIN_BACKDOOR_PASSWORD = 'letmein2024'` + comparison `=== $ADMIN_BACKDOOR_PASSWORD`. Categoria: `OWASP-A04` o `BACKEND-PHP`.
3. **Credenziali DB hardcoded in `config.php`** — `$DB_PASS = 'rootroot123'`. Categoria: `BACKEND-GENERAL` o `OWASP-A04`.
4. **No verifica MIME reale in `upload.php`** — si fida di `$_FILES['type']`; possibile upload `.php` come immagine → RCE. Categoria: `OWASP-A03` o `BACKEND-PHP`.
5. **`display_errors=1` in produzione (`config.php:9`)** — espone stack trace. Categoria: `OWASP-A02` o `BACKEND-PHP`.
6. **Header injection in `index.php` form contatto** — `$_POST['email']` concatenato in `From:` senza sanitizzare `\r\n`. Categoria: `EMAIL-GENERAL` o `OWASP-A03`.

### ALTO

7. **Form login senza CSRF token** — `login.php` HTML form privo di token. Categoria: `OWASP-CSRF` o `SECURITY-CSRF`.
8. **Form contatto senza CSRF** — `index.php` form contatto privo di token. Categoria: `OWASP-CSRF`.
9. **Form upload senza CSRF** — `upload.php` form upload privo di token. Categoria: `OWASP-CSRF`.
10. **`mail()` nativo PHP in `index.php`** — inaffidabile su shared, no SMTP auth. Categoria: `EMAIL-PHP`.
11. **Session ID non rigenerato dopo login (`login.php`)** — `$_SESSION['user'] = $user;` senza `session_regenerate_id(true)`. Categoria: `OWASP-A07`.
12. **PDO senza `ATTR_EMULATE_PREPARES => false` (`config.php`)** — emulated prepares enabled di default. Categoria: `DATABASE-MYSQL`.
13. **PDO senza `charset=utf8mb4` nella DSN (`config.php`)** — charset di default può causare problemi emoji/CJK. Categoria: `DATABASE-MYSQL`.
14. **Upload file con nome originale preservato (`upload.php`)** — nessun rename random. Categoria: `BACKEND-GENERAL` o `OWASP-A01`.
15. **`.htaccess` non blocca accesso a `.env` / `config.php`** — file di config raggiungibili via HTTP. Categoria: `HOSTING-NETSONS` o `OWASP-A02`.
16. **`.htaccess` non forza HTTPS** — no redirect HTTP → HTTPS. Categoria: `OWASP-A04` o `HOSTING-GENERAL`.

### MEDIO

17. **User enumeration in `login.php`** — messaggio "Username errato o password sbagliata: $username" rivela username esistenti. Categoria: `OWASP-A07`.
18. **Errore SQL esposto in `config.php` catch** — `echo "DB Error: " . $e->getMessage();`. Categoria: `OWASP-A10` o `OWASP-A02`.
19. **`var_dump($_POST)` lasciato in `index.php`** — debug in produzione. Categoria: `BACKEND-PHP` o `BACKEND-GENERAL`.
20. **No security headers configurati** — manca CSP, X-Frame-Options, HSTS, X-Content-Type-Options. Categoria: `SECURITY-HEADER`.
21. **No rate limiting su login** — brute force possibile. Categoria: `OWASP-A07` o `SECURITY-RATELIMIT`.
22. **No CAPTCHA su form contatto** — spam relay possibile. Categoria: `EMAIL-GENERAL`.
23. **Output XSS in `upload.php`** — `echo "Upload riuscito: " . $file['name'];` non sanitizzato. Categoria: `OWASP-A03`.
24. **No meta description / canonical / Open Graph in `index.php`** — SEO scadente. Categoria: `SEO-META`.
25. **No alt text su `<img src="logo.jpg">`** — accessibilità WCAG 2.1. Categoria: `FRONTEND` o `MOBILE-UX-A11Y`.
26. **Touch target `<button>` 20x20px sotto 44x44px minimo** — mobile UX. Categoria: `MOBILE-UX-TOUCH`.

### BASSO

27. **`<input type="text">` per email invece di `type="email"`** — UX mobile (`login.php`, `index.php`). Categoria: `MOBILE-UX-FORM`.
28. **No `lang` attribute sull'`<html>` di `login.php`** (presente solo in altri file). Categoria: `FRONTEND` o `SEO-META`.
29. **Form senza `autocomplete` attributes** — Categoria: `FRONTEND-FORM-UX`.

## Totale atteso

- ~6 CRITICO
- ~10 ALTO
- ~10 MEDIO
- ~3 BASSO
- **Totale: ~29 finding** (con possibile dedup cross-skill che riduce a ~25)

## Note sulla GDPR

Il fixture **non** ha cookie banner ne' privacy policy ne' analytics: la skill `audit-gdpr` rileverà la mancanza di:

- Privacy policy ex art.13 (CRITICO se ci sono form con dati personali)
- Cookie policy (MEDIO se non usa cookie non tecnici, basta nota)
- Checkbox consenso non pre-selezionata su form contatto (MEDIO)

Aggiungere ~3 finding GDPR al conto sopra.

## Note finali

Il fixture è volutamente piccolo (~6 file) per non sovraccaricare il test. Coverage di tutti i 10 axes:

- backend (PHP) ✅
- frontend (HTML) ✅
- mobile-ux ✅
- database (MySQL via PDO) ✅
- security (OWASP injection + auth) ✅
- algorithms (var_dump residuo) ✅
- seo (HTML senza meta) ✅
- gdpr (form senza consensi) ✅
- hosting (Netsons via .htaccess) ✅
- email (mail() + PHPMailer in composer.json) ✅
