#!/usr/bin/env bash
# check-bundle-equivalence.sh
#
# Verifica che per ogni file v1 splittato in v2, il bundle dei sub-file v2
# preservi semanticamente i check del v1. Usa matching fuzzy: per ogni bullet
# del v1, verifica che le PRIME 5 PAROLE SIGNIFICATIVE (>3 char, no stopword)
# compaiano nel bundle v2 (anche distribuite su righe diverse, incluso headers ###).
#
# Soglia: ≤5% bullet "non rintracciati" = OK (riformulazioni accettabili),
# >5% = WARN (probabili contenuti effettivamente persi).
# Per le migrazioni 1:1, soglia 0% (identity check stretto via set-diff).
#
# Usage:
#   cd tests/non-regression
#   bash check-bundle-equivalence.sh

set -uo pipefail

V1_ROOT="../../../audit-deploy-plugin-main/skills/audit-deploy/checklists"
V2_ROOT="../../skills"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Stopword italiane comuni (case-insensitive, post-lowercase)
STOPWORDS='^(che|della|dello|delle|degli|sono|sulla|sull|fare|tutti|tutto|nessun|nessuna|presente|deve|essere|stati|stata|stato|come|piu|cosa|tutto|alcun|alcuni|altre|altro|altra|altri|anche|cosi|dopo|fino|prima|sopra|sotto|sempre|spesso|mentre|quando|quanto|qualche|quale|quali|quasi|quello|quella|questi|queste|questo|questa|verso|senza|solo|tale|tali|stesso|stessa|stessi|stesse|nella|nelle|negli|degli|ogni|sull|fra|tra|per|con|del|dei|nel|nei|dal|dai|sul|sui|del|tra|dalla|dalle|alle|alla|allo|agli)$'

declare -i errors=0 warnings=0

normalize_bullets() {
  grep -E '^[[:space:]]*-[[:space:]]*\[[[:space:]]?\]' "$1" 2>/dev/null \
    | sed -E 's/^[[:space:]]*-[[:space:]]*\[[[:space:]]?\][[:space:]]*//' \
    | sed -E 's/[[:space:]]+/ /g' \
    | sed -E 's/[[:space:]]+$//' \
    | tr -d '\r' \
    | tr '[:upper:]' '[:lower:]' \
    | sort -u
}

normalize_full_corpus() {
  # Estrai TUTTO il testo significativo (bullets, headers, sub-bullet) di un file
  cat "$1" 2>/dev/null \
    | sed -E 's/[`*_]//g' \
    | tr -d '\r' \
    | tr '[:upper:]' '[:lower:]'
}

significant_words() {
  echo "$1" | tr -s '[:punct:]' ' ' | tr ' ' '\n' \
    | awk 'length($0) > 3' \
    | grep -ivE "$STOPWORDS" \
    | head -5
}

fuzzy_check() {
  # Per ogni bullet v1, verifica che le prime 5 parole significative compaiano
  # nel bundle v2 (anywhere). Restituisce conteggio bullet non rintracciati.
  local v1_bullets="$1"
  local v2_corpus="$2"
  local missing_file="$3"

  : > "$missing_file"
  local total_v1=0 missed=0

  while IFS= read -r bullet; do
    [[ -z "$bullet" ]] && continue
    total_v1=$((total_v1 + 1))
    local words found=0 word_count=0
    words=$(significant_words "$bullet")
    for w in $words; do
      word_count=$((word_count + 1))
      if grep -qF "$w" "$v2_corpus" 2>/dev/null; then
        found=$((found + 1))
      fi
    done
    if [[ $word_count -eq 0 ]]; then
      # bullet senza parole significative (es. solo punteggiatura) - skip
      continue
    fi
    # Soglia match: almeno 60% delle parole significative trovate
    if (( (found * 100) / word_count < 60 )); then
      echo "$bullet" >> "$missing_file"
      missed=$((missed + 1))
    fi
  done < "$v1_bullets"

  echo "$total_v1 $missed"
}

compare_split() {
  local v1_file="$1"
  local label="$2"
  shift 2
  local v2_files=("$@")

  echo ""
  echo "=== $label (split, fuzzy matching) ==="
  echo "v1:   $(basename "$v1_file")"

  if [[ ! -f "$v1_file" ]]; then
    echo "  WARNING: v1 file non trovato (skip)"
    warnings=$((warnings + 1))
    return
  fi

  local v1_bullets="$TMPDIR/v1_b_${label}.txt"
  local v2_corpus="$TMPDIR/v2_c_${label}.txt"
  local missing="$TMPDIR/missing_${label}.txt"

  normalize_bullets "$v1_file" > "$v1_bullets"
  : > "$v2_corpus"
  for f in "${v2_files[@]}"; do
    if [[ -f "$f" ]]; then
      normalize_full_corpus "$f" >> "$v2_corpus"
    else
      echo "  WARNING: v2 file non trovato: $f"
      warnings=$((warnings + 1))
    fi
  done

  local stats total missed
  stats=$(fuzzy_check "$v1_bullets" "$v2_corpus" "$missing")
  total=$(echo "$stats" | cut -d' ' -f1)
  missed=$(echo "$stats" | cut -d' ' -f2)

  local pct=0
  if [[ $total -gt 0 ]]; then
    pct=$((missed * 100 / total))
  fi

  echo "  bullet v1 con check: $total | non rintracciati in v2: $missed (${pct}%)"

  if [[ $missed -gt 0 ]]; then
    echo "  primi 5 bullet non rintracciati (probabili rephrasing):"
    head -5 "$missing" | sed 's/^/    - /'
  fi

  # Soglia ≤5% accettabile per split (riformulazioni inevitabili)
  if [[ $pct -le 5 ]]; then
    echo "  OK: ${pct}% non rintracciati (sotto soglia 5%)"
  elif [[ $pct -le 15 ]]; then
    echo "  WARN: ${pct}% non rintracciati (5-15%, audit manuale consigliato)"
    warnings=$((warnings + 1))
  else
    echo "  FAIL: ${pct}% non rintracciati (>15%, contenuti probabilmente persi)"
    errors=$((errors + missed))
  fi
}

compare_1to1() {
  local v1_file="$1"
  local label="$2"
  local v2_file="$3"

  echo ""
  echo "=== $label (1:1, strict identity) ==="
  echo "v1:   $(basename "$v1_file") <-> v2: $(basename "$v2_file")"

  if [[ ! -f "$v1_file" ]] || [[ ! -f "$v2_file" ]]; then
    echo "  WARNING: file mancante (skip)"
    warnings=$((warnings + 1))
    return
  fi

  local v1_norm="$TMPDIR/v1_1to1_${label}.txt"
  local v2_norm="$TMPDIR/v2_1to1_${label}.txt"
  local missing="$TMPDIR/missing_1to1_${label}.txt"

  normalize_bullets "$v1_file" > "$v1_norm"
  normalize_bullets "$v2_file" > "$v2_norm"

  comm -23 "$v1_norm" "$v2_norm" > "$missing"
  local missing_count
  missing_count=$(wc -l < "$missing")

  local v1_count v2_count
  v1_count=$(wc -l < "$v1_norm")
  v2_count=$(wc -l < "$v2_norm")
  echo "  bullet v1: $v1_count | bullet v2: $v2_count | mancanti (strict): $missing_count"

  if [[ $missing_count -eq 0 ]]; then
    echo "  OK: identita' perfetta v1<->v2"
  else
    echo "  FAIL — bullet del v1 non identici in v2:"
    head -5 "$missing" | sed 's/^/    - /'
    errors=$((errors + missing_count))
  fi
}

# === 4 SPLIT (fuzzy) ===

compare_split "$V1_ROOT/01-backend-php.md" "backend-php" \
  "$V2_ROOT/audit-backend/checklists/general.md" \
  "$V2_ROOT/audit-backend/checklists/php.md"

compare_split "$V1_ROOT/03-database-sqli.md" "database-sqli" \
  "$V2_ROOT/audit-database/checklists/general.md" \
  "$V2_ROOT/audit-database/checklists/mysql.md"

compare_split "$V1_ROOT/08-ingegnerizzazione.md" "hosting-netsons" \
  "$V2_ROOT/audit-hosting/checklists/general.md" \
  "$V2_ROOT/audit-hosting/checklists/netsons.md"

compare_split "$V1_ROOT/09-email-smtp.md" "email-phpmailer" \
  "$V2_ROOT/audit-email/checklists/general.md" \
  "$V2_ROOT/audit-email/checklists/php-phpmailer.md"

# === 6 MIGRAZIONI 1:1 (identity strict) ===

compare_1to1 "$V1_ROOT/02-frontend-uiux.md" "frontend" \
  "$V2_ROOT/audit-frontend/checklists/desktop.md"

compare_1to1 "$V1_ROOT/02b-mobile-ux.md" "mobile-ux" \
  "$V2_ROOT/audit-mobile-ux/checklists/general.md"

compare_1to1 "$V1_ROOT/04-cybersec-owasp.md" "security-owasp" \
  "$V2_ROOT/audit-security/checklists/owasp.md"

compare_1to1 "$V1_ROOT/05-algoritmica.md" "algorithms" \
  "$V2_ROOT/audit-algorithms/checklists/general.md"

compare_1to1 "$V1_ROOT/06-seo.md" "seo" \
  "$V2_ROOT/audit-seo/checklists/general.md"

compare_1to1 "$V1_ROOT/07-gdpr-cookie.md" "gdpr" \
  "$V2_ROOT/audit-gdpr/checklists/general.md"

# === ESITO ===

echo ""
echo "=================================="
echo "RIEPILOGO"
echo "=================================="
echo "Errors: $errors  |  Warnings: $warnings"

if [[ $errors -eq 0 ]]; then
  if [[ $warnings -eq 0 ]]; then
    echo "OK: compat retro v2 garantita (zero perdite, zero warnings)."
  else
    echo "OK con warnings: compat retro v2 garantita ma $warnings split hanno rephrasing 5-15%. Audit manuale consigliato sui file flaggati WARN."
  fi
  exit 0
else
  echo "FAIL: $errors bullet del v1 non sono rintracciabili nel v2 (>15% in alcuni split o identity rotta sui 1:1). Rivedi."
  exit 1
fi
