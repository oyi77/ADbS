# ADbS User Guide

**ADbS (Ai Dont be Stupid, please!)** is a workflow enforcer designed to prevent AI hallucinations by ensuring a structured, context-rich development process. It forces you (and the AI) to think before you code.

## Core Concept
ADbS works by injecting **Rules** into your AI IDE (Cursor, Windsurf, Zed, Trae). These rules force the AI to read your project's context and follow a strict stage-based workflow.

---

## 1. The Classic Flow (SDD)
The original workflow based on **Specification-Driven Development**. Use this for complex, multi-stage projects requiring deep architectural planning.

### Directory Structure
- `.sdd/plans/`: High-level plans.
- `.sdd/requirements/`: Detailed requirements.
- `.sdd/designs/`: Technical designs.
- `.sdd/tasks/`: Task breakdown.

### The Workflow Loop

1.  **Explore**: Research the problem.
    ```bash
    adbs status # -> Current stage: Explore
    # Write notes...
    adbs validate
    adbs next
    ```
2.  **Plan**: Create a high-level plan.
    ```bash
    # Create `.sdd/plans/plan-001.md`
    adbs validate
    adbs next
    ```
3.  **Requirements**: Detail what you need.
    ```bash
    # Create `.sdd/requirements/requirements.plan-001.md`
    adbs validate
    adbs next
    ```
4.  **Design**: Technical architecture.
    ```bash
    # Create `.sdd/designs/design.plan-001.md`
    adbs validate
    adbs next
    ```
5.  **Execution**: Code it.
    ```bash
    adbs task create "Implement feature"
    # AI writes code...
    ```

---

## 2. The Modern Flow (OpenSpec)
A streamlined, native integration of the [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) standard. Use this for agile, iterative feature development where "Proposals" replace the rigid SDD stack.

### Directory Structure
- `openspec/specs/`: Source of truth (The "Now").
- `openspec/changes/`: Proposed changes (The "Future").
- `openspec/archive/`: Completed history.

### The Workflow Loop

1.  **Initialize** (One time)
    ```bash
    adbs openspec init
    ```

2.  **Propose**: Start a new feature or fix.
    ```bash
    adbs propose "add-login-flow"
    # Creates `openspec/changes/2024-12-17-add-login-flow/proposal.md`
    ```

3.  **Spec & Task**: Information gap feeling?
    -   Edit `proposal.md` to define what you are building.
    -   AI reads this file as the absolute instruction source.

4.  **Implement**:
    -   AI writes code based on the Proposal.
    -   AI updates `openspec/specs/` to reflect the new system state.

5.  **Archive**: Done?
    ```bash
    adbs archive "2024-12-17-add-login-flow"
    # Moves folder to `openspec/archive/`, marking it complete.
    ```

### Why use this?
-   **Less Friction**: No rigid "Next Stage" command. You are either "Proposing" or "Archived".
-   **Native to AI**: Optimizes context for AI tools by keeping "Active Context" in one folder (`changes/current`).

---

## 3. Platform Integration
ADbS automatically detects your IDE and generates the correct Rule files so your AI **knows** which workflow to follow.

### Usage
```bash
# 1. Detect and Generate Rules
adbs rules generate cursor   # or zed, trae, windsurf

# 2. Verify
ls .cursor/rules   # (or .rules for Zed, etc.)
```

### Supported Platforms
| Platform | Rule Location | Feature |
| :--- | :--- | :--- |
| **Cursor** | `.cursor/rules/<name>/RULE.md` | Full multi-file support. |
| **Windsurf** | `.windsurf/rules/*.md` | Native Cascade support. |
| **Zed** | `.rules` | Single-file concatenation (Project Rules). |
| **Trae** | `.trae/rules/project_rules.md` | Single-file support. |

## Command Cheat Sheet

| Action | Classic (SDD) | Modern (OpenSpec) |
| :--- | :--- | :--- |
| **Start** | `adbs init` | `adbs openspec init` |
| **New Work** | (Create Plan Document) | `adbs propose "name"` |
| **Check Status** | `adbs status` | `adbs specs` / `ls openspec/changes` |
| **Finish** | `adbs next` (until Done) | `adbs archive "name"` |
| **Update Rules** | `adbs rules generate` | `adbs rules generate` |

---
**Recommendation**: Use **OpenSpec** (`adbs propose`) for most new feature work. Use **Classic SDD** only when you need extensive document chaining (Plan -> Req -> Design) for very large subsystems.

## Troubleshooting

### "Validation failed. Commit blocked."
If you installed the git hooks (`adbs install-hooks`) and cannot commit because validation fails:
1.  **Bypass it (One time)**: `git commit --no-verify -m "msg"`
2.  **Fix it**: Satisfy the requirements (e.g., create missing notes).
3.  **Disable it**: `rm .git/hooks/pre-commit`
