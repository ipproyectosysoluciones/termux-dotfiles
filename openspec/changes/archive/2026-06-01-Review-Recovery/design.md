# Design: Review-Recovery

## Technical Approach

Three-phase incremental fix targeting documentation correctness and Mistral AI provider integration. Phase 1 fixes docs (low risk, ~50-100 lines). Phase 2 creates provider architecture doc. Phase 3 adds Mistral provider. Chained PRs if total exceeds 400 lines.

## Architecture Decisions

### Decision: Mistral Provider Pattern

**Choice**: Mirror the existing gemini.sh provider pattern exactly — `run_mistral()` function, fallback to `run_opencode` and `run_gentle`, exit 0 on success.

**Alternatives considered**: Creating a new abstract base interface, using a config-driven provider factory.

**Rationale**: The codebase already has established provider conventions. Consistency within ~98% Bash codebase reduces cognitive load. The fallback chain (gemini → opencode → gentle → mistral as final) is preserved by mimicking the existing error-handling pattern.

### Decision: Testing Framework — bats

**Choice**: bats (bash automated testing system), installable via `apt install bats`.

**Alternatives considered**: shunit2 (more feature-rich but additional dependency), manual verification only.

**Rationalie**: User explicitly selected bats. Bash-native — aligns with project language. No additional dependencies beyond `bats` package.

### Decision: URL Correction Strategy

**Choice**: Exact find-replace on the two occurrences of `ipproyectosysoluciones/termux-dotfiles` → `bladimir/Termux-AI-Astaroth`.

**Alternatives considered**: Add a note explaining the correct URL alongside the wrong one.

**Rationale**: Wrong URLs in recovery docs defeat the purpose. Clean fix is correct fix here.

### Decision: Provider Doc Location

**Choice**: Standalone `docs/provider-architecture.md`.

**Alternatives considered**: Section within `docs/ai-workspace.md`.

**Rationale**: Provider architecture spans multiple AI runtimes and is a distinct concern from workspace session management. Standalone doc is easier to discover and maintain.

## Data Flow

```
provider_selector.sh
    │
    ├── intent="research"    → provider_available(gemini)? → "gemini" : "opencode"
    ├── intent="architecture" → provider_available(gemini)? → "gemini" : "opencode"
    ├── intent="devops"       → provider_available(opencode)? → "opencode" : fallback
    ├── intent="coding"      → provider_available(opencode)? → "opencode" : fallback
    └── default               → "opencode"

[NEW: mistral intent case will route via provider_available(mistral)? → "mistral" : fallback]

fallback chain (gemini.sh pattern):
    mistral.sh → run_opencode → run_gentle
```

## File Changes

### Phase 1

| File | Action | Description |
|------|--------|-------------|
| `docs/recovery.md` | Modify | Fix URL (line 76, 459), add AI workspace recovery section, add doctor.sh validation, add explicit TPM git clone+init |
| `docs/installation.md` | Modify | Add AI tools section referencing ai.sh |

### Phase 2

| File | Action | Description |
|------|--------|-------------|
| `docs/provider-architecture.md` | Create | Provider system docs: selector, routing, provider interface contract, adding providers, fallback chain |

### Phase 3

| File | Action | Description |
|------|--------|-------------|
| `scripts/ai/providers/mistral.sh` | Create | Mistral provider script following gemini.sh pattern |
| `scripts/ai/core/provider_selector.sh` | Modify | Add mistral routing case |
| `scripts/debian/bootstrap/ai.sh` | Modify | Add mistral bootstrap entry |

### Infrastructure

| File | Action | Description |
|------|--------|-------------|
| `tests/` | Create | bats test suite, `tests/phase1/`, `tests/phase2/`, `tests/phase3/` |

## Interface: Provider Script Contract

Every provider script in `scripts/ai/providers/` MUST implement:

```bash
#!/data/data/com.termux/files/usr/bin/bash

run_<provider>() {
    local prompt="$*"
    # Execute provider-specific API call
    # On success: echo output, return 0
    # On quota exhaustion: echo message, call next provider in chain, return 0
    # On generic failure: echo message, call final fallback, return 0
}
```

**Exit codes**: 0 = success (or fallback handled), non-zero = unrecoverable failure.

**Required env vars** (sourced from `.env` or `scripts/ai/core/env.sh`):
- `MISTRAL_API_KEY` — Mistral API key

**API endpoint**: `https://api.mistral.ai/v1/chat/completions` (OpenAI-compatible)

**Error conventions** (from gemini.sh):
- Detect `QUOTA_EXHAUSTED` in output → call next provider
- Detect non-zero exit → call next provider
- Final fallback should be `run_gentle`

## Testing Strategy

### Phase 1 Tests

```bash
# URL validation — must find zero occurrences of wrong URL
@test "recovery.md has no old URL" {
  run grep -c 'ipproyectosysoluciones/termux-dotfiles' docs/recovery.md
  [[ $status -ne 0 ]]
}

# Path validation — referenced scripts must exist
@test "recovery.md referenced scripts exist" {
  # Extract script paths from recovery.md and verify existence
}

# doctor.sh reference exists in recovery.md
@test "recovery.md references doctor.sh" {
  run grep -c 'doctor.sh' docs/recovery.md
  [[ $output -gt 0 ]]
}
```

### Phase 2 Tests

```bash
# provider-architecture.md exists
@test "provider architecture doc exists" {
  [[ -f docs/provider-architecture.md ]]
}

# Doc covers required topics
@test "doc covers architecture section" {
  run grep -c '## Architecture' docs/provider-architecture.md
  [[ $output -gt 0 ]]
}
```

### Phase 3 Tests

```bash
# mistral.sh syntax check
@test "mistral.sh loads without errors" {
  run bash -n scripts/ai/providers/mistral.sh
  [[ $status -eq 0 ]]
}

# mistral.sh is executable
@test "mistral.sh is executable" {
  [[ -x scripts/ai/providers/mistral.sh ]]
}

# provider_selector.sh accepts mistral
@test "provider_selector includes mistral routing" {
  run grep -c 'mistral' scripts/ai/core/provider_selector.sh
  [[ $output -gt 0 ]]
}

# ai.sh bootstrap includes mistral
@test "ai.sh bootstrap includes mistral" {
  run grep -c 'mistral' scripts/debian/bootstrap/ai.sh
  [[ $output -gt 0 ]]
}
```

### Test Execution

```bash
# Run all tests
bats tests/

# Run phase-specific tests
bats tests/phase1/
bats tests/phase2/
bats tests/phase3/
```

All tests must pass before phase is considered complete.

## Open Questions

- [ ] None — all decisions resolved via proposal or user confirmation.

## Rollback Plan

| Phase | Rollback Action |
|-------|-----------------|
| Phase 1 | `git checkout docs/recovery.md docs/installation.md` |
| Phase 2 | `rm docs/provider-architecture.md` |
| Phase 3 | `rm scripts/ai/providers/mistral.sh`, `git checkout scripts/ai/core/provider_selector.sh scripts/debian/bootstrap/ai.sh` |

## Chained PR Strategy

| PR | Phase | Scope | Est. Lines |
|----|-------|-------|------------|
| PR 1 | Phase 1 | Docs fix: recovery.md, installation.md | ~50-100 |
| PR 2 | Phase 2 + 3 | provider-architecture.md + mistral.sh + routing + bootstrap | ~150-250 |
| PR 3 | Infra | tests/ directory structure + phase tests | ~100-150 |

**Total estimated**: ~300-500 lines across 3 PRs. Chained PRs keep each review focused and under 400-line budget per PR.