---
name: "ADbS: Workflow"
description: "Show detailed workflow state for a work item"
---

# ADbS: Workflow

Show the detailed workflow state for a specific work item.

## Usage

```bash
adbs workflow "feature-name"
```

## What it shows

- **Current stage**: Planning, implementing, or done
- **Completed steps**: What's been done so far
- **Required documents**: Requirements, proposal, design, tasks
- **Validation status**: Whether ready to advance
- **Next actions**: What to do next

## Example output

```
Work: user-authentication
Stage: planning → implementing

✓ Requirements (requirements.md)
✓ Proposal (proposal.md)
✓ Design (design.md)
⚠ Tasks (tasks.md) - In progress

Status: Ready to advance to implementing
Next: Run 'adbs advance user-authentication'
```

## Workflow progression

```
explore → planning → implementing → done
```

## Related commands

- `adbs progress "name"` - Check if ready to advance
- `adbs advance "name"` - Move to next stage
- `adbs approve "name"` - Approve and advance
- `adbs status` - Show all active work
