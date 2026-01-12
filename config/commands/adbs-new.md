---
name: "ADbS: New Work"
description: "Start new feature or fix with ADbS"
---

# ADbS: New Work

Start a new work item with ADbS (AI Don't Be Stupid).

## Usage

This command will help you start a new feature or fix. You can optionally use `--ai-generate` to automatically generate a complete workflow (requirements, proposal, design, tasks).

**Simple workflow:**
```bash
adbs new "feature-name"
```

**AI-powered workflow:**
```bash
adbs new "feature-name" --ai-generate
```

## What happens

1. Creates a new work directory in `.adbs/work/`
2. Sets up the workflow structure
3. If `--ai-generate` is used, automatically generates:
   - Requirements document
   - Proposal document
   - Design document
   - Task breakdown

## Next steps

After creating new work:
- Check status: `adbs status`
- View workflow: `adbs workflow "feature-name"`
- Add tasks: `adbs todo "task description"`
