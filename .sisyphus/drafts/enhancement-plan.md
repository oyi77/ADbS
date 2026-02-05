# Draft: ADbS Evolution (OpenCode & Mobile Parity)

## Requirements (confirmed)
- [Goal]: Complete ADbS features (OpenSpec, Memory, Dashboard) and integrate with OpenCode.
- [Mobile]: Support Termux (Android) and iOS (iSH/Blink) with **zero runtime dependencies**.
- [Integration]: ADbS acts as a plugin/skill for `oh-my-opencode`.
- [Testing]: Full E2E coverage for cross-platform workflows.

## Technical Decisions (Final)
- **Decision: Refactor to Go**: Migrate dual Bash/PS1 logic to a unified Go binary.
    - Rationale: Single static binary is the only viable path for "mere android/iOS" (Termux) parity without dependency hell.
    - Footprint: Go binary (5-15MB) vs Node runtime (50-80MB).
- **Staged Migration**: Implement core commands in Go, keep Bash/PS1 as temporary compatibility shims.
- **Memory Engine (Tiered)**:
    - Core: Native Go KV store (always available).
    - Advanced: Optional Python indexer (desktop-only, not blocking mobile).
- **Dashboard**: Generate static HTML by default, optionally serve via embedded Go server.
- **Distribution**: Ship pre-compiled binaries for:
    - Linux arm64 (Termux)
    - Linux 386 (iSH)
    - Windows amd64
    - macOS arm64/amd64

## Research Findings
- [OpenCode]: Node-based harness. Uses `~/.config/opencode/opencode.json` for plugins. Exposes "Skills" for agents.
- [Parity Debt]: Current codebase spends ~40% of effort maintaining Bash/PS1 parity.
- [Termux/iSH Constraints]: No sudo access, relies on BusyBox (limited GNU utils), requires explicit `$PREFIX` path handling.

## Open Questions (Self-Resolved)
- **Role**: ADbS will be the "Workflow Layer" for OpenCode, providing the SDD structure that OpenCode agents follow.
- **Testing**: We will use a mock "Executor Agent" to verify workflows across platforms.
