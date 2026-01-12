---
name: "ADbS: Done"
description: "Mark work as complete and archive it"
---

# ADbS: Done

Mark a work item as complete and move it to the archive.

## Usage

```bash
adbs done "feature-name"
```

## What happens

1. Validates that the work is complete
2. Archives all documents to `.adbs/archive/`
3. Removes from active work list
4. Updates workflow state to "done"

## Example

```bash
# Complete the user authentication work
adbs done "user-authentication"

# Output:
# ✓ Work 'user-authentication' marked as complete
# ✓ Archived to .adbs/archive/user-authentication-001/
```

## Before marking as done

Make sure you've:
- ✅ Completed all tasks
- ✅ Tested the implementation
- ✅ Reviewed the code
- ✅ Updated documentation

## Related commands

- `adbs status` - Check current work status
- `adbs workflow "name"` - View workflow progress
- `adbs list` - List all work items
