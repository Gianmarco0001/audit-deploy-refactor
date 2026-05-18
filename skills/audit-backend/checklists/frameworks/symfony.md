# Checklist — Symfony Framework (framework-specific) — STUB

> **TODO**: contributi benvenuti — vedi [CONTRIBUTING.md](../../../../../CONTRIBUTING.md).

Questa checklist e' attualmente vuota. La detection in `audit-backend/SKILL.md` la attiva quando `composer.json` contiene `symfony/framework-bundle`.

## Topic suggeriti per la prima versione

- Security Bundle: firewalls, access_control, voters
- CSRF token su form (`SymfonyComponentFormExtensionCsrfType`)
- Doctrine ORM: query builder vs DQL safety, prepared parameter binding
- Doctrine mass assignment (no `setData($request->getContent())`)
- Validator: Constraints custom, Assert\* su DTO
- Messenger: queue async, failure transport, retry strategy
- Mailer: DSN env, ShouldQueue equivalent
- Environment: `APP_ENV=prod`, `APP_DEBUG=0`, `APP_SECRET` rigenerato
- Cache: `composer dump-env prod`, `cache:clear --env=prod`
- HttpClient con TLS verification on
- LexikJWTAuthenticationBundle se uso JWT
- Versione Symfony LTS (es. 6.4 LTS, 7.x)

## FORMATO REPORT

- **Categoria**: prefix `SYMFONY-NNN`
