# ADbS Reference Guide

Complete command reference for ADbS.

## Command Reference

### Work Management

| Command | Description | Example |
|---------|-------------|---------|
| `adbs new <name>` | Start new work item | `adbs new "user login"` |
| `adbs status` | Show current status | `adbs status` |
| `adbs done <name>` | Mark work complete | `adbs done "user login"` |
| `adbs show <name>` | Show work details | `adbs show "user login"` |
| `adbs list` | List all work | `adbs list` |

### Task Management

| Command | Description | Example |
|---------|-------------|---------|
| `adbs todo <desc>` | Add a task | `adbs todo "Fix bug"` |
| `adbs todo <desc> --priority <level>` | Add task with priority | `adbs todo "Critical fix" --priority high` |
| `adbs todo <desc> --tags <tags>` | Add task with tags | `adbs todo "Update docs" --tags "docs,api"` |
| `adbs list --tasks` | List all tasks | `adbs list --tasks` |
| `adbs list --tasks --status <status>` | Filter tasks by status | `adbs list --tasks --status todo` |
| `adbs list --tasks --priority <level>` | Filter by priority | `adbs list --tasks --priority high` |
| `adbs update <id> <field> <value>` | Update a task | `adbs update task-123 status done` |
| `adbs show <id>` | Show task details | `adbs show task-123` |

### Setup & Maintenance

| Command | Description | Example |
|---------|-------------|---------|
| `adbs setup` | Initialize ADbS | `adbs setup` |
| `adbs check` | Validate current work | `adbs check` |
| `adbs version` | Show version | `adbs version` |
| `adbs help` | Show help | `adbs help` |
| `adbs update-adbs` | Update ADbS itself | `adbs update-adbs` |

---

## Command Details

### `adbs new <name>`

Start a new work item.

**Arguments:**
- `<name>` - Name of the work item (required)

**Examples:**
```bash
adbs new "user authentication"
adbs new "fix memory leak"
adbs new "refactor API layer"
```

**What it does:**
- Creates a new directory in `.adbs/work/`
- Generates a proposal file for planning
- Makes the work visible to your AI assistant

---

### `adbs status`

Show current status of all work and tasks.

**Examples:**
```bash
adbs status
```

**Output:**
```
ADbS Status
===========

Active work: 2
Completed: 5

Active Work:

  • user authentication
  • fix memory leak
```

---

### `adbs done <name>`

Mark work as complete and archive it.

**Arguments:**
- `<name>` - Name of the work item (required)

**Examples:**
```bash
adbs done "user authentication"
adbs done "memory leak"
```

**What it does:**
- Moves work from `.adbs/work/` to `.adbs/archive/`
- Preserves all work history

---

### `adbs show <name>`

Show details of a work item or task.

**Arguments:**
- `<name>` - Name of work item or task ID (required)

**Examples:**
```bash
adbs show "user authentication"
adbs show task-123
```

---

### `adbs list`

List all active work and tasks.

**Options:**
- `--tasks` - List only tasks

**Examples:**
```bash
# List all work and tasks
adbs list

# List only tasks
adbs list --tasks
```

---

### `adbs todo <description>`

Add a new task or reminder.

**Arguments:**
- `<description>` - Task description (required)

**Options:**
- `--priority <level>` - Set priority (high, medium, low)
- `--tags <tags>` - Add tags (comma-separated)

**Examples:**
```bash
adbs todo "Write tests"
adbs todo "Fix critical bug" --priority high
adbs todo "Update API docs" --tags "docs,api"
```

---

### `adbs update <id> <field> <value>`

Update a task.

**Arguments:**
- `<id>` - Task ID (required)
- `<field>` - Field to update (status, priority)
- `<value>` - New value (required)

**Examples:**
```bash
# Mark task as done
adbs update task-123 status done

# Change priority
adbs update task-456 priority high
```

**Valid Fields:**
- `status` - Values: todo, in-progress, done
- `priority` - Values: high, medium, low

---

### `adbs setup`

Initialize ADbS in your project.

**Examples:**
```bash
adbs setup
```

**What it does:**
- Creates `.adbs/` directory structure
- Detects your IDE
- Generates IDE-specific rules
- Migrates old structure if upgrading

---

### `adbs check`

Validate current work state.

**Examples:**
```bash
adbs check
```

**Output:**
```
Checking work...
  ✓ 2 active work item(s)

Active Work:
  • user authentication
  • fix memory leak
```

---

### `adbs version`

Show ADbS version.

**Examples:**
```bash
adbs version
```

**Output:**
```
ADbS version 1.0.0
```

---

### `adbs help`

Show help message with all commands.

**Examples:**
```bash
adbs help
```

---

## Directory Structure

### `.adbs/`

Main ADbS directory containing all work and state.

```
.adbs/
├── work/           # Active work items
│   └── 2025-12-30-user-authentication/
│       └── proposal.md
├── archive/        # Completed work
│   └── 2025-12-29-fix-bug/
│       └── proposal.md
└── internal/       # Internal state (can be gitignored)
```

### `.adbs-tasks.json`

Task database in JSON format. Managed automatically by ADbS.

---

## Configuration

### IDE Rules

ADbS generates rules for your IDE automatically:

| IDE | Rules Location |
|-----|----------------|
| Cursor | `.cursor/rules/` |
| Windsurf | `.windsurf/rules/` |
| Zed | `.rules` |
| VS Code | `.vscode/` |

### Regenerating Rules

If you switch IDEs or update ADbS:

```bash
adbs setup
```

---

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ADBS_DIR` | ADbS directory location | `.adbs` |
| `BEADS_BINARY` | Path to Beads binary (if using) | `bin/beads/bd` |

**Example:**
```bash
export ADBS_DIR=".my-custom-adbs"
adbs setup
```

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error (invalid command, missing argument, etc.) |

---

## Tips

### Fuzzy Matching

Work names support fuzzy matching:

```bash
# These all work if you have "user-authentication"
adbs done "user-authentication"
adbs done "authentication"
adbs done "auth"
```

### No Command = Status

Running `adbs` with no command shows status:

```bash
adbs
# Same as: adbs status
```

### Combining Work and Tasks

Use work items for features, tasks for todos:

```bash
adbs new "payment integration"
adbs todo "Research payment providers"
adbs todo "Implement Stripe"
adbs todo "Add tests"
```

---

For more information, see the [User Guide](USER_GUIDE.md).
