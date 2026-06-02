# Delta Spec: AI-Workspace

## Change Overview

Fix documentation gaps, wire Mistral provider into runtime, implement workspace launcher, and replace hardcoded `$HOME/dotfiles/` paths with dynamic path detection across 4 phased batches.

---

## Phase 1 — Documentation Fix

### ADDED Requirements

### Requirement: ai-workspace-architecture-diagram

The file `docs/ai-workspace.md` SHALL display the complete `scripts/ai/` directory tree including all subdirectories: `core/`, `providers/`, `runtime/`, and `templates/`.

The system SHALL document the core orchestration layer in the architecture section.

#### Scenario: Architecture diagram shows full tree

- GIVEN `docs/ai-workspace.md` is being reviewed
- WHEN the reader examines the Architecture section
- THEN the diagram SHALL list all 10 top-level scripts AND all 29 core modules AND 5 providers AND 4 templates AND runtime

#### Scenario: Core orchestration layer is documented

- GIVEN `docs/ai-workspace.md` is being reviewed
- WHEN the reader examines the Architecture section
- THEN the core orchestration layer (orchestrator, agent_registry, subagent_registry, agent_router, capability_router) SHALL be referenced or diagrammed

### Requirement: provider-architecture-mistral-table

The file `docs/provider-architecture.md` SHALL list all five providers: claude, gentle, gemini, mistral, and opencode in the provider table.

#### Scenario: Mistral appears in provider table

- GIVEN `docs/provider-architecture.md` is being reviewed
- WHEN the reader examines the Current Providers table
- THEN Mistral SHALL appear with script path `scripts/ai/providers/mistral.sh` and a status indicator

#### Scenario: Fallback chain updated

- GIVEN `docs/provider-architecture.md` is being reviewed
- WHEN the reader examines the Fallback Chain section
- THEN the chain SHALL reflect the correct provider ordering including Mistral

### Affected Files (Phase 1)
- `docs/ai-workspace.md`
- `docs/provider-architecture.md`

### Verification Criteria (Phase 1)
- [ ] `docs/ai-workspace.md` architecture diagram shows `core/`, `providers/`, `runtime/`, `templates/` subdirectories
- [ ] `docs/provider-architecture.md` provider table lists all 5 providers (claude, gentle, gemini, mistral, opencode)
- [ ] Mistral row includes script path and status field

---

## Phase 2 — Runtime Wiring

### ADDED Requirements

### Requirement: ai-runtime-sources-mistral

The file `scripts/ai/runtime/ai-runtime.sh` SHALL source `mistral.sh` alongside the other provider scripts.

The system SHALL source mistral immediately after the existing provider sourcing block (after line 41).

#### Scenario: Mistral is sourced in ai-runtime.sh

- GIVEN `scripts/ai/runtime/ai-runtime.sh` is executed
- WHEN the runtime loads provider scripts
- THEN `source "$BASE_DIR/providers/mistral.sh"` SHALL be executed before `run_provider` is called

#### Scenario: AI_PROVIDER=mistral routes correctly

- GIVEN `AI_PROVIDER=mistral` is set and `ai-runtime.sh` is invoked with `mistral` as first argument
- WHEN `run_provider "mistral" "$PROMPT"` is called
- THEN the mistral case in `router.sh` SHALL execute `run_mistral`

### Requirement: agent-router-has-mistral-route

The file `scripts/ai/core/agent_router.sh` SHALL contain a mistral route in the `route_agent_provider` function.

The system SHALL echo "mistral" when the agent intent matches mistral routing criteria.

#### Scenario: Mistral route exists in agent_router

- GIVEN `scripts/ai/core/agent_router.sh` is sourced and `route_agent_provider` is called with a mistral-labeled agent
- WHEN the agent matches mistral routing criteria
- THEN the function SHALL echo "mistral" and return

### Requirement: workspace-launcher-implementation

The file `scripts/ai/workspace.sh` SHALL implement a functional launcher that coordinates the workspace template system.

The system SHALL source and coordinate multiple runtimes or use the template loader pattern from `templates/` directory.

#### Scenario: workspace.sh launches and coordinates templates

- GIVEN `scripts/ai/workspace.sh` is executed
- WHEN the script runs without arguments or with a template name
- THEN it SHALL load and apply a workspace template from `scripts/ai/templates/`

#### Scenario: workspace.sh is called from menu.sh

- GIVEN the user selects "Full Workspace" from `menu.sh`
- WHEN `~/dotfiles/scripts/ai/workspace.sh` is invoked
- THEN workspace.sh SHALL produce observable output or tmux session activity

### Affected Files (Phase 2)
- `scripts/ai/runtime/ai-runtime.sh`
- `scripts/ai/core/agent_router.sh`
- `scripts/ai/workspace.sh`

### Verification Criteria (Phase 2)
- [ ] `ai-runtime.sh` contains `source "$BASE_DIR/providers/mistral.sh"`
- [ ] `agent_router.sh` contains a mistral case in `route_agent_provider`
- [ ] `workspace.sh` is executable and produces observable output when run standalone
- [ ] `AI_PROVIDER=mistral ./ai-runtime.sh mistral "test"` does not error with "unknown provider"

---

## Phase 3 — Agent/Subagent Documentation

### ADDED Requirements

### Requirement: orchestration-framework-doc

The file `docs/orchestration.md` SHALL be created and SHALL document the agent/subagent orchestration layer.

The document SHALL explain: orchestrator.sh, agent_registry.sh, subagent_registry.sh, subagent_runtime.sh, agent_router.sh, and capability_router.sh.

#### Scenario: Orchestration doc covers agent framework

- GIVEN `docs/orchestration.md` is created
- WHEN a developer reads it
- THEN they SHALL understand the purpose and relationships of: orchestrator, agent registry, subagent registry, agent router, and capability router

#### Scenario: Orchestration doc covers subagent system

- GIVEN `docs/orchestration.md` is created
- WHEN a developer reads it
- THEN they SHALL understand how subagents are resolved from prompts and spawned via `subagent_runtime.sh`

#### Scenario: Orchestration doc covers capability routing

- GIVEN `docs/orchestration.md` is created
- WHEN a developer reads it
- THEN they SHALL understand how `route_capability` maps skills to intent (research, devops, coding, lightweight)

### Affected Files (Phase 3)
- `docs/orchestration.md` (new file)

### Verification Criteria (Phase 3)
- [ ] `docs/orchestration.md` exists
- [ ] File is non-empty (>100 lines)
- [ ] Mentions all 6 core orchestration modules by name
- [ ] Documents agent resolution flow from skill to provider

---

## Phase 4 — Path Hardcoding Fix

### ADDED Requirements

### Requirement: ai-sh-portable-path

The file `scripts/ai/ai.sh` SHALL use dynamic path detection instead of hardcoded `$HOME/dotfiles/` path.

The system SHALL detect its own location via `$(dirname "${BASH_SOURCE[0]}")` and derive `BASE_DIR` relative to the script location.

#### Scenario: ai.sh works from any installation path

- GIVEN `scripts/ai/ai.sh` is symlinked or installed to a path other than `$HOME/dotfiles/scripts/ai/`
- WHEN the script is executed
- THEN all `source` commands SHALL resolve correctly using dynamic path detection

### Requirement: ai-runtime-sh-portable-path

The file `scripts/ai/runtime/ai-runtime.sh` SHALL use dynamic path detection instead of hardcoded `$HOME/dotfiles/` path.

#### Scenario: ai-runtime.sh works from any installation path

- GIVEN `scripts/ai/runtime/ai-runtime.sh` is invoked from a working directory other than `$HOME`
- WHEN the script runs
- THEN `BASE_DIR` SHALL be derived from `$(dirname "${BASH_SOURCE[0]}")/../..`

### Requirement: router-sh-portable-paths

The file `scripts/ai/core/router.sh` SHALL use dynamic path detection for all provider sourcing.

The system SHALL source providers relative to the script's actual location, not hardcoded `$HOME/dotfiles/`.

#### Scenario: router.sh sources mistral correctly

- GIVEN `scripts/ai/core/router.sh` is sourced from `ai-runtime.sh`
- WHEN `run_provider "mistral" "$PROMPT"` is called
- THEN `mistral.sh` SHALL be sourced from the correct provider directory

### Requirement: menu-sh-portable-paths

The file `scripts/ai/menu.sh` SHALL use dynamic path detection for all referenced script paths.

The system SHALL resolve all `~/dotfiles/scripts/ai/...` paths to the actual script location.

#### Scenario: Menu options work from any path

- GIVEN the user launches `menu.sh` from an arbitrary directory
- WHEN they select any menu option
- THEN the correct script SHALL be invoked using dynamic path resolution

### Requirement: core-intelligence-sh-portable-path

The file `scripts/ai/core/intelligence.sh` SHALL use dynamic path detection for sourcing `state.sh`.

#### Scenario: intelligence.sh sources state.sh correctly

- GIVEN `scripts/ai/core/intelligence.sh` is sourced from `ai.sh`
- WHEN `resume_last_session` is called
- THEN `state.sh` SHALL be sourced from the correct relative path

### Requirement: core-layout-sh-portable-path

The file `scripts/ai/core/layout.sh` SHALL use dynamic path detection for template paths and sourcing `runtime.sh`.

#### Scenario: layout.sh resolves templates from any path

- GIVEN `scripts/ai/core/layout.sh` is executed
- WHEN `apply_layout` is called
- THEN `$HOME/dotfiles/scripts/ai/templates/${layout}.sh` SHALL be resolved relative to script location

### Requirement: core-workspace-sh-portable-paths

The file `scripts/ai/core/workspace.sh` SHALL use dynamic path detection for workspace database directory.

The system SHALL use `XDG_STATE_HOME` or `~/.local/state` conventions when available.

#### Scenario: workspace database location is configurable

- GIVEN the environment has `XDG_STATE_HOME` set
- WHEN `ensure_workspace` is called
- THEN `$WORKSPACE_DB` SHALL be set to `$XDG_STATE_HOME/ai/workspaces` instead of `$HOME/.ai/workspaces`

### MODIFIED Requirements

### Requirement: provider-selector-mistral-intent (MODIFIED)

The existing `provider_selector.sh` already has mistral routing intent. This requirement confirms it remains functional after path fixes.

#### Scenario: Provider selector routes to mistral

- GIVEN a prompt containing mistral-related keywords is processed
- WHEN `route_capability` and `resolve_agent` are called
- THEN the agent_router returns "mistral" and the runtime invokes `run_mistral`

### Affected Files (Phase 4)
- `scripts/ai/ai.sh`
- `scripts/ai/runtime/ai-runtime.sh`
- `scripts/ai/core/router.sh`
- `scripts/ai/menu.sh`
- `scripts/ai/core/intelligence.sh`
- `scripts/ai/core/layout.sh`
- `scripts/ai/core/workspace.sh`

### Verification Criteria (Phase 4)
- [ ] `ai.sh` contains no literal `$HOME/dotfiles/` (uses `BASH_SOURCE[0]` pattern)
- [ ] `ai-runtime.sh` contains no literal `$HOME/dotfiles/`
- [ ] `router.sh` sources all providers without hardcoded home paths
- [ ] `menu.sh` resolves all script paths dynamically
- [ ] `core/intelligence.sh` sources state.sh dynamically
- [ ] `core/layout.sh` resolves template paths dynamically
- [ ] `core/workspace.sh` uses `XDG_STATE_HOME` when available
- [ ] All modified files pass shellcheck with no SC2086 or SC1090 warnings on hardcoded paths

---

## Rollback Criteria

Each phase SHALL be independently revertable:

1. **Phase 1 rollback**: Restore `docs/ai-workspace.md` and `docs/provider-architecture.md` from git
2. **Phase 2 rollback**: Remove mistral sourcing from `ai-runtime.sh` (1 line), remove mistral case from `agent_router.sh` (5 lines), revert `workspace.sh` to 3-line stub
3. **Phase 3 rollback**: Delete `docs/orchestration.md`
4. **Phase 4 rollback**: Restore hardcoded `$HOME/dotfiles/` paths in all 7 affected files