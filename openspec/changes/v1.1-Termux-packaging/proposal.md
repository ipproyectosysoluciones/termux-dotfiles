# Proposal: v1.1 Termux Packaging

## Intent

Ship a Termux-native `.deb` package alongside the existing curl installer, enabling `pkg install termux-dotfiles` distribution. This unblocks users who prefer package managers over manual git clone + curl piping.

## Approach

### Delivery Strategy
- **Ask-always**: Will check review workload guard before requesting reviews
- **Strict TDD**: bats tests written before implementation
- **Non-breaking**: Existing curl installer remains fully functional (separate install path: `$PREFIX` vs `$HOME/dotfiles`)

### Implementation Order

| Phase | Tasks | Strategy |
|-------|-------|----------|
| 1 | Docs fix (URL, README, SECURITY, FUNDING) | Low risk, independent, can parallelize |
| 2 | Code scanning fixes | Quick permission additions |
| 3 | Version + CHANGELOG | Trivial metadata updates |
| 4 | Package structure + CI workflow | Core deliverable, TDD order |

## Scope

### Must Do (7 tasks)

| # | Task | Files | Detail |
|---|------|-------|--------|
| 1 | Termux package structure | `debbuild/` | `DEBIAN/control`, `DEBIAN/postinst`, `DEBIAN/prerm`, `data/` files |
| 2 | CI packaging workflow | `.github/workflows/package.yml` | Build .deb on tag push, attach to GitHub Release |
| 3 | Fix docs/installation.md URL | `docs/installation.md` | Line 88: `bladimir/Termux-AI-Astaroth` → `ipproyectosysoluciones/termux-dotfiles` |
| 4 | Fix code scanning alerts | `test.yml`, `shellcheck.yml` | Add `permissions: read` at top level |
| 5 | Create SECURITY.md | `SECURITY.md` | Vulnerability reporting policy, contact: `ipproyectossoluciones@gmail.com` |
| 6 | Create FUNDING.yml | `FUNDING.yml` | GitHub Sponsors + sponsor links |
| 7 | Update README.md | `README.md` | Add Termux package installation section, uninstall docs, VERSION badge → 1.1.x |

### Should Do (3 tasks)

| # | Task | Files | Detail |
|---|------|-------|--------|
| 8 | Version bump | `VERSION` | `1.0.0` → `1.1.0-dev` |
| 9 | CHANGELOG.md placeholder | `CHANGELOG.md` | Add `[v1.1]` section |
| 10 | Update `scripts/core/update.sh` | `scripts/core/update.sh` | Support Termux package version detection |

## Package Design

### Install Path Separation

| Method | Install Path | Symlinks |
|--------|-------------|----------|
| Curl installer | `$HOME/dotfiles` | `~/dotfiles/zsh/.zshrc` → `$HOME/.zshrc` |
| Termux package | `$PREFIX` | `$PREFIX/etc/profile.d/termux-dotfiles.sh` |

### debbuild Structure

```
debbuild/
├── DEBIAN/
│   ├── control          # Package metadata (name, version, depends, maintainer)
│   ├── postinst         # Post-install: symlinks, profile.d sourcing
│   └── prerm            # Pre-removal: cleanup symlinks
└── data/
    └── data/
        └── com.termux/
            └── files/
                ├── usr/
                │   ├── bin/          # Executable wrappers (ai, aip)
                │   ├── etc/profile.d/ # Shell integration
                │   └── share/
                │       └── termux-dotfiles/  # Actual dotfiles
                └── home/
                    └──(user's home — no files here, pure PREFIX install)
```

### Package Metadata

| Field | Value |
|-------|-------|
| Package | `termux-dotfiles` |
| Version | Derived from `VERSION` file at build time |
| Depends | `termux-api`, `ncurses`, `openssh`, `git`, `curl`, `zsh`, `tmux`, `neovim` |
| Architecture | `all` (no native binaries) |
| Maintainer | `ipproyectossoluciones@gmail.com` |
| Section | `utilities` |
| Homepage | `https://github.com/ipproyectosysoluciones/termux-dotfiles` |

## CI Workflow

### package.yml Design

Trigger: Push tag matching `v*`

Steps:
1. Checkout + read VERSION
2. Run `termux-create-package` (or manual tarball → dpkg-deb)
3. Attach `.deb` to the GitHub Release created by `release.yml`
4. Publish to release assets

## Testing Strategy

| Phase | Test File | Coverage |
|-------|-----------|----------|
| Package structure | `tests/unit/package_structure.bats` | Verify debbuild/ contents, control file, scripts |
| CI workflow | `tests/e2e/package_ci.bats` | Mock tag push, verify .deb creation |
| URL fix | `tests/unit/docs.bats` | Verify correct URL in installation.md |
| Permission fix | `tests/unit/permissions.bats` | Verify `permissions: read` in workflows |
| README update | `tests/e2e/readme_package_section.bats` | Verify package install instructions |

## Verification Checklist

- [ ] `bats tests/` passes (all existing + new)
- [ ] `.deb` builds without error on tag push
- [ ] `.deb` attaches to GitHub Release as asset
- [ ] `permissions: read` present in `test.yml` and `shellcheck.yml`
- [ ] Code scanning alerts resolved
- [ ] `docs/installation.md` URL correct
- [ ] SECURITY.md exists with correct contact email
- [ ] FUNDING.yml exists with sponsor links
- [ ] README.md has Termux package install section
- [ ] README.md VERSION badge shows 1.1.x
- [ ] VERSION file shows 1.1.0-dev
- [ ] CHANGELOG.md has [v1.1] placeholder section

## Delivery Forecast

| Task | Effort | Risk |
|------|--------|------|
| Docs fixes (URL, SECURITY, FUNDING, README) | Low | Minimal |
| Code scanning permission fixes | Low | Minimal |
| Version + CHANGELOG | Low | Minimal |
| debbuild structure | Medium | Package tool availability |
| package.yml CI workflow | Medium | GitHub Actions secrets/permissions |
| update.sh version detection | Low | Straightforward grep/sed |

**Total estimated**: 3-4 review cycles for full delivery.