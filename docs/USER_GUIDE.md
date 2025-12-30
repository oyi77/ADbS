# ADbS User Guide

**ADbS (AI Development Assistant)** helps you work more effectively with AI coding assistants by keeping them focused and organized.

## Table of Contents

- [Getting Started](#getting-started)
- [Daily Workflow](#daily-workflow)
- [Managing Work](#managing-work)
- [Managing Tasks](#managing-tasks)
- [Configuration](#configuration)
- [Tips & Best Practices](#tips--best-practices)
- [Troubleshooting](#troubleshooting)

---

## Getting Started

### Installation

Run the installer to automatically detect your OS and IDE:

```bash
# via curl
curl -sSL https://raw.githubusercontent.com/oyi77/ADbS/main/install.sh | bash

# via wget
wget -qO- https://raw.githubusercontent.com/oyi77/ADbS/main/install.sh | bash
```

### First-Time Setup

Initialize ADbS in your project:

```bash
cd your-project
adbs setup
```

This will:
- Create the `.adbs/` directory structure
- Detect your IDE (Cursor, Windsurf, Zed, etc.)
- Generate IDE-specific rules automatically
- Migrate any existing work (if upgrading)

---

## Daily Workflow

### 1. Start Something New

When you want to build a feature or fix a bug:

```bash
adbs new "user authentication"
```

This creates a structured work item that your AI can see and stay focused on.

### 2. Check What You're Working On

```bash
adbs status
```

Shows all active work and tasks.

### 3. Add Reminders

```bash
adbs todo "Write tests for login"
adbs todo "Update documentation"
```

Keep track of things you need to do.

### 4. Complete Your Work

```bash
adbs done "user authentication"
```

Archives the work item when you're finished.

---

## Managing Work

### Creating Work Items

```bash
# Start new work
adbs new "add payment processing"
adbs new "fix login bug"
adbs new "refactor database layer"
```

Each work item gets its own directory in `.adbs/work/` with a proposal file that describes what you're building.

### Viewing Work

```bash
# Show all active work
adbs list

# Show details of specific work
adbs show "payment processing"
```

### Editing Work Plans

After creating work, you can edit the plan:

```bash
# Work plan is at:
.adbs/work/2025-12-30-add-payment-processing/proposal.md
```

Edit this file to describe:
- What you're building
- Why you're building it
- How you'll approach it
- When it's done

Your AI assistant will read this file and stay focused on your plan.

### Completing Work

```bash
adbs done "payment processing"
```

This moves the work to `.adbs/archive/` for your records.

---

## Managing Tasks

### Adding Tasks

```bash
# Simple task
adbs todo "Fix typo in README"

# Task with priority
adbs todo "Implement OAuth" --priority high

# Task with tags
adbs todo "Update API docs" --tags "docs,api"
```

### Listing Tasks

```bash
# List all tasks
adbs list --tasks

# Filter by status
adbs list --tasks --status todo
adbs list --tasks --status done

# Filter by priority
adbs list --tasks --priority high
```

### Updating Tasks

```bash
# Mark task as done
adbs update task-123 status done

# Change priority
adbs update task-456 priority high
```

### Viewing Task Details

```bash
adbs show task-123
```

---

## Configuration

### IDE Integration

ADbS automatically detects your IDE and generates the appropriate rules:

- **Cursor**: Rules in `.cursor/rules/`
- **Windsurf**: Rules in `.windsurf/rules/`
- **Zed**: Rules in `.rules`
- **VS Code**: Rules in `.vscode/`

If you switch IDEs, just run:

```bash
adbs setup
```

### Directory Structure

After setup, your project will have:

```
your-project/
├── .adbs/
│   ├── work/           # Active work items
│   ├── archive/        # Completed work
│   └── internal/       # Internal state (ignore this)
└── .adbs-tasks.json    # Task database
```

You can safely add `.adbs/internal/` to your `.gitignore` if you don't want to commit internal state.

---

## Tips & Best Practices

### 1. Keep Work Items Focused

Each work item should be for one feature or fix:

✅ **Good:**
```bash
adbs new "add user login"
adbs new "add user registration"
```

❌ **Too broad:**
```bash
adbs new "build entire authentication system"
```

### 2. Use Descriptive Names

Make it easy to understand what you're working on:

✅ **Good:**
```bash
adbs new "fix memory leak in image processor"
```

❌ **Too vague:**
```bash
adbs new "fix bug"
```

### 3. Update Work Plans

Edit the proposal file to keep your AI focused:

```markdown
# Add User Login

## What are we building?
A login form with email/password authentication

## Why?
Users need to access their accounts

## How?
1. Create login form component
2. Add authentication API endpoint
3. Implement session management

## Done when...
- [ ] User can log in with email/password
- [ ] Invalid credentials show error
- [ ] Session persists across page refreshes
```

### 4. Use Tasks for Small Items

For quick reminders or small todos:

```bash
adbs todo "Add error handling to login form"
adbs todo "Write unit tests"
```

### 5. Check Status Regularly

```bash
adbs status
```

This helps you and your AI stay aligned on what's active.

---

## Troubleshooting

### "Unknown command" Error

Make sure ADbS is properly installed:

```bash
adbs version
```

If this doesn't work, reinstall:

```bash
curl -sSL https://raw.githubusercontent.com/oyi77/ADbS/main/install.sh | bash
```

### AI Not Seeing My Work

1. Make sure you ran `adbs setup`
2. Check that rules were generated for your IDE
3. Restart your IDE

### Migration Issues

If upgrading from an older version:

```bash
# Manually trigger migration
adbs setup
```

This will migrate your old `.openspec/` or `.sdd/` directories to the new structure.

### Work Not Showing in Status

```bash
# List all work
adbs list

# Check the work directory
ls .adbs/work/
```

If work is missing, it may have been archived:

```bash
ls .adbs/archive/
```

---

## Getting Help

- **Documentation**: Check the [Reference Guide](REFERENCE.md) for all commands
- **Issues**: Report bugs at https://github.com/oyi77/ADbS/issues
- **Contributing**: See [Contributing Guide](CONTRIBUTING.md)

---

**Happy coding with your AI assistant! 🚀**
