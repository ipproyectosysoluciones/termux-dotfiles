# SDD Delta Spec: crear-issues-github

## Purpose

Describe the 13 GitHub issues to create and the 4-PR chained review plan for the termux-dotfiles project audit findings.

---

## Issue Specifications

All 13 issues SHALL be created with `status:needs-review` label and assigned to the authenticated user.

### P1 — Critical (2 issues)

| # | Title | Labels | File(s) | Description |
|---|-------|--------|---------|-------------|
| 1 | `fix(scripts/nvim): correct echo header — installs ZSH plugins, not "ZSH" in filename` | `bug`, `priority:high` | `scripts/nvim/plugins.sh` (line 4) | Change `echo "Installing ZSH plugins..."` → `echo "Installing ZSH shell plugins..."` |
| 2 | `fix(docs): update gc entry in docs/aliases.md — it's a ZSH function, not an alias` | `bug`, `priority:high` | `docs/aliases.md` (~line 150) | Update `gc` entry to indicate it's a function in `zsh/functions.zsh`, not an alias |

### P2 — Grave (1 issue)

| # | Title | Labels | File(s) | Description |
|---|-------|--------|---------|-------------|
| 3 | `fix(.gitignore): add .local/bin to prevent accidental commit of generated wrappers` | `bug`, `priority:high` | `.gitignore` | Add `.local/bin/` to gitignore — wrappers created by `scripts/debian/wrappers.sh` must not be committed |

### P3 — Moderate (3 issues)

| # | Title | Labels | File(s) | Description |
|---|-------|--------|---------|-------------|
| 4 | `fix(docs): update phantom script references — setup-symlinks.sh → scripts/core/symlinks.sh` | `documentation`, `priority:medium` | `docs/workflows.md`, `docs/recovery.md` | Replace all `~/dotfiles/scripts/setup-symlinks.sh` with `~/dotfiles/scripts/core/symlinks.sh` |
| 5 | `fix(docs): remove references to scripts/install-plugins.sh — script does not exist` | `documentation`, `priority:medium` | `docs/workflows.md`, `docs/recovery.md` | Remove phantom `install-plugins.sh` references; point to `scripts/nvim/plugins.sh` if Neovim intent |
| 6 | `fix(docs): update bootstrap-packages.sh → scripts/core/packages.sh in workflows.md` | `documentation`, `priority:medium` | `docs/workflows.md` (~line 311) | Replace `~/dotfiles/scripts/bootstrap-packages.sh` with `~/dotfiles/scripts/core/packages.sh` |

### P4 — Moderate (2 issues)

| # | Title | Labels | File(s) | Description |
|---|-------|--------|---------|-------------|
| 7 | `fix(scripts/debian): implement or remove empty doctor.sh script` | `bug`, `priority:medium` | `scripts/debian/doctor.sh` | 0-byte file — decide: implement health-check logic or remove |
| 8 | `fix(scripts/debian): implement or remove empty runtime.sh script` | `bug`, `priority:medium` | `scripts/debian/runtime.sh` | 0-byte file — decide: implement runtime setup or remove |

### P5 — Low (5 issues)

| # | Title | Labels | File(s) | Description |
|---|-------|--------|---------|-------------|
| 9 | `fix(docs): fill or delete empty docs/debian-runtime.md` | `documentation`, `priority:low` | `docs/debian-runtime.md` | 0-byte file — fill with Debian runtime content or delete |
| 10 | `fix(docs): fill or delete empty docs/neovim.md` | `documentation`, `priority:low` | `docs/neovim.md` | 0-byte file — fill with Neovim config content or delete |
| 11 | `chore(scripts/debian/legacy): archive or remove orphaned setup-debian-devops.sh (249 lines)` | `cleanup`, `priority:low` | `scripts/debian/legacy/setup-debian-devops.sh` | Orphaned legacy script not called from any flow — archive to `scripts/archive/` or remove |
| 12 | `fix(scripts/core): integrate update.sh into install flow or document its purpose` | `bug`, `priority:low` | `scripts/core/update.sh`, `scripts/install.sh` | `update.sh` (35 lines) never called — add to install.sh as final step, or document manual usage, or remove |
| 13 | `docs(cleanup): remove duplicate gc documentation entry from docs/aliases.md` | `documentation`, `priority:low` | `docs/aliases.md` | Post-Issue #2 cleanup: deduplicate `gc` entries, consistent formatting, correct function annotation |

---

## PR Chain Specification

All PRs follow the 400-line budget. PRs form a linear chain: each targets the previous PR's branch.

### PR1 — `pr/fix-docs-phantom-scripts`

| Field | Value |
|-------|-------|
| Branch | `pr/fix-docs-phantom-scripts` (from `main`) |
| Closes | Issues #2, #4, #5, #6, #13 |
| Scope | Documentation text edits only |
| Files | `docs/aliases.md`, `docs/workflows.md`, `docs/recovery.md` |
| Est. Lines | ~20 |
| Boundary | **Includes**: alias correction, phantom script path corrections, duplicate cleanup. **Excludes**: code changes, gitignore, empty file decisions. |
| Acceptance | All phantom script references point to existing paths; `gc` marked as function; no duplicate `gc` entry |

### PR2 — `pr/fix-code-misleading-echo-gitignore`

| Field | Value |
|-------|-------|
| Branch | `pr/fix-code-misleading-echo-gitignore` (from `pr/fix-docs-phantom-scripts`) |
| Closes | Issues #1, #3, #7, #8 |
| Scope | Code fixes and gitignore |
| Files | `scripts/nvim/plugins.sh`, `.gitignore`, `scripts/debian/doctor.sh`, `scripts/debian/runtime.sh` |
| Est. Lines | ~65 |
| Boundary | **Includes**: echo header fix, `.local/bin/` gitignore entry, decision on `doctor.sh` and `runtime.sh` (remove or stub). **Excludes**: empty doc files (#9, #10), legacy script removal (#11, #12). |
| Acceptance | Echo text clearly says "ZSH shell plugins"; `.local/bin/` in gitignore; empty debian scripts resolved |

### PR3 — `pr/fix-docs-empty-files`

| Field | Value |
|-------|-------|
| Branch | `pr/fix-docs-empty-files` (from `pr/fix-code-misleading-echo-gitignore`) |
| Closes | Issues #9, #10 |
| Scope | Documentation content or deletion |
| Files | `docs/debian-runtime.md`, `docs/neovim.md`, `docs/aliases.md` |
| Est. Lines | ~110 |
| Boundary | **Includes**: fill or delete `debian-runtime.md` and `neovim.md`. **Excludes**: legacy script decisions (#11, #12). |
| Acceptance | Both doc files either have meaningful content OR are deleted; no 0-byte documentation files remain |

### PR4 — `pr/cleanup-legacy-uncalled-scripts`

| Field | Value |
|-------|-------|
| Branch | `pr/cleanup-legacy-uncalled-scripts` (from `pr/fix-docs-empty-files`) |
| Closes | Issues #11, #12 |
| Scope | Legacy code removal + integration |
| Files | `scripts/debian/legacy/setup-debian-devops.sh`, `scripts/core/update.sh`, `scripts/install.sh` |
| Est. Lines | ~255 |
| Boundary | **Includes**: remove/archive orphaned setup-debian-devops.sh; integrate or remove update.sh. **Excludes**: No other changes. |
| Acceptance | Orphaned legacy script archived or removed; `update.sh` either integrated into install.sh or explicitly documented as manual-only |

### Chain Summary

| Order | Branch | Issues | Est. Lines |
|-------|--------|--------|------------|
| 1 | `pr/fix-docs-phantom-scripts` | #2,#4,#5,#6,#13 | ~20 |
| 2 | `pr/fix-code-misleading-echo-gitignore` | #1,#3,#7,#8 | ~65 |
| 3 | `pr/fix-docs-empty-files` | #9,#10 | ~110 |
| 4 | `pr/cleanup-legacy-uncalled-scripts` | #11,#12 | ~255 |
| **Total** | | **13 issues** | **~450 lines** |

---

## Verification Criteria

For each created issue, verify:

1. **Existence**: `gh issue list --search "crear-issues-github"` returns 13 open issues
2. **Title format**: All titles follow `type(scope): description` conventional commit format
3. **Labels**: Each issue has at minimum `status:needs-review` and a type label (`bug`, `documentation`, `cleanup`)
4. **Priority labels**: P1 → `priority:high`, P3/P4 → `priority:medium`, P5 → `priority:low`
5. **Assignee**: Each issue shows the authenticated user as assignee
6. **Body completeness**: Each issue body contains Description, Affected File(s), Expected Behavior, Proposed Fix, Priority
7. **PR chain mapping**: Each issue is referenced by exactly one PR in the chain

Post-creation verification command:
```bash
gh issue list --search "repo:ipproyectosysoluciones/termux-dotfiles creator:@me state:open" --json number,title,labels,assignees --jq '.[] | {num: .number, title: .title, labels: [.labels[].name], assignee: [.assignees[].login]}'
```
Expected: 13 issues, each with `status:needs-review` label and correct priority label.