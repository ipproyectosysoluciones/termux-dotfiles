# Dotfiles Architecture

## Overview

This repository contains a modular mobile-first developer workstation
optimized for:

- Termux
- Debian Proot
- NeoVim
- tmux
- AI workflows
- Full-stack development

The environment is designed around portability, modularity and
runtime orchestration.

---

# Core Principles

## Modular Architecture

Each subsystem is isolated:

- shell
- tmux
- nvim
- AI workflows
- utilities
- automation scripts

---

## Mobile-First UX

The environment is optimized primarily for Android + Termux.

Design decisions prioritize:

- low friction
- popup interfaces
- reusable sessions
- keyboard efficiency
- reduced pane complexity

---

## Runtime Isolation

AI workflows are separated into dedicated tmux sessions.

Examples:

- NeoVim
- OpenCode
- Gentle AI
- Engram

---

# Repository Structure

```text
dotfiles/
├── docs/
├── nvim/
├── tmux/
├── zsh/
├── scripts/
│   ├── ai/
│   ├── core/
│   ├── nvim/
│   ├── tmux/
│   └── utils/
```

---

# Shell Layer

The shell layer is based on:

- zsh
- powerlevel10k
- modular aliases
- modular functions
- SSH agent orchestration

Key files:

```text
zsh/
├── aliases.zsh
├── exports.zsh
├── functions.zsh
├── history.zsh
└── ssh.zsh
```

---

# NeoVim Layer

NeoVim uses a modular plugin architecture.

Structure:

```text
nvim/lua/plugins/
├── ai/
├── completion/
├── dap/
├── editor/
├── formatting/
├── git/
├── lsp/
├── terminal/
├── testing/
└── ui/
```

---

# tmux Layer

tmux acts as the orchestration runtime.

Responsibilities:

- workspace persistence
- popup launcher
- AI session management
- session switching
- mobile workflow optimization

---

# AI Workspace Layer

AI runtimes are managed through:

```text
scripts/ai/
```

Components:

- launcher
- popup menu
- workspace runtime
- session orchestration
- UI helpers

---

# Popup Launcher

The popup launcher uses:

- tmux display-popup
- gum
- reusable tmux sessions

Access:

```text
PREFIX + m
```

or:

```bash
aip
```

---

# Session Management

AI runtimes use reusable tmux sessions.

Behavior:

- auto-create session
- attach if outside tmux
- switch-client if already inside tmux

This avoids nested tmux issues.

---

# SSH Architecture

SSH keys are separated by responsibility.

Examples:

- infrastructure keys
- GitHub workstation keys

This reduces operational friction while maintaining isolation.

---

# Current Goals

- stable mobile workstation
- AI orchestration
- reproducible environments
- portable development workflows
- lightweight runtime management
