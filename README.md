# ADbS - Ai Dont be Stupid, please!

A generic, cross-platform AI workflow enforcement system that automatically detects your IDE/platform and enforces **SDD (Specification-Driven Development)** methodology and **Beads** integration through platform-specific rules files. 

**Features:**
- **Plan-based SDD workflow** with incremental plan IDs (plan-001, plan-002, etc.)
- **Cross-platform support** - Works on Linux, macOS, Windows (PowerShell, CMD, Bash)
- **Multi-platform detection** - Supports Cursor, Trae, Gemini, VS Code, and more
- **Multi-file rules generation** - Auto-generates `.mdc` rules files per platform
- **Enhanced task management** - Hierarchical tasks, dependencies, tags, comments, and search
- **OpenSpec Integration** - Native support for Fission-AI/OpenSpec workflow (Proposals, Specs)
- **Pure shell implementation** - No Python, Node.js, or Go dependencies required

## Overview

ADbS prevents AI hallucinations and ensures systematic development by enforcing a structured workflow:

1. **Explore** - Initial research and understanding
2. **Plan** - Outline objectives and strategies  
3. **SDD** - Specification-Driven Development
4. **Assign** - Task management
5. **Execution** - Implementation

For detailed workflow instructions (Classic vs OpenSpec), see **[USER_GUIDE.md](USER_GUIDE.md)**.

## Features

- **Automatic Platform Detection** - Detects Cursor, Trae, VS Code, and other IDEs
- **Platform-Specific Rules** - Automatically creates `.cursor/rules`, `.trae/rules`, etc.
- **SDD Enforcement** - Ensures proper specification before implementation
- **Beads Integration** - Optional task management with fallback to pure shell alternative
- **Pure Shell Implementation** - Runs everywhere (cloud, SSH, containers) with no dependencies
- **Single-Line Installation** - One command to get started

## Quick Start

### Installation

```bash
curl -sSL https://raw.githubusercontent.com/your-username/ADbS/main/install.sh | bash
```

Or using wget:

```bash
wget -qO- https://raw.githubusercontent.com/your-username/ADbS/main/install.sh | bash
```

The installer will:
- Detect your OS and architecture
- Detect your IDE/platform (Cursor, Trae, VS Code, etc.)
- Create platform-specific rules directory (`.cursor/rules`, `.trae/rules`, etc.)
- Set up workflow enforcement files
- Optionally download Beads binary (if available for your platform)

### Usage

After installation, your AI agent will automatically read the rules file from the platform-specific directory. The workflow enforcer ensures:

1. **Explore** stage is completed before planning
2. **Plan** stage is completed before SDD
3. **SDD** stages (requirements → design → tasks) are completed in order
4. **Tasks** are assigned using Beads or the alternative task manager
5. **Execution** only proceeds after all previous stages are validated

### Manual Workflow Control

```bash
# Check status
adbs status

# Classic SDD
adbs validate
adbs next

# Modern OpenSpec (Recommended)
adbs propose "new-feature"
adbs specs
adbs archive "new-feature"

# Create a task (using Beads or alternative)
adbs task create "Implement feature X"

# List tasks
adbs task list
```

**Note**: `adbs` is a shorter alias for `workflow-enforcer`. Both commands work identically.

## Architecture

### Core Components

1. **Platform Detector** (`lib/platform_detector.sh`) - Detects IDE/platform
2. **Rules Generator** - Creates platform-specific rules files
3. **Workflow Validator** (`lib/validator/workflow.sh`) - Enforces stage completion
4. **Task Manager** (`lib/task_manager/`) - Beads integration + pure shell alternative
5. **SDD Templates** (`templates/sdd/`) - Requirements, design, and tasks templates

### File Structure

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
│   └── migrate.sh
├── templates/
│   ├── sdd/
│   │   ├── requirements.md.template
│   │   ├── design.md.template
│   │   └── tasks.md.template
│   └── rules/
│       ├── sdd.mdc.template
│       ├── workflow.mdc.template
│       ├── beads.mdc.template
│       └── platform-*.mdc.template
├── bin/
│   ├── workflow-enforcer / adbs (shorter alias)
│   ├── workflow-enforcer.ps1 / adbs.ps1
│   └── workflow-enforcer.bat / adbs.bat
└── .sdd/ (created at runtime)
    ├── plans/
    │   ├── .index.json
    │   └── *.md
    ├── requirements/
    │   └── requirements.plan-*.md
    ├── designs/
    │   └── design.plan-*.md
    └── tasks/
        └── tasks.plan-*.md
```

### Platform-Specific Rules

After installation, multiple `.mdc` rule files are automatically generated in your platform's `rules/` directory:

- **Cursor**: `.cursor/rules/*.mdc`
- **Trae**: `.trae/rules/*.mdc`
- **Gemini**: `.gemini/rules/*.mdc`
- **VS Code**: `.vscode/rules/*.mdc`
- **Generic**: `.ai-rules/rules/*.mdc`

Rule files generated:
- `sdd.mdc` - SDD workflow rules
- `workflow.mdc` - Workflow enforcement rules
- `beads.mdc` - Task management rules (if Beads available)
- `tasks.mdc` - Task manager rules (if task manager active)
- `{platform}.mdc` - Platform-specific rules

These files contain SDD and Beads enforcement rules that your AI agent automatically reads.

## Workflow Stages

### 1. Explore
Initial research phase. Document findings and understanding of the problem.
- Create: `.sdd/plans/explore.md`

### 2. Plan
Outline objectives, strategies, and high-level approach.
- Create: `.sdd/plans/plan-001.md` (or next plan ID)
- Plan IDs are incremental: `plan-001`, `plan-002`, etc.
- Plan metadata tracked in `.sdd/plans/.index.json`

### 3. SDD - Requirements
Define functional and non-functional requirements.
- Create: `.sdd/requirements/requirements.plan-001.md`
- Links to plan via filename pattern
- Minimum 500 words required

### 4. SDD - Design
Create architecture and design documents.
- Create: `.sdd/designs/design.plan-001.md`
- Links to plan via filename pattern
- Minimum 500 words required

### 5. SDD - Tasks
Break down work into specific, actionable tasks.
- Create: `.sdd/tasks/tasks.plan-001.md`
- Links to plan via filename pattern
- Minimum 3 tasks required

### 6. Assign
Use Beads (or alternative) to manage and track tasks.
- Create tasks in task manager
- Link tasks to plan ID
- Set dependencies and tags

### 7. Execution
Implement and test the solution.
- Update task status as work progresses
- Mark tasks complete when done

## Task Management

### Beads Integration

If Beads binary is available for your platform, it will be automatically downloaded and used. Beads provides:

- Hierarchical task management
- Dependency tracking
- Status management
- Export/import capabilities

### Enhanced Task Manager

If Beads is not available, a pure shell-based alternative is used with enhanced features:

- **JSON-based storage** (`.workflow-enforcer/tasks.json`)
- **Hierarchical tasks** - Parent/child relationships (`task-abc`, `task-abc.1`, `task-abc.2`)
- **Dependencies** - Track task dependencies
- **Tags** - Organize tasks with tags
- **Comments** - Add comments with timestamps
- **Search** - Filter by status, priority, tags, description
- **Status management** - todo, in-progress, done, blocked
- **ID generation** - Similar to Beads format

#### Task Management Commands

```bash
# Create task with all features
adbs task create "Implement feature" high "" "frontend,urgent"

# Create child task
adbs task create "Subtask" medium task-abc123

# Add comment
adbs task comment task-abc123 "Working on this now"

# Add tag
adbs task tag task-abc123 "blocked"

# Search tasks
adbs task search todo high "frontend"
```

## Configuration

Workflow configuration is stored in `config/workflow.yaml`:

```yaml
stages:
  - explore
  - plan
  - sdd:
      - requirements
      - design
      - tasks
  - assign
  - execution

enforcement:
  strict: true
  allow_skip: false
  require_validation: true
  require_beads: false  # Optional, falls back to simple task manager
```

## Cross-Platform Support

- **Linux/macOS**: Native bash script support
- **Windows**: 
  - **PowerShell** (preferred) - Native PowerShell scripts (`.ps1`)
  - **CMD** - Batch file wrappers (`.bat`)
  - **Bash** - Via Git Bash or WSL (fallback)
- **Cloud/SSH**: Pure shell implementation - no dependencies
- **Architecture**: Auto-detects and downloads appropriate Beads binary (amd64, arm64)

### Installation on Windows

The installer automatically detects your environment:

```powershell
# PowerShell (preferred)
.\install.ps1

# CMD (fallback)
install.bat

# Git Bash/WSL
bash install.sh
```

The installer routes to the appropriate script based on detected shell.

After installation, use the shorter `adbs` command:
```bash
adbs status
adbs validate
adbs task create "My task"
```

## Plan ID System

ADbS uses an incremental plan ID system to link all SDD artifacts:

- **Format**: `plan-001`, `plan-002`, etc. (zero-padded 3-digit numbers)
- **Generation**: Automatic when creating a new plan
- **Linking**: All artifacts link to plan via filename pattern
  - Requirements: `requirements.plan-001.md`
  - Design: `design.plan-001.md`
  - Tasks: `tasks.plan-001.md`
- **Index**: Plan metadata stored in `.sdd/plans/.index.json`

### Plan Management

```bash
# Create new plan
plan_id=$(lib/plan_manager.sh create)

# Get current plan ID
current_plan=$(lib/plan_manager.sh current)

# List all plans
lib/plan_manager.sh list

# Link artifact to plan
lib/plan_manager.sh link plan-001 requirements requirements.plan-001.md
```

**Note**: You can also use `adbs` for most operations - it's shorter and easier to type than `workflow-enforcer`.

## Migration from Old Structure

If you have an existing `.workflow-enforcer/artifacts/` structure, use the migration utility:

```bash
lib/migrate.sh
```

This will:
- Convert artifacts to plan-based structure
- Create plan ID and link artifacts
- Preserve old structure as backup

## Contributing

Contributions are welcome! Please ensure all scripts are pure shell (bash/sh) for maximum portability.

## License

MIT License - See LICENSE file for details

## Credits

Inspired by:
- [Beads](https://github.com/steveyegge/beads) - A memory upgrade for your coding agent
- SDD (Specification-Driven Development) methodology

