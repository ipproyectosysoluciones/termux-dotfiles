# Spec: Review-Recovery

## Phase 1: Recovery & Installation Docs Fix

### Requirements

#### R1.1: Fix repository URL in recovery.md
- **File**: `docs/recovery.md`
- ALL references to `ipproyectosysoluciones/termux-dotfiles` MUST be updated to `bladimir/Termux-AI-Astaroth`
- Verify: `grep -c "ipproyectosysoluciones" docs/recovery.md` returns 0

#### R1.2: Add AI workspace recovery
- **File**: `docs/recovery.md`
- MUST include step-by-step recovery for `scripts/ai/` directory
- MUST include gentle-ai reinstallation procedure
- MUST include engram recovery steps
- MUST reference `scripts/debian/bootstrap/ai.sh` for AI tool restoration

#### R1.3: Add doctor.sh validation
- **File**: `docs/recovery.md`
- MUST include post-recovery validation using `scripts/debian/doctor.sh`
- MUST list expected health checks and their pass/fail criteria

#### R1.4: Document explicit TPM installation
- **File**: `docs/recovery.md`
- MUST include explicit `git clone` step for tmux-plugins/tpm
- MUST reference TPM initialization command

#### R1.5: Add AI tools section to installation.md
- **File**: `docs/installation.md`
- MUST document AI provider installation options
- MUST reference `scripts/debian/bootstrap/ai.sh`

#### R1.6: Tests for Phase 1
- **Test**: Verify URL fix in recovery.md — `grep -c "ipproyectosysoluciones" docs/recovery.md` returns 0
- **Test**: Verify recovery doc references existing scripts (not phantom paths)
- **Test**: Verify installation.md references ai.sh bootstrap script

---

## Phase 2: Provider Architecture Documentation

### Requirements

#### R2.1: Document provider system
- **File**: `docs/provider-architecture.md` (NEW)
- MUST explain `provider_selector.sh` intent routing
- MUST document provider fallback chain (gemini → opencode → gentle)
- MUST include step-by-step guide for adding new providers
- MUST document required provider script interface (functions, exit codes, patterns)

#### R2.2: Tests for Phase 2
- **Test**: Verify doc exists at `docs/provider-architecture.md`
- **Test**: Verify doc covers provider_selector.sh intent routing
- **Test**: Verify doc covers fallback chain
- **Test**: Verify doc includes adding-new-provider guide

---

## Phase 3: Mistral AI Provider

### Requirements

#### R3.1: Create mistral provider script
- **File**: `scripts/ai/providers/mistral.sh` (NEW)
- MUST follow existing provider pattern (gemini.sh structure)
- MUST support `.env` API key configuration (MISTRAL_API_KEY)
- MUST implement `run_mistral` function with query handling
- MUST implement error handling with fallback to gentle
- All functions MUST include executable bit (chmod +x)

#### R3.2: Integrate into provider selector
- **File**: `scripts/ai/core/provider_selector.sh`
- MUST add mistral to the provider routing table
- MUST follow existing routing pattern

#### R3.3: Add mistral bootstrap entry
- **File**: `scripts/debian/bootstrap/ai.sh`
- MUST add mistral installation step
- MUST follow existing provider bootstrap pattern

#### R3.4: Tests for Phase 3
- **Test**: Verify `scripts/ai/providers/mistral.sh` exists and is executable
- **Test**: Verify `source scripts/ai/providers/mistral.sh` loads without errors
- **Test**: Verify `provider_selector.sh` recognizes "mistral" as valid provider
- **Test**: Verify `MISTRAL_API_KEY` env var is respected in mistral.sh

---

## Global Requirements

### G1: Conventional Commits
All commits MUST follow conventional commit format.

### G2: Test-First (strict_tdd)
- Tests MUST be written BEFORE implementation code
- Each phase MUST include test files (`tests/` directory)
- Tests MUST be executable and verifiable

### G3: No phantom references
All script paths in documentation MUST point to existing files.

### G4: Chained PRs
If total changes exceed 400 lines, split into 3 chained PRs (1 per phase).

---

## Scenario Coverage

### Happy Paths
- URL fix corrects all references in recovery.md
- AI workspace recovery restores scripts/ai/ fully
- Provider architecture doc enables new provider addition
- Mistral provider integrates seamlessly with existing fallback chain

### Edge Cases
- Missing .env file — mistral.sh should fail gracefully with helpful message
- Provider script missing — provider_selector.sh should skip and fall back
- TPM not installed — recovery.md should detect and offer fix

### Error States
- Mistral API key invalid — should fallback to gentle
- Script not executable — tests should catch this
- Phantom path references — tests should validate against actual filesystem