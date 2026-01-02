---
name: "ADbS: Status"
description: "Show current ADbS work status"
---

# ADbS: Status

Show the current status of all active work items.

## Usage

```bash
adbs status
```

## What it shows

- **Active work items**: All work currently in progress
- **Current workflow stage**: Planning, implementing, or done
- **Recent tasks**: Tasks associated with active work
- **Quick actions**: Suggested next steps

## Example output

```
Active Work:
  • user-authentication (planning)
  • payment-integration (implementing)

Tasks:
  • Write login tests
  • Add OAuth2 support

Next: Run 'adbs workflow <name>' to see detailed progress
```

## Related commands

- `adbs new "name"` - Start new work
- `adbs workflow "name"` - View detailed workflow state
- `adbs list` - List all work and tasks
