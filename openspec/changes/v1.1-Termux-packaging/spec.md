# Delta: v1.1 Termux Packaging

## ADDED Requirements

### Requirement: Termux Package Structure (debbuild/)

The system SHALL provide a Termux-native `.deb` package structure under `debbuild/` that enables distribution via GitHub Releases.

The `debbuild/` directory MUST contain:
- `DEBIAN/control` — Package metadata with fields: Package, Version, Section, Priority, Architecture, Depends, Maintainer, Description, Homepage
- `DEBIAN/postinst` — Post-install script that creates symlinks from `$PREFIX` to `$HOME/.config`
- `DEBIAN/prerm` — Pre-removal script that cleans up symlinks on uninstall
- `data/data/com.termux/files/usr/` — Directory containing scripts and config files

The package metadata MUST use: Package=`termux-dotfiles`, Architecture=`all`, Section=`utilities`, Maintainer=`ipproyectossoluciones@gmail.com`, Homepage=`https://github.com/ipproyectosysoluciones/termux-dotfiles`.

#### Scenario: Package structure validation

- GIVEN the `debbuild/` directory exists
- WHEN `bats tests/unit/package_structure.bats` runs
- THEN it MUST verify `DEBIAN/control` contains all required fields
- AND it MUST verify `DEBIAN/postinst` creates correct symlinks
- AND it MUST verify `DEBIAN/prerm` cleans up symlinks
- AND it MUST verify `data/data/com.termux/files/usr/` contains expected scripts

#### Scenario: Control file fields

- GIVEN the `debbuild/DEBIAN/control` file
- WHEN it is parsed
- THEN Package field MUST equal `termux-dotfiles`
- AND Version field MUST be derived from the `VERSION` file at build time
- AND Architecture field MUST be `all`
- AND Depends field MUST include: `termux-api`, `ncurses`, `openssh`, `git`, `curl`, `zsh`, `tmux`, `neovim`

---

### Requirement: CI Packaging Workflow (package.yml)

The system SHALL provide a GitHub Actions workflow that builds the `.deb` package on tag push and uploads it as a GitHub Release asset.

The workflow file `.github/workflows/package.yml` MUST:
- Trigger on push tags matching `v*`
- Read the `VERSION` file for package version
- Build the `.deb` using `dpkg-deb` or equivalent
- Upload the `.deb` as an asset to the GitHub Release

#### Scenario: Workflow file existence

- GIVEN the repository
- WHEN the workflow file is inspected
- THEN `.github/workflows/package.yml` MUST exist
- AND it MUST have `on: push: tags: [v*]` trigger

#### Scenario: Workflow tag-based execution

- GIVEN a tag `v1.1.0` is pushed
- WHEN the workflow runs
- THEN it MUST read `VERSION` file
- AND it MUST build a `.deb` package
- AND it MUST attach the `.deb` to the GitHub Release

---

### Requirement: Fix docs/installation.md URL

The system SHALL correct the GitHub repository URL in `docs/installation.md` to reference the correct owner and repo.

Line 88 of `docs/installation.md` MUST be changed from `bladimir/Termux-AI-Astaroth` to `ipproyectosysoluciones/termux-dotfiles`.

#### Scenario: URL correction verification

- GIVEN `docs/installation.md` is read
- WHEN line 88 is inspected
- THEN it MUST contain `ipproyectosysoluciones/termux-dotfiles`
- AND it MUST NOT contain `bladimir/Termux-AI-Astaroth`

---

### Requirement: Fix Code Scanning Alerts

The system SHALL resolve open code scanning alerts by adding `permissions: read` at the workflow level to `test.yml` and `shellcheck.yml`.

Both `.github/workflows/test.yml` and `.github/workflows/shellcheck.yml` MUST have `permissions: read` added at the top-level of the workflow.

#### Scenario: Workflow permission addition

- GIVEN the workflow files `test.yml` and `shellcheck.yml`
- WHEN each file is parsed
- THEN the top-level MUST contain `permissions: read`

#### Scenario: Code scanning alert resolution

- GIVEN the workflow files have been updated
- WHEN `gh api repos/{owner}/{repo}/code-scanning/alerts` is queried
- THEN all alerts related to `missing-workflow-permissions` MUST be closed

---

### Requirement: Create SECURITY.md

The system SHALL provide a vulnerability disclosure policy to enable security researchers to report issues responsibly.

The file `SECURITY.md` at repository root MUST contain:
- A standard vulnerability disclosure policy
- Contact email: `ipproyectossoluciones@gmail.com`
- Link to GitHub Security Advisories tab

#### Scenario: SECURITY.md existence and content

- GIVEN the repository root
- WHEN `SECURITY.md` is read
- THEN it MUST exist
- AND it MUST contain contact information
- AND it MUST reference the GitHub Security Advisories page

---

### Requirement: Create FUNDING.yml

The system SHALL provide a funding configuration file to enable GitHub Sponsors support.

The file `.github/FUNDING.yml` MUST:
- Contain GitHub Sponsors listing
- Link to `ipproyectosysoluciones` profile sponsors page

#### Scenario: FUNDING.yml existence

- GIVEN the repository
- WHEN `.github/FUNDING.yml` is read
- THEN it MUST exist
- AND it MUST link to the correct GitHub Sponsors profile

---

### Requirement: Update README.md

The system SHALL update `README.md` to include Termux package installation instructions and update version badge.

The README MUST:
- Add a Termux package installation section with installation instructions
- Add an uninstall section
- Update VERSION badge to reflect `1.1.0-dev`

#### Scenario: README package section

- GIVEN `README.md` is read
- WHEN the file is inspected
- THEN it MUST contain a Termux package installation section
- AND it MUST contain uninstall instructions
- AND the VERSION badge MUST show `1.1.0-dev`

---

### Requirement: Version Bump

The system SHALL update the version identifier to reflect the v1.1 pre-release cycle.

The `VERSION` file MUST change from `1.0.0` to `1.1.0-dev`.

The `CHANGELOG.md` MUST have a `[v1.1]` unreleased section added above the `[v1.0.0]` section in keepachangelog format.

#### Scenario: VERSION file update

- GIVEN the `VERSION` file is read
- WHEN its content is inspected
- THEN it MUST contain `1.1.0-dev`

#### Scenario: CHANGELOG placeholder

- GIVEN `CHANGELOG.md` is read
- WHEN the file is inspected
- THEN it MUST contain a `[v1.1]` section marked as unreleased
- AND this section MUST appear above the `[v1.0.0]` section

#### Scenario: Tests pass after version bump

- GIVEN `VERSION` and `CHANGELOG.md` are updated
- WHEN `bats --recursive tests/` runs
- THEN all tests MUST pass (270 existing + any new)

---

### Requirement: CHANGELOG Placeholder

The system SHALL add a placeholder section in `CHANGELOG.md` for the v1.1 release.

The `[v1.1]` section MUST use keepachangelog format and be placed above `[v1.0.0]`.

#### Scenario: CHANGELOG section format

- GIVEN `CHANGELOG.md` is read
- WHEN the `[v1.1]` section is found
- THEN it MUST be formatted in keepachangelog format
- AND it MUST be marked as `[Unreleased]`

---

### Requirement: update.sh Enhancement

The system SHALL enhance `scripts/core/update.sh` to detect if running as a Termux package vs git clone and support version comparison with Termux pkg version.

The script MUST:
- Detect installation method (Termux package vs git clone)
- Support version comparison logic
- Pass existing tests

#### Scenario: Installation method detection

- GIVEN `scripts/core/update.sh` is executed
- WHEN the script runs
- THEN it MUST detect whether it was installed via Termux package or git clone
- AND it MUST use appropriate version checking logic for each method

#### Scenario: Version comparison

- GIVEN the script detects Termux package installation
- WHEN version comparison is needed
- THEN it MUST compare against the Termux pkg version correctly

#### Scenario: Existing tests pass

- GIVEN `scripts/core/update.sh` is updated
- WHEN `bats --recursive tests/` runs
- THEN any existing tests for `update.sh` MUST pass

---

## Verification Checklist

- [ ] `debbuild/DEBIAN/control` exists with all required fields
- [ ] `debbuild/DEBIAN/postinst` creates correct symlinks
- [ ] `debbuild/DEBIAN/prerm` cleans up symlinks
- [ ] `.github/workflows/package.yml` exists and triggers on `v*` tags
- [ ] `docs/installation.md` line 88 has correct URL
- [ ] `test.yml` has `permissions: read` at top level
- [ ] `shellcheck.yml` has `permissions: read` at top level
- [ ] Code scanning alerts are closed
- [ ] `SECURITY.md` exists with correct contact
- [ ] `.github/FUNDING.yml` exists with sponsor link
- [ ] `README.md` has Termux package install section and uninstall section
- [ ] `README.md` VERSION badge shows `1.1.0-dev`
- [ ] `VERSION` file shows `1.1.0-dev`
- [ ] `CHANGELOG.md` has `[v1.1]` unreleased section
- [ ] `scripts/core/update.sh` detects Termux package vs git clone
- [ ] All `bats tests/` pass