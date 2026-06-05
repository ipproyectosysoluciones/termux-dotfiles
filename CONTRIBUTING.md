# Contributing to termux-dotfiles

Thank you for your interest in contributing to termux-dotfiles!

## How to Contribute

### Reporting Issues

- **Bug reports**: Use the [Bug Report template](../.github/ISSUE_TEMPLATE/bug_report.md)
- **Feature requests**: Use the [Feature Request template](../.github/ISSUE_TEMPLATE/feature_request.md)
- Search existing issues before creating a new one
- Include environment details (OS, version, shell) and reproduction steps

### Pull Requests

1. Fork the repository
2. Create a feature branch from `dev`: `git checkout -b feature/my-feature dev`
3. Make your changes
4. Run tests and linting locally
5. Push your branch and open a PR against `dev`

## Branch Strategy

```
main    ← production releases (protected)
  └── dev  ← development branch (PR target)
        └── feature/*, fix/*, refactor/*  ← your branches
```

- All PRs target `dev` branch
- Releases are tagged from `main`
- Use descriptive branch names: `feature/ai-menu`, `fix/repair-backup`

## PR Requirements

### Format

- Use the [PR template](../.github/PULL_REQUEST_TEMPLATE.md)
- Fill in all sections
- Link related issues

### Size

- Keep PRs focused and reviewable (under 400 lines changed)
- For larger changes, consider splitting into chained PRs

### Commits

This project uses **Conventional Commits**:

```
<type>(<scope>): <description>

feat(ai): add new provider fallback
fix(install): correct version flag handling
docs(readme): update installation instructions
test(repair): add restore scenario
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Testing Requirements

All tests must pass before merging:

```bash
# Run the full test suite
make test

# Run linting
make lint

# Or run bats directly
bats --recursive tests/
```

### Test Coverage

- New features should include tests
- Bug fixes should include a test that reproduces the bug
- Run `bats tests/e2e/` for end-to-end tests

## Linting Requirements

Shell scripts must pass shellcheck:

```bash
# Lint all scripts
make lint

# Or manually
shellcheck scripts/**/*.sh
```

## Code Style

- Use `set -euo pipefail` for shell scripts
- Use descriptive variable names
- Add comments for non-obvious logic
- Prefer functions over inline scripts

## Commit Message Conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

feat(ai): add intent routing for mistral provider
fix(install): handle missing dotfiles directory
docs(recovery): clarify TPM initialization steps
```

## Related Documents

- [Code of Conduct](../CODE_OF_CONDUCT.md) — Be respectful and constructive
- [README](../README.md) — Project overview and setup
- [CHANGELOG](../CHANGELOG.md) — Release history

## Questions?

- Open a discussion issue for questions
- Email: ipproyectossoluciones@gmail.com

---

**Note**: This project uses linear history and prefers rebase merges. Please ensure your branch is rebased on the latest `dev` before requesting review.