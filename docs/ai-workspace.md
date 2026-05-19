# AI Workspace

## Overview

The AI workspace system provides a modular runtime environment for:

- NeoVim
- OpenCode
- Gentle AI
- Engram
- future AI runtimes

The system is optimized for:

- Termux
- tmux
- mobile workflows
- reusable sessions
- popup-driven navigation

---

# Goals

Main objectives:

- fast runtime switching
- reusable development sessions
- low-friction AI access
- mobile-first workflows
- popup-based orchestration

---

# Architecture

```text
scripts/ai/
├── menu.sh
├── popup.sh
├── workspace.sh
├── sessions.sh
├── utils.sh
├── ui.sh
├── nvim.sh
├── opencode.sh
├── gentle.sh
└── engram.sh
```

---

# Launcher System

The launcher system uses:

- gum
- tmux popup
- reusable tmux sessions

The launcher acts as the entry point for all AI workflows.

---

# Menu Launcher

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

# Popup Workflow

The popup launcher uses:

```bash
tmux display-popup
```

Benefits:

- non-destructive UI
- overlay navigation
- session preservation
- mobile-friendly interaction

---

# Runtime Sessions

Each AI runtime uses its own tmux session.

Examples:

| Runtime | Session |
|---|---|
| NeoVim | `nvim` |
| OpenCode | `opencode` |
| Gentle AI | `gentle` |
| Engram | `engram` |

---

# Session Lifecycle

Each launcher follows this flow:

1. verify session existence
2. create session if missing
3. attach or switch-client

This prevents duplicated sessions and nested tmux problems.

---

# Session Utilities

Shared logic is centralized in:

```text
scripts/ai/utils.sh
```

Main helpers:

- `session_exists`
- `create_session`
- `attach_or_switch`

---

# UI Layer

The UI layer uses:

```text
scripts/ai/ui.sh
```

Powered by:

- gum style
- gum choose

Responsibilities:

- banners
- sections
- visual consistency
- popup styling

---

# Mobile Optimization

The system avoids heavy pane usage.

Reason:

Small mobile screens reduce usability with large split layouts.

Preferred strategy:

- reusable sessions
- popup launchers
- fast switching
- isolated runtimes

---

# Full Workspace Mode

The workspace launcher can create multiple coordinated runtimes.

Current focus:

- lightweight orchestration
- reusable sessions
- minimal startup friction

---

# Session Management

Interactive session selector:

```bash
ai
→ Sessions
```

Powered by:

```bash
tmux ls
```

and:

```bash
gum choose
```

---

# Future Directions

Potential future improvements:

- session metadata
- workspace profiles
- AI provider switching
- runtime previews
- persistent AI state
- workspace templates

These features are intentionally separated from the current stable runtime.

---

# Design Philosophy

The AI workspace prioritizes:

- portability
- simplicity
- runtime isolation
- mobile usability
- low maintenance overhead

