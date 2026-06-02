## Exploration: Review-Recovery

### Files Analyzed
- `docs/recovery.md` — [exists, needs work] (516 lines, detailed but has gaps)
- `scripts/debian/bootstrap/ai.sh` — [exists] (46 lines, installs gemini/claude/opencode)
- `scripts/debian/bootstrap/opencode.sh` — [exists] (142 lines, full setup + zsh plugins for debian)
- `scripts/core/symlinks.sh` — [exists] (73 lines, creates zsh/tmux/termux/nvim symlinks)
- `scripts/install.sh` — [exists] (22 lines, main installer orchestrator)
- `scripts/ai/ai.sh` — [exists] (292 lines, main AI orchestration)
- `scripts/ai/providers/claude.sh` — [exists] (15 lines, simple wrapper)
- `scripts/ai/providers/gemini.sh` — [exists] (71 lines, has fallback logic to opencode/gentle)
- `scripts/ai/providers/gentle.sh` — [exists] (36 lines, gentle control plane)
- `scripts/ai/core/provider_selector.sh` — [exists] (70 lines, intent-based provider routing)
- `scripts/ai/core/routing.sh` — [exists] (51 lines, intent detection from prompts)
- `docs/ai-workspace.md` — [exists] (245 lines, documents AI workspace system)
- `docs/installation.md` — [exists] (356 lines, install guide)
- `docs/android-termux.md` — [exists] (483 lines, Termux setup)
- `openspec/config.yaml` — [exists] (29 lines, project config with testing disabled)

### Recovery Process Assessment
- Current state: **has gaps**
- Key findings:
  - Recovery doc is detailed (516 lines) but references wrong repository URL (`ipproyectosysoluciones/termux-dotfiles` vs actual)
  - Missing AI workspace (scripts/ai/) from recovery scenarios
  - Missing gentle-ai, engram recovery instructions
  - Script references in doc don't always match actual paths (e.g., `scripts/nvim/plugins.sh` vs full path)
  - TPM installation process incomplete (no explicit `git clone` step for TPM itself in doc)
  - No mention of `scripts/core/doctor.sh` for post-recovery verification
  - AI provider fallback chain (gemini → opencode → gentle) not documented
- Issues found:
  1. Repo URL mismatch in recovery.md line 76
  2. No `scripts/ai/` or AI tools in recovery scenarios
  3. TPM explicit install step missing (user must infer from other docs)
  4. No doctor.sh usage in recovery validation steps
  5. Missing backup strategy for AI workspace state

### AI Pack Assessment
- Current providers: **gemini, claude, opencode** (in ai.sh bootstrap)
- Additional providers in `scripts/ai/providers/`: gentle (control plane only)
- Installation scripts:
  - `scripts/debian/bootstrap/ai.sh` — main AI bootstrap (gemini, claude, opencode)
  - `scripts/debian/bootstrap/opencode.sh` — opencode + zsh plugins
  - `scripts/ai/providers/gentle.sh` — gentle-ai control plane
- Where mistral fits:
  - Would need new `scripts/ai/providers/mistral.sh` following existing pattern
  - Would need integration into `scripts/ai/core/provider_selector.sh` intent routing
  - Would need fallback chain entry (gemini → opencode → gentle → mistral?)
  - Would need bootstrap entry in `scripts/debian/bootstrap/ai.sh`
- Issues/gaps:
  - No mistral provider exists yet
  - Provider selection is intent-based only, no explicit mistral routing
  - No documentation on how to add new AI providers

### Documentation Landscape
- Files found:
  - `docs/recovery.md` — needs updates (wrong URL, missing AI tools)
  - `docs/installation.md` — needs updates (AI workspace not covered)
  - `docs/ai-workspace.md` — exists but doesn't document recovery scenarios
  - `docs/android-termux.md` — Termux setup, relevant but not linked from recovery
  - `docs/architecture.md` — system overview, could reference recovery
  - `docs/shell-runtime.md` — shell layer docs
  - `docs/tmux.md`, `docs/neovim.md`, `docs/zsh.md` — subsystem docs
  - `docs/debian-runtime.md`, `docs/workflows.md`, `docs/tmux-workflows.md`, `docs/aliases.md`
- Docs that need updating:
  1. `docs/recovery.md` — fix repo URL, add AI workspace recovery, add gentle-ai/engram
  2. `docs/ai-workspace.md` — add recovery scenarios section
  3. `docs/installation.md` — add AI tools section

### Testing Readiness
- Current testing: **none**
- What's needed:
  - Test framework selection (bash testing: bats, shunit2, or similar)
  - Test directory structure (tests/ or spec/)
  - CI configuration (.github/workflows/ or similar)
  - Entry-point tests for key scripts (install.sh, symlinks.sh, doctor.sh)
  - Smoke tests for AI provider detection and routing
  - Recovery validation tests
  - openspec/config.yaml shows `strict_tdd: false` and all testing layers disabled

### Risk Areas
1. **Recovery URL mismatch** — users following docs will clone wrong repo
2. **No AI recovery** — gentle-ai, engram, and AI workspace not covered in recovery
3. **Missing provider pattern docs** — adding mistral requires understanding existing routing
4. **No test infrastructure** — verification must be manual, error-prone
5. **Provider fallback chain undocumented** — gemini → opencode → gentle logic not in docs
6. **Recovery gaps for Debian bootstrap** — `scripts/debian/bootstrap/` not referenced in recovery doc

### Recommended Approach
1. **Phase 1: Fix recovery.md** — correct repo URL, add AI workspace recovery, add gentle-ai/engram
2. **Phase 2: Document provider architecture** — create doc explaining how to add new AI providers (mistral)
3. **Phase 3: Add mistral provider** — follow existing pattern in `scripts/ai/providers/`
4. **Phase 4: Update ai-workspace.md** — add recovery scenarios section
5. **Phase 5: Set up test infrastructure** — add basic smoke tests for critical paths (low priority given project config)

Order makes sense because: fix docs first (lowest risk), document provider pattern before adding mistral (ensures understanding), then add mistral (actual change), then improve docs further, then testing (if time permits).