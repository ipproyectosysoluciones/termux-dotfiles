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
├── ai.sh                    # main entry point
├── menu.sh                  # launcher menu
├── popup.sh                 # popup launcher
├── workspace.sh             # workspace launcher (templates)
├── sessions.sh              # session manager
├── utils.sh                 # shared utilities
├── ui.sh                    # UI layer (gum)
├── nvim.sh                  # NeoVim launcher
├── opencode.sh              # OpenCode launcher
├── gentle.sh                # Gentle AI launcher
├── engram.sh                # Engram launcher
├── core/                    # orchestration layer (29 modules)
│   ├── agent_context.sh    # agent context management
│   ├── agent_registry.sh   # agent resolution from skills
│   ├── agent_router.sh     # agent → provider routing
│   ├── capability_router.sh # skill-to-intent routing
│   ├── context.sh          # prompt context
│   ├── doctor.sh           # diagnostics
│   ├── executor.sh         # prompt execution
│   ├── hooks.sh            # lifecycle hooks
│   ├── hydration.sh        # state hydration
│   ├── intelligence.sh     # resume / last-session
│   ├── layout.sh           # tmux layout selection + apply
│   ├── memory.sh           # memory persistence
│   ├── metadata.sh         # workspace metadata
│   ├── orchestrator.sh     # orchestration coordinator
│   ├── paths.sh            # path utilities (Termux/Debian)
│   ├── policies.sh         # execution policies
│   ├── project.sh          # project detection
│   ├── provider_selector.sh # intent → provider mapping
│   ├── registry.sh         # skill registry
│   ├── routing.sh          # prompt routing
│   ├── runtime.sh          # runtime detection (mobile/remote/local)
│   ├── runtime_session.sh  # runtime session management
│   ├── session.sh          # session utilities
│   ├── skill_detector.sh   # skill detection from prompts
│   ├── skill_registry.sh   # available skills
│   ├── state.sh            # state management
│   ├── subagent_registry.sh # subagent registry
│   ├── subagent_runtime.sh # subagent spawning
│   └── workspace.sh        # workspace session management
├── providers/               # AI provider implementations (5)
│   ├── claude.sh           # Anthropic Claude
│   ├── gentle.sh           # Gentle AI
│   ├── gemini.sh           # Google Gemini
│   ├── mistral.sh          # Mistral AI
│   └── opencode.sh         # OpenCode
├── runtime/
│   └── ai-runtime.sh       # unified runtime entry point
└── templates/              # workspace layouts (4)
    ├── default.sh           # editor + claude + gemini
    ├── mobile.sh           # mobile-optimized layout
    ├── node.sh             # Node.js project layout
    └── remote.sh           # remote-optimized layout
```

## Core Orchestration Layer

The `core/` directory contains the agent/subagent framework:

- **orchestrator.sh** — Coordinates multi-agent sessions
- **agent_registry.sh** — Resolves agents from skills
- **subagent_registry.sh** — Registry for subagent definitions
- **subagent_runtime.sh** — Spawns and manages subagents
- **agent_router.sh** — Routes agent intents to providers
- **capability_router.sh** — Maps skills to intents (research, devops, coding, lightweight)

Data flow: `prompt → routing → capability_router → agent_registry → agent_router → orchestrator → subagent_registry → subagent_runtime`

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

| Runtime   | Session    |
| --------- | ---------- |
| NeoVim    | `nvim`     |
| OpenCode  | `opencode` |
| Gentle AI | `gentle`   |
| Engram    | `engram`   |

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
