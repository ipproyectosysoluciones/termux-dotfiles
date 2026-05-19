# Shell Runtime

## Overview

The shell runtime is based on:

- zsh
- modular configuration
- reusable aliases
- reusable functions
- SSH agent orchestration
- mobile-first workflows

The shell layer acts as the primary interface for:

- development
- tmux orchestration
- AI workflows
- infrastructure management

---

# Shell Structure

```text
zsh/
├── aliases.zsh
├── exports.zsh
├── functions.zsh
├── history.zsh
├── ssh.zsh
└── p10k.zsh
```

---

# Design Philosophy

The shell runtime prioritizes:

- modularity
- portability
- low startup friction
- reusable workflows
- Android compatibility

---

# aliases.zsh

Contains reusable command shortcuts.

Examples:

- AI launchers
- git shortcuts
- tmux shortcuts
- utility commands

Examples:

```bash
alias ai='~/dotfiles/scripts/ai/menu.sh'
alias aip='~/dotfiles/scripts/ai/popup.sh'
```

---

# functions.zsh

Contains reusable shell functions.

Responsibilities:

- workflow helpers
- Debian wrappers
- utility orchestration
- session helpers

Functions are preferred over aliases for:

- arguments
- reusable logic
- conditional behavior

---

# exports.zsh

Defines shell environment variables.

Examples:

- PATH
- editor variables
- runtime configuration
- language toolchains

---

# history.zsh

Controls shell history behavior.

Responsibilities:

- history expansion
- duplicate handling
- history persistence
- shell compatibility

Example:

```bash
unsetopt BANG_HIST
```

This prevents conflicts with:

```bash
#!/bin/bash
```

inside zsh.

---

# SSH Runtime

SSH orchestration is managed through:

```text
zsh/ssh.zsh
```

Responsibilities:

- ssh-agent startup
- agent reuse
- key lifecycle management

---

# SSH Key Separation

SSH keys are separated by responsibility.

Examples:

| Key | Purpose |
|---|---|
| `id_ed25519` | infrastructure/VPS |
| `id_ed25519_github` | GitHub workstation |

This reduces operational friction while preserving isolation.

---

# SSH Agent Lifecycle

The shell runtime:

1. checks existing agent
2. reuses valid session
3. starts new agent if needed

The system avoids unnecessary prompts during shell startup.

---

# Powerlevel10k

The shell uses:

```text
powerlevel10k
```

for prompt rendering.

Goals:

- fast startup
- clean UI
- mobile readability

Special care is taken to avoid:

- console output during startup
- SSH prompt interference
- delayed initialization

---

# Mobile Optimization

The shell runtime is optimized for:

- Termux
- Android keyboards
- reduced typing overhead
- popup workflows
- tmux integration

---

# Runtime Integration

The shell layer integrates directly with:

- tmux
- NeoVim
- AI launchers
- git workflows
- Debian proot environments

---

# Current Goals

- stable startup behavior
- portable shell runtime
- modular workflows
- low maintenance overhead
- reusable automation

---

# Future Improvements

Potential future additions:

- shell telemetry
- dynamic runtime loading
- lazy-loaded workflows
- contextual aliases
- workspace-aware prompts
- runtime status indicators

Future features remain separated from the stable runtime layer.

