# AI Setup / Configuración de AI

## ES

### Visión General

Esta configuración tiene **dos capas de AI**:

1. **In-editor AI** (CodeCompanion.nvim) — chat e inline assistance directamente en Neovim
2. **AI CLI splits** (tmux splits) — scripts de providers que corren en splits de terminal

Ambas capas son independientes y pueden usarse en paralelo.

---

### Requisitos Previos

```bash
# Verificar que tenés las variables de entorno necesarias
echo $GEMINI_API_KEY $ANTHROPIC_API_KEY $OPENAI_API_KEY

# Si no tenés ninguna, vas a usar solo los CLI splits (no el plugin in-editor)
# Los CLI splits funcionan con tokens via archivos de config o vars
```

---

### CodeCompanion.nvim (In-Editor AI)

CodeCompanion se carga lazily cuando alguna de estas variables está seteada:

| Variable | Provider |
|---|---|
| `GEMINI_API_KEY` | Google Gemini |
| `ANTHROPIC_API_KEY` | Anthropic Claude |
| `OPENAI_API_KEY` | OpenAI GPT |

**Fallback chain**: Si un provider falla (ej: 429 rate limit), CodeCompanion intenta el siguiente en orden: `gemini → claude → openai → ollama`.

**Configuración de adapters** (en `nvim/lua/plugins/ai/init.lua`):
- Cada adapter usa su variable de API correspondiente
- El adapter activo se puede cambiar con `<leader>as` (CodeCompanion Chat -s)
- La UI muestra cuál adapter está activo en el chat header

**Keymaps de CodeCompanion**:

| Keymap | Acción |
|---|---|
| `<leader>aa` | Abrir chat (Normal+Visual) |
| `<leader>ai` | Inline assist (bufline) |
| `<leader>at` | Toggle chat window |
| `<leader>am` | Actions panel |
| `<leader>as` | Switch adapter |

---

### AI CLI Splits (tmux splits)

Los CLI splits usan scripts en `scripts/ai/providers/`. Cada script abre un split horizontal y ejecuta el provider CLI.

**Variables de entorno para CLI splits**:

| Variable | Default | Propósito |
|---|---|---|
| `AI_WORKSPACE` | `cwd` | Workspace actual |
| `AI_PROJECT` | `default` | Proyecto (para contexto) |
| `AI_AGENT` | `generic-agent` | Agent a usar |
| `AI_SKILL` | `generic-skill` | Skill del agent |

**Keymaps de CLI splits**:

| Keymap | Provider | Script |
|---|---|---|
| `<leader>ag` | Gemini | `scripts/ai/providers/gemini.sh` |
| `<leader>ac` | Claude | `scripts/ai/providers/claude.sh` |
| `<leader>ao` | OpenCode | `scripts/ai/providers/opencode.sh` |
| `<leader>gm` | Mistral | `scripts/ai/providers/mistral.sh` |
| `<leader>gg` | Gentle | `scripts/ai/providers/gentle.sh` |

---

### Configuración de Providers

#### Gemini

```bash
# En tu ~/.bashrc o equivalente
export GEMINI_API_KEY="tu-api-key"

# O usar un archivo de config si el script lo soporta
```

#### Claude

```bash
export ANTHROPIC_API_KEY="tu-api-key"
```

#### OpenAI

```bash
export OPENAI_API_KEY="tu-api-key"
```

#### Ollama (local)

```bash
# Instalar ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Verificar que corre
ollama list
```

---

### Workflow Recomendado

1. **Para assistance rápido**: `<leader>ai` (inline) o `<leader>aa` (chat)
2. **Para tareas pesadas o debugging**: `<leader>tt` para abrir terminal, luego un CLI split desde ahí
3. **Para switch de provider**: `<leader>as` en modo Normal

---

## EN

### Overview

This configuration has **two layers of AI**:

1. **In-editor AI** (CodeCompanion.nvim) — chat and inline assistance directly in Neovim
2. **AI CLI splits** (tmux splits) — provider scripts running in terminal splits

Both layers are independent and can be used in parallel.

---

### Prerequisites

```bash
# Verify you have the necessary environment variables
echo $GEMINI_API_KEY $ANTHROPIC_API_KEY $OPENAI_API_KEY

# If you have none, you only use CLI splits (not the in-editor plugin)
# CLI splits work with tokens via config files or vars
```

---

### CodeCompanion.nvim (In-Editor AI)

CodeCompanion loads lazily when any of these variables is set:

| Variable | Provider |
|---|---|
| `GEMINI_API_KEY` | Google Gemini |
| `ANTHROPIC_API_KEY` | Anthropic Claude |
| `OPENAI_API_KEY` | OpenAI GPT |

**Fallback chain**: If a provider fails (e.g: 429 rate limit), CodeCompanion tries the next in order: `gemini → claude → openai → ollama`.

**Adapter configuration** (in `nvim/lua/plugins/ai/init.lua`):
- Each adapter uses its corresponding API variable
- The active adapter can be changed with `<leader>as` (CodeCompanion Chat -s)
- The UI shows which adapter is active in the chat header

**CodeCompanion keymaps**:

| Keymap | Action |
|---|---|
| `<leader>aa` | Open chat (Normal+Visual) |
| `<leader>ai` | Inline assist (bufline) |
| `<leader>at` | Toggle chat window |
| `<leader>am` | Actions panel |
| `<leader>as` | Switch adapter |

---

### AI CLI Splits (tmux splits)

CLI splits use scripts in `scripts/ai/providers/`. Each script opens a horizontal split and runs the provider CLI.

**Environment variables for CLI splits**:

| Variable | Default | Purpose |
|---|---|---|
| `AI_WORKSPACE` | `cwd` | Current workspace |
| `AI_PROJECT` | `default` | Project (for context) |
| `AI_AGENT` | `generic-agent` | Agent to use |
| `AI_SKILL` | `generic-skill` | Agent skill |

**CLI split keymaps**:

| Keymap | Provider | Script |
|---|---|---|
| `<leader>ag` | Gemini | `scripts/ai/providers/gemini.sh` |
| `<leader>ac` | Claude | `scripts/ai/providers/claude.sh` |
| `<leader>ao` | OpenCode | `scripts/ai/providers/opencode.sh` |
| `<leader>gm` | Mistral | `scripts/ai/providers/mistral.sh` |
| `<leader>gg` | Gentle | `scripts/ai/providers/gentle.sh` |

---

### Provider Configuration

#### Gemini

```bash
# In your ~/.bashrc or equivalent
export GEMINI_API_KEY="your-api-key"

# Or use a config file if the script supports it
```

#### Claude

```bash
export ANTHROPIC_API_KEY="your-api-key"
```

#### OpenAI

```bash
export OPENAI_API_KEY="your-api-key"
```

#### Ollama (local)

```bash
# Install ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Verify it's running
ollama list
```

---

### Recommended Workflow

1. **For quick assistance**: `<leader>ai` (inline) or `<leader>aa` (chat)
2. **For heavy tasks or debugging**: `<leader>tt` to open terminal, then a CLI split from there
3. **To switch provider**: `<leader>as` in Normal mode