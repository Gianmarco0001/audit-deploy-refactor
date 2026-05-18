# Checklist — Backend Go (stack-specific)

Sei un Senior Go Developer specializzato in security, concurrency safety, e performance. Questa checklist e' applicata in AGGIUNTA a `general.md` quando il progetto e' un'applicazione Go (`go.mod` presente). Validata su Go Security Best Practices ufficiali (go.dev/doc/security/best-practices) + Go Secure Coding Practices.

## CHECKLIST GO

### 1. Versione & dipendenze

- [ ] Go ultima minor o penultima minor (rolling support window, no LTS formale: oggi 1.23+ raccomandato)
- [ ] `go.mod` con `go 1.x` esplicito a versione minima supportata
- [ ] `go.sum` committato
- [ ] Subscribe `golang-announce@googlegroups.com` per security pre-announce
- [ ] **`govulncheck`** integrato nel CI/CD:
  ```bash
  go install golang.org/x/vuln/cmd/govulncheck@latest
  govulncheck ./...
  ```
- [ ] Scanning JSON in CI: `govulncheck -json ./...`
- [ ] VSCode/IDE plugin govulncheck attivo per editor-time scanning

### 2. HTTP Server hardening (anti-DoS)

- [ ] Usare `http.Server{}` con timeouts espliciti, MAI `http.ListenAndServe(...)` con default mux:
  ```go
  srv := &http.Server{
      Addr:              ":8080",
      Handler:           mux,
      ReadHeaderTimeout: 5 * time.Second,   // anti Slowloris
      ReadTimeout:       30 * time.Second,
      WriteTimeout:      30 * time.Second,
      IdleTimeout:       120 * time.Second,
      MaxHeaderBytes:    1 << 20,           // 1 MB
  }
  ```
- [ ] **`ReadHeaderTimeout`** OBBLIGATORIO (mitiga Slowloris)
- [ ] `MaxHeaderBytes` impostato per limitare header oversize
- [ ] Evitare `http.DefaultServeMux` in produzione (global state, registrazione handler implicita)
- [ ] `http.MaxBytesReader(w, r.Body, N)` su body POST/PUT per limitare payload
- [ ] Graceful shutdown con `srv.Shutdown(ctx)` su SIGTERM/SIGINT

### 3. Context & cancellation

- [ ] `context.Context` propagato su OGNI handler / DB call / outbound HTTP call
- [ ] `context.WithTimeout` o `context.WithDeadline` su operazioni con SLA (DB query, outbound API)
- [ ] No `context.Background()` deep in code path (passa request context)
- [ ] Cleanup risorse con `defer` (file, rows, response body, mutex)

### 4. Concurrency & race conditions

- [ ] **`go test -race ./...`** in CI obbligatorio
- [ ] `go build -race` per binari di test/staging
- [ ] Goroutine leak prevention: ogni `go func()` ha context cancellation o channel close path
- [ ] `sync.WaitGroup` per goroutine sync; `errgroup.Group` per propagation errori
- [ ] Channel close: solo il sender chiude; mai close due volte (panic)
- [ ] `sync.Mutex`/`sync.RWMutex` invece di `runtime.LockOSThread` (eccetto casi specifici)
- [ ] `sync/atomic` per counter concorrenti (no mutex se sufficiente)

### 5. Code quality static analysis

- [ ] **`go vet ./...`** in CI (rileva unreachable code, unused, goroutine mistakes, printf-format errors)
- [ ] `staticcheck` (`honnef.co/go/tools/cmd/staticcheck`) per analisi estesa
- [ ] `gosec` SAST: `gosec ./...` per security issue
- [ ] `gofmt`/`gofumpt`/`goimports` enforced in pre-commit

### 6. Template engine (XSS safety)

- [ ] **`html/template`** per output HTML (escape automatico contestuale)
- [ ] **MAI `text/template`** per HTML (no auto-escape, XSS rischio diretto)
- [ ] Audit grep: `text/template` import in handler HTTP → flag CRITICO se output va al browser

### 7. SQL & ORM

- [ ] `database/sql` con prepared statements: `db.Query("SELECT ... WHERE id = ?", id)`, MAI string concat
- [ ] `sqlx` per scan struct-friendly
- [ ] ORM (GORM, ent): verifica che query builder non concateni stringhe da input
- [ ] Connection pool: `db.SetMaxOpenConns(N)`, `db.SetMaxIdleConns(N)`, `db.SetConnMaxLifetime(T)`
- [ ] `gorm.io` v2: PreparedStmt cache attivo

### 8. JSON & input

- [ ] `json.Decoder.DisallowUnknownFields()` per rifiutare campi inattesi (defense-in-depth)
- [ ] `json.Number` invece di `float64` per precisione numerica su valori monetari
- [ ] Validation con `go-playground/validator` o equivalente DOPO unmarshal
- [ ] `omitempty` su risposte JSON per non leakare zero-value campi sensibili

### 9. Filesystem & path safety

- [ ] `filepath.Clean(path)` PRIMA di operazioni su file path da input utente
- [ ] `filepath.IsLocal(path)` (Go 1.20+) per verificare path non risali (`..`)
- [ ] `os.OpenFile` con permission flags espliciti (0644 file, 0755 dir, 0600 secrets)
- [ ] No `os.RemoveAll` su path da input utente non sanitizzato

### 10. Cryptography

- [ ] `crypto/subtle.ConstantTimeCompare` per token/MAC comparison
- [ ] `crypto/rand` per random sicuro (MAI `math/rand` per token/session ID)
- [ ] Password hashing: `golang.org/x/crypto/bcrypt`, `argon2`, o `scrypt`
- [ ] JWT: `golang-jwt/jwt/v5` o `go-jose/go-jose/v4`, **MAI algoritmo `none`**, verifica `alg` esplicita
- [ ] TLS config moderna: `MinVersion: tls.VersionTLS12`, cipher suite IANA preferred

### 11. Fuzzing (Go 1.18+)

- [ ] Fuzz test su parser, validator, deserializer: `func FuzzXxx(f *testing.F)`
- [ ] `go test -fuzz=Fuzz -fuzztime=30s` in CI per coverage edge case
- [ ] Crash corpus committato in `testdata/fuzz/`

### 12. Build & deploy

- [ ] **`CGO_ENABLED=0`** in build production (no C deps, container scratch-friendly)
- [ ] **`-trimpath`** per rimuovere local paths dai binari
- [ ] **`-ldflags="-s -w"`** per strip symbols/dwarf
- [ ] **`GOFLAGS=-mod=readonly`** per prevenire accidental dep changes
- [ ] **`GOPROXY=https://proxy.golang.org,direct`** e `GOSUMDB=sum.golang.org` per validation
- [ ] Container: `distroless` (`gcr.io/distroless/static`) o `scratch` (no shell, no package manager)
- [ ] Binary embed (`embed.FS`) per asset statici (no filesystem deploy)

### 13. Logging & monitoring

- [ ] Structured logging: `log/slog` (Go 1.21+) o `zerolog`/`zap`
- [ ] NO password/token nei log
- [ ] Log strutturato JSON in produzione
- [ ] Health endpoint pubblico (`/healthz`, `/readyz`)
- [ ] Metrics endpoint (Prometheus `/metrics`) protetto se non interno

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file.go:riga
- **Problema**: descrizione
- **Soluzione**: fix con esempio Go idiomatic
- **Categoria**: prefix `BACKEND-GO-NNN`

## RIFERIMENTI

- Go Security Best Practices: <https://go.dev/doc/security/best-practices>
- govulncheck: <https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck>
- Race Detector: <https://go.dev/doc/articles/race_detector>
- Go Fuzzing: <https://go.dev/security/fuzz/>
- Go-SCP (Checkmarx): <https://github.com/Checkmarx/Go-SCP>
