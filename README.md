# Portable AI Developer Workstation

Mobile-first developer workstation powered by:

- Termux
- tmux
- NeoVim
- zsh
- AI runtime orchestration

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

Integrated runtime launcher for:

- NeoVim
- OpenCode
- Gentle AI
- Engram

Powered by:

- tmux
- gum
- popup overlays

---

# Repository Structure

```text
dotfiles/
├── docs/
├── nvim/
├── scripts/
│   ├── ai/
│   ├── core/
│   ├── nvim/
│   ├── tmux/
│   └── utils/
├── tmux/
└── zsh/
```

---

# Installation

Clone repository:

```bash
git clone https://github.com/ipproyectosysoluciones/termux-dotfiles.git
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
|---|---|
| `docs/architecture.md` | global architecture |
| `docs/ai-workspace.md` | AI runtime workflows |
| `docs/tmux-workflows.md` | tmux orchestration |
| `docs/shell-runtime.md` | shell runtime |

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

- modular shell runtime
- tmux popup launcher
- AI workspace orchestration
- modular NeoVim architecture
- reusable automation scripts

---

# Future Roadmap

Potential future additions:

- workspace profiles
- session metadata
- runtime previews
- AI provider switching
- workspace templates
- runtime persistence

---

# Philosophy

The project focuses on creating a lightweight portable development
environment optimized for mobile workflows and AI-assisted development.

