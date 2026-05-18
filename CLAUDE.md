# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A **Claude Code plugin**, not application code. There is no build, no tests, no runtime — the repo is a bundle of Markdown + JSON read by the Claude Code CLI. Changes are validated by installing the plugin locally and invoking `/audit-deploy` (or one of the granular skills like `/audit-security`).

Install locally for testing:

```bash
cp -r skills/* ~/.claude/skills/
cp -r commands/* ~/.claude/commands/
```

The plugin is **stack-aware**: it autodetects backend language (PHP/Laravel/Node/Python/Go), database engine (MySQL/Postgres/SQLite/Mongo), hosting profile (Netsons/Vercel/Railway/AWS) and email transport, then loads only the relevant sub-files. Default profile (when no markers match): PHP + MySQL + Netsons (preserves legacy v1 behavior). Checklists and user-facing text are in **Italian** — preserve language when editing. Internal comments may be English.

## Architecture

Three layers:

1. **Plugin manifest** ([.claude-plugin/plugin.json](.claude-plugin/plugin.json) + [marketplace.json](.claude-plugin/marketplace.json)) — identity + distribution metadata for the Claude Code marketplace.

2. **11 skills** ([skills/](skills/)) — one orchestrator (`audit-deploy`) + 10 granular skills (`audit-backend`, `audit-frontend`, `audit-mobile-ux`, `audit-database`, `audit-security`, `audit-algorithms`, `audit-seo`, `audit-gdpr`, `audit-hosting`, `audit-email`). Each granular skill is **self-contained** and **invocable on its own** via slash command. The orchestrator dispatches them in parallel via Task tool.

3. **11 slash commands** ([commands/](commands/)) — thin wrappers (5-10 lines each) that map `/audit-X` to the corresponding skill with `$ARGUMENTS` passthrough.

### Progressive disclosure (sub-files per stack/engine/hosting)

Each granular skill has `checklists/general.md` (universal) + stack-specific sub-files loaded on demand. Example for `audit-backend`:

- `checklists/general.md` — universal backend checks (logging, env, secrets, error handling)
- `checklists/php.md` — PHP-specific (loaded if `composer.json` present)
- `checklists/frameworks/laravel.md` — Laravel 13.x specific (loaded if `laravel/framework` in composer.json, ADDITIVE to php.md)
- `checklists/node.md`, `python.md`, `go.md` — stub TODO v2.1, community contributions welcome

Detection rules are formalized in [skills/audit-deploy/detection-rules.md](skills/audit-deploy/detection-rules.md).

### The 3-phase pipeline (model-tiered for cost)

[skills/audit-deploy/SKILL.md](skills/audit-deploy/SKILL.md) hard-codes this sequence — do not change models casually, the tiering is deliberate:

| Phase | Model | Purpose |
|-------|-------|---------|
| 1. Pre-check | `haiku` | Single agent scans project, emits JSON feature flags (`has_login`, `has_db`, `has_email`, framework, hosting profile, …). Downstream skills are skipped based on these flags. |
| 2. Audit | `sonnet` | **Up to 10 skills run in parallel** via Task tool. Each loads its `general.md` + relevant sub-files via Read. Each returns findings as structured JSON. |
| 3. Scoring | `haiku` | One agent assigns 0–100 confidence, drops findings < 60, deduplicates across skills, writes `AUDIT-REPORT.md` from [skills/audit-deploy/templates/report-template.md](skills/audit-deploy/templates/report-template.md). |

Opus is intentionally left free for the user's main work.

### Iterative fix loop with approval gate

After the first report, the orchestrator auto-fixes findings, tags each fix with `// AUDIT-FIX:`, and re-runs Phase 2+3 on affected skills only (not all).

- Default `max_iterations`: **3** (reduced from v1's 10 for cost control). Override via `/audit-deploy . --max-iter=N`.
- Default `approval_gate`: **high** — LOW/MEDIUM auto-applied, HIGH/CRITICAL require user confirmation.
- Hard `protected_paths` (always approval, regardless of severity): `.env`, `composer.json`, `package.json`, `.htaccess`, `*.sql`, `.git/*`, `**/database/migrations/**`, `tauri.conf.json`, `manifest.json`.

The 10 granular skills have `allowed-tools` WITHOUT `Edit` — they can only Read/Grep/Glob. Only the orchestrator applies fixes, after approval.

Business logic is off-limits — only security, perf, compliance, best-practices fixes. Architectural changes must be flagged `RICHIEDE INTERVENTO MANUALE`.

### Checklist layout

```
skills/audit-<area>/
├── SKILL.md                # dispatcher prose with detection + Read sub-files
└── checklists/
    ├── general.md          # universal checks
    ├── <stack>.md          # stack-specific (php.md, node.md, ...)
    └── frameworks/         # only audit-backend
        └── laravel.md
```

Numbered prefixes from v1 (`01-backend-php.md`) are gone — content is now organized by axis (skill/stack/framework).

## Editing conventions

- When changing the finding JSON schema in Phase 2, update both the orchestrator `SKILL.md` and [skills/audit-deploy/templates/report-template.md](skills/audit-deploy/templates/report-template.md) — the template consumes those fields.
- `${CLAUDE_SKILL_DIR}` is resolved by Claude Code at runtime — don't hardcode paths. Cross-skill references use `${CLAUDE_SKILL_DIR}/../<skill-name>/`.
- Severity vocabulary is Italian (`CRITICO|ALTO|MEDIO|BASSO`) — do not translate, the report template matches on these strings.
- Adding a new framework/stack/hosting: see [CONTRIBUTING.md](CONTRIBUTING.md). Add sub-file, update [detection-rules.md](skills/audit-deploy/detection-rules.md), test locally with a fixture project.
- Skills have `disable-model-invocation: true` to prevent accidental auto-invocation during normal chats — they activate only via explicit slash command or Task spawn from the orchestrator. The only exception is `audit-deploy` itself, which has `disable-model-invocation: false`.

## Non-regression vs v1

The legacy plugin `audit-deploy-plugin-main/` (sibling of this folder) is the v1 baseline. The split rule is: `cat general.md <stack>.md | bullet-extract | sort` must equal the original v1 checklist's bullet-extract sorted. The script [tests/non-regression/check-bundle-equivalence.sh](tests/non-regression/check-bundle-equivalence.sh) automates this check.

A test fixture project lives at [tests/fixtures/legacy-php-mysql-netsons/](tests/fixtures/legacy-php-mysql-netsons/) — a minimal PHP+MySQL app with known bugs. Expected findings are in [tests/non-regression/expected-findings.md](tests/non-regression/expected-findings.md).
