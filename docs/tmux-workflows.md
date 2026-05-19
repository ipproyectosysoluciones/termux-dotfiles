# tmux Workflows

## Overview

tmux is the orchestration layer of the workstation.

Responsibilities include:

- persistent sessions
- AI runtime management
- popup launchers
- session switching
- mobile workflow optimization

The configuration is designed primarily for:

- Android
- Termux
- portable development
- low-friction multitasking

---

# Core Philosophy

The tmux workflow avoids:

- excessive pane fragmentation
- large static layouts
- deeply nested sessions

Instead, the system prioritizes:

- reusable sessions
- popup overlays
- fast navigation
- isolated runtimes

---

# Session Strategy

Each major workflow runs inside its own tmux session.

Examples:

| Session | Purpose |
|---|---|
| `nvim` | editor runtime |
| `opencode` | OpenCode runtime |
| `gentle` | Gentle AI runtime |
| `engram` | memory/runtime tools |

---

# Session Lifecycle

The launcher system follows this logic:

1. check if session exists
2. create session if missing
3. attach outside tmux
4. switch-client inside tmux

This prevents:

- nested tmux sessions
- duplicated runtimes
- attach conflicts

---

# Popup Launcher

The workspace uses:

```bash
tmux display-popup
```

This creates overlay interfaces without destroying the current layout.

Main launcher shortcut:

```text
PREFIX + m
```

---

# Popup Benefits

Popup workflows improve mobile usability.

Advantages:

- minimal context switching
- overlay navigation
- preserved layouts
- cleaner multitasking

Especially useful on:

- phones
- tablets
- small terminal windows

---

# AI Launcher

The popup launcher provides access to:

- NeoVim
- OpenCode
- Gentle AI
- Engram
- session manager

Main commands:

```bash
ai
aip
```

---

# Session Switching

Inside tmux:

```bash
tmux switch-client -t SESSION
```

Outside tmux:

```bash
tmux attach -t SESSION
```

This logic is centralized in:

```text
scripts/ai/utils.sh
```

---

# Mobile Optimization

Large pane layouts are intentionally avoided.

Reason:

Mobile screens become difficult to manage with multiple simultaneous panes.

Preferred approach:

- one runtime per session
- popup launchers
- quick session switching

---

# Session Discovery

Current sessions can be viewed with:

```bash
tmux ls
```

Interactive selection uses:

- gum choose
- popup launcher integration

---

# Recommended Workflows

## Editing

```text
ai → NeoVim
```

---

## AI Runtime

```text
ai → OpenCode
```

or:

```text
ai → Gentle AI
```

---

## Runtime Switching

```text
PREFIX + m
```

Then select target runtime.

---

# Configuration

Main configuration file:

```text
tmux/tmux.conf
```

Responsibilities:

- keybindings
- popup launcher
- visual behavior
- workflow shortcuts

---

# Current Design Goals

- lightweight orchestration
- mobile-first UX
- reusable runtime sessions
- minimal startup friction
- stable popup navigation

---

# Future Improvements

Potential future additions:

- session metadata
- popup previews
- runtime status indicators
- workspace templates
- session persistence
- dynamic layouts

Future features are intentionally separated from the stable runtime layer.

