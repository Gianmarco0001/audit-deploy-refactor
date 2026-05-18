# Checklist — Backend Go (stack-specific) — STUB

> **TODO**: contributi benvenuti — vedi [CONTRIBUTING.md](../../../../CONTRIBUTING.md).

Questa checklist e' attualmente vuota. La detection in `audit-backend/SKILL.md` la attiva quando rileva `go.mod`.

## Topic suggeriti per la prima versione

- `net/http` patterns (timeouts su Server, ReadHeaderTimeout, IdleTimeout)
- Context propagation (`context.Context` su ogni handler / DB call / outbound)
- Goroutine leak detection (context cancel, channel chiusi correttamente)
- `defer` su risorse (file, DB rows, response body)
- Error wrapping (`fmt.Errorf("...: %w", err)`)
- Race condition (`go test -race` in CI)
- Database/sql connection pooling (`SetMaxOpenConns`, `SetMaxIdleConns`)
- `gosec` static analyzer nel CI
- Dipendenze: `go list -m -u all` per vulnerabilita', `govulncheck` ufficiale
- Versione Go: rolling support (ultime 2 minor), no Go EOL
- `nil` pointer dereferencing in handler
- JSON unmarshaling: campo `omitempty` vs nullable, `json.Number` per precisione
- Build: `CGO_ENABLED=0`, `-trimpath`, `-ldflags="-s -w"` per binary stripped

## Riferimenti utili

- Go Security Best Practices: <https://github.com/Checkmarx/Go-SCP>
- govulncheck: <https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck>

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file.go:riga
- **Problema**: descrizione
- **Soluzione**: fix con esempio
- **Categoria**: prefix `BACKEND-GO-NNN`
