# AGENTS.md

## Commands

| Task | Command |
|---|---|
| Build | `go build -o shopware-cli .` |
| Run | `go run . [command]` |
| All tests | `go test -v ./...` |
| Single test | `go test -v ./[package] -run TestName` |
| Lint | `golangci-lint run --timeout 4m` |
| Format | `go fmt ./...` (golangci-lint also runs gci + gofmt) |
| Tidy | `go mod tidy` |

Global CLI flags: `--verbose`, `--no-interaction` / `-n`

## Test Workflow Quirks

- CI sets `SHOPWARE_CLI_DISABLE_WASM_CACHE=1` for tests
- Use `t.Context()` to create context in tests
- Use `t.Setenv()` for environment variables
- Use `assert.ElementsMatch` for list comparisons (ignores ordering)
- Integration test fixtures live in `testdata/` directories

## Import Order (gci)

Enforced by golangci-lint:
1. Standard library
2. Third-party (Default)
3. `github.com/shopware/shopware-cli` (project-local)

## Build Notes

- `CGO_ENABLED=0` for all builds
- Version injected via ldflags: `-X 'github.com/shopware/shopware-cli/cmd.version=<ver>'`
- `./scripts/completion.sh` generates shell completions (called by goreleaser pre-hook)

## Architecture

- Entry point: `main.go` → `cmd.Execute(ctx)` → Cobra root command
- Command groups: `cmd/account/`, `cmd/extension/`, `cmd/project/`
- Each group: `[group].go` registers subcommands, `[group]_[subcommand].go` implements them
- Account commands use a ServiceContainer for dependency injection
- Extension type auto-detected by file presence: `composer.json` (Plugin), `manifest.xml` (App), or bundle

## Key Internal Packages

- `internal/verifier/` — PHPStan, ESLint, Twig linting
- `internal/account-api/` — Shopware Account API client
- `internal/llm/` — AI providers (OpenAI, Gemini, OpenRouter)
- `internal/twigparser/` — Custom Twig parsing
- `internal/system/` — PHP/Node detection, filesystem, interaction context
- `internal/ci/` — CI/CD config generation

## Config Files

- `.shopware-cli.yaml` — global CLI config
- `.shopware-extension.yml` — extension settings (schema: `internal/shopware-extension-schema.json`)
- `.shopware-project.yml` — project settings (schema: `internal/shop/shopware-project-schema.json`)

## Logging

- Structured logging via `go.uber.org/zap`
- Access via `logging.FromContext(ctx)`

## Go Version

Module requires Go 1.25.8. Prefer Go 1.24+ stdlib packages (e.g., `slices`).
