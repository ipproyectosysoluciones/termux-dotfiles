# AI Agent Orchestration Framework

> How agents and subagents are resolved, routed, and spawned across the AI workspace.

## Overview

The orchestration layer coordinates AI provider execution through a layered routing system. When a user prompt arrives, it flows through skill detection → capability routing → agent resolution → provider routing → subagent spawning.

```
prompt
  └─ skill_detector.sh → SKILL_MODE (e.g., sdd-apply, debugging, authoring)
        └─ capability_router.sh → INTENT_MODE (research | devops | coding | lightweight)
              └─ agent_registry.sh → AGENT_MODE (e.g., claude, mistral, opencode)
                    └─ agent_router.sh → PROVIDER (e.g., mistral, claude, gemini)
                          └─ orchestration.sh → coordinates multi-agent workflows
                                └─ subagent_registry.sh → resolves subagent capabilities
                                      └─ subagent_runtime.sh → spawns and manages subagents
```

## Core Modules

### orchestration.sh

The orchestration coordinator manages multi-agent workflows and session lifecycle.

**Responsibilities:**
- Coordinates concurrent agent execution
- Manages session state and context propagation
- Orchestrates subagent collaboration for complex tasks

**Key functions:**
- `orchestrate_agents()` — main entry point for multi-agent coordination
- `sync_agent_context()` — propagates context between agents
- `merge_agent_outputs()` — combines results from parallel agents

**Flow:**
```
user prompt (complex task)
  └─ orchestrate_agents() evaluates task complexity
        ├─ if simple: route directly to single agent
        └─ if complex: spawn parallel subagents
              └─ wait for results → merge → respond
```

---

### agent_registry.sh

Resolves agent identity from skill mode. Acts as the authoritative mapping between user intent and agent selection.

**Responsibilities:**
- Maps SKILL_MODE to AGENT_MODE
- Provides agent metadata (name, provider, capabilities)
- Supports agent fallbacks when primary is unavailable

**Key functions:**
- `resolve_agent()` — primary resolution function
- `list_agents()` — returns all registered agents
- `agent_capabilities()` — returns capability set for an agent

**Registered agents:** claude, gentle, gemini, mistral, opencode

**Example resolution:**
```
SKILL_MODE="sdd-apply" → resolve_agent("sdd-apply") → "claude"
SKILL_MODE="debugging" → resolve_agent("debugging") → "mistral"
```

---

### agent_router.sh

Routes agent to the appropriate AI provider. Maintains the definitive agent→provider mapping.

**Responsibilities:**
- Maps AGENT_MODE to PROVIDER
- Provides routing metadata for each agent

**Key functions:**
- `route_agent_provider()` — echoes provider name for given agent
- `list_routes()` — shows all agent→provider mappings

**Route table:**

| Agent | Provider | Notes |
|-------|----------|-------|
| claude | claude | Primary coding agent |
| gentle | gentle | GDE-focused agent |
| gemini | gemini | Fast fallback |
| mistral | mistral | Latest model, secondary fallback |
| opencode | opencode | Open source agent |

**Example:**
```bash
$ route_agent_provider "mistral"
mistral
```

---

### capability_router.sh

Routes skill intent to capability level. Determines whether a task needs heavy orchestration or lightweight execution.

**Responsibilities:**
- Classifies tasks by complexity (research, devops, coding, lightweight)
- Drives the ORCHESTRATION_MODE flag in ai.sh

**Key functions:**
- `route_capability()` — returns INTENT_MODE

**Capability levels:**

| Intent | Description | Orchestration |
|--------|-------------|---------------|
| research | Deep investigation, multi-source synthesis | Full orchestration |
| devops | Infrastructure, deployment, CI/CD | Moderate orchestration |
| coding | Implementation, debugging, refactoring | Light orchestration |
| lightweight | Quick edits, simple queries | Minimal overhead |

---

### subagent_registry.sh

Registry of available subagent capabilities. Used by orchestration.sh to determine which subagents to spawn for a given task.

**Responsibilities:**
- Defines subagent capability set
- Maps subagent to skills it can handle
- Provides subagent metadata for spawning

**Key functions:**
- `resolve_subagents()` — returns list of subagents for a task
- `subagent_capabilities()` — returns capability manifest
- `validate_subagent()` — checks if subagent is available

**Example subagent manifest:**
```
code-review: handles PR reviews, feedback synthesis
test-generation: creates tests from implementation
documentation: generates and updates docs
security-scan: identifies potential vulnerabilities
```

---

### subagent_runtime.sh

Spawns and manages subagent lifecycles. Handles process creation, monitoring, and result collection.

**Responsibilities:**
- Spawns subagent processes with proper environment
- Monitors subagent health and timeout
- Collects and aggregates subagent outputs

**Key functions:**
- `spawn_subagent()` — creates subagent process
- `monitor_subagent()` — watches subagent health
- `collect_subagent_results()` — aggregates outputs

**Spawn pattern:**
```bash
spawn_subagent "code-review" "$TASK_CONTEXT" "$TIMEOUT"
  └─ forks subagent process
       └─ subagent executes with inherited context
            └─ results piped back to orchestrator
```

---

## Data Flow: Prompt to Provider

```
1. User prompt arrives at ai.sh

2. Skill detection:
   SKILL_MODE="$(detect_skill "$PROMPT")"
   → e.g., "sdd-apply", "debugging", "authoring"

3. Capability routing:
   INTENT_MODE="$(route_capability "$SKILL_MODE")"
   → "coding", "research", "devops", "lightweight"

4. Agent resolution:
   AGENT_MODE="$(resolve_agent "$SKILL_MODE")"
   → "claude", "mistral", "opencode", etc.

5. Provider routing:
   PROVIDER="$(route_agent_provider "$AGENT_MODE")"
   → actual provider executable name

6. Orchestration decision:
   if [[ "$PROMPT" =~ production|platform|distributed|fullstack ]]; then
       ORCHESTRATION_MODE="true"
   fi

7. Runtime session:
   ai-runtime.sh receives PROVIDER + HYDRATED_PROMPT
   → run_provider "$PROVIDER" "$PROMPT"
```

## Orchestration Session Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                      SESSION START                          │
├─────────────────────────────────────────────────────────────┤
│ 1. ensure_runtime_session() — create tmux session if needed │
│ 2. runtime.env written with AI_PROJECT, AI_PROVIDER, etc.  │
│ 3. AI context propagated to subagent processes             │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   ORCHESTRATION BRANCH                       │
├──────────────────────┬──────────────────────────────────────┤
│   ORCHESTRATION=true │   ORCHESTRATION=false                 │
├──────────────────────┼──────────────────────────────────────┤
│ spawn multi-agent    │ route to single provider              │
│ coordinate results   │ run_provider "$PROVIDER" "$PROMPT"   │
└──────────────────────┴──────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      SESSION END                            │
│  - attach_runtime_session() to view results                │
│  - context saved to memory.sh for resume                    │
└─────────────────────────────────────────────────────────────┘
```

## Path Portability

All core modules use dynamic path detection to work from any installation location:

```bash
# Pattern used across all core modules:
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Sources resolve relative to BASE_DIR:
source "$BASE_DIR/core/registry.sh"
source "$BASE_DIR/core/router.sh"
```

This allows the AI workspace to be symlinked or installed to paths other than `$HOME/dotfiles/scripts/ai/`.

## Provider Fallback

See [Provider Architecture](provider-architecture.md#fallback-chain) for the authoritative fallback chain definition.

The `router.sh` `run_provider()` function routes to the selected provider's script. When a provider fails at runtime (e.g., `QUOTA_EXHAUSTED`), the provider script itself handles fallback to the next available provider in the chain.