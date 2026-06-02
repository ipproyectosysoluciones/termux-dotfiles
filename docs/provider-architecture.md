# Provider Architecture

## Overview
The AI provider system routes user requests to the appropriate AI service based on intent detection. It supports multiple providers with automatic fallback when a provider is unavailable.

## Architecture

### Components
- `scripts/ai/core/provider_selector.sh` — Intent detection and provider routing
- `scripts/ai/core/routing.sh` — Prompt analysis for intent classification
- `scripts/ai/providers/` — Individual provider implementations

### Routing Flow
1. User sends prompt → `ai.sh`
2. `routing.sh` analyzes intent (code, chat, analysis, etc.)
3. `provider_selector.sh` maps intent → provider
4. Selected provider script handles the API call
5. On failure → fallback to next provider in chain

### Provider Interface
Each provider script MUST implement:
- `run_<provider>()` — Main execution function
- Exit code 0 on success, non-zero on failure
- Source `.env` for API keys
- Handle QUOTA_EXHAUSTED errors by falling back

### Current Providers
| Provider | Script | Status |
|----------|--------|--------|
| Gemini | `scripts/ai/providers/gemini.sh` | Active (primary) |
| OpenCode | `scripts/ai/providers/opencode.sh` | Active (first fallback) |
| Claude | `scripts/ai/providers/claude.sh` | Active (intent-routed) |
| Mistral | `scripts/ai/providers/mistral.sh` | Active (secondary) |
| Gentle | `scripts/ai/providers/gentle.sh` | Active (control plane) |

### Fallback Chain
When the primary provider (Gemini) is unavailable:
```
gemini → opencode → gentle
```
- `QUOTA_EXHAUSTED` → fallback to **opencode**
- Generic failure → fallback to **gentle**
- Providers like Claude and Mistral are selected directly by intent routing, not through the fallback chain.

### Adding a New Provider
1. Create `scripts/ai/providers/<name>.sh` following the interface
2. Add routing case to `provider_selector.sh`
3. Add bootstrap entry to `scripts/debian/bootstrap/ai.sh`
4. Add API key to `.env.example`
5. Update this documentation
6. Write tests

### Environment Variables
Each provider uses its own API key variable in `.env`:
- `GEMINI_API_KEY` — Google Gemini
- `MISTRAL_API_KEY` — Mistral AI
- (other providers as added)