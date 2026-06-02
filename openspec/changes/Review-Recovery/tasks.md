# Tasks: Review-Recovery

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~300-400 lines across ~8 files |
| 400-line budget risk | Medium |
| Chained PRs recommended | Yes |
| Suggested split | 3 chained PRs (1 per phase) |
| Delivery strategy | ask-on-risk |
| Chain strategy | stacked-to-main |

**Decision needed before apply**: No (user already approved chained PRs)
**Chained PRs recommended**: Yes
**Chain strategy**: stacked-to-main
**400-line budget risk**: Medium

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Testing infrastructure + Phase 1 docs fix | PR 1 | Set up bats framework, write Phase 1 tests; fix recovery.md + installation.md |
| 2 | Phase 2 provider docs | PR 2 | Create provider-architecture.md, write tests |
| 3 | Phase 3 Mistral provider | PR 3 | Create mistral.sh, update provider_selector.sh and ai.sh, write tests |

---

## Phase 0: Testing Infrastructure

- [x] 0.1 Create `tests/` directory structure (`tests/phase1/`, `tests/phase2/`, `tests/phase3/`)
- [x] 0.2 Create `tests/test_helper.bash` with common test utilities (setup/teardown helpers, common assertions)
- [x] 0.3 Verify bats is available: `which bats || bats --version`; if unavailable, document installation in README under tests/
- [x] 0.4 Document test conventions: each test file starts with `# bats file_prefix: tests/phaseN/` + brief description of what the tests verify

---

## Phase 1: Recovery & Installation Docs Fix (PR 1)

### Tests First (RED)
- [x] 1.1 RED: Write `tests/phase1/recovery_url_fix.bats` — verify `grep -c "ipproyectosysoluciones" docs/recovery.md` returns 0 (non-zero exit = pass)
- [x] 1.2 RED: Write `tests/phase1/recovery_phantom_paths.bats` — extract script paths from `docs/recovery.md`, verify each referenced path exists on filesystem
- [x] 1.3 RED: Write `tests/phase1/recovery_doctor_ref.bats` — verify `docs/recovery.md` references `doctor.sh` at least once
- [x] 1.4 RED: Write `tests/phase1/recovery_tpm_docs.bats` — verify `docs/recovery.md` documents explicit TPM git clone step
- [x] 1.5 RED: Write `tests/phase1/installation_ai_tools.bats` — verify `docs/installation.md` references `scripts/debian/bootstrap/ai.sh`

### Implementation (GREEN)
- [x] 1.6 GREEN: Fix repo URL in `docs/recovery.md` — replace all `ipproyectosysoluciones/termux-dotfiles` with `bladimir/Termux-AI-Astaroth`
- [x] 1.7 GREEN: Add AI workspace recovery section to `docs/recovery.md`: gentle-ai reinstallation, engram recovery steps, reference to `scripts/debian/bootstrap/ai.sh`
- [x] 1.8 GREEN: Add doctor.sh validation section to `docs/recovery.md`: post-recovery validation steps, expected health checks with pass/fail criteria
- [x] 1.9 GREEN: Add explicit TPM git clone + init step to `docs/recovery.md`: `git clone https://github.com/tmux-plugins/tpm.git`, TPM initialization command
- [x] 1.10 GREEN: Add AI tools section to `docs/installation.md`: document AI provider installation via `scripts/debian/bootstrap/ai.sh`

### Refactor (REFACTOR)
- [x] 1.11 REFACTOR: Run `bats tests/phase1/` — all tests must pass; fix any failures before proceeding

---

## Phase 2: Provider Architecture Documentation (PR 2)

### Tests First (RED)
- [ ] 2.1 RED: Write `tests/phase2/provider_doc_exists.bats` — verify `docs/provider-architecture.md` exists
- [ ] 2.2 RED: Write `tests/phase2/provider_doc_sections.bats` — verify doc contains: provider system overview, intent routing explanation, fallback chain (gemini → opencode → gentle), adding-new-provider guide, provider script interface contract

### Implementation (GREEN)
- [ ] 2.3 GREEN: Create `docs/provider-architecture.md` with:
  - Provider system overview
  - `provider_selector.sh` intent routing explanation
  - Fallback chain (gemini → opencode → gentle)
  - Step-by-step guide for adding new providers
  - Provider script interface documentation (run_\<provider\> function signature, exit codes, required env vars, error conventions)

### Refactor (REFACTOR)
- [ ] 2.4 REFACTOR: Run `bats tests/phase2/` — all tests must pass; fix any failures before proceeding

---

## Phase 3: Mistral AI Provider (PR 3)

### Tests First (RED)
- [x] 3.1 RED: Write `tests/phase3/mistral_syntax.bats` — verify `bash -n scripts/ai/providers/mistral.sh` returns exit 0 (syntax check)
- [x] 3.2 RED: Write `tests/phase3/mistral_executable.bats` — verify `scripts/ai/providers/mistral.sh` is executable (`-x` check)
- [x] 3.3 RED: Write `tests/phase3/mistral_loads.bats` — verify `source scripts/ai/providers/mistral.sh` loads without errors (capture stderr)
- [x] 3.4 RED: Write `tests/phase3/mistral_env_var.bats` — verify mistral.sh sources `.env` and references `MISTRAL_API_KEY`
- [x] 3.5 RED: Write `tests/phase3/provider_selector_mistral.bats` — verify `scripts/ai/core/provider_selector.sh` contains "mistral" routing case
- [x] 3.6 RED: Write `tests/phase3/bootstrap_mistral.bats` — verify `scripts/debian/bootstrap/ai.sh` contains mistral installation step

### Implementation (GREEN)
- [x] 3.7 GREEN: Create `scripts/ai/providers/mistral.sh` following gemini.sh pattern:
  - Shebang: `#!/data/data/com.termux/files/usr/bin/bash`
  - Source `.env` for `MISTRAL_API_KEY`
  - Implement `run_mistral()` function: call Mistral API endpoint, handle quota errors with fallback chain
  - Implement `status_mistral()` check function
  - Include error handling: QUOTA_EXHAUSTED detection → call next provider, final fallback to `run_gentle`
  - `chmod +x` on the file
- [x] 3.8 GREEN: Update `scripts/ai/core/provider_selector.sh` — add mistral case in routing table following existing pattern
- [x] 3.9 GREEN: Update `scripts/debian/bootstrap/ai.sh` — add mistral installation step following existing provider bootstrap pattern

### Refactor (REFACTOR)
- [x] 3.10 REFACTOR: Run `bats tests/phase3/` — all tests must pass; fix any failures before proceeding

---

## Phase 4: Final Verification

- [ ] 4.1 Run ALL tests: `bats tests/` (all phase1, phase2, phase3 tests must pass)
- [ ] 4.2 Verify no phantom script references in updated `docs/recovery.md`
- [ ] 4.3 Verify all new files are executable where needed (mistral.sh)
- [ ] 4.4 Final review: conventional commits used, no debug code, all spec requirements satisfied