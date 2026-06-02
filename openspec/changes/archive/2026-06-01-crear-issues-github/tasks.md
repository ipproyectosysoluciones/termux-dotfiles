# Tasks: crear-issues-github

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~450 lines across 10 files |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | 4 stacked PRs (docs → code → docs → legacy) |
| Delivery strategy | ask-always |
| Chain strategy | stacked-to-main |

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: High

---

## Phase 1: Create GitHub Issues (13 issues)

### P1 — Critical (2 issues)

- [ ] 1.1 **Issue #1** — `gh issue create --title "fix(scripts/nvim): correct echo header — installs ZSH plugins, not ZSH in filename" --body "$(cat <<'EOF'
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`scripts/nvim/plugins.sh` has a misleading echo header at line 4: `echo "Installing ZSH plugins..."`. The script installs ZSH shell plugins, but the path `scripts/nvim/` suggests Neovim plugins.

### Affected File
`scripts/nvim/plugins.sh` line 4

### Expected Behavior
Echo should say "Installing ZSH shell plugins..." to clarify it's shell plugins, not Neovim plugins.

### Proposed Fix
Change line 4 to: `echo "Installing ZSH shell plugins..."`

### Priority
P1 — Critical (1-line fix, misleading output)
EOF
)" --label "bug" --label "priority:high" --repo ipproyectosysoluciones/termux-dotfiles`

- [ ] 1.2 **Issue #2** — `gh issue create --title "fix(docs): update gc entry in docs/aliases.md — it's a ZSH function, not an alias" --body "$(cat <<'EOF'
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`docs/aliases.md` describes `gc` as an alias, but `gc` is actually a **shell function** defined in `zsh/functions.zsh` (line 5):
```bash
gc() {
    if [[ -z "$*" ]]; then
        echo "Usage: gc \"mensaje\""
        return 1
    fi
    git commit -m "$*"
}
```

### Affected File
`docs/aliases.md` — the `gc` entry (around line 150)

### Expected Behavior
Documentation should accurately reflect that `gc` is a ZSH function, not an alias.

### Proposed Fix
Update `gc` entry to: `gc "message" → ZSH function (zsh/functions.zsh) — git commit shorthand`

### Priority
P1 — Critical (incorrect documentation misleads contributors)
EOF
)" --label "bug" --label "priority:high" --repo ipproyectosysoluciones/termux-dotfiles`

### P2 — Grave (1 issue)

- [ ] 1.3 **Issue #3** — `gh issue create --title "fix(.gitignore): add .local/bin to prevent accidental commit of generated wrappers" --body "$(cat <<'EOF'
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`scripts/debian/wrappers.sh` creates wrapper scripts at `$HOME/.local/bin/`, but `.local/bin/` is **not** in `.gitignore`. Generated wrappers could be accidentally committed.

### Affected File
`.gitignore`

### Expected Behavior
`.local/bin/` should be in `.gitignore` to prevent committing generated wrapper scripts.

### Proposed Fix
Add to `.gitignore`: `.local/bin/`

### Priority
P2 — Grave (risk of committing generated artifacts)
EOF
)" --label "bug" --label "priority:medium" --repo ipproyectosysoluciones/termux-dotfiles`

### P3 — Moderate (3 issues)

- [ ] 1.4 **Issue #4** — `gh issue create --title "fix(docs): update phantom script references — setup-symlinks.sh → scripts/core/symlinks.sh" --body "$(cat <<'EOF'
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`docs/workflows.md` and `docs/recovery.md` reference `~/dotfiles/scripts/setup-symlinks.sh` which **does not exist**. The actual path is `scripts/core/symlinks.sh`.

### Affected Files
- `docs/workflows.md` (line ~297)
- `docs/recovery.md` (lines ~152, ~372)

### Expected Behavior
Documentation should reference the correct script path.

### Proposed Fix
Update all references from `~/dotfiles/scripts/setup-symlinks.sh` to `~/dotfiles/scripts/core/symlinks.sh`.

### Priority
P3 — Moderate (broken documentation links)
EOF
)" --label "documentation" --label "priority:medium" --repo ipproyectosysoluciones/termux-dotfiles`

- [ ] 1.5 **Issue #5** — `gh issue create --title "fix(docs): remove references to scripts/install-plugins.sh — script does not exist" --body "$(cat <<'EOF'
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`docs/workflows.md` and `docs/recovery.md` reference `~/dotfiles/scripts/install-plugins.sh` which **does not exist**. Correct scripts: `scripts/nvim/plugins.sh` for Neovim plugins.

### Affected Files
- `docs/workflows.md` (line ~304)
- `docs/recovery.md` (line ~207)

### Expected Behavior
Remove or correct the `install-plugins.sh` references. Point to `scripts/nvim/plugins.sh` if Neovim intent.

### Proposed Fix
Remove or correct references; if intent was Neovim plugins, point to `scripts/nvim/plugins.sh`.

### Priority
P3 — Moderate (broken documentation links)
EOF
)" --label "documentation" --label "priority:medium" --repo ipproyectosysoluciones/termux-dotfiles`

- [ ] 1.6 **Issue #6** — `gh issue create --title "fix(docs): update bootstrap-packages.sh → scripts/core/packages.sh in workflows.md" --body "$(cat <<'EOF'
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`docs/workflows.md` references `~/dotfiles/scripts/bootstrap-packages.sh` which **does not exist**. The actual path is `scripts/core/packages.sh`.

### Affected File
`docs/workflows.md` (line ~311)

### Expected Behavior
Documentation should reference the correct script path.

### Proposed Fix
Update reference from `~/dotfiles/scripts/bootstrap-packages.sh` to `~/dotfiles/scripts/core/packages.sh`.

### Priority
P3 — Moderate (broken documentation link)
EOF
)" --label "documentation" --label "priority:medium" --repo ipproyectosysoluciones/termux-dotfiles`

### P4 — Moderate (2 issues)

- [ ] 1.7 **Issue #7** — `gh issue create --title "fix(scripts/debian): implement or remove empty doctor.sh script" --body "$(cat <<'EOF'
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`scripts/debian/doctor.sh` is **0 bytes** — an empty file with no implementation.

### Affected File
`scripts/debian/doctor.sh`

### Expected Behavior
Either implement the script with health-check logic or remove it. An empty placeholder is misleading.

### Proposed Fix
**Option A:** Implement with basic diagnostics (check required binaries, verify environment).
**Option B:** Remove the empty file.

### Priority
P4 — Moderate (dead code / misleading empty file)
EOF
)" --label "enhancement" --label "priority:low" --repo ipproyectosysoluciones/termux-dotfiles`

- [ ] 1.8 **Issue #8** — `gh issue create --title "fix(scripts/debian): implement or remove empty runtime.sh script" --body "$(cat <<'EOF'
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`scripts/debian/runtime.sh` is **0 bytes** — an empty file with no implementation.

### Affected File
`scripts/debian/runtime.sh`

### Expected Behavior
Either implement the script with runtime setup logic or remove it. An empty placeholder is misleading.

### Proposed Fix
**Option A:** Implement with runtime setup logic.
**Option B:** Remove the empty file.

### Priority
P4 — Moderate (dead code / misleading empty file)
EOF
)" --label "enhancement" --label "priority:low" --repo ipproyectosysoluciones/termux-dotfiles`

### P5 — Low (5 issues)

- [ ] 1.9 **Issue #9** — `gh issue create --title "fix(docs): fill or delete empty docs/debian-runtime.md" --body "$(cat <<'EOF'
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`docs/debian-runtime.md` is **0 bytes** — an empty file with no content.

### Affected File
`docs/debian-runtime.md`

### Expected Behavior
Fill with Debian runtime configuration content or delete if not needed.

### Proposed Fix
**Option A:** Document Debian runtime configuration, required packages, environment setup.
**Option B:** Delete the empty file.

### Priority
P5 — Low (empty documentation file)
EOF
)" --label "documentation" --label "priority:low" --repo ipproyectosysoluciones/termux-dotfiles`

- [ ] 1.10 **Issue #10** — `gh issue create --title "fix(docs): fill or delete empty docs/neovim.md" --body "$(cat <<'EOF'
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`docs/neovim.md` is **0 bytes** — an empty file with no content.

### Affected File
`docs/neovim.md`

### Expected Behavior
Fill with Neovim configuration content or delete if not needed.

### Proposed Fix
**Option A:** Document Neovim configuration, plugin list, keybindings, setup.
**Option B:** Delete the empty file.

### Priority
P5 — Low (empty documentation file)
EOF
)" --label "documentation" --label "priority:low" --repo ipproyectosysoluciones/termux-dotfiles`

- [ ] 1.11 **Issue #11** — `gh issue create --title "chore(scripts/debian/legacy): archive or remove orphaned setup-debian-devops.sh (249 lines)" --body "$(cat <<'EOF'
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`scripts/debian/legacy/setup-debian-devops.sh` (249 lines) is **orphaned legacy code** — not called from `scripts/install.sh` or any other flow.

### Affected File
`scripts/debian/legacy/setup-debian-devops.sh`

### Expected Behavior
Legacy scripts not part of any active workflow should be archived or removed.

### Proposed Fix
**Option A:** Archive to `scripts/archive/` with a note about when/why it was archived.
**Option B:** Remove entirely if confirmed unused.

### Priority
P5 — Low (orphaned legacy code, no active usage)
EOF
)" --label "enhancement" --label "cleanup" --label "priority:low" --repo ipproyectosysoluciones/termux-dotfiles`

- [ ] 1.12 **Issue #12** — `gh issue create --title "fix(scripts/core): integrate update.sh into install flow or document its purpose" --body "$(cat <<'EOF'
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`scripts/core/update.sh` (35 lines) exists but is **never called from `scripts/install.sh`** or any other script. It is dead code unless manually invoked.

### Affected Files
- `scripts/core/update.sh`
- `scripts/install.sh`

### Expected Behavior
Either integrate `update.sh` into the installation flow, document manual usage, or remove it.

### Proposed Fix
**Option A:** Add `bash "$BASE_DIR/core/update.sh"` to `scripts/install.sh` as a final step.
**Option B:** Add documentation in `docs/` explaining when/how to run `update.sh` manually.
**Option C:** Remove if not needed.

### Priority
P5 — Low (uncalled script, potential dead code)
EOF
)" --label "enhancement" --label "priority:low" --repo ipproyectosysoluciones/termux-dotfiles`

- [ ] 1.13 **Issue #13** — `gh issue create --title "docs(cleanup): remove duplicate gc documentation entry from docs/aliases.md" --body "$(cat <<'EOF'
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Note
Follow-up to Issue #2. After fixing the `gc` function vs alias discrepancy in `docs/aliases.md`, perform a general cleanup pass:
- Remove any duplicate `gc` entries
- Ensure consistent formatting with other function entries
- Align with the corrected documentation approach

### Affected File
`docs/aliases.md`

### Expected Behavior
After Issue #2 is fixed, `gc` should appear exactly once with accurate type annotation (function, not alias).

### Priority
P5 — Low (documentation cleanup, depends on Issue #2)
EOF
)" --label "documentation" --label "priority:low" --repo ipproyectosysoluciones/termux-dotfiles`

---

## Phase 2: Implement Code + Docs Fixes (4 stacked PRs)

### PR1 — `pr/01-fix-docs-phantom-scripts` (~20 lines)
**Branch from:** `dev` | **Merges to:** `main` | **Closes:** #2, #4, #5, #6, #13

**Files:**
- `docs/workflows.md` — fix 3 phantom script paths
- `docs/recovery.md` — fix 2 phantom script paths
- `docs/aliases.md` — correct `gc` entry from alias to function

**Commits (work units):**
1. `fix(docs): correct gc entry in aliases.md — it's a function, not alias` — Issue #2
2. `fix(docs): replace phantom setup-symlinks.sh with scripts/core/symlinks.sh` — Issue #4
3. `fix(docs): remove phantom install-plugins.sh references` — Issue #5
4. `fix(docs): update bootstrap-packages.sh path to scripts/core/packages.sh` — Issue #6
5. `fix(docs): remove duplicate gc entry from aliases.md` — Issue #13

**Acceptance Criteria:**
- All phantom script references point to existing paths
- `gc` marked as ZSH function in `zsh/functions.zsh`
- No duplicate `gc` entry in aliases.md

---

### PR2 — `pr/02-fix-code-misleading-echo` (~65 lines)
**Branch from:** `pr/01-fix-docs-phantom-scripts` → retarget to `main` after PR1 merges | **Closes:** #1, #3, #7, #8

**Files:**
- `scripts/nvim/plugins.sh` — fix echo header (1 line)
- `.gitignore` — add `.local/bin/`
- `scripts/debian/doctor.sh` — implement or remove (DECISION NEEDED)
- `scripts/debian/runtime.sh` — implement or remove (DECISION NEEDED)

**Commits (work units):**
1. `fix(scripts/nvim): correct echo header to say ZSH shell plugins` — Issue #1
2. `fix(.gitignore): add .local/bin/` — Issue #3
3. `fix(scripts/debian): remove empty doctor.sh and runtime.sh` — Issues #7, #8

**Acceptance Criteria:**
- Echo text clearly says "Installing ZSH shell plugins..."
- `.local/bin/` present in `.gitignore`
- Empty debian scripts removed (or implemented with stub)

**Decision:** ✅ Implementar diagnóstico básico en `doctor.sh` y runtime básico en `runtime.sh`

---

### PR3 — `pr/03-fix-docs-empty-files` (~110 lines)
**Branch from:** `pr/02-fix-code-misleading-echo` → retarget to `main` after PR2 merges | **Closes:** #9, #10

**Files:**
- `docs/debian-runtime.md` — fill with content or delete
- `docs/neovim.md` — fill with content or delete

**Commits (work units):**
1. `fix(docs): fill or delete docs/debian-runtime.md` — Issue #9
2. `fix(docs): fill or delete docs/neovim.md` — Issue #10

**Acceptance Criteria:**
- Both doc files have meaningful content OR are deleted
- No 0-byte documentation files remain

**Decision:** ✅ Rellenar ambos archivos con contenido adecuado (`debian-runtime.md` y `neovim.md`)

---

### PR4 — `pr/04-cleanup-legacy-scripts` (~255 lines)
**Branch from:** `pr/03-fix-docs-empty-files` → retarget to `main` after PR3 merges | **Closes:** #11, #12

**Files:**
- `scripts/debian/legacy/setup-debian-devops.sh` — archive or remove (DECISION NEEDED)
- `scripts/core/update.sh` — integrate into install.sh or document (DECISION NEEDED)
- `scripts/install.sh` — add update.sh call (~6 lines) if integrating

**Commits (work units):**
1. `chore(scripts/debian/legacy): archive orphaned setup-debian-devops.sh` — Issue #11
2. `fix(scripts/core): integrate update.sh into install flow` — Issue #12

**Acceptance Criteria:**
- Orphaned legacy script archived or removed
- `update.sh` either integrated into install.sh or documented as manual-only

**Decision:** ✅ Archivar `setup-debian-devops.sh` en `scripts/archive/` (conservar para consulta futura) + Integrar `update.sh` en `install.sh` y documentar su uso

---

## Review Workload Forecast

| PR | Branch | Est. Lines | 400-line budget |
|----|--------|------------|-----------------|
| PR1 | `pr/01-fix-docs-phantom-scripts` | ~20 | ✅ Under |
| PR2 | `pr/02-fix-code-misleading-echo` | ~65 | ✅ Under |
| PR3 | `pr/03-fix-docs-empty-files` | ~110 | ✅ Under |
| PR4 | `pr/04-cleanup-legacy-scripts` | ~255 | ✅ Under |
| **Total** | | **~450** | **✅ All under budget** |

**Decisiones resueltas por el usuario:**
1. ✅ PR2: Implementar diagnóstico básico en `doctor.sh` y runtime básico en `runtime.sh`
2. ✅ PR3: Rellenar `debian-runtime.md` y `neovim.md` con contenido adecuado
3. ✅ PR4: Archivar `setup-debian-devops.sh` en `scripts/archive/` (conservar consulta futura)
4. ✅ PR4: Integrar `update.sh` en `install.sh` y documentar su uso

**Chained PRs recommended:** Yes — 4 stacked PRs, each merging to `main` in sequence.
**Chain strategy:** stacked-to-main
**Delivery strategy:** ask-always (requires maintainer decision before apply)