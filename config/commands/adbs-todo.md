---
name: "ADbS: Add Task"
description: "Add a new task or reminder to current work"
---

# ADbS: Add Task

Add a new task or reminder to your current work.

## Usage

```bash
adbs todo "task description"
```

## Examples

```bash
# Add a simple task
adbs todo "Write unit tests for login"

# Add a task with details
adbs todo "Implement OAuth2 authentication with JWT tokens"

# Add a reminder
adbs todo "Update API documentation"
```

## What happens

1. Creates a new task entry
2. Associates it with current active work
3. Assigns a unique task ID
4. Tracks task status (pending, in progress, done)

## Managing tasks

```bash
# List all tasks
adbs list --tasks

# Update a task
adbs update <task-id> status done

# View tasks for specific work
adbs show "feature-name"
```

## Task workflow

Tasks can have these statuses:
- **Pending** - Not started yet
- **In Progress** - Currently working on it
- **Done** - Completed
- **Blocked** - Waiting on something

## Related commands

- `adbs list --tasks` - List all tasks
- `adbs update <id> <field>` - Update task
- `adbs status` - Show current work and tasks
