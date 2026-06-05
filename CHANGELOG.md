# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.1] - [Unreleased]

### Added

- Termux `.deb` package structure with `debbuild/` directory
- CI workflow to build and attach `.deb` package on tag push
- `SECURITY.md` — vulnerability disclosure policy
- `.github/FUNDING.yml` — GitHub Sponsors configuration
- `install_type.sh` — detect Termux package vs git clone installation
- Package trampoline executables (`ai`, `aip`) for `$PREFIX/bin/`
- Shell integration via `profile.d/termux-dotfiles.sh`
- 37 new bats tests for packaging, workflow, and install detection

### Changed

- `VERSION` bumped from `1.0.0` to `1.1.0-dev`
- `docs/installation.md` — corrected GitHub URL to `ipproyectosysoluciones/termux-dotfiles`
- `README.md` — added Termux package install and uninstall sections
- `scripts/core/update.sh` — integrated with `install_type.sh` for package-aware detection
- `test.yml` and `shellcheck.yml` — added `permissions: read` to resolve code scanning alerts

### Fixed

### Security

## [v1.0.0] - 2026-06-05

### Added

- Initial v1.0.0 release with foundation tooling
- Makefile with test/lint/install/clean targets
- VERSION file as single source of truth for release management
- CHANGELOG.md following keepachangelog.com conventions
- MIT LICENSE file
