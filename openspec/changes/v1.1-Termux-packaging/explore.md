# Exploration: v1.1 Termux Packaging

## 1. Current Installation

| Method | Command |
|--------|---------|
| One-liner | `curl -fsSL https://raw.githubusercontent.com/ipproyectosysoluciones/termux-dotfiles/main/scripts/install.sh \| bash` |
| Makefile | `make install` |
| Manual | `git clone` + `bash scripts/install.sh` |

`scripts/install.sh` (114 lines, shebang `#!/data/data/com.termux/files/usr/bin/bash`) does:
1. Git clone into `$HOME/dotfiles`
2. `scripts/core/packages.sh` — 17 Termux packages
3. `scripts/core/symlinks.sh` — zsh, tmux, termux, nvim symlinks
4. `scripts/nvim/plugins.sh` — nvim plugins
5. `scripts/tmux/tmux_plugins.sh` — tmux plugins
6. `scripts/core/update.sh` — version check

## 2. What a Termux Package Requires

Termux `.deb` packages use `termux-create-package`:
- `data/data/com.termux/files/usr/bin/` — executables
- `data/data/com.termux/files/usr/etc/profile.d/` — shell integration
- `metadata/` — name, version, depends, maintainer, section, homepage
- `scripts/` — install, postinst, prerm

**Key differences from current install.sh:**
- No git clone — package ships files directly
- Installs to `$PREFIX` not `$HOME/dotfiles`
- Uses `$PREFIX/bin` for executables
- `pkg` repository distribution instead of GitHub raw URL

## 3. Security & Quality

### GitHub Alerts

| Type | Count | Status |
|------|-------|--------|
| Dependabot | 0 | ✅ Clean |
| Code Scanning | **2** | ⚠️ Open (medium) |
| Secret Scanning | 0 | ✅ Clean |
| Security Advisories | 0 | ✅ Clean |

### Code Scanning Alerts (2 open)

| # | Rule | File | Line |
|---|------|------|------|
| 2 | `actions/missing-workflow-permissions` | `.github/workflows/test.yml` | 13 |
| 1 | `actions/missing-workflow-permissions` | `.github/workflows/shellcheck.yml` | 13 |

**Fix:** Add `permissions: read` at the top level of both files. `release.yml` already has `permissions: contents: write`.

### ShellCheck (from CI — not installed locally)

Previous report (`shellcheck-report.txt`):
- 1 Error: SC2148 (missing shebang on some file)
- 6 Warnings: SC1090 (non-constant source paths)
- 10 Info: SC1091 (not following included files)

**Note:** `scripts/utils/logger.sh` DOES have `#!/usr/bin/env bash` — the SC2148 may be on another file or a stale report.

### Tests

`bats --recursive tests/`: **270 passed, 0 failed** ✅

## 4. Documentation Gaps

| File | Status | Detail |
|------|--------|--------|
| `SECURITY.md` | ❌ Missing | No vulnerability reporting process |
| `FUNDING.yml` | ❌ Missing | No sponsor links |
| `docs/installation.md` | ⚠️ Wrong URL | Line 88: `bladimir/Termux-AI-Astaroth` → should be `ipproyectosysoluciones/termux-dotfiles` |
| `README.md` | ⚠️ Missing packaging | No Termux package installation method |
| `.github/FUNDING.yml` | ❌ Missing | No `.github/` FUNDING.yml |

## 5. Version Management

- `VERSION`: single source of truth (1.0.0)
- `scripts/release.sh`: reads VERSION, updates CHANGELOG, commits, tags
- `.github/workflows/release.yml`: creates GitHub Release on v* tag push
- No Termux package build step in CI

## 6. Repository Health

- Branch protection on `main` and `dev`: enforce_admins, 1 review, 2 status checks, linear history
- Both branches at same commit (`b1286ce`)
- 3 branches total
- Public, MIT licensed
- Community Standards: CODE_OF_CONDUCT.md, CONTRIBUTING.md, LICENSE, README — missing SECURITY.md, FUNDING.yml

## Key Findings

### Must Fix (SDD scope)
1. **Termux package structure** — `debbuild/` directory with `termux-create-package` metadata
2. **CI packaging workflow** — Build .deb on tag push, attach to GitHub Release
3. **docs/installation.md URL** — Fix `bladimir/Termux-AI-Astaroth` → `ipproyectosysoluciones/termux-dotfiles`
4. **Code scanning alerts** — Add `permissions: read` to `test.yml` and `shellcheck.yml`
5. **SECURITY.md** — Create vulnerability reporting policy
6. **FUNDING.yml** — Create sponsor funding file
7. **README update** — Add Termux package installation section, uninstall docs

### Should Fix (stretch)
8. **Version sync** — Update `VERSION` to 1.1.0-dev for pre-release cycle
9. **Update `scripts/core/update.sh`** — Support Termux package version check
10. **CHANGELOG.md** — Add [v1.1] placeholder section

## Risks
- Termux `termux-create-package` may have specific constraints for dotfiles projects
- Package install path (`$PREFIX` vs `$HOME/dotfiles`) requires different symlink strategy
- Version drift between GitHub Release and Termux package if not automated in CI
