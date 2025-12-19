# ADbS Architecture

## Core Components

1.  **Platform Detector** (`lib/platform_detector.sh`):
    *   Detects the IDE (Cursor, Trae, VS Code, etc.) by checking environment variables and specific directories.
2.  **Rules Generator** (`lib/rules_generator.sh`):
    *   Reads templates from `templates/rules/`.
    *   Generates platform-specific rules (e.g., `.cursor/rules/*.mdc`).
3.  **Workflow Validator** (`lib/validator/workflow.sh`):
    *   Enforces the SDD stages (Explore -> Plan -> Requirements -> Design -> Tasks -> Execution).
    *   Ensures required files exist and meet minimum word counts.
4.  **Task Manager** (`lib/task_manager/`):
    *   **Beads Wrapper**: Tries to use the [Beads](https://github.com/steveyegge/beads) binary.
    *   **Simple Manager**: A pure shell fallback using `jq` or `python3` (or `awk/sed` as last resort) to manage `tasks.json`.
5.  **OpenSpec Engine** (`lib/openspec.sh`):
    *   Manages the `openspec/` directory structure for the Proposal-based workflow.

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

1.  **User/Agent** runs `adbs <command>`.
2.  **Bin Wrapper** detects OS and forwards to `lib/` script.
3.  **Validator** checks `.workflow-enforcer/current-stage` and verifies artifacts in `.sdd/`.
4.  **Rule Generator** writes `.mdc` files to `.cursor/rules/` to allow the IDE's AI to read the current context rules.
