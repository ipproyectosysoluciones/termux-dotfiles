# Delta for Documentation

## ADDED Requirements

### Requirement: GitHub Release Descriptions

The system MUST provide meaningful, user-facing release descriptions for v1.0.0 and v1.1.0 that communicate the value delivered in each release.

Release descriptions SHALL be written from a user perspective and reference the changelog content.

#### Scenario: v1.0.0 release description

- GIVEN the v1.0.0 GitHub release exists with placeholder text
- WHEN `gh release view v1.0.0` is executed
- THEN the output MUST contain descriptive text covering foundation tooling (Makefile, VERSION, CHANGELOG, MIT license)
- AND the description MUST NOT contain the phrase "See CHANGELOG.md" as a placeholder

#### Scenario: v1.1.0 release description

- GIVEN the v1.1.0 GitHub release exists with placeholder text
- WHEN `gh release view v1.1.0` is executed
- THEN the output MUST contain descriptive text covering Termux .deb packaging, CI workflow, security docs, package trampolines, shell integration, and 37 new tests
- AND the description MUST NOT contain the phrase "See CHANGELOG.md" as a placeholder

---

### Requirement: Repository URL Synchronization

The system MUST replace all occurrences of the old repository URL `bladimir/Termux-AI-Astaroth` with the new URL `ipproyectosysoluciones/termux-dotfiles` in user-facing documentation.

#### Scenario: recovery.md URL replacement

- GIVEN `docs/recovery.md` contains references to `https://github.com/bladimir/Termux-AI-Astaroth`
- WHEN a reader follows clone instructions in that file
- THEN the resulting git clone command MUST use the URL `https://github.com/ipproyectosysoluciones/termux-dotfiles`
- AND zero occurrences of `bladimir/Termux-AI-Astaroth` remain in the file

---

### Requirement: README Version Reference Sync

The system MUST keep the version reference in `README.md` synchronized with the current VERSION file content.

#### Scenario: README version matches VERSION file

- GIVEN VERSION file contains `1.1.0`
- WHEN `README.md` line 330 is read
- THEN that line MUST contain `v1.1.0` (not `v1.0.0`)

---

### Requirement: Automated Release Notes Extraction

The CI workflow MUST automatically extract release notes from `CHANGELOG.md` when creating or publishing a GitHub release, instead of leaving release descriptions empty.

The system SHALL parse the CHANGELOG.md using the Keep a Changelog format, extracting content under the `## [version]` section corresponding to the tag being released.

#### Scenario: Release notes extracted from CHANGELOG.md

- GIVEN a tag `v1.2.0` is pushed and CHANGELOG.md contains `## [v1.2.0] - YYYY-MM-DD` with content
- WHEN the package.yml workflow executes
- THEN `gh release create` MUST be called with `--notes` flag containing the extracted section content
- AND the extracted notes MUST include the Added/Changed/Fixed/Security subsections for that version

#### Scenario: Backward compatibility with existing releases

- GIVEN releases v1.0.0 and v1.1.0 already exist with manually edited descriptions
- WHEN future releases are created via the workflow
- THEN existing release descriptions for v1.0.0 and v1.1.0 MUST NOT be modified
- AND only new releases created by the workflow shall use automated extraction

---

## Out of Scope

- Code changes or script modifications
- New test coverage for documentation
- Changes to release.yml workflow (separate from package.yml)
- Modification of CHANGELOG.md content structure
- Updates to any file outside: docs/recovery.md, README.md, package.yml, and GitHub Releases