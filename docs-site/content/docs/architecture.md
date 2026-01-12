---
title: "Architecture"
description: "Technical architecture of ADbS"
date: 2025-01-01
---

# ADbS Architecture

Technical deep dive into ADbS internals for developers and contributors.

## Core Components

1. **Platform Detector** (`lib/platform_detector.sh`):
   - Detects the IDE (Cursor, Trae, VS Code, etc.) by checking environment variables and specific directories.

2. **Rules Generator** (`lib/rules_generator.sh`):
   - Reads templates from `templates/rules/`.
   - Generates platform-specific rules (e.g., `.cursor/rules/*.mdc`).

3. **Workflow Validator** (`lib/validator/workflow.sh`):
   - Enforces the SDD stages (Explore -> Plan -> Requirements -> Design -> Tasks -> Execution).
   - Ensures required files exist and meet minimum word counts.

4. **Task Manager** (`lib/task_manager/`):
   - **Beads Wrapper**: Tries to use the [Beads](https://github.com/steveyegge/beads) binary.
   - **Simple Manager**: A pure shell fallback using `jq` or `python3` (or `awk/sed` as last resort) to manage `tasks.json`.

5. **OpenSpec Engine** (`lib/openspec.sh`):
   - Manages the `openspec/` directory structure for the Proposal-based workflow.

## File Structure

```
ADbS/
├── README.md
├── install.sh / install.ps1 / install.bat
├── config/
│   ├── workflow.yaml
│   └── rules-template.md
├── lib/
│   ├── validator/
│   │   ├── workflow.sh
│   │   └── workflow.ps1
│   ├── task_manager/
│   │   ├── beads_wrapper.sh
│   │   └── simple.sh
│   ├── platform_detector.sh / .ps1
│   ├── plan_manager.sh / .ps1
│   ├── rules_generator.sh
│   ├── openspec.sh
│   └── migrate.sh
├── templates/
│   ├── sdd/
│   └── rules/
├── bin/
│   ├── workflow-enforcer / adbs (shorter alias)
└── .sdd/ (runtime)
```

## Data Flow

1. **User/Agent** runs `adbs <command>`.
2. **Bin Wrapper** detects OS and forwards to `lib/` script.
3. **Validator** checks `.workflow-enforcer/current-stage` and verifies artifacts in `.sdd/`.
4. **Rule Generator** writes `.mdc` files to `.cursor/rules/` to allow the IDE's AI to read the current context rules.

## Platform Detection

ADbS automatically detects your development environment:

- **IDE Detection**: Checks for IDE-specific directories and environment variables
- **OS Detection**: Identifies Windows, macOS, or Linux
- **Shell Detection**: Determines bash, zsh, or PowerShell

## Rule Generation

Rules are generated from templates in `templates/rules/`:

- Platform-specific templates (Cursor, Windsurf, Zed, etc.)
- Dynamic content injection from work items
- Automatic updates when work changes

## Task Management

ADbS supports multiple backends for task management:

1. **Beads** (preferred if available)
2. **Simple Manager** (fallback using jq/python3/awk/sed)

The system automatically selects the best available backend.

## Workflow Management

ADbS manages work items through:

- **Work Directory**: `.adbs/work/` for active items
- **Archive Directory**: `.adbs/archive/` for completed items
- **Proposal Files**: Markdown files describing each work item

## IDE Integration

Rules are generated for each supported IDE:

- **Cursor**: `.cursor/rules/*.mdc`
- **Windsurf**: `.windsurf/rules/*.mdc`
- **Zed**: `.rules/*.mdc`
- **VS Code**: `.vscode/*.json`

## Migration System

ADbS includes automatic migration from older versions:

- Detects old directory structures
- Migrates work items and tasks
- Creates backups of old data
- Preserves all history

## Contributing

Want to contribute? See the [Contributing Guide](/contributing/) for details on:

- Development workflow
- Code standards
- Testing requirements
- Pull request process

---

For more information, see the [Contributing Guide](/contributing/) and [Testing Documentation](/docs/testing/).

