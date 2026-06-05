# Tasks: v1.1 Termux Packaging

**Change**: v1.1 Termux Packaging
**Project**: termux-dotfiles
**Created**: 2026-06-05
**Issues**: #73–#82

---

## Overview

| # | Task | Issue | Priority | Est. Lines | Deliverable |
|---|------|-------|----------|------------|-------------|
| T1 | Create Termux package structure (debbuild/) | #73 | Must | ~120 | `debbuild/` directory with DEBIAN/ scripts and data/ payload |
| T2 | Create CI packaging workflow (package.yml) | #74 | Must | ~60 | `.github/workflows/package.yml` |
| T3 | Fix docs/installation.md URL | #75 | Must | ~1 | `docs/installation.md` line 88 |
| T4 | Fix code scanning alerts | #76 | Must | ~4 | `test.yml`, `shellcheck.yml` |
| T5 | Create SECURITY.md | #77 | Must | ~15 | `SECURITY.md` |
| T6 | Create .github/FUNDING.yml | #78 | Must | ~8 | `.github/FUNDING.yml` |
| T7 | Update README.md | #79 | Must | ~20 | `README.md` |
| T8 | Version bump to 1.1.0-dev | #80 | Should | ~25 | `VERSION`, `CHANGELOG.md` |
| T9 | CHANGELOG placeholder | #81 | Should | ~15 | `CHANGELOG.md` [v1.1] section |
| T10 | Enhanced update.sh | #82 | Should | ~30 | `scripts/core/update.sh` |

---

## Task Details

### T1: Create Termux package structure (debbuild/)
**Issue**: #73 | **Effort**: ~120 lines | **Phase**: 4 (core)

**Description**: Create the `debbuild/` directory structure for the Termux-native `.deb` package.

**Files to create**:
- `debbuild/DEBIAN/control` — Package metadata
- `debbuild/DEBIAN/postinst` — Post-install symlink creation
- `debbuild/DEBIAN/prerm` — Pre-removal symlink cleanup
- `debbuild/data/data/com.termux/files/usr/bin/ai` — Trampoline
- `debbuild/data/data/com.termux/files/usr/bin/aip` — Trampoline
- `debbuild/data/data/com.termux/files/usr/etc/profile.d/termux-dotfiles.sh` — Shell integration
- `debbuild/data/data/com.termux/files/usr/share/termux-dotfiles/` — Dotfiles payload

**Verification**: `tests/unit/package_structure.bats`

---

### T2: Create CI packaging workflow (package.yml)
**Issue**: #74 | **Effort**: ~60 lines | **Phase**: 4 (core)

**Description**: Create GitHub Actions workflow to build `.deb` on tag push and upload as release asset.

**File to create**: `.github/workflows/package.yml`

**Trigger**: `v*` tag push

**Verification**: `tests/e2e/package_ci.bats`

---

### T3: Fix docs/installation.md URL
**Issue**: #75 | **Effort**: ~1 line | **Phase**: 1 (docs)

**Description**: Fix line 88 of `docs/installation.md` from `bladimir/Termux-AI-Astaroth` to `ipproyectosysoluciones/termux-dotfiles`.

**Verification**: `tests/unit/docs.bats`

---

### T4: Fix code scanning alerts
**Issue**: #76 | **Effort**: ~4 lines | **Phase**: 2 (quick fixes)

**Description**: Add `permissions: read` at top level to `test.yml` and `shellcheck.yml`.

**Files to modify**:
- `.github/workflows/test.yml`
- `.github/workflows/shellcheck.yml`

**Verification**: `tests/unit/permissions.bats`

---

### T5: Create SECURITY.md
**Issue**: #77 | **Effort**: ~15 lines | **Phase**: 1 (docs)

**Description**: Create vulnerability disclosure policy.

**File to create**: `SECURITY.md`

**Verification**: `tests/unit/security_md.bats`

---

### T6: Create .github/FUNDING.yml
**Issue**: #78 | **Effort**: ~8 lines | **Phase**: 1 (docs)

**Description**: Create GitHub Sponsors funding configuration.

**File to create**: `.github/FUNDING.yml`

**Verification**: `tests/unit/funding_yml.bats`

---

### T7: Update README.md
**Issue**: #79 | **Effort**: ~20 lines | **Phase**: 1 (docs)

**Description**: Add Termux package installation section, uninstall section, update VERSION badge to `v1.1.0-dev`.

**File to modify**: `README.md`

**Verification**: `tests/e2e/readme_package_section.bats`

---

### T8: Version bump to 1.1.0-dev
**Issue**: #80 | **Effort**: ~25 lines | **Phase**: 3 (metadata)

**Description**: Update VERSION to `1.1.0-dev` and add `[v1.1]` section to CHANGELOG.md.

**Files to modify**:
- `VERSION`
- `CHANGELOG.md`

**Verification**: `bats --recursive tests/`

---

### T9: CHANGELOG placeholder
**Issue**: #81 | **Effort**: ~15 lines | **Phase**: 3 (metadata)

**Description**: Add `[v1.1]` unreleased section above `[v1.0.0]` in keepachangelog format.

**Note**: Already covered by T8.

**Verification**: CHANGELOG structure validation

---

### T10: Enhanced update.sh
**Issue**: #82 | **Effort**: ~30 lines | **Phase**: 4 (core)

**Description**: Add `detect_install_type()` and `get_local_version()` functions to support Termux package vs git clone detection.

**File to modify**: `scripts/core/update.sh`

**Verification**: `bats tests/` + new unit tests

---

## Review Workload Forecast

### Total Changed Lines Estimate

| Component | Est. Lines |
|-----------|------------|
| debbuild/ directory structure | ~120 |
| package.yml workflow | ~60 |
| docs/installation.md fix | ~1 |
| test.yml + shellcheck.yml permissions | ~4 |
| SECURITY.md | ~15 |
| FUNDING.yml | ~8 |
| README.md updates | ~20 |
| VERSION + CHANGELOG | ~25 |
| update.sh enhancements | ~30 |
| **Total** | **~283 lines** |

### Delivery Recommendation

**Total estimated: ~283 lines** — Within 400-line single PR budget.

**Delivery strategy**: Single PR (ask-always per SDD contract)

**Implementation order** (from design.md Section 9):
1. Phase 1 (docs-only, parallelizable): T3, T5, T6, T7
2. Phase 2 (quick fixes): T4
3. Phase 3 (metadata): T8, T9
4. Phase 4 (core deliverable, TDD order): T1, T2, T10

### Delivery Slices

| Slice | Tasks | Est. Lines | Notes |
|-------|-------|------------|-------|
| 1 | T3, T5, T6, T7 | ~44 | Docs-only, parallelizable |
| 2 | T4 | ~4 | Quick fix |
| 3 | T8, T9 | ~40 | Metadata |
| 4 | T1, T2, T10 | ~195 | Core deliverable, TDD |

**Recommended**: Ship as single PR since total is under 400 lines.

---

## Project Board

| Issue | Task | Project Status |
|-------|------|----------------|
| #73 | T1: Create Termux package structure | Done |
| #74 | T2: Create CI packaging workflow | Done |
| #75 | T3: Fix docs/installation.md URL | Done |
| #76 | T4: Fix code scanning alerts | Done |
| #77 | T5: Create SECURITY.md | Done |
| #78 | T6: Create .github/FUNDING.yml | Done |
| #79 | T7: Update README.md | Done |
| #80 | T8: Version bump to 1.1.0-dev | Done |
| #81 | T9: CHANGELOG placeholder | Done |
| #82 | T10: Enhanced update.sh | Done |

---

## Verification Checklist

After implementation, all of the following must pass:

- [x] `debbuild/DEBIAN/control` exists with all required fields
- [x] `debbuild/DEBIAN/postinst` creates idempotent symlinks
- [x] `debbuild/DEBIAN/prerm` removes symlinks with restore
- [x] `ai` and `aip` trampolines are executable
- [x] `profile.d/termux-dotfiles.sh` sets DOTFILES_DIR and PATH
- [x] `.github/workflows/package.yml` exists and triggers on `v*`
- [x] `docs/installation.md` line 88 has correct URL
- [x] `test.yml` has `permissions: read` at top level
- [x] `shellcheck.yml` has `permissions: read` at top level
- [x] Code scanning alerts resolved
- [x] `SECURITY.md` exists with contact email
- [x] `.github/FUNDING.yml` exists with sponsor link
- [x] `README.md` has Termux package install section
- [x] `README.md` VERSION badge shows `v1.1.0-dev`
- [x] `VERSION` shows `1.1.0-dev`
- [x] `CHANGELOG.md` has `[v1.1]` unreleased section
- [x] `scripts/core/update.sh` detects install type
- [x] All `bats tests/` pass

---

**Reference artifacts**:
- Explore: `openspec/changes/v1.1-Termux-packaging/explore.md`
- Proposal: `openspec/changes/v1.1-Termux-packaging/proposal.md`
- Spec: `openspec/changes/v1.1-Termux-packaging/spec.md`
- Design: `openspec/changes/v1.1-Termux-packaging/design.md`