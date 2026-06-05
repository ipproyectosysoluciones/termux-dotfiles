# Homebrew Tap Specification

## Purpose

Add Homebrew as a third delivery mechanism for termux-dotfiles, enabling Termux users on Debian proot (Android 11+) to install via `brew tap ipproyectosysoluciones/termux-dotfiles && brew install termux-dotfiles`. All three delivery methods ship identical code; only the installation mechanism differs.

---

## ADDED Requirements

### Requirement: Homebrew Formula

The system SHALL provide a Homebrew formula at `Formula/termux-dotfiles.rb` that enables `brew tap ipproyectosysoluciones/termux-dotfiles && brew install termux-dotfiles`.

The formula MUST download the release tarball from `https://github.com/ipproyectosysoluciones/termux-dotfiles/archive/refs/tags/v{VERSION}.tar.gz`, install it to the Homebrew Cellar, and declare itself `keg_only` to prevent conflicts with system files.

#### Scenario: Formula installs without error

- GIVEN Homebrew is installed inside Debian proot on Android 11+
- WHEN the user executes `brew tap ipproyectosysoluciones/termux-dotfiles && brew install termux-dotfiles`
- THEN the installation MUST complete with exit code 0
- AND the formula MUST be registered under `brew list --versions termux-dotfiles`

#### Scenario: Formula is keg-only

- GIVEN `termux-dotfiles` has been installed via Homebrew
- WHEN `brew info termux-dotfiles` is executed
- THEN the output MUST contain `keg_only`
- AND no files from the Cellar path SHALL conflict with system directories

---

### Requirement: Setup Script

The system SHALL provide `scripts/termux-dotfiles-setup` that creates `$HOME/.config/termux-dotfiles/` with symlinks pointing into the Homebrew Cellar.

The script MUST detect the Cellar path via `$(brew --prefix)/Cellar/termux-dotfiles/`, create the config directory, symlink all dotfile directories (zsh, tmux, nvim, scripts), and be idempotent, skipping existing symlinks unless `--force` is passed.

#### Scenario: Setup creates symlinks

- GIVEN `termux-dotfiles` is installed via Homebrew Cellar
- WHEN `termux-dotfiles-setup` is executed without flags
- THEN `$HOME/.config/termux-dotfiles/` MUST be created
- AND each dotfile directory (zsh, tmux, nvim, scripts) MUST be symlinked to the corresponding Cellar path

#### Scenario: Setup is idempotent

- GIVEN `termux-dotfiles-setup` has already been run
- WHEN `termux-dotfiles-setup` is executed a second time
- THEN no error SHALL occur
- AND existing symlinks SHALL NOT be replaced unless `--force` is passed

---

### Requirement: CI Auto-Update of Formula

On every tag push matching `v*`, the CI workflow MUST compute the SHA256 of the release tarball and update the `version` and `sha256` fields in `Formula/termux-dotfiles.rb`, then commit and push the updated formula in a separate commit from the release commit.

The version MUST be derived from the `VERSION` file and MUST stay in sync with the tag.

#### Scenario: Formula version and SHA256 updated on tag push

- GIVEN a commit bumps `VERSION` to `1.2.0` and a tag `v1.2.0` is pushed
- WHEN the CI workflow triggers on the tag push
- THEN the formula's `version` field MUST be set to `1.2.0`
- AND the formula's `sha256` field MUST match the SHA256 of `https://github.com/ipproyectosysoluciones/termux-dotfiles/archive/refs/tags/v1.2.0.tar.gz`
- AND a commit updating the formula MUST be pushed to the repository

---

### Requirement: Documentation — Three Delivery Methods

The system MUST document all three delivery methods (curl, .deb, brew tap) in `docs/installation.md` using a comparison table that covers installation command, platform requirements, update mechanism, and when to use each method.

A separate `docs/homebrew.md` SHALL provide Spanish-language instructions for the brew tap method.

#### Scenario: Installation docs show all three methods

- GIVEN a reader opens `docs/installation.md`
- WHEN the comparison table is located
- THEN it MUST list curl, .deb, and brew tap rows
- AND each row MUST include: installation command, platform, update command, and suitable use case

#### Scenario: Spanish Homebrew guide exists

- GIVEN a Spanish-speaking user references `docs/homebrew.md`
- WHEN the file is read
- THEN it MUST contain brew tap installation instructions in Spanish
- AND it MUST include the setup script invocation

---

### Requirement: GitHub Issues — Board #9 Integration

The system MUST create GitHub issues linked to the Core-AI-Astaroth project board (#9) during implementation, with the issue body and status field reflecting the Todo/In Progress/Done workflow states.

Issues MUST be assigned to the authenticated user.

#### Scenario: Issue created with correct board state

- GIVEN the Core-AI-Astaroth board (#9) exists with a Status field having Todo/In Progress/Done options
- WHEN an issue is created for a homebrew-tap deliverable
- THEN the issue MUST be added to board #9
- AND the Status field MUST be set to Todo (for new issues) or the appropriate workflow state
- AND the issue MUST be assigned to the user

---

## Out of Scope

- Native Homebrew support outside Debian proot (Android/Termux proot is the only target)
- Separate `homebrew-tap` standalone repo (formula lives in the main repo)
- Auto-upgrade symlink refresh after `brew upgrade` (user re-runs setup script manually)
- Changes to existing curl or .deb delivery mechanisms (all three ship identical code)
- Modifying the Termux packages repository structure

---

## Acceptance Criteria

| # | Criterion | Verification |
|---|-----------|-------------|
| 1 | `brew tap ipproyectosysoluciones/termux-dotfiles && brew install termux-dotfiles` completes with exit code 0 in Debian proot | Manual test in proot environment |
| 2 | `termux-dotfiles-setup` creates `$HOME/.config/termux-dotfiles/` with correct symlinks | Script execution + `ls -la` check |
| 3 | `termux-dotfiles-setup --force` replaces existing symlinks without error | Re-run script with `--force` flag |
| 4 | On tag push, formula version matches tag version | CI logs inspection |
| 5 | On tag push, formula sha256 matches actual tarball sha256 | CI logs + manual `shasum -a 256` verification |
| 6 | Formula commit is pushed separately from release commit | Git log inspection |
| 7 | `docs/installation.md` contains comparison table with curl, .deb, and brew tap rows | File content review |
| 8 | `docs/homebrew.md` exists with Spanish brew tap instructions | File existence + language check |
| 9 | GitHub issues are linked to board #9 with correct Status field | GitHub API or web UI inspection |