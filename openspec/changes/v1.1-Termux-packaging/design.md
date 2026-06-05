# Design: v1.1 Termux Packaging

**What**: Package the dotfiles as a Termux-native `.deb` (`termux-dotfiles`) installable via `pkg install termux-dotfiles`, coexisting with the existing curl installer at `$HOME/dotfiles`.

**Why**: Users who prefer package managers over manual `curl | bash` get a first-class Termux-native install. The curl path remains untouched.

---

## 1. Package Architecture — `debbuild/`

```
debbuild/
├── DEBIAN/
│   ├── control       # Package metadata, Version substituted at CI build time
│   ├── postinst      # Idempotent symlink creation with backup
│   └── prerm         # Idempotent symlink removal with restore
└── data/
    └── data/
        └── com.termux/
            └── files/
                └── usr/
                    ├── bin/
                    │   ├── ai            # Wrapper: delegates to share/termux-dotfiles/scripts/cli/ai.sh
                    │   └── aip           # Wrapper: delegates to share/termux-dotfiles/scripts/cli/aip.sh
                    ├── etc/
                    │   └── profile.d/
                    │       └── termux-dotfiles.sh   # Sets DOTFILES_DIR, adds share/termux-dotfiles/bin to PATH
                    └── share/
                        └── termux-dotfiles/          # The actual dotfiles tree
                            ├── VERSION
                            ├── zsh/
                            ├── tmux/
                            ├── termux/
                            ├── nvim/
                            ├── scripts/
                            │   ├── core/
                            │   │   ├── packages.sh
                            │   │   ├── symlinks.sh
                            │   │   └── update.sh      # Extended to detect package install
                            │   ├── nvim/
                            │   ├── tmux/
                            │   ├── utils/
                            │   └── install.sh
                            └── README.md             # Package-specific README (not curl installer)
```

### `debbuild/DEBIAN/control`

```
Package: termux-dotfiles
Version: __VERSION__
Section: utilities
Priority: optional
Architecture: all
Depends: termux-api, ncurses, openssh, git, curl, zsh, tmux, neovim
Maintainer: ipproyectossoluciones@gmail.com
Description: Termux dotfiles — zsh, tmux, Neovim config for Termux
```

**Version substitution**: CI sed-replaces `__VERSION__` with the contents of `VERSION` before building. No hardcoded version in the repo.

### `debbuild/DEBIAN/postinst`

```bash
#!/data/data/com.termux/files/usr/bin/bash
set -e

DOTFILES_DIR="/data/data/com.termux/files/usr/share/termux-dotfiles"
BACKUP_SUFFIX=".termux-dotfiles-backup"

backup() {
    local target="$1"
    if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
        mv "$target" "${target}${BACKUP_SUFFIX}"
    fi
}

link() {
    local source="$1"
    local target="$2"
    if [[ -L "$target" ]]; then
        # Already linked by this package — skip
        exit 0
    fi
    backup "$target"
    mkdir -p "$(dirname "$target")"
    ln -sf "$source" "$target"
}

# Shell integration
mkdir -p "$HOME/.config/zsh" "$HOME/.config/tmux" "$HOME/.config/termux" "$HOME/.config/nvim"
mkdir -p "$HOME/.termux"

link "$DOTFILES_DIR/zsh"        "$HOME/.config/zsh"
link "$DOTFILES_DIR/tmux"       "$HOME/.config/tmux"
link "$DOTFILES_DIR/termux"    "$HOME/.config/termux"
link "$HOME/.config/tmux/tmux.conf"  "$HOME/.tmux.conf"
link "$HOME/.config/termux/termux.properties" "$HOME/.termux/termux.properties"
link "$HOME/.config/zsh/zshrc"  "$HOME/.zshrc"
link "$DOTFILES_DIR/nvim"       "$HOME/.config/nvim"
```

**Idempotency**: `[[ -L "$target" ]]` check before touching anything. If already linked by this package, exits 0. Never removes user files — only backs up non-symlink targets.

### `debbuild/DEBIAN/prerm`

```bash
#!/data/data/com.termux/files/usr/bin/bash
set -e

DOTFILES_DIR="/data/data/com.termux/files/usr/share/termux-dotfiles"
BACKUP_SUFFIX=".termux-dotfiles-backup"

unlink() {
    local target="$1"
    if [[ -L "$target" ]]; then
        rm "$target"
        # Restore backup if it exists
        if [[ -e "${target}${BACKUP_SUFFIX}" ]]; then
            mv "${target}${BACKUP_SUFFIX}" "$target"
        fi
    fi
}

unlink "$HOME/.zshrc"
unlink "$HOME/.tmux.conf"
unlink "$HOME/.termux/termux.properties"
unlink "$HOME/.config/zsh"
unlink "$HOME/.config/tmux"
unlink "$HOME/.config/termux"
unlink "$HOME/.config/nvim"
```

**Restore logic**: If `~/.zshrc.termux-dotfiles-backup` exists, it is moved back to `~/.zshrc` after symlink removal. User config is never lost.

### `debbuild/data/data/com.termux/files/usr/bin/ai` and `aip`

```bash
#!/data/data/com.termux/files/usr/bin/bash
exec /data/data/com.termux/files/usr/share/termux-dotfiles/scripts/cli/"$(basename "$0")".sh "$@"
```

Minimal trampolines. Allow both `ai` and `aip` on PATH without polluting `$PREFIX/bin/` with the full script payload.

---

## 2. CI Workflow — `package.yml`

### Decision: Separate workflow, not extension of `release.yml`

`release.yml` is responsible for creating the GitHub Release. `package.yml` builds the `.deb` and attaches it as an asset to the already-created release. Keeping them separate:
- `release.yml` stays simple (create release)
- `package.yml` only does: build → upload asset
- Failure in packaging does not block release creation

### Trigger

```yaml
on:
  push:
    tags:
      - 'v*'
```

Matches `release.yml` trigger exactly — same tag push fires both workflows. No new trigger pattern needed.

### Job: `build-package`

```yaml
jobs:
  build-package:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4

      - name: Read version
        id: version
        run: echo "VERSION=$(cat VERSION)" >> $GITHUB_OUTPUT

      - name: Prepare debbuild
        run: |
          # Copy debbuild staging tree
          cp -r debbuild /tmp/debbuild
          # Substitute __VERSION__ in control
          sed -i "s/__VERSION__/${{ steps.version.outputs.VERSION }}/g" \
            /tmp/debbuild/DEBIAN/control

      - name: Build .deb
        run: |
          cd /tmp/debbuild
          # Termux-create-package or manual dpkg-deb
          dpkg-deb --build data  # builds data.deb
          mv data.deb termux-dotfiles_${{ steps.version.outputs.VERSION }}_all.deb

      - name: Upload to GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: termux-dotfiles_${{ steps.version.outputs.VERSION }}_all.deb
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Asset upload behavior

`softprops/action-gh-release` appends the `.deb` to the release created by `release.yml`. No conflict — GitHub supports multiple assets per release.

---

## 3. Non-Breaking Strategy

### Path separation

| Method | Install root | Config symlinks |
|--------|-------------|-----------------|
| Curl installer | `$HOME/dotfiles` | `$HOME/.config/zsh` → `$HOME/dotfiles/zsh` |
| Termux package | `$PREFIX/share/termux-dotfiles` | `$HOME/.config/zsh` → `$PREFIX/share/termux-dotfiles/zsh` |

Both create the same symlinks in `$HOME/.config/`, but the source differs. They **cannot** be active simultaneously — the second install overwrites the first's symlinks. However:

- **Curl installer files** live exclusively in `$HOME/dotfiles/`. Removing `$HOME/dotfiles/` does not affect the package.
- **Package files** live exclusively in `$PREFIX/share/termux-dotfiles/`. `pkg remove termux-dotfiles` cleans up completely via `prerm`.
- **Shared state**: None. Each install method is independently removable.

### Uninstall isolation

```
# Curl uninstall
rm -rf $HOME/dotfiles
# Package uninstall
pkg remove termux-dotfiles
```

Both leave no trace of the other method.

---

## 4. Version Sync Strategy

```
VERSION (file) ← single source of truth
     ↓ (read by CI at build time)
debbuild/DEBIAN/control (Version: __VERSION__)
     ↓ (sed substitution in package.yml)
Final .deb has real version string
```

`update.sh` detects installation type:

```bash
detect_install_type() {
    if [[ -d "/data/data/com.termux/files/usr/share/termux-dotfiles" ]]; then
        echo "package"
    elif [[ -d "$HOME/dotfiles" ]]; then
        echo "curl"
    else
        echo "unknown"
    fi
}

get_local_version() {
    local install_type=$(detect_install_type)
    case "$install_type" in
        package)
            cat /data/data/com.termux/files/usr/share/termux-dotfiles/VERSION
            ;;
        curl)
            cat "$HOME/dotfiles/VERSION"
            ;;
    esac
}
```

---

## 5. Documentation Architecture

### `README.md` additions

```markdown
## Termux Package Install (v1.1+)

pkg install termux-dotfiles

# Uninstall
pkg remove termux-dotfiles
```

No curl commands in the package README section. Package install section must be clearly separated from the curl install section.

### `SECURITY.md`

```markdown
# Security Policy

## Reporting a Vulnerability

Email: ipproyectossoluciones@gmail.com
GitHub: https://github.com/ipproyectosysoluciones/termux-dotfiles/security/advisories

Response SLA: 48 hours

Please do not open public issues for security vulnerabilities.
```

### `FUNDING.yml`

```yaml
github: [ipproyectosysoluciones]
links:
  - label: Sponsor
    url: https://github.com/sponsors/ipproyectosysoluciones
```

---

## 6. Branch & PR Strategy

| Target | Trigger | Project | Assignee |
|--------|---------|---------|----------|
| `dev` | Feature branch PR | Core-AI-Astaroth (#9) | ipproyectosysoluciones |
| `main` | PR from `dev` | Core-AI-Astaroth (#9) | ipproyectosysoluciones |

- All PRs → Project #9, status "In Progress" on open, "Done" on merge
- Chained PRs if total diff > 400 lines
- PR titles follow conventional commits: `feat: termux packaging`

---

## 7. Component Design Summary

| Component | File | Purpose |
|-----------|------|---------|
| Package staging | `debbuild/` | Source tree for `dpkg-deb --build` |
| Package metadata | `debbuild/DEBIAN/control` | Name, depends, version (substituted at CI) |
| Post-install hook | `debbuild/DEBIAN/postinst` | Idempotent symlink creation with backup |
| Pre-removal hook | `debbuild/DEBIAN/prerm` | Idempotent symlink removal with restore |
| Executable trampolines | `debbuild/.../bin/ai`, `aip` | Lightweight PATH wrappers |
| Shell integration | `debbuild/.../profile.d/termux-dotfiles.sh` | DOTFILES_DIR env + PATH prepend |
| Dotfiles payload | `debbuild/.../share/termux-dotfiles/` | Actual zsh/tmux/nvim/scripts |
| CI build workflow | `.github/workflows/package.yml` | Build .deb on tag push, attach to release |
| Install detection | `scripts/core/update.sh` | Detect `package` vs `curl` install type |

---

## 8. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| `termux-create-package` not available in GitHub Actions runner | Medium | High | Use `dpkg-deb --build` on a standard Ubuntu runner instead |
| Package symlinks conflict with curl install | Low | Medium | Path separation; prerm restores backups; users choose one method |
| Version drift between GitHub Release tag and .deb | Low | Low | CI reads `VERSION` file at build time; no manual version entry |
| `postinst` fails on fresh Termux install | Low | Low | `mkdir -p` before every `ln -sf`; idempotent checks prevent double-run |
| `.deb` exceeds GitHub Release asset size limit | Very Low | Low | Dotfiles are text files; total payload < 5 MB |

---

## 9. Implementation Order (from proposal)

```
Phase 1 (docs-only, parallelizable)
  ├── Fix docs/installation.md URL
  ├── Create SECURITY.md
  ├── Create FUNDING.yml
  └── Update README.md (package install section)

Phase 2 (quick fixes)
  ├── Add permissions: read to test.yml
  └── Add permissions: read to shellcheck.yml

Phase 3 (metadata)
  ├── Bump VERSION → 1.1.0-dev
  └── Add CHANGELOG.md [v1.1] placeholder

Phase 4 (core deliverable, TDD order)
  ├── Write bats tests (package_structure.bats, package_ci.bats)
  ├── Create debbuild/ structure
  ├── Create package.yml CI workflow
  └── Update scripts/core/update.sh (install detection)
```