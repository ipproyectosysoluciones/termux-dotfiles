# SDD Proposal: crear-issues-github

## 1. Change

`crear-issues-github`

## 2. Intent

Create 13 GitHub issues for audit findings in the termux-dotfiles project, organized by severity (Critical → Grave → Moderate → Low), with all issues assigned to the user ("assign to me") and grouped into a 4-PR chained review plan respecting the 400-line budget.

## 3. Scope

### In Scope

- All 13 confirmed audit findings from the exploration phase
- Documentation fixes for all references to non-existent scripts
- Code fixes for misleading headers, empty files, and gitignore gaps
- Legacy code cleanup decisions
- Chained PR planning for all changes

### Out of Scope

- Actually creating the issues (this proposal documents what to create)
- Actually implementing fixes (separate from issue creation)
- Creating the chained PRs (covered by separate implementation SDDs)

## 4. Approach

1. **Issue creation order**: Critical (P1) first, then Grave (P2), then Moderate (P3+P4), then Low (P5) — following severity-first ordering
2. **Assignment**: All issues assigned to user with "assign to me" note (no GitHub username available)
3. **Labels**: `bug` for code issues, `documentation` for doc issues, `cleanup` for legacy issues; priority labels (`priority:high`, `priority:medium`, `priority:low`)
4. **PR grouping**: Issues are designed to map 1:1 to a 4-PR chain where each PR is self-contained and under 400 lines

## 5. Issue Descriptions

---

### Issue 1 — P1-Critical: Misleading echo header in scripts/nvim/plugins.sh

**Title:** `fix(scripts/nvim): correct echo header — installs ZSH plugins, not "ZSH" in filename`

**Body:**
```
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`scripts/nvim/plugins.sh` has a misleading echo header:

```bash
echo "Installing ZSH plugins..."
```

Despite the filename and path (`scripts/nvim/`), this script installs **zsh plugins** for shell use. The header is not wrong, but the path `scripts/nvim/` is confusing — users might think this installs Neovim plugins.

### Affected File
`scripts/nvim/plugins.sh` line 4

### Expected Behavior
The echo should make clear this installs **ZSH shell plugins**, not Neovim plugins.

### Proposed Fix
Change echo to:
```bash
echo "Installing ZSH shell plugins..."
```

### Priority
P1 — Critical (misleading output, 1-line fix)
```

---

### Issue 2 — P1-Critical: `gc` documented as alias but is a function

**Title:** `fix(docs): update gc entry in docs/aliases.md — it's a ZSH function, not an alias`

**Body:**
```
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`docs/aliases.md` describes `gc` as an alias, but `gc` is actually a **shell function** defined in `zsh/functions.zsh` (line 5).

```bash
# zsh/functions.zsh
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
Update the `gc` entry in `docs/aliases.md` to indicate it's a function, e.g.:
```
gc "message"     → ZSH function (zsh/functions.zsh) — git commit shorthand
```

### Priority
P1 — Critical (incorrect documentation misleads contributors)
```

---

### Issue 3 — P2-Grave: `.local/bin` not in `.gitignore`

**Title:** `fix(.gitignore): add .local/bin to prevent accidental commit of generated wrappers`

**Body:**
```
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`scripts/debian/wrappers.sh` creates wrapper scripts at `$HOME/.local/bin/`, but `.local/bin/` is **not** in `.gitignore`. Generated wrappers could be accidentally committed to the repo.

### Affected File
`.gitignore`

### Expected Behavior
`.local/bin/` should be in `.gitignore` to prevent committing generated wrapper scripts.

### Proposed Fix
Add to `.gitignore`:
```
.local/bin/
```

### Priority
P2 — Grave (risk of committing generated artifacts)
```

---

### Issue 4 — P3-Moderate: Docs reference non-existent `scripts/setup-symlinks.sh`

**Title:** `fix(docs): update phantom script references — setup-symlinks.sh → scripts/core/symlinks.sh`

**Body:**
```
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`docs/workflows.md` and `docs/recovery.md` reference:
```
~/dotfiles/scripts/setup-symlinks.sh
```

This script **does not exist**. The actual path is:
```
scripts/core/symlinks.sh
```

### Affected Files
- `docs/workflows.md` (line ~297)
- `docs/recovery.md` (lines ~152, ~372)

### Expected Behavior
Documentation should reference the correct script path.

### Proposed Fix
Update all references from `~/dotfiles/scripts/setup-symlinks.sh` to `~/dotfiles/scripts/core/symlinks.sh`.

### Priority
P3 — Moderate (broken documentation links)
```

---

### Issue 5 — P3-Moderate: Docs reference non-existent `scripts/install-plugins.sh`

**Title:** `fix(docs): remove references to scripts/install-plugins.sh — script does not exist`

**Body:**
```
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`docs/workflows.md` and `docs/recovery.md` reference:
```
~/dotfiles/scripts/install-plugins.sh
```

This script **does not exist anywhere** in the repository. The correct scripts are:
- `scripts/nvim/plugins.sh` — Neovim plugin installation
- `scripts/nvim/` — Neovim plugin directory

### Affected Files
- `docs/workflows.md` (line ~304)
- `docs/recovery.md` (lines ~207)

### Expected Behavior
Documentation should reference only existing scripts, or this reference should be removed.

### Proposed Fix
Remove or correct the `install-plugins.sh` references in both docs. If the intent was to reference Neovim plugin installation, point to `scripts/nvim/plugins.sh`.

### Priority
P3 — Moderate (broken documentation links)
```

---

### Issue 6 — P3-Moderate: Docs reference non-existent `scripts/bootstrap-packages.sh`

**Title:** `fix(docs): update bootstrap-packages.sh → scripts/core/packages.sh in workflows.md`

**Body:**
```
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`docs/workflows.md` references:
```
~/dotfiles/scripts/bootstrap-packages.sh
```

This script **does not exist**. The actual path is:
```
scripts/core/packages.sh
```

### Affected File
`docs/workflows.md` (line ~311)

### Expected Behavior
Documentation should reference the correct script path.

### Proposed Fix
Update the reference from `~/dotfiles/scripts/bootstrap-packages.sh` to `~/dotfiles/scripts/core/packages.sh`.

### Priority
P3 — Moderate (broken documentation link)
```

---

### Issue 7 — P4-Moderate: `scripts/debian/doctor.sh` is empty (0 bytes)

**Title:** `fix(scripts/debian): implement or remove empty doctor.sh script`

**Body:**
```
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`scripts/debian/doctor.sh` is **0 bytes** — an empty file with no implementation.

### Affected File
`scripts/debian/doctor.sh`

### Expected Behavior
Either implement the script or remove it. An empty placeholder file is misleading.

### Proposed Fix
**Option A:** Implement the script with actual health-check logic (e.g., check for required binaries, verify environment).
**Option B:** Remove the empty file.

### Priority
P4 — Moderate (dead code / misleading empty file)
```

---

### Issue 8 — P4-Moderate: `scripts/debian/runtime.sh` is empty (0 bytes)

**Title:** `fix(scripts/debian): implement or remove empty runtime.sh script`

**Body:**
```
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`scripts/debian/runtime.sh` is **0 bytes** — an empty file with no implementation.

### Affected File
`scripts/debian/runtime.sh`

### Expected Behavior
Either implement the script or remove it. An empty placeholder file is misleading.

### Proposed Fix
**Option A:** Implement the script with actual runtime setup logic.
**Option B:** Remove the empty file.

### Priority
P4 — Moderate (dead code / misleading empty file)
```

---

### Issue 9 — P5-Low: `docs/debian-runtime.md` is empty (0 bytes)

**Title:** `fix(docs): fill or delete empty docs/debian-runtime.md`

**Body:**
```
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`docs/debian-runtime.md` is **0 bytes** — an empty file with no content.

### Affected File
`docs/debian-runtime.md`

### Expected Behavior
Either fill with relevant content (Debian runtime configuration notes, environment setup, etc.) or delete if not needed.

### Proposed Fix
**Option A:** Document Debian runtime configuration, required packages, or environment setup.
**Option B:** Delete the empty file.

### Priority
P5 — Low (empty documentation file)
```

---

### Issue 10 — P5-Low: `docs/neovim.md` is empty (0 bytes)

**Title:** `fix(docs): fill or delete empty docs/neovim.md`

**Body:**
```
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`docs/neovim.md` is **0 bytes** — an empty file with no content.

### Affected File
`docs/neovim.md`

### Expected Behavior
Either fill with relevant content (Neovim configuration, plugin list, setup instructions) or delete if not needed.

### Proposed Fix
**Option A:** Document Neovim configuration, plugin list, keybindings, or setup.
**Option B:** Delete the empty file.

### Priority
P5 — Low (empty documentation file)
```

---

### Issue 11 — P5-Low: Orphaned legacy script `scripts/debian/legacy/setup-debian-devops.sh`

**Title:** `chore(scripts/debian/legacy): archive or remove orphaned setup-debian-devops.sh (249 lines)`

**Body:**
```
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`scripts/debian/legacy/setup-debian-devops.sh` (249 lines) is **orphaned legacy code** — it exists in `scripts/debian/legacy/` but is not called from `scripts/install.sh` or any other flow. The `scripts/debian/` directory has `install.sh`, `bootstrap/`, `wrappers.sh`, `doctor.sh` (empty), and `runtime.sh` (empty), but no reference to this legacy script.

### Affected File
`scripts/debian/legacy/setup-debian-devops.sh`

### Expected Behavior
Legacy scripts that are not part of any active workflow should be archived or removed to avoid confusion.

### Proposed Fix
**Option A:** Archive to `scripts/archive/` with a note about when/why it was archived.
**Option B:** Remove entirely if confirmed unused.

### Priority
P5 — Low (orphaned legacy code, no active usage)
```

---

### Issue 12 — P5-Low: `scripts/core/update.sh` exists but is never called

**Title:** `fix(scripts/core): integrate update.sh into install flow or document its purpose`

**Body:**
```
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Bug Description
`scripts/core/update.sh` (35 lines) exists but is **not called from `scripts/install.sh`** or any other script. It is dead code unless manually invoked.

### Affected File
`scripts/core/update.sh`

### Expected Behavior
Either integrate `update.sh` into the installation/update flow, document how to use it, or remove it.

### Proposed Fix
**Option A:** Add `bash "$BASE_DIR/core/update.sh"` to `scripts/install.sh` as a final step.
**Option B:** Add documentation in `docs/` explaining when/how to run `update.sh` manually.
**Option C:** Remove if not needed.

### Priority
P5 — Low (uncalled script, potential dead code)
```

---

### Issue 13 — P5-Low: `gc` documentation in docs/aliases.md duplicate of Issue 2

**Title:** `docs(cleanup): remove duplicate gc documentation entry from docs/aliases.md`

**Body:**
```
### Pre-flight Checks
- [x] I have searched existing issues and this is not a duplicate
- [x] I understand this issue needs status:approved before a PR can be opened

### Note
This is a follow-up to Issue #2. After fixing the `gc` function vs alias discrepancy in `docs/aliases.md`, perform a general cleanup pass:
- Remove any duplicate `gc` entries
- Ensure consistent formatting with other function entries
- Align with the corrected documentation approach

### Affected File
`docs/aliases.md`

### Expected Behavior
After Issue #2 is fixed, `gc` should appear exactly once with accurate type annotation (function, not alias).

### Priority
P5 — Low (documentation cleanup, depends on Issue #2)
```

---

## 6. Proposed PR Chain

### PR1 — Docs: Fix phantom script references + gc function documentation

| Field | Value |
|-------|-------|
| **Branch** | `pr/fix-docs-phantom-scripts` |
| **Scope** | Documentation only |
| **Files** | `docs/workflows.md`, `docs/recovery.md`, `docs/aliases.md` |
| **Est. Lines** | ~20 lines |
| **Issues Closed** | #2, #4, #5, #6, #13 |
| **Notes** | Low cognitive load — all text edits. Issue #13 is minor cleanup after #2. |

---

### PR2 — Code: Fix misleading echo + empty files + gitignore

| Field | Value |
|-------|-------|
| **Branch** | `pr/fix-code-misleading-echo-gitignore` |
| **Scope** | Code fixes, gitignore |
| **Files** | `scripts/nvim/plugins.sh`, `.gitignore`, `scripts/debian/doctor.sh`, `scripts/debian/runtime.sh` |
| **Est. Lines** | ~65 lines |
| **Issues Closed** | #1, #3, #7, #8 |
| **Notes** | `doctor.sh` and `runtime.sh` decision (implement vs remove) should be made before this PR. Estimated lines include option to remove them (~4 lines) or implement minimal stubs (~20 lines). |

---

### PR3 — Docs: Fill or delete empty doc files

| Field | Value |
|-------|-------|
| **Branch** | `pr/fix-docs-empty-files` |
| **Scope** | Documentation content or deletion |
| **Files** | `docs/debian-runtime.md`, `docs/neovim.md`, `docs/aliases.md` |
| **Est. Lines** | ~110 lines |
| **Issues Closed** | #9, #10 (alias cleanup from #13 absorbed here) |
| **Notes** | Requires author input on what content to write. Fallback: delete both files. |

---

### PR4 — Legacy: Remove orphan script + integrate uncalled update.sh

| Field | Value |
|-------|-------|
| **Branch** | `pr/cleanup-legacy-uncalled-scripts` |
| **Scope** | Legacy code removal + integration |
| **Files** | `scripts/debian/legacy/setup-debian-devops.sh`, `scripts/core/update.sh`, `scripts/install.sh` |
| **Est. Lines** | ~255 lines |
| **Issues Closed** | #11, #12 |
| **Notes** | Largest PR due to legacy script removal (249 lines). `update.sh` integration adds ~6 lines to `install.sh`. If `setup-debian-devops.sh` is archived rather than deleted, line count increases slightly. |

---

### PR Chain Summary

| Order | PR | Issues | Est. Total |
|-------|----|--------|-----------|
| 1 | `pr/fix-docs-phantom-scripts` | #2,#4,#5,#6,#13 | ~20 lines |
| 2 | `pr/fix-code-misleading-echo-gitignore` | #1,#3,#7,#8 | ~65 lines |
| 3 | `pr/fix-docs-empty-files` | #9,#10 | ~110 lines |
| 4 | `pr/cleanup-legacy-uncalled-scripts` | #11,#12 | ~255 lines |
| **Total** | | **13 issues** | **~450 lines across 10 files** |

## 7. Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| **PR4 line count** | `setup-debian-devops.sh` has 249 lines — even deleted, git still tracks it; reviewers must confirm removal intent | Add clear commit message and PR description explaining it's dead code |
| **Empty files decision** | Issues #7, #8, #9, #10 require decision (implement vs remove) | Maintainer decides before PR2/PR3 — proposal should be clear both options are valid |
| **update.sh integration** | Adding `update.sh` to `install.sh` changes installation behavior | Confirm user wants auto-update on install; alternative: document-only |
| **.local/bin/ in gitignore** | `.local/bin/` is already in gitignore under `.ai/` subtree — verify no conflicts | Already checked: `.local/bin/` is NOT in root `.gitignore` — adding it is safe |
| **gc issue dependency** | Issue #13 depends on Issue #2 | PR1 addresses both, so dependency is within the same PR |

## 8. Size Estimate

| Metric | Value |
|--------|-------|
| **Total issues** | 13 |
| **PR count** | 4 |
| **Files affected** | 10 files |
| **Estimated total lines** | ~450 lines |
| **Largest single change** | `setup-debian-devops.sh` removal (249 lines in PR4) |
| **Smallest single change** | `scripts/nvim/plugins.sh` echo fix (1 line) |
| **Priority breakdown** | P1: 2, P2: 1, P3: 3, P4: 2, P5: 5 |

---

## Appendix: Verification Notes

### Files confirmed empty (0 bytes)
- `scripts/debian/doctor.sh`
- `scripts/debian/runtime.sh`
- `docs/debian-runtime.md`
- `docs/neovim.md`

### Files confirmed not in gitignore
- `.local/bin/`

### Scripts confirmed called from install.sh
- `scripts/core/packages.sh`
- `scripts/core/symlinks.sh`
- `scripts/nvim/plugins.sh`
- `scripts/tmux/tmux_plugins.sh`

### Scripts NOT called from install.sh
- `scripts/core/update.sh` (35 lines, orphaned)
- `scripts/debian/legacy/setup-debian-devops.sh` (249 lines, orphaned)