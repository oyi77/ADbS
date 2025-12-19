# ADbS User Guide

**ADbS (Ai Dont be Stupid, please!)** enforces a structured development workflow to prevent AI hallucinations and keep your project organized. It supports two main workflows: the modern **OpenSpec** (for agile features) and the classic **SDD** (for complex architecture).

## Table of Contents

- [Getting Started](#getting-started)
- [Workflows](#workflows)
    - [Modern: OpenSpec](#modern-openspec-recommended)
    - [Classic: SDD](#classic-specification-driven-development)
- [Task Management](#task-management)
- [Platform Integration](#platform-integration)
- [Reference](#reference)
    - [Command Reference](#command-reference)
    - [Configuration](#configuration)
    - [Directory Structure](#directory-structure)
- [Troubleshooting](#troubleshooting)

---

## Getting Started

### Installation
Run the single-line installer to detect your OS and Platform (Cursor, etc.):

```bash
# via curl
curl -sSL https://raw.githubusercontent.com/your-username/ADbS/main/install.sh | bash

# via wget
wget -qO- https://raw.githubusercontent.com/your-username/ADbS/main/install.sh | bash
```

### Initialization
Initialize ADbS in your project root.

```bash
# Initialize for OpenSpec (Recommended)
adbs openspec init

# Initialize for Classic SDD
adbs init
```

---

## Workflows

### Modern: OpenSpec (Recommended)
Best for agile, iterative feature development using "Proposals".

1.  **Propose a Change**:
    ```bash
    adbs propose "add-login"
    ```
    *Creates `.openspec/changes/<date>-add-login/proposal.md`.*

2.  **Define Spec**:
    Edit the created `proposal.md`. This file is the **SINGLE SOURCE OF TRUTH** for the AI for this task.

3.  **Implement**:
    The AI writes code based *only* on the proposal.

4.  **Archive**:
    When done and verified:
    ```bash
    adbs archive "add-login"
    ```
    *Moves folder to `.openspec/archive/`, marking it complete.*

### Classic: Specification-Driven Development
Best for complex formatting requiring strict stages (Plan -> Requirements -> Design -> Tasks).

1.  **Check Status**:
    ```bash
    adbs status
    # Output: Current stage: Explore
    ```

2.  **Advance Stage**:
    Complete the required documents for the current stage, then validate and move next.
    ```bash
    adbs validate   # Checks if you met the stage requirements
    adbs next       # Moves to the next stage (e.g., Explore -> Plan)
    ```

3.  **The Loop**:
    Repeat `adbs status` -> Create Docs -> `adbs validate` -> `adbs next` until you reach Execution.

---

## Task Management

Manage tasks using the built-in system (or [Beads](https://github.com/steveyegge/beads) if available).

```bash
# Create a task
# Usage: adbs task create <title> <priority> <parent_id> <tags>
adbs task create "Implement OAuth" high "" "backend,auth"

# List tasks
adbs task list --status todo

# Comment on a task
adbs task comment task-123 "Started researching providers"
```

---

## Platform Integration

ADbS works by injecting **Rules** into your AI IDE. These rules force the AI to follow your workflow.

### Generate Rules
If you switch IDEs or update ADbS, regenerate the rules:

```bash
# Auto-detect platform and generate
adbs rules generate

# Force specific platform
adbs rules generate cursor   # Options: cursor, windsurf, zed, trae, gemini
```

### Supported Platforms
| Platform | Rule Location | Feature |
| :--- | :--- | :--- |
| **Cursor** | `.cursor/rules/` | Multi-file rules, auto-attached. |
| **Windsurf** | `.windsurf/rules/` | Native Cascade support. |
| **Zed** | `.rules` | Project-specific rules. |
| **Trae** | `.trae/rules/` | Project rules. |

---

## Reference

For a complete list of commands, configuration options, and directory structure, please see the **[Reference Guide](REFERENCE.md)**.

---

## Troubleshooting

**"Validation failed. Commit blocked."**
If git hooks are blocking you:
1.  **Fix it**: Run `adbs validate` to see what's missing.
2.  **Bypass**: `git commit --no-verify -m "wip"`
3.  **Disable**: `rm .git/hooks/pre-commit`
