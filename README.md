# Portable AI Developer Workstation

<p align="center">
  <strong>Stack</strong><br>
  <img src="https://img.shields.io/badge/Termux-0.118+-000000?style=for-the-badge&logo=terminal&logoColor=white" alt="Termux 0.118+">
  <img src="https://img.shields.io/badge/NeoVim-0.10+-57A143?style=for-the-badge&logo=neovim&logoColor=white" alt="NeoVim 0.10+">
  <img src="https://img.shields.io/badge/NvChad-v2.5-C792EA?style=for-the-badge&logo=neovim&logoColor=white" alt="NvChad v2.5">
  <img src="https://img.shields.io/badge/tmux-3.5+-1BB91F?style=for-the-badge&logo=tmux&logoColor=white" alt="tmux 3.5+">
  <img src="https://img.shields.io/badge/zsh-5.9+-F15A24?style=for-the-badge&logo=zsh&logoColor=white" alt="zsh 5.9+">
  <img src="https://img.shields.io/badge/Debian-Bookworm-A81D33?style=for-the-badge&logo=debian&logoColor=white" alt="Debian Bookworm">
  <br>
  <strong>AI Providers</strong><br>
  <img src="https://img.shields.io/badge/Gemini-2.5-8E75B2?style=for-the-badge&logo=google&logoColor=white" alt="Gemini 2.5">
  <img src="https://img.shields.io/badge/Claude-4-FF6B6B?style=for-the-badge&logo=anthropic&logoColor=white" alt="Claude 4">
  <img src="https://img.shields.io/badge/Mistral-3.x-FF6B35?style=for-the-badge&logo=data:image/svg%2bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI2MCIgaGVpZ2h0PSI2MCI+PHJlY3Qgd2lkdGg9IjYwIiBoZWlnaHQ9IjYwIiBmaWxsPSIjZmZmIi8+PC9zdmc+&logoColor=white" alt="Mistral 3.x">
  <img src="https://img.shields.io/badge/OpenCode-Gemini-4285F4?style=for-the-badge&logo=openai&logoColor=white" alt="OpenCode">
  <br>
  <strong>CI / Meta</strong><br>
  <img src="https://img.shields.io/badge/Tests-270%20passing-22c55e?style=for-the-badge&logo=github-actions&logoColor=white" alt="Tests 270 passing">
  <img src="https://img.shields.io/badge/Lint-shellcheck%20%7C%20bats-1f2937?style=for-the-badge&logo=github-actions&logoColor=white" alt="Lint CI">
  <img src="https://img.shields.io/badge/Release-v1.0.0-6366f1?style=for-the-badge&logo=github&logoColor=white" alt="Release v1.0.0">
  <img src="https://img.shields.io/badge/License-MIT-facc15?style=for-the-badge&logo=open-source-initiative&logoColor=white" alt="License MIT">
</p>

Mobile-first developer workstation powered by Termux, tmux, NeoVim, zsh and AI runtime orchestration (Gemini, Claude, Mistral, OpenCode, Gentle). Designed for portable full-stack development and AI-assisted workflows.

---

# Features

## Shell Runtime

- modular zsh configuration
- reusable aliases/functions
- SSH agent orchestration
- mobile-first shell workflows

---

## NeoVim Stack

- modular plugin architecture
- LSP support
- Treesitter
- formatting
- DAP
- completion system
- AI-ready workflows

---

## tmux Orchestration

- reusable sessions
- popup launcher
- mobile-optimized workflows
- AI runtime switching

---

## AI Workspace

Multi-provider AI orchestration with intent-based routing and automatic fallback.

**Providers:**

- Gemini (primary) — research, architecture
- OpenCode — coding, devops (first fallback)
- Claude — intent-routed coding agent
- Mistral — secondary provider via intent routing
- Gentle — control plane operations (final fallback)

**Launchers:**

- `ai` — main interactive menu (`menu.sh`)
- `aip` — popup overlay launcher
- `PREFIX + A` — tmux popup keybinding

**Docker:**

- `ai-menu → Docker` — opens a Debian shell with Docker CLI (vía proot-distro)
- Daemon no disponible en proot; CLI works for build/pull/push/info
- Remote context disponible para containers (`docker context create remote`)
- Bootstrap idempotente en `scripts/debian/bootstrap/docker.sh`

**Architecture:**

- `scripts/ai/core/` — 29 orchestration modules (routing, agents, memory, runtime)
- `scripts/ai/providers/` — 5 provider implementations
- `scripts/ai/runtime/` — runtime executor with tmux session management
- `scripts/ai/templates/` — workspace templates (default, mobile, node, remote, infra)

Powered by tmux + gum with dynamic path detection for portable installation.

---

# Repository Structure

```text
dotfiles/
├── .github/
│   └── workflows/              # CI/CD workflows (test.yml, shellcheck.yml, release.yml)
├── docs/                      # Documentation
│   ├── ai-workspace.md        # AI workspace architecture
│   ├── provider-architecture.md  # Provider routing & fallback
│   ├── orchestration.md       # Agent/subagent framework
│   ├── recovery.md            # System recovery guide
│   └── ...                    # Additional docs
├── nvim/                      # NeoVim configuration
├── openspec/                  # SDD artifacts (spec-driven development)
│   ├── config.yaml
│   ├── specs/
│   └── changes/
├── scripts/
│   ├── ai/                    # AI workspace framework
│   │   ├── ai.sh              # AI orchestration engine
│   │   ├── core/              # 29 orchestration modules
│   │   ├── providers/         # 5 provider implementations
│   │   ├── runtime/           # Runtime executor
│   │   └── templates/         # Workspace templates
│   ├── core/
│   │   ├── packages.sh        # Package installation
│   │   ├── symlinks.sh       # Symlink creation
│   │   └── update.sh          # Environment update with version check
│   ├── debian/                # Debian bootstrap
│   ├── nvim/                  # NeoVim helpers
│   ├── tmux/                  # tmux configuration
│   ├── utils/                 # Shared utilities
│   ├── install.sh             # Main installer with flags
│   ├── repair.sh              # Repair/backup/restore utility
│   └── release.sh             # Release preparation script
├── tests/
│   └── e2e/                   # End-to-end tests (install.bats, repair.bats)
├── CHANGELOG.md               # Keep a Changelog format
├── LICENSE                    # MIT License
├── Makefile                   # Build targets (test, lint, install, clean, changelog, release)
├── README.md
└── VERSION                    # Semver single source of truth (1.0.0)
```

---

# Installation

## Quick Install (One-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/ipproyectosysoluciones/termux-dotfiles/main/scripts/install.sh | bash
```

## Manual Install

Clone repository:

```bash
git clone https://github.com/ipproyectosysoluciones/termux-dotfiles.git
```

---

## Run Installer

Using Makefile:

```bash
make install
```

Or using the script directly:

```bash
cd termux-dotfiles/scripts

bash install.sh
```

### install.sh Flags

| Flag              | Description                                                   |
| ----------------- | ------------------------------------------------------------- |
| `--version <tag>` | Pin installation to a specific version (default: latest main) |
| `--dry-run`       | Show what would be installed without making changes           |
| `--check`         | Verify existing installation health                           |
| `--force`         | Overwrite existing installation without prompting             |
| `--help`          | Show usage help                                               |

Examples:

```bash
# Dry-run to see what would be installed
bash install.sh --dry-run

# Install specific version
bash install.sh --version v1.0.0

# Check existing installation
bash install.sh --check

# Force reinstall
bash install.sh --force
```

---

## Repair Utility

The `repair.sh` script provides maintenance and recovery functions:

```bash
bash scripts/repair.sh --help
```

| Command       | Description                                        |
| ------------- | -------------------------------------------------- |
| `--check`     | Check installation health and report issues        |
| `--backup`    | Create timestamped backup at `~/.dotfiles-backup/` |
| `--restore`   | Restore from latest backup                         |
| `--reinstall` | Full reinstallation with automatic backup          |

---

## Release Process

Prepare a release using the Makefile:

```bash
make changelog   # Update CHANGELOG.md, commit, and tag
make release     # Push changelog and tags to origin
```

Or use the release script directly:

```bash
bash scripts/release.sh changelog
```

This will:

1. Validate VERSION file exists
2. Validate CHANGELOG.md has [Unreleased] section
3. Check tag doesn't already exist
4. Replace [Unreleased] with version and date
5. Commit changes and create git tag

---

# AI Launcher

Main launcher:

```bash
ai
```

Popup launcher:

```bash
aip
```

tmux popup shortcut:

```text
PREFIX + m
```

---

# CI/CD

[![Test](https://github.com/ipproyectosysoluciones/termux-dotfiles/actions/workflows/test.yml/badge.svg)](https://github.com/ipproyectosysoluciones/termux-dotfiles/actions/workflows/test.yml)
[![ShellCheck](https://github.com/ipproyectosysoluciones/termux-dotfiles/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/ipproyectosysoluciones/termux-dotfiles/actions/workflows/shellcheck.yml)
[![Release](https://github.com/ipproyectosysoluciones/termux-dotfiles/actions/workflows/release.yml/badge.svg)](https://github.com/ipproyectosysoluciones/termux-dotfiles/actions/workflows/release.yml)

**Workflows:**

- `test.yml` — Runs bats test suite on push/PR to dev
- `shellcheck.yml` — Lints all shell scripts on push/PR to dev
- `release.yml` — Creates GitHub Release when tags matching `v*` are pushed

---

# Documentation

Additional documentation:

| Document                        | Description                                     |
| ------------------------------- | ----------------------------------------------- |
| `docs/architecture.md`          | Global architecture                             |
| `docs/ai-workspace.md`          | AI workspace launcher & runtime                 |
| `docs/provider-architecture.md` | Provider routing & fallback chain               |
| `docs/orchestration.md`         | Agent/subagent orchestration framework          |
| `docs/tmux-workflows.md`        | tmux orchestration                              |
| `docs/shell-runtime.md`         | Shell runtime                                   |
| `docs/recovery.md`              | System recovery guide                           |
| `docs/installation.md`          | Installation guide                              |
| `docs/debian-runtime.md`        | Debian proot runtime & Docker workflow          |
| `CHANGELOG.md`                  | Detailed changelog following keepachangelog.com |

---

# Version

Current release: **v1.0.0** (see [CHANGELOG.md](CHANGELOG.md) for details)

---

# Design Goals

- portability
- modularity
- mobile-first UX
- lightweight orchestration
- reusable runtime sessions
- low maintenance overhead

---

# Platform Targets

Primary target:

- Android + Termux

Secondary environments:

- Debian Proot
- Linux workstations
- VPS environments

---

# Current Status

The workstation currently includes:

- modular shell runtime with zsh
- tmux popup launcher with gum
- AI workspace orchestration with 5 providers (Gemini, Claude, Mistral, OpenCode, Gentle)
- Intent-based provider routing with automatic fallback chain
- Agent/subagent orchestration framework
- Modular NeoVim architecture with LSP, Treesitter, DAP
- Dynamic path detection for portable installation
- Bats test suite (270 tests covering workspace, docker, bootstrap, launchers, scaffolding, install, repair)
- SDD (Spec-Driven Development) workflow
- Reusable automation scripts
- PROJECTS_DIR integration — projects created in `~/Projects/` by default
- Dual-stack scaffolding (`new-mean.sh` / `new-mern.sh`) via `ai-menu → New Project`
- `sync-skills.sh --local` for direct deployment on remote devices
- VERSION file as single source of truth for release management
- Makefile with test/lint/install/clean/changelog/release targets

---

# Future Roadmap

Potential future additions:

- workspace profiles (templates exist, profiles pending)
- session metadata & persistence
- runtime previews
- XDG base directory migration
- Enhanced subagent capabilities

---

# Philosophy

The project focuses on creating a lightweight portable development
environment optimized for mobile workflows and AI-assisted development.
