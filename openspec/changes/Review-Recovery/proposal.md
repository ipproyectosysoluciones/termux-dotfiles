# Proposal: Review-Recovery

## Intent

Fix critical gaps in recovery documentation and establish a sustainable AI provider architecture for the Termux-AI-Astaroth project. The recovery guide has wrong repo URLs and omits AI workspace recovery entirely, while the AI provider system (gemini → opencode → gentle) lacks documentation for adding new providers like Mistral.

## Scope

### In Scope
- Fix repo URL references in `docs/recovery.md`
- Add AI workspace (scripts/ai/, gentle-ai, engram) recovery procedures
- Add `doctor.sh` validation to recovery steps
- Document TPM installation explicitly
- Document provider architecture: how to add new AI providers
- Add Mistral AI provider (script + routing integration + bootstrap entry)
- Add recovery scenarios to `docs/ai-workspace.md`
- Add AI tools section to `docs/installation.md`

### Out of Scope
- Test infrastructure setup (deferred — project has `strict_tdd: false`)
- Full rewrite of any documentation file
- Changes to AI provider intent routing logic
- Modifications to existing provider scripts

## Capabilities

### New Capabilities
- `ai-provider-docs`: Documentation explaining how to add new AI providers to the system
- `mistral-provider`: New Mistral AI provider integrated into the existing provider selection system

### Modified Capabilities
- `recovery-guide`: Updated with correct repo URL, AI workspace recovery, doctor.sh validation, and explicit TPM installation steps

## Approach

**Phase-based incremental fix** — target the 400-line review budget by grouping related changes:

1. **Phase 1 — Doc Fixes**: Correct recovery.md URL, add AI workspace recovery, gentle/engram backup strategy, doctor.sh validation, explicit TPM install. Also add AI tools section to installation.md.
2. **Phase 2 — Provider Architecture Docs**: Create a doc explaining the provider system (selector, routing, fallback chain) and how to add new providers. This enables Phase 3.
3. **Phase 3 — Mistral Provider**: Add `scripts/ai/providers/mistral.sh`, integrate into provider_selector.sh routing, add bootstrap entry. Creates small but self-contained change.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `docs/recovery.md` | Modified | Fix URL, add AI workspace recovery, gentle/engram, doctor.sh, TPM install |
| `docs/ai-workspace.md` | Modified | Add recovery scenarios section |
| `docs/installation.md` | Modified | Add AI tools installation section |
| `docs/provider-architecture.md` | New | Document provider system and how to add new providers |
| `scripts/ai/providers/mistral.sh` | New | Mistral provider script |
| `scripts/ai/core/provider_selector.sh` | Modified | Add Mistral routing entry |
| `scripts/debian/bootstrap/ai.sh` | Modified | Add Mistral bootstrap entry |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Wrong URL persists in docs | Low | Targeted find/replace in recovery.md |
| AI workspace recovery incomplete | Low | Verify with actual restoration test |
| Mistral API key management | Medium | Use .env integration — same pattern as other providers |
| Review budget exceeded | Medium | Use chained PRs if needed (see next section) |

## Rollback Plan

- **Phase 1**: Revert recovery.md and installation.md to previous state via git
- **Phase 2**: Delete provider-architecture.md doc
- **Phase 3**: Remove mistral.sh, undo provider_selector.sh and ai.sh changes

## Dependencies

- Mistral API account and key
- Existing provider pattern knowledge (in `scripts/ai/providers/`)

## Success Criteria

- [ ] `docs/recovery.md` has correct repo URL (bladimir/Termux-AI-Astaroth)
- [ ] Recovery doc includes AI workspace recovery (scripts/ai/, gentle-ai, engram)
- [ ] Recovery doc includes doctor.sh post-recovery validation step
- [ ] Provider architecture doc exists and explains how to add providers
- [ ] Mistral provider script exists and follows existing provider pattern
- [ ] Mistral integrated into provider_selector.sh fallback chain

## Key Decisions Needed

1. **Test framework**: bats (bash-native) vs shunit2 — or defer testing entirely given `strict_tdd: false`?
2. **Mistral API key handling**: `.env` variable, dedicated provider config file, or interactive prompt?
3. **Provider doc location**: Standalone `docs/provider-architecture.md` or section in `docs/ai-workspace.md`?
4. **Recovery doc restructuring**: Targeted fixes only (faster, less risk) or structured rewrite (more complete)?
5. **Review budget**: If combined changes exceed 400 lines, prefer chained PRs (1 per phase) or single PR with phases clearly labeled?