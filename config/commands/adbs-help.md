---
name: "ADbS: Help"
description: "Show ADbS help and available commands"
---

# ADbS: Help

Get help with ADbS (AI Don't Be Stupid) commands and workflow.

## Usage

```bash
adbs help
```

## Quick Reference

### Work Management
- `adbs new "name"` - Start new feature or fix
- `adbs status` - Show current work
- `adbs done "name"` - Mark work as complete
- `adbs show "name"` - Show work details
- `adbs list` - List all work and tasks

### AI Orchestration
- `adbs workflow "name"` - Show workflow state
- `adbs progress "name"` - Check if ready to advance
- `adbs advance "name"` - Move to next state
- `adbs approve "name"` - Approve and advance
- `adbs block "name" "reason"` - Block state

### Task Management
- `adbs todo "description"` - Add a task
- `adbs update <id> <field>` - Update a task

### Setup & Maintenance
- `adbs setup` - Initialize ADbS in project
- `adbs check` - Validate current work
- `adbs version` - Show version

## Workflow Stages

1. **Planning** - Requirements, proposal, design
2. **Implementing** - Code implementation
3. **Done** - Completed and archived

## Learn More

- Documentation: https://github.com/oyi77/ADbS
- Quick Start: Run `adbs new "my-feature" --ai-generate`
- Support: Check the README.md in your project
