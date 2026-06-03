# SDD Spec: Test-Apply (AI Workspace TDD Coverage)

## Change ID
`Test-Apply`

## Intent
Create comprehensive TDD tests for the entire AI Workspace framework (`scripts/ai/`), fixing bugs discovered during exploration and establishing systematic testing practice that catches regressions before production.

**Problem being solved**: The AI Workspace framework has 30+ core modules, 5 providers, and multiple launcher scripts — yet test coverage is severely incomplete. Critical bugs (hardcoded paths, failing docs) exist undetected.

---

## Specification

### Conventions

- **RFC 2119 keywords**: MUST, SHALL, SHOULD, MAY denote requirement levels
- **Scenario format**: Given/When/Then for all test specifications
- **Test framework**: bats (Bash Automated Testing System)
- **Test location**: `tests/` directory with phase subdirectories

---

## Phase 1 — Core Module Tests (CRITICAL)

### 1.1 `project.sh` Tests

#### 1.1.1 `detect_project` function

**Requirement**: `detect_project` MUST traverse parent directories to find project root via git/package managers.

**Scenario: Git project detection**
```
Given a directory structure with .git at /project/root/.git
When calling detect_project from /project/root/subdir/nested
Then output SHALL be "/project/root"
```

**Scenario: Node project detection**
```
Given /project has package.json at /project/package.json (no .git)
When calling detect_project from /project/src
Then output SHALL be "/project"
```

**Scenario: Docker project detection**
```
Given /project has docker-compose.yml at /project/docker-compose.yml
When calling detect_project from any subdirectory of /project
Then output SHALL be "/project"
```

**Scenario: Rust project detection**
```
Given /project has Cargo.toml at /project/Cargo.toml
When calling detect_project from /project/src/bin
Then output SHALL be "/project"
```

**Scenario: Python project detection**
```
Given /project has requirements.txt at /project/requirements.txt
When calling detect_project from /project/tests/unit
Then output SHALL be "/project"
```

**Scenario: Falls back to PWD when no project marker found**
```
Given no .git, package.json, docker-compose.yml, Cargo.toml, or requirements.txt exists in parent tree
When calling detect_project from /orphan/dir
Then output SHALL be "/orphan/dir"
```

#### 1.1.2 `project_name` function

**Requirement**: `project_name` MUST extract basename from path argument.

**Scenario: Basic extraction**
```
Given path "/home/user/my-project"
When calling project_name with that path
Then output SHALL be "my-project"
```

**Scenario: Root directory**
```
Given path "/"
When calling project_name with that path
Then output SHALL be ""
```

#### 1.1.3 `project_type` function

**Requirement**: `project_type` MUST detect project type from marker files.

**Scenario: Node project**
```
Given directory /project with package.json
When calling project_type "/project"
Then output SHALL be "node"
```

**Scenario: Rust project**
```
Given directory /project with Cargo.toml
When calling project_type "/project"
Then output SHALL be "rust"
```

**Scenario: Python project**
```
Given directory /project with requirements.txt
When calling project_type "/project"
Then output SHALL be "python"
```

**Scenario: Docker project**
```
Given directory /project with docker-compose.yml
When calling project_type "/project"
Then output SHALL be "docker"
```

**Scenario: Generic project**
```
Given directory /project with no recognized marker files
When calling project_type "/project"
Then output SHALL be "generic"
```

#### 1.1.4 `git_branch` function

**Requirement**: `git_branch` MUST return current git branch name or "no-git" if not a git repo.

**Scenario: Git repo with branch**
```
Given a git repository at /project with current branch "main"
When calling git_branch "/project"
Then output SHALL be "main"
```

**Scenario: Not a git repo**
```
Given /project is not a git repository
When calling git_branch "/project"
Then output SHALL be "no-git"
```

---

### 1.2 `runtime.sh` Tests

#### 1.2.1 `detect_runtime` function

**Requirement**: `detect_runtime` MUST return "mobile", "remote", or "local" based on environment.

**Scenario: Mobile detection via Termux directory**
```
Given /data/data/com.termux directory exists
When calling detect_runtime
Then output SHALL be "mobile"
```

**Scenario: Remote detection via SSH_CONNECTION**
```
Given SSH_CONNECTION variable is set to "192.168.1.100 12345 10.0.0.1 22"
When calling detect_runtime
Then output SHALL be "remote"
```

**Scenario: Default to local**
```
Given /data/data/com.termux does not exist
And SSH_CONNECTION is not set
When calling detect_runtime
Then output SHALL be "local"
```

#### 1.2.2 `detect_tmux_mode` function

**Requirement**: `detect_tmux_mode` MUST return "nested" or "standalone" based on TMUX variable.

**Scenario: Nested tmux session**
```
Given TMUX variable is set to "12345,1234,0"
When calling detect_tmux_mode
Then output SHALL be "nested"
```

**Scenario: No tmux**
```
Given TMUX variable is empty or unset
When calling detect_tmux_mode
Then output SHALL be "standalone"
```

#### 1.2.3 `detect_network` function

**Requirement**: `detect_network` MUST return "online" or "offline" based on connectivity.

**Scenario: Online connectivity**
```
Given ping to 1.1.1.1 succeeds
When calling detect_network
Then output SHALL be "online"
```

**Scenario: Offline (mocked via test environment)**
```
Given ping to 1.1.1.1 fails
When calling detect_network
Then output SHALL be "offline"
```

---

### 1.3 `state.sh` Tests

#### 1.3.1 `save_current_workspace` function

**Requirement**: `save_current_workspace` MUST write workspace state to `$STATE_DIR/current_workspace`.

**Scenario: Save workspace with all parameters**
```
Given STATE_DIR="/tmp/test-state"
And session="test-session", project="test-project", root="/tmp/test", type="node", branch="main", layout="default"
When calling save_current_workspace with those parameters
Then file /tmp/test-state/current_workspace SHALL contain:
  SESSION_NAME="test-session"
  PROJECT_NAME="test-project"
  PROJECT_ROOT="/tmp/test"
  PROJECT_TYPE="node"
  GIT_BRANCH="main"
  LAYOUT="default"
  UPDATED_AT="[0-9]+"
```

#### 1.3.2 `load_current_workspace` function

**Requirement**: `load_current_workspace` MUST source the state file and return 0 on success, 1 if file missing.

**Scenario: Load existing workspace**
```
Given STATE_DIR="/tmp/test-state"
And /tmp/test-state/current_workspace exists with valid state
When calling load_current_workspace
Then return value SHALL be 0
And variables SESSION_NAME, PROJECT_NAME, PROJECT_ROOT, PROJECT_TYPE, GIT_BRANCH, LAYOUT SHALL be set
```

**Scenario: Missing state file**
```
Given /tmp/test-state/current_workspace does not exist
When calling load_current_workspace
Then return value SHALL be 1
```

#### 1.3.3 `clear_current_workspace` function

**Requirement**: `clear_current_workspace` MUST remove the state file.

**Scenario: Clear workspace state**
```
Given /tmp/test-state/current_workspace exists
When calling clear_current_workspace
Then /tmp/test-state/current_workspace SHALL NOT exist
```

---

### 1.4 `memory.sh` Tests

#### 1.4.1 `memory_available` function

**Requirement**: `memory_available` MUST return 0 if engram command exists, 1 otherwise.

**Scenario: Engram available**
```
Given engram command exists in PATH
When calling memory_available
Then return value SHALL be 0
```

**Scenario: Engram not available**
```
Given engram command does not exist in PATH
When calling memory_available
Then return value SHALL be 1
```

#### 1.4.2 `memory_project_context` function

**Requirement**: `memory_project_context` MUST call engram context with project name when available.

**Scenario: With project and engram available**
```
Given engram command exists
And project="my-project"
When calling memory_project_context "my-project"
Then engram context "my-project" SHALL be invoked
```

**Scenario: Engram not available**
```
Given engram command does not exist
When calling memory_project_context "my-project"
Then function SHALL return 0 without error
```

**Scenario: Empty project name**
```
Given project=""
When calling memory_project_context ""
Then function SHALL return 0 without calling engram
```

#### 1.4.3 `memory_search` function

**Requirement**: `memory_search` MUST call engram search with query and project, limit 5.

**Scenario: Valid search with engram**
```
Given engram command exists
And query="authentication", project="my-project"
When calling memory_search "authentication" "my-project"
Then engram search "authentication" --project "my-project" --limit 5 SHALL be invoked
```

**Scenario: Empty query**
```
Given query=""
When calling memory_search ""
Then function SHALL return 0 without calling engram
```

#### 1.4.4 `memory_save` function

**Requirement**: `memory_save` MUST call engram save with title, content, project scope.

**Scenario: Valid save with engram**
```
Given engram command exists
And title="session", content="user login at 10am", project="my-project"
When calling memory_save "session" "user login at 10am" "my-project"
Then engram save "session" "user login at 10am" --project "my-project" --scope project SHALL be invoked
```

**Scenario: Empty content**
```
Given content=""
When calling memory_save "title" ""
Then function SHALL return 0 without calling engram
```

---

### 1.5 `hydration.sh` Tests

#### 1.5.1 `build_context` function

**Requirement**: `build_context` MUST compose context from memory, project info, and branch.

**Scenario: Build context with memory and project**
```
Given MEMORY_CONTEXT="previous conversation about auth"
And AI_PROJECT="my-project"
And PROJECT_NAME="my-project"
And GIT_BRANCH="feature/auth"
When calling build_context "user request about login"
Then output SHALL include:
  "Project: my-project"
  "Branch: feature/auth"
  "Relevant memory:" section
  "User request:" section
```

**Scenario: Build context without memory**
```
Given memory_search returns empty
And AI_PROJECT="", PROJECT_NAME="unknown"
When calling build_context "simple request"
Then output SHALL include "Relevant memory:" (possibly empty)
And SHALL include "User request: simple request"
```

---

### 1.6 `sync.sh` Tests

#### 1.6.1 `sync_project_path` function

**Requirement**: `sync_project_path` MUST return path within SYNC_ROOT for given project.

**Scenario: Project path generation**
```
Given SYNC_ROOT="/tmp/sync"
When calling sync_project_path "my-project"
Then output SHALL be "/tmp/sync/my-project"
```

#### 1.6.2 `mirror_project` function

**Requirement**: `mirror_project` MUST copy source project to sync directory.

**Scenario: Mirror project creates target directory**
```
Given SYNC_ROOT="/tmp/sync"
And source="/project/src" with files
When calling mirror_project "/project/src" "my-project"
Then /tmp/sync/my-project SHALL exist
And contents SHALL match source
```

#### 1.6.3 `provider_workspace` function

**Requirement**: `provider_workspace` MUST return workspace path for provider execution.

**Scenario: Provider workspace path**
```
Given DEBIAN_WORKSPACE_ROOT="/home/dev/workspaces"
When calling provider_workspace "my-project"
Then output SHALL be "/home/dev/workspaces/my-project"
```

#### 1.6.4 `ensure_sync_root` function

**Requirement**: `ensure_sync_root` MUST create SYNC_ROOT directory if not exists.

**Scenario: Create sync root**
```
Given SYNC_ROOT="/tmp/new-sync-root"
And directory does not exist
When calling ensure_sync_root
Then /tmp/new-sync-root SHALL be created
```

---

### 1.7 `provider_selector.sh` Tests

#### 1.7.1 `select_provider` function

**Requirement**: `select_provider` MUST route to provider based on intent, falling back to opencode.

**Scenario: Research intent with gemini available**
```
Given provider_available gemini returns 0
When calling select_provider "generic" "mobile" "lightweight" "research"
Then output SHALL be "gemini"
```

**Scenario: Research intent with gemini unavailable**
```
Given provider_available gemini returns 1
When calling select_provider "generic" "mobile" "lightweight" "research"
Then output SHALL be "opencode"
```

**Scenario: Architecture intent routes to gemini**
```
Given provider_available gemini returns 0
When calling select_provider "generic" "local" "balanced" "architecture"
Then output SHALL be "gemini"
```

**Scenario: Devops intent routes to opencode**
```
Given provider_available opencode returns 0
When calling select_provider "generic" "local" "balanced" "devops"
Then output SHALL be "opencode"
```

**Scenario: Coding intent routes to opencode**
```
Given provider_available opencode returns 0
When calling select_provider "node" "mobile" "lightweight" "coding"
Then output SHALL be "opencode"
```

**Scenario: Mistral intent routes to mistral**
```
Given provider_available mistral returns 0
When calling select_provider "python" "local" "balanced" "mistral"
Then output SHALL be "mistral"
```

**Scenario: Mistral intent falls back to opencode**
```
Given provider_available mistral returns 1
When calling select_provider "python" "local" "balanced" "mistral"
Then output SHALL be "opencode"
```

**Scenario: Unknown intent defaults to opencode**
```
Given provider_available gemini returns 1
And provider_available opencode returns 0
When calling select_provider "generic" "local" "lightweight" "unknown-intent"
Then output SHALL be "opencode"
```

---

### 1.8 `agent_router.sh` Tests

#### 1.8.1 `route_agent_provider` function

**Requirement**: `route_agent_provider` MUST route agent to appropriate provider.

**Scenario: RAG agent routes to gemini**
```
When calling route_agent_provider "rag-agent"
Then output SHALL be "gemini"
```

**Scenario: Kubernetes agent routes to opencode**
```
When calling route_agent_provider "kubernetes-agent"
Then output SHALL be "opencode"
```

**Scenario: MERN agent routes to claude**
```
When calling route_agent_provider "mern-agent"
Then output SHALL be "claude"
```

**Scenario: Terminal agent routes to opencode**
```
When calling route_agent_provider "terminal-agent"
Then output SHALL be "opencode"
```

**Scenario: Editor agent routes to claude**
```
When calling route_agent_provider "editor-agent"
Then output SHALL be "claude"
```

**Scenario: Mistral agent routes to mistral**
```
When calling route_agent_provider "mistral"
Then output SHALL be "mistral"
```

**Scenario: Unknown agent defaults to opencode**
```
When calling route_agent_provider "unknown-agent"
Then output SHALL be "opencode"
```

---

### 1.9 `skill_detector.sh` Tests

#### 1.9.1 `detect_skill` function

**Requirement**: `detect_skill` MUST detect skill from prompt keywords (case-insensitive).

**Scenario: RAG skill detection**
```
When calling detect_skill "help me set up RAG pipeline"
Then output SHALL be "rag-research"
```

**Scenario: Kubernetes skill detection**
```
When calling detect_skill "deploy to kubernetes cluster"
Then output SHALL be "k8s-devops"
```

**Scenario: MERN skill detection**
```
When calling detect_skill "build react node application"
Then output SHALL be "mern-engineer"
```

**Scenario: TMUX skill detection**
```
When calling detect_skill "create tmux session for workspace"
Then output SHALL be "terminal-automation"
```

**Scenario: Neovim skill detection**
```
When calling detect_skill "configure nvim with treesitter"
Then output SHALL be "editor-engineering"
```

**Scenario: Default skill for unrecognized prompts**
```
When calling detect_skill "simple task request"
Then output SHALL be "general"
```

---

### 1.10 `skill_registry.sh` Tests

#### 1.10.1 `load_skill_registry` function

**Requirement**: `load_skill_registry` MUST return 0 and cat registry file, or return 1 if missing.

**Scenario: Registry exists**
```
Given SKILL_REGISTRY_FILE="/tmp/registry.md"
And file contains "## rag-research\nSkill for RAG"
When calling load_skill_registry
Then output SHALL be contents of file
And return value SHALL be 0
```

**Scenario: Registry missing**
```
Given SKILL_REGISTRY_FILE="/tmp/nonexistent.md"
When calling load_skill_registry
Then return value SHALL be 1
```

#### 1.10.2 `skill_exists` function

**Requirement**: `skill_exists` MUST return 0 if skill found in registry, 1 otherwise.

**Scenario: Skill exists in registry**
```
Given SKILL_REGISTRY_FILE="/tmp/registry.md" containing "rag-research"
When calling skill_exists "rag-research"
Then return value SHALL be 0
```

**Scenario: Skill not in registry**
```
Given SKILL_REGISTRY_FILE="/tmp/registry.md" not containing "unknown-skill"
When calling skill_exists "unknown-skill"
Then return value SHALL be 1
```

**Scenario: Empty skill name**
```
When calling skill_exists ""
Then return value SHALL be 1
```

#### 1.10.3 `list_skills` function

**Requirement**: `list_skills` MUST list all skills (## headers) from registry.

**Scenario: List all skills**
```
Given SKILL_REGISTRY_FILE="/tmp/registry.md" containing:
  ## rag-research
  ## k8s-devops
  ## mern-engineer
When calling list_skills
Then output SHALL contain:
  rag-research
  k8s-devops
  mern-engineer
```

---

## Phase 2 — Provider Tests (HIGH)

### 2.1 `gemini.sh` Tests

#### 2.1.1 `run_gemini` function

**Requirement**: `run_gemini` MUST execute gemini with prompt and handle fallbacks.

**Scenario: Successful gemini execution**
```
Given gemini command succeeds with output "AI response"
When calling run_gemini "user prompt"
Then output SHALL be "AI response"
And return value SHALL be 0
```

**Scenario: QUOTA_EXHAUSTED triggers fallback to opencode**
```
Given gemini output contains "QUOTA_EXHAUSTED"
And run_opencode returns "fallback response"
When calling run_gemini "user prompt"
Then output SHALL include "[ai] gemini quota exhausted"
And output SHALL include "[ai] falling back to opencode"
And final output SHALL include "fallback response"
```

**Scenario: Non-zero exit triggers fallback to gentle**
```
Given gemini exits with status 1 and no output
When calling run_gemini "user prompt"
Then output SHALL include "[ai] gemini failed"
And output SHALL include "[ai] falling back to gentle"
```

**Scenario: Missing GEMINI_API_KEY handling**
```
Given GEMINI_API_KEY is not set
When calling run_gemini "user prompt"
Then output SHALL indicate missing credentials or fallback
```

---

### 2.2 `claude.sh` Tests

#### 2.2.1 `run_claude` function

**Requirement**: `run_claude` MUST execute claude with prompt and proper env vars.

**Scenario: Successful claude execution**
```
Given claude binary exists and responds to prompt
When calling run_claude "write tests for auth"
Then claude SHALL be invoked with "write tests for auth"
And CLAUDE_PROJECT, CLAUDE_AGENT, CLAUDE_SKILL, CLAUDE_WORKSPACE env vars SHALL be set
```

**Scenario: Missing claude binary**
```
Given claude binary does not exist
When calling run_claude "some prompt"
Then output SHALL indicate "command not found" or similar
And return value SHALL be non-zero
```

---

### 2.3 `opencode.sh` Tests

#### 2.3.1 `run_opencode` function

**Requirement**: `run_opencode` MUST execute opencode with prompt.

**Scenario: Successful opencode execution**
```
Given opencode binary exists
When calling run_opencode "analyze this codebase"
Then opencode run "analyze this codebase" SHALL be executed
```

**Scenario: Missing opencode binary**
```
Given opencode is not in PATH
When calling run_opencode "some prompt"
Then output SHALL be "[ai] opencode unavailable"
And return value SHALL be 1
```

---

### 2.4 `gentle.sh` Tests

#### 2.4.1 `gentle_sync` function

**Requirement**: `gentle_sync` MUST run gentle-ai sync when available.

**Scenario: Sync available**
```
Given gentle-ai binary exists
When calling gentle_sync
Then gentle-ai sync SHALL be executed
And return value SHALL be 0
```

**Scenario: gentle-ai unavailable**
```
Given gentle-ai binary does not exist
When calling gentle_sync
Then output SHALL be "[ai] gentle-ai unavailable"
And return value SHALL be 1
```

#### 2.4.2 `gentle_upgrade` function

**Requirement**: `gentle_upgrade` MUST run gentle-ai upgrade when available.

**Scenario: Upgrade available**
```
Given gentle-ai binary exists
When calling gentle_upgrade
Then gentle-ai upgrade SHALL be executed
```

**Scenario: gentle-ai unavailable**
```
Given gentle-ai binary does not exist
When calling gentle_upgrade
Then output SHALL be "[ai] gentle-ai unavailable"
```

#### 2.4.3 `gentle_refresh_skills` function

**Requirement**: `gentle_refresh_skills` MUST run gentle-ai skill-registry refresh.

**Scenario: Refresh available**
```
Given gentle-ai binary exists
When calling gentle_refresh_skills
Then gentle-ai skill-registry refresh SHALL be executed
```

**Scenario: gentle-ai unavailable**
```
Given gentle-ai binary does not exist
When calling gentle_refresh_skills
Then output SHALL be "[ai] gentle-ai unavailable"
```

---

## Phase 3 — Integration Tests (HIGH)

### 3.1 `ai.sh` Main Entry Point Tests

#### 3.1.1 Bootstrap loading

**Requirement**: `ai.sh` MUST source all core modules without errors.

**Scenario: All core modules source successfully**
```
Given all core modules exist at expected paths
When sourcing ai.sh
Then all 30+ source commands SHALL complete without error
```

#### 3.1.2 Project detection integration

**Requirement**: `ai.sh` MUST detect project and set PROJECT_ROOT, PROJECT_NAME, PROJECT_TYPE, GIT_BRANCH.

**Scenario: Node project detected**
```
Given current directory is inside a node project with package.json
When executing ai.sh with any arguments
Then PROJECT_ROOT, PROJECT_NAME, PROJECT_TYPE, GIT_BRANCH SHALL be set
And output SHALL include "[ai] project : <name>"
And output SHALL include "[ai] type    : node"
```

#### 3.1.3 Runtime detection integration

**Requirement**: `ai.sh` MUST detect runtime mode and set RUNTIME_MODE, NETWORK_MODE, TMUX_MODE.

**Scenario: Runtime detection produces output**
```
Given detect_runtime returns "local"
And detect_network returns "online"
And detect_tmux_mode returns "standalone"
When executing ai.sh "test prompt"
Then output SHALL include:
  "[ai] runtime : local"
  "[ai] network : online"
  "[ai] tmux    : standalone"
```

#### 3.1.4 Intent routing integration

**Requirement**: `ai.sh` MUST route intent based on skill detection.

**Scenario: Intent routing from prompt**
```
Given prompt contains "kubernetes"
When executing ai.sh "deploy to kubernetes"
Then SKILL_MODE SHALL be "k8s-devops"
And INTENT_MODE SHALL be "devops"
And output SHALL include "[ai] intent  : devops"
```

#### 3.1.5 Agent resolution integration

**Requirement**: `ai.sh` MUST resolve agent and route to provider.

**Scenario: Agent routes to provider**
```
Given skill "k8s-devops" resolves to "kubernetes-agent"
When executing ai.sh "k8s deployment"
Then AGENT_MODE SHALL be "kubernetes-agent"
And PROVIDER SHALL be "opencode"
And output SHALL include "[ai] provider : opencode"
```

#### 3.1.6 Doctor command
**Requirement**: `ai.sh` MUST execute run_doctor when first arg is "doctor".

**Scenario: Doctor invocation**
```
Given ai.sh is executable
When running ai.sh doctor
Then run_doctor SHALL be called
And script SHALL exit 0
```

#### 3.1.7 Resume command
**Requirement**: `ai.sh` MUST execute resume_last_session when first arg is "resume".

**Scenario: Resume invocation**
```
Given ai.sh is executable
When running ai.sh resume
Then resume_last_session SHALL be called
And script SHALL exit 0
```

---

### 3.2 `router.sh` Integration Tests

#### 3.2.1 `run_provider` function

**Requirement**: `run_provider` MUST dispatch to correct provider function.

**Scenario: Dispatch to opencode**
```
Given run_opencode is mocked
When calling run_provider "opencode" "test prompt"
Then run_opencode run "test prompt" SHALL be invoked
```

**Scenario: Dispatch to gemini**
```
Given run_gemini is mocked
When calling run_provider "gemini" "test prompt"
Then run_gemini "test prompt" SHALL be invoked
```

**Scenario: Dispatch to claude**
```
Given run_claude is mocked
When calling run_provider "claude" "test prompt"
Then run_claude "test prompt" SHALL be invoked
```

**Scenario: Dispatch to mistral**
```
Given run_mistral is mocked
When calling run_provider "mistral" "test prompt"
Then run_mistral "test prompt" SHALL be invoked
```

**Scenario: Unknown provider returns error**
```
When calling run_provider "unknown-provider" "test"
Then output SHALL be "[ai] unknown provider: unknown-provider"
And return value SHALL be 1
```

---

## Phase 4 — Launcher & Template Tests (MEDIUM)

### 4.1 `menu.sh` Tests

#### 4.1.1 Menu options invocation

**Requirement**: `menu.sh` MUST invoke correct script for each menu choice.

**Scenario: NeoVim choice invokes nvim.sh**
```
Given gum is available
And SCRIPT_DIR is correctly detected
When menu.sh is run with NeoVim selected
Then $SCRIPT_DIR/nvim.sh SHALL be invoked
```

**Scenario: OpenCode choice invokes opencode.sh**
```
Given gum is available
When menu.sh is run with OpenCode selected
Then $SCRIPT_DIR/opencode.sh SHALL be invoked
```

**Scenario: Gentle AI choice invokes gentle.sh**
```
Given gum is available
When menu.sh is run with "Gentle AI" selected
Then $SCRIPT_DIR/gentle.sh SHALL be invoked
```

**Scenario: Exit choice exits cleanly**
```
Given gum is available
When menu.sh is run with Exit selected
Then script SHALL exit 0
```

---

### 4.2 `utils.sh` Tests

#### 4.2.1 `session_exists` function

**Requirement**: `session_exists` MUST return 0 if tmux session exists, 1 otherwise.

**Scenario: Session exists**
```
Given tmux has session "test-session"
When calling session_exists "test-session"
Then return value SHALL be 0
```

**Scenario: Session does not exist**
```
Given tmux has no session "nonexistent"
When calling session_exists "nonexistent"
Then return value SHALL be 1
```

#### 4.2.2 `attach_or_switch` function

**Requirement**: `attach_or_switch` MUST attach or switch to session based on TMUX variable.

**Scenario: Inside tmux session switches client**
```
Given TMUX variable is set
And tmux session "other-session" exists
When calling attach_or_switch "other-session"
Then tmux switch-client -t "other-session" SHALL be executed
```

**Scenario: Outside tmux attaches to session**
```
Given TMUX variable is empty
And tmux session "my-session" exists
When calling attach_or_switch "my-session"
Then tmux attach -t "my-session" SHALL be executed
```

#### 4.2.3 `create_session` function

**Requirement**: `create_session` MUST create tmux session if not exists, optionally send command.

**Scenario: Creates new session**
```
Given session "new-session" does not exist
When calling create_session "new-session" "ls"
Then tmux new-session -d -s "new-session" SHALL be executed
And tmux send-keys -t "new-session" "ls" C-m SHALL be executed
```

**Scenario: Does not recreate existing session**
```
Given tmux session "existing-session" exists
When calling create_session "existing-session" "echo hi"
Then tmux new-session SHALL NOT be called
```

---

### 4.3 Template Tests

#### 4.3.1 `default.sh` build_layout

**Requirement**: `build_layout` MUST create 4 windows: shell, editor, claude, gemini.

**Scenario: Default layout creates windows**
```
Given tmux session "test" exists
When calling build_layout "test"
Then tmux SHALL have window "editor" running nvim
And tmux SHALL have window "claude" running claude
And tmux SHALL have window "gemini" running gemini
And focus SHALL be on editor window
```

#### 4.3.2 `mobile.sh` build_layout

**Requirement**: `build_layout` MUST create minimal mobile layout: editor and claude.

**Scenario: Mobile layout creates minimal windows**
```
Given tmux session "mobile-test" exists
When calling build_layout "mobile-test"
Then tmux SHALL have window "editor" running nvim
And tmux SHALL have window "claude" running claude
And focus SHALL be on editor window
```

#### 4.3.3 `node.sh` build_layout

**Requirement**: `build_layout` MUST create node-optimized layout: server, editor, claude, gemini.

**Scenario: Node layout with dev server**
```
Given tmux session "node-test" exists
When calling build_layout "node-test"
Then tmux SHALL have window "server" running "pnpm dev"
And tmux SHALL have window "editor" running nvim
And tmux SHALL have window "claude" running claude
And tmux SHALL have window "gemini" running gemini
```

#### 4.3.4 `remote.sh` build_layout

**Requirement**: `build_layout` MUST create minimal remote layout: shell and editor.

**Scenario: Remote layout for SSH**
```
Given tmux session "remote-test" exists
When calling build_layout "remote-test"
Then tmux SHALL have window "shell"
And tmux SHALL have window "editor" running nvim
And focus SHALL be on editor window
```

---

### 4.4 `workspace.sh` Tests

#### 4.4.1 Template selection

**Requirement**: `workspace.sh` MUST auto-detect template based on runtime when no argument given.

**Scenario: Mobile runtime selects mobile template**
```
Given detect_runtime returns "mobile"
And no template argument provided
When executing workspace.sh
Then TEMPLATE variable SHALL be "mobile"
```

**Scenario: Node project auto-detection**
```
Given detect_runtime returns "local"
And runtime matches "node" pattern
When executing workspace.sh
Then TEMPLATE variable SHALL be "node"
```

**Scenario: Default template for unknown runtime**
```
Given detect_runtime returns "local"
And no specific template matches
When executing workspace.sh
Then TEMPLATE variable SHALL be "default"
```

---

## Phase 5 — Error Path Tests (MEDIUM)

### 5.1 Empty prompt handling

**Requirement**: `ai.sh` MUST handle empty prompt gracefully.

**Scenario: Empty prompt does not crash**
```
Given PROMPT is empty
When executing ai.sh with no arguments
Then ai.sh SHALL NOT crash
And output SHALL show header with empty user request section
```

---

### 5.2 Missing .env file

**Requirement**: Providers MUST handle missing .env gracefully without sourcing errors.

**Scenario: Provider sources missing .env**
```
Given .env file does not exist
When sourcing provider script
Then script SHALL NOT error on missing .env
And provider variables SHALL have defaults
```

---

### 5.3 TMUX unavailable

**Requirement**: Scripts MUST handle tmux not being available.

**Scenario: tmux command not found**
```
Given tmux is not installed
When calling session_exists "test"
Then function SHALL return 1
```

**Scenario: TMUX not available during ai.sh execution**
```
Given tmux binary does not exist
When executing ai.sh "test prompt"
Then script SHALL handle gracefully or exit with clear error
```

---

### 5.4 Network offline

**Requirement**: `detect_network` MUST return "offline" when network unavailable.

**Scenario: Network offline detection**
```
Given network connectivity fails (mocked)
When calling detect_network
Then output SHALL be "offline"
```

---

### 5.5 Provider binary missing

**Requirement**: Fallback chains MUST work when primary provider unavailable.

**Scenario: opencode unavailable triggers gentle fallback**
```
Given opencode binary does not exist
When calling run_provider "opencode" "test"
Then fallback to gentle SHALL be attempted
```

---

### 5.6 Malformed project directories

**Requirement**: `detect_project` MUST handle edge cases gracefully.

**Scenario: Circular symlink protection**
```
Given directory structure has circular references
When calling detect_project from deeply nested location
Then function SHALL complete without infinite loop
And SHALL return some valid path
```

**Scenario: Permission denied on directories**
```
Given some parent directories have no read permission
When calling detect_project
Then function SHALL handle gracefully and return PWD as fallback
```

---

## Bug Fix Specifications

### BUG-FIX-1: Hardcoded `$HOME/dotfiles` in `scripts/debian/bootstrap/ai.sh`

**Requirement**: Bootstrap script MUST use `$(dirname "${BASH_SOURCE[0]}")` for dynamic path resolution.

**Scenario: Bootstrap uses relative path**
```
Given script is located at /path/to/Termux-AI-Astaroth/scripts/debian/bootstrap/ai.sh
When script executes
Then ROOT variable SHALL be computed via dirname BASH_SOURCE[0]
And SHALL resolve to /path/to/Termux-AI-Astaroth/scripts/debian
```

**Current bug**: Line 5 uses `ROOT="$HOME/dotfiles/scripts/debian"` which fails if installed elsewhere.

---

### BUG-FIX-2: Hardcoded `$HOME/dotfiles` in `scripts/ai/core/router.sh`

**Requirement**: Router MUST source providers using relative path from script location.

**Scenario: Router sources use BASE_DIR**
```
Given SCRIPT_DIR is computed from BASH_SOURCE[0]
When router.sh sources provider scripts
Then sources SHALL use "$BASE_DIR/providers/*.sh" pattern
Not hardcoded "$HOME/dotfiles/scripts/ai/providers/*.sh"
```

**Current bug**: Lines 7-11 use hardcoded `$HOME/dotfiles`.

---

### BUG-FIX-3: Hardcoded paths in `scripts/ai/menu.sh`

**Requirement**: Menu script MUST use `SCRIPT_DIR` for self-location, not hardcoded paths.

**Scenario: Menu script location detection**
```
Given menu.sh is executed from any location
When script determines paths to other scripts
Then all paths SHALL be relative to SCRIPT_DIR
Not hardcoded "~/dotfiles/scripts/ai/..."
```

---

### BUG-FIX-4: `recovery.md` line 557 wrong repo URL

**Requirement**: Recovery doc MUST reference correct repo URL `bladimir/Termux-AI-Astaroth`.

**Scenario: Verify recovery.md has correct URL**
```
Given docs/recovery.md
When searching for git clone URL
Then URL SHALL be "https://github.com/bladimir/Termux-AI-Astaroth.git"
Not "https://github.com/ipproyectosysoluciones/termux-dotfiles.git"
```

**Current bug**: Line 557 contains `ipproyectosysoluciones/termux-dotfiles`.

---

## Test Infrastructure Requirements

### Test Helper Enhancement

**Requirement**: `tests/test_helper.bash` MUST provide:
- Mock functions for provider binaries
- Fixtures for temporary test projects
- Path resolution helpers

### Test Execution

Tests SHALL be executable via:
```bash
bats --recursive tests/
bats tests/phase1/
bats tests/phase1/project_detection.bats
```

### Test Independence

Each test file SHALL:
- Be independently runnable
- Clean up any created state in teardown
- Use unique session names to avoid collisions

---

## Acceptance Criteria

### Phase 1 Acceptance
- [ ] All 10 core module test files exist in `tests/phase1/`
- [ ] Each test covers all public functions in the module
- [ ] All tests follow Given/When/Then format
- [ ] All tests use RFC 2119 keywords appropriately

### Phase 2 Acceptance
- [ ] All 4 provider test files exist in `tests/phase2/`
- [ ] Fallback chains are tested end-to-end
- [ ] Missing binary scenarios are covered

### Phase 3 Acceptance
- [ ] `ai.sh` integration tests cover bootstrap, detection, routing
- [ ] `router.sh` tests cover all provider dispatch cases

### Phase 4 Acceptance
- [ ] Menu, utils, workspace tests cover main execution paths
- [ ] All 4 template `build_layout` functions are tested

### Phase 5 Acceptance
- [ ] Error path tests cover all identified failure modes
- [ ] Bug fix tests verify hardcoded paths are resolved

### General Acceptance
- [ ] All tests follow TDD Red-Green-Refactor cycle
- [ ] Tests are documented with scenario format
- [ ] Test infrastructure supports local and SSH device execution

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|-------------|
| Hardcoded paths in tests | HIGH | MEDIUM | Use `test_helper.bash` path resolution |
| TMUX not available in CI | HIGH | LOW | Skip tmux-dependent tests, test manually on device |
| Provider API mocking complex | MEDIUM | MEDIUM | Mock at shell level with bats-mock stubs |
| SSH connection flaky | MEDIUM | LOW | Run tests locally when possible |
| Tests pollute tmux state | MEDIUM | MEDIUM | Clean up sessions in teardown |

---

*Spec created: 2026-06-02*
*Author: sdd-spec sub-agent*
*Skill Resolution: paths-injected — 1 skill (test-driven-development)*