# Portable AI Developer Workstation

Mobile-first developer workstation powered by:

- Termux
- tmux
- NeoVim
- zsh
- AI runtime orchestration (Gemini, Claude, Mistral, OpenCode, Gentle)

Designed for portable full-stack development and AI-assisted workflows.

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
- `ai` — main tmux launcher menu
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
├── docs/                    # Documentation
│   ├── ai-workspace.md      # AI workspace architecture
│   ├── provider-architecture.md  # Provider routing & fallback
│   ├── orchestration.md     # Agent/subagent framework
│   ├── recovery.md          # System recovery guide
│   └── ...                  # Additional docs
├── nvim/                    # NeoVim configuration
├── openspec/                # SDD artifacts (spec-driven development)
│   ├── config.yaml
│   ├── specs/
│   └── changes/
├── scripts/
│   ├── ai/                  # AI workspace framework
│   │   ├── ai.sh            # Entry point
│   │   ├── core/            # 29 orchestration modules
│   │   ├── providers/       # 5 provider implementations
│   │   ├── runtime/         # Runtime executor
│   │   └── templates/       # Workspace templates
│   ├── debian/              # Debian bootstrap
│   ├── nvim/                # NeoVim helpers
│   ├── tmux/                # tmux configuration
│   └── utils/               # Shared utilities
├── tests/                   # Bats test suite
├── tmux/                    # tmux configuration
└── zsh/                     # Zsh configuration
```

---

# Installation

Clone repository:

```bash
git clone https://github.com/bladimir/Termux-AI-Astaroth.git
```

---

# Run installer

```bash
cd termux-dotfiles/scripts

bash install.sh
```

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

# Documentation

Additional documentation:

| Document | Description |
|---|---|---|
| `docs/architecture.md` | Global architecture |
| `docs/ai-workspace.md` | AI workspace launcher & runtime |
| `docs/provider-architecture.md` | Provider routing & fallback chain |
| `docs/orchestration.md` | Agent/subagent orchestration framework |
| `docs/tmux-workflows.md` | tmux orchestration |
| `docs/shell-runtime.md` | Shell runtime |
| `docs/recovery.md` | System recovery guide |
| `docs/installation.md` | Installation guide |
| `docs/debian-runtime.md` | Debian proot runtime & Docker workflow |


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
- Bats test suite (248+ tests covering workspace, docker, bootstrap, launchers, scaffolding)
- SDD (Spec-Driven Development) workflow
- Reusable automation scripts
- PROJECTS_DIR integration — projects created in `~/Projects/` by default
- Dual-stack scaffolding (`new-mean.sh` / `new-mern.sh`) via `ai-menu → New Project`
- `sync-skills.sh --local` for direct deployment on remote devices

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

