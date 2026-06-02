# SDD Design: crear-issues-github

## Context

This design covers the GitHub issue creation workflow and PR chain architecture for the `crear-issues-github` change in the `termux-dotfiles` project.

**Workspace:** `/media/bladimir/Datos1/Datos/proyectos/work/Termux-AI-Astaroth`
**Project:** `termux-dotfiles`
**GitHub:** `https://github.com/ipproyectosysoluciones/termux-dotfiles`
**Working branch:** `dev`
**Default branch:** `main`

---

## 1. GitHub Workflow Design

### 1.1 Issue Creation via `gh issue create`

All 13 issues will be created using the GitHub CLI. The workflow follows the issue-creation skill rules:

- **Blank issues are disabled** — MUST use a template (bug report or feature request)
- **Every issue gets `status:needs-review`** automatically
- **Maintainer must add `status:approved`** before PRs can be opened

### 1.2 Issue Template Selection

| Priority | Issue Type | Template | Auto-labels |
|----------|-----------|----------|-------------|
| P1-Critical, P2-Grave, P3-Moderate | Bug fix | `bug_report.yml` | `bug`, `status:needs-review` |
| P4-Moderate, P5-Low | Enhancement/cleanup | `feature_request.yml` | `enhancement`, `status:needs-review` |

**Note:** The project may not have `.github/ISSUE_TEMPLATE/` directories. If templates don't exist, fall back to `--body` with manual formatting that matches the template structure.

### 1.3 Label Scheme

| Label | Usage | Applied By |
|-------|-------|------------|
| `bug` | Code bugs (misleading echo, empty files) | Auto via template |
| `documentation` | Doc fixes (phantom script refs, empty docs) | Auto via template |
| `enhancement` | Improvements and cleanup | Auto via template |
| `cleanup` | Legacy code removal | Manual |
| `status:needs-review` | All new issues | Auto |
| `status:approved` | Ready for PR | Maintainer |
| `priority:high` | P1-Critical | Manual |
| `priority:medium` | P2-Grave, P3-Moderate | Manual |
| `priority:low` | P4-Moderate, P5-Low | Manual |

### 1.4 Assignment

All issues assigned to user with "assign to me" note. Since no GitHub username is available, issues will be created without explicit assignee — the user can self-assign after creation.

```bash
# Issue creation command pattern
gh issue create \
  --title "<title>" \
  --body "<body>" \
  --label "<labels>" \
  --repo ipproyectosysoluciones/termux-dotfiles
```

### 1.5 Issue Creation Order

Issues created in severity order: P1 → P2 → P3 → P4 → P5, with concurrent creation where possible.

| Order | Issue | Title | Labels |
|-------|-------|-------|--------|
| 1 | #1 | `fix(scripts/nvim): correct echo header — installs ZSH plugins` | `bug`, `priority:high` |
| 2 | #2 | `fix(docs): update gc entry — it's a ZSH function, not an alias` | `bug`, `priority:high` |
| 3 | #3 | `fix(.gitignore): add .local/bin` | `bug`, `priority:medium` |
| 4 | #4 | `fix(docs): update phantom script ref — setup-symlinks.sh` | `documentation`, `priority:medium` |
| 5 | #5 | `fix(docs): remove references to scripts/install-plugins.sh` | `documentation`, `priority:medium` |
| 6 | #6 | `fix(docs): update bootstrap-packages.sh → scripts/core/packages.sh` | `documentation`, `priority:medium` |
| 7 | #7 | `fix(scripts/debian): implement or remove empty doctor.sh` | `enhancement`, `priority:low` |
| 8 | #8 | `fix(scripts/debian): implement or remove empty runtime.sh` | `enhancement`, `priority:low` |
| 9 | #9 | `fix(docs): fill or delete empty docs/debian-runtime.md` | `documentation`, `priority:low` |
| 10 | #10 | `fix(docs): fill or delete empty docs/neovim.md` | `documentation`, `priority:low` |
| 11 | #11 | `chore(scripts/debian/legacy): archive or remove orphaned setup-debian-devops.sh` | `enhancement`, `cleanup`, `priority:low` |
| 12 | #12 | `fix(scripts/core): integrate update.sh into install flow` | `enhancement`, `priority:low` |
| 13 | #13 | `docs(cleanup): remove duplicate gc documentation entry` | `documentation`, `priority:low` |

---

## 2. PR Chain Architecture

### 2.1 Strategy: Stacked PRs to Main

Given that each PR addresses self-contained file changes with no overlap, **Stacked PRs to main** is the optimal strategy:

- Each PR can merge independently to `main`
- After each parent PR merges, the next PR is retargeted to `main` for a clean diff
- No feature branch accumulation needed — work is linear and independent
- Simplest rollback: revert any individual PR without chain dependencies

```
main ← PR1: docs/phatom-scripts ← PR2: code/echo-gitignore ← PR3: docs/empty-files ← PR4: legacy/cleanup
```

### 2.2 Branch Naming Convention

Format: `pr/<pr-number>-<short-description>`

| PR | Branch | Short Description |
|----|--------|-------------------|
| PR1 | `pr/01-fix-docs-phantom-scripts` | fix-docs-phantom-scripts |
| PR2 | `pr/02-fix-code-misleading-echo` | fix-code-misleading-echo |
| PR3 | `pr/03-fix-docs-empty-files` | fix-docs-empty-files |
| PR4 | `pr/04-cleanup-legacy-scripts` | cleanup-legacy-scripts |

### 2.3 Merge Order

| Step | Action | Command |
|------|--------|---------|
| 1 | Merge PR1 to `main` | `gh pr merge 1 --squash --delete-branch` |
| 2 | Retarget PR2 from `pr/01-...` to `main` | `gh pr edit 2 --base main` |
| 3 | Merge PR2 to `main` | `gh pr merge 2 --squash --delete-branch` |
| 4 | Retarget PR3 from `pr/02-...` to `main` | `gh pr edit 3 --base main` |
| 5 | Merge PR3 to `main` | `gh pr merge 3 --squash --delete-branch` |
| 6 | Retarget PR4 from `pr/03-...` to `main` | `gh pr edit 4 --base main` |
| 7 | Merge PR4 to `main` | `gh pr merge 4 --squash --delete-branch` |
| 8 | Merge `dev` to `main` | `gh pr merge dev --squash --delete-branch` |

### 2.4 File Change Independence

All PRs modify **different files** — no merge conflicts expected:

| PR | Files Modified |
|----|----------------|
| PR1 | `docs/workflows.md`, `docs/recovery.md`, `docs/aliases.md` |
| PR2 | `scripts/nvim/plugins.sh`, `.gitignore`, `scripts/debian/doctor.sh`, `scripts/debian/runtime.sh` |
| PR3 | `docs/debian-runtime.md`, `docs/neovim.md`, `docs/aliases.md` |
| PR4 | `scripts/debian/legacy/setup-debian-devops.sh`, `scripts/core/update.sh`, `scripts/install.sh` |

**Parallel-safe:** YES. File changes do not overlap between PRs.

---

## 3. File Change Specifications Per PR

### PR1 — Docs: Fix phantom script references + gc function documentation

**Branch:** `pr/01-fix-docs-phantom-scripts`
**Base:** `dev`
**Issues:** #2, #4, #5, #6, #13
**Est. Lines:** ~20 lines

#### File: `docs/workflows.md`

| Line | Change | Issue |
|------|--------|-------|
| ~297 | `~/dotfiles/scripts/setup-symlinks.sh` → `~/dotfiles/scripts/core/symlinks.sh` | #4 |
| ~304 | `~/dotfiles/scripts/install-plugins.sh` → remove or point to `scripts/nvim/plugins.sh` | #5 |
| ~311 | `~/dotfiles/scripts/bootstrap-packages.sh` → `~/dotfiles/scripts/core/packages.sh` | #6 |

#### File: `docs/recovery.md`

| Line | Change | Issue |
|------|--------|-------|
| ~152 | `bash scripts/setup-symlinks.sh` → `bash scripts/core/symlinks.sh` | #4 |
| ~207 | `bash scripts/install-plugins.sh` → remove or `bash scripts/nvim/plugins.sh` | #5 |
| ~372 | `bash scripts/setup-symlinks.sh` → `bash scripts/core/symlinks.sh` | #4 |

#### File: `docs/aliases.md`

| Line | Change | Issue |
|------|--------|-------|
| ~150 | `gc "commit message"` entry: change from alias notation to function notation | #2 |
| ~349 | Remove duplicate `gc` entry if exists | #13 |

**GC Function Entry Format:**
```
gc "message"     → ZSH function (zsh/functions.zsh) — git commit shorthand
```

---

### PR2 — Code: Fix misleading echo + empty files + gitignore

**Branch:** `pr/02-fix-code-misleading-echo`
**Base:** `pr/01-fix-docs-phantom-scripts` (retarget to `main` after PR1 merges)
**Issues:** #1, #3, #7, #8
**Est. Lines:** ~65 lines

#### File: `scripts/nvim/plugins.sh`

| Line | Change | Issue |
|------|--------|-------|
| 4 | Change `echo "Installing ZSH plugins..."` → `echo "Installing ZSH shell plugins..."` | #1 |

#### File: `.gitignore`

| Change | Issue |
|--------|-------|
| Add `.local/bin/` | #3 |

#### File: `scripts/debian/doctor.sh`

| Change | Issue |
|--------|-------|
| Implement with basic diagnostic OR remove (maintainer decision) | #7 |

#### File: `scripts/debian/runtime.sh`

| Change | Issue |
|--------|-------|
 Implement with basic runtime OR remove (maintainer decision) | #8 |

**Decision Required Before PR2:** Implement or remove `doctor.sh` and `runtime.sh`. Fallback: remove both (minimal change ~4 lines).

---

### PR3 — Docs: Fill or delete empty doc files

**Branch:** `pr/03-fix-docs-empty-files`
**Base:** `pr/02-fix-code-misleading-echo` (retarget to `main` after PR2 merges)
**Issues:** #9, #10
**Est. Lines:** ~110 lines

#### File: `docs/debian-runtime.md`

| Change | Issue |
|--------|-------|
| Fill with Debian runtime documentation OR delete | #9 |

**Option A — Content:** Document Debian runtime configuration, required packages, environment setup.
**Option B — Delete:** Remove empty file.

#### File: `docs/neovim.md`

| Change | Issue |
|--------|-------|
| Fill with Neovim documentation OR delete | #10 |

**Option A — Content:** Document Neovim configuration, plugin list, keybindings, setup.
**Option B — Delete:** Remove empty file.

**Decision Required Before PR3:** Author input on content to write. Fallback: delete both files.

---

### PR4 — Legacy: Remove orphan script + integrate uncalled update.sh

**Branch:** `pr/04-cleanup-legacy-scripts`
**Base:** `pr/03-fix-docs-empty-files` (retarget to `main` after PR3 merges)
**Issues:** #11, #12
**Est. Lines:** ~255 lines

#### File: `scripts/debian/legacy/setup-debian-devops.sh`

| Change | Issue |
|--------|-------|
| Archive to `scripts/archive/setup-debian-devops.sh` OR remove entirely | #11 |

**Option A — Archive:** Move to `scripts/archive/` with a note in commit message.
**Option B — Remove:** Delete the file.

#### File: `scripts/core/update.sh`

| Change | Issue |
|--------|-------|
| Integrate into `scripts/install.sh` OR document standalone purpose | #12 |

**Option A — Integrate:** Add `bash "$BASE_DIR/core/update.sh"` as final step in `install.sh`.
**Option B — Document:** Add documentation in `docs/` explaining manual usage.

#### File: `scripts/install.sh` (if integrating update.sh)

| Change | Issue |
|--------|-------|
| Add ~6 lines to call `core/update.sh` at end of install flow | #12 |

---

## 4. Implementation Order and Dependencies

### 4.1 Execution Order

```
Phase 1: Create Issues (sequential by priority)
  → gh issue create #1 (P1-Critical)
  → gh issue create #2 (P1-Critical)
  → gh issue create #3 (P2-Grave)
  → gh issue create #4-6 (P3-Moderate)
  → gh issue create #7-8 (P4-Moderate)
  → gh issue create #9-13 (P5-Low)

Phase 2: Create PRs (stacked chain)
  → Create PR1 from dev → merge to main → retarget PR2 to main
  → Create PR2 from dev → merge to main → retarget PR3 to main
  → Create PR3 from dev → merge to main → retarget PR4 to main
  → Create PR4 from dev → merge to main → merge dev to main
```

### 4.2 Dependencies

| Item | Dependency | Type |
|------|-----------|------|
| PR2 | None (parallel to PR1, but PR1 should merge first for clean ordering) | Soft |
| PR3 | None (but depends on maintainer decision for empty files) | External |
| PR4 | None (but depends on maintainer decision for legacy/update handling) | External |
| Issue #13 | Depends on Issue #2 being fixed (both in PR1) | Internal |
| update.sh integration | Maintained decision on whether to auto-update on install | External |

### 4.3 Parallel Safety

**YES — All PRs are parallel-safe.** Each PR modifies disjoint file sets:
- PR1: `docs/*.md`
- PR2: `scripts/nvim/plugins.sh`, `.gitignore`, `scripts/debian/{doctor,runtime}.sh`
- PR3: `docs/debian-runtime.md`, `docs/neovim.md`
- PR4: `scripts/debian/legacy/setup-debian-devops.sh`, `scripts/core/update.sh`, `scripts/install.sh`

No merge conflicts between PRs, only sequential ordering for clean git history.

---

## 5. Verification Plan

### 5.1 Issue Creation Verification

```bash
# Verify all 13 issues created
gh issue list --state all --repo ipproyectosysoluciones/termux-dotfiles --limit 20

# Expected: 13 issues with correct labels
```

### 5.2 PR Verification Per Step

```bash
# Verify PR diff is clean (only expected files changed)
gh pr diff <PR_NUMBER> --name-only

# Verify CI passes
gh pr checks <PR_NUMBER> --watch
```

### 5.3 Final Verification

```bash
# After all PRs merged, verify dev == main
git log main..dev --oneline

# Verify all 13 issues are closed
gh issue list --state closed --repo ipproyectosysoluciones/termux-dotfiles --limit 20
```

---

## Appendix: Chain Context Section (for PR descriptions)

Each PR body should include:

```markdown
## Chain Context

| Field | Value |
|-------|-------|
| Chain | crear-issues-github |
| Tracker PR | Not needed (stacked PRs) |
| Position | <N of 4> |
| Base | `<target branch>` |
| Depends on | <PR #N or "None"> |
| Follow-up | <PR #N or "None"> |
| Review budget | <lines changed> / 400 |
| Starts at | <branch, PR, or state this builds on> |
| Ends with | <standalone result delivered by this PR> |

### Chain Overview
```text
main
 └── #<N-1> Previous PR
      └── 📍 #<N> This PR
           └── #<N+1> Next PR
```

### Scope
- Includes: <focused unit>
- Excludes: <deferred work>

### Autonomy
- [ ] CI is expected to pass for this PR branch
- [ ] This PR has one deliverable scope
- [ ] This PR can be rolled back without unrelated changes
- [ ] Tests, docs, or manual verification cover this unit
```
