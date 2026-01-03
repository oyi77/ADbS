---
title: "Migration Guide"
description: "Migrating from ADbS 0.x to 1.0"
date: 2025-01-01
---

# Migration Guide

This guide helps you migrate from ADbS 0.x to 1.0.

## What Changed?

ADbS 1.0 introduces a completely new, user-friendly command interface that hides all implementation details.

### Command Changes

| Old Command | New Command | Notes |
|------------|-------------|-------|
| `adbs openspec propose <name>` | `adbs new <name>` | Start new work |
| `adbs openspec status` | `adbs status` | Show status |
| `adbs openspec archive <name>` | `adbs done <name>` | Complete work |
| `adbs task create <desc>` | `adbs todo <desc>` | Add task |
| `adbs task list` | `adbs list --tasks` | List tasks |
| `adbs validate` | `adbs check` | Validate work |
| `adbs init` | `adbs setup` | Initialize |
| `adbs next` | *(removed)* | Auto-managed |
| `adbs set <stage>` | *(removed)* | Auto-managed |

### Directory Changes

| Old Location | New Location | Auto-Migrated? |
|-------------|--------------|----------------|
| `.openspec/changes/` | `.adbs/work/` | ✅ Yes |
| `.openspec/archive/` | `.adbs/archive/` | ✅ Yes |
| `.sdd/` | `.adbs/internal/` | ✅ Yes |
| `.workflow-enforcer/` | `.adbs/internal/` | ✅ Yes |
| `tasks.json` | `.adbs-tasks.json` | ✅ Yes |

### Removed Concepts

These are now internal implementation details:

- ❌ "OpenSpec" (users don't need to know)
- ❌ "SDD stages" (auto-managed)
- ❌ "Beads" (auto-detected backend)
- ❌ "spec-kit" (internal library)

## Automatic Migration

When you first run ADbS 1.0, it will automatically detect your old structure and migrate it.

### What Gets Migrated

1. **Active Work** (`.openspec/changes/`) → `.adbs/work/`
2. **Archived Work** (`.openspec/archive/`) → `.adbs/archive/`
3. **SDD Artifacts** (`.sdd/`) → `.adbs/internal/`
4. **Workflow State** (`.workflow-enforcer/`) → `.adbs/internal/`
5. **Tasks** (`tasks.json`) → `.adbs-tasks.json`

### Backup

Old directories are backed up with `.backup` suffix:
- `.openspec.backup`
- `.sdd.backup`
- `.workflow-enforcer.backup`
- `tasks.json.backup`

You can safely delete these after verifying the migration.

## Manual Migration

If automatic migration doesn't work, you can manually migrate:

```bash
# Run migration manually
cd your-project
adbs setup
```

This will:
1. Detect old structure
2. Prompt for migration
3. Copy all data to new structure
4. Backup old directories

## Step-by-Step Migration

### 1. Update ADbS

```bash
# If installed via git
cd ~/.adbs  # or wherever ADbS is installed
git pull

# If installed via installer
curl -sSL https://raw.githubusercontent.com/oyi77/ADbS/main/distribution/install.sh | bash
```

### 2. Verify Version

```bash
adbs version
# Should show: ADbS version 1.0.0
```

### 3. Run Setup

```bash
cd your-project
adbs setup
```

### 4. Verify Migration

```bash
# Check status
adbs status

# List work
adbs list

# Verify old work is present
ls .adbs/work/
ls .adbs/archive/
```

### 5. Update Your Workflow

Start using new commands:

```bash
# Old way
adbs openspec propose "new-feature"

# New way
adbs new "new-feature"
```

## Troubleshooting

### Migration Didn't Run

If migration didn't happen automatically:

```bash
# Check if old structure exists
ls -la | grep -E '\.(openspec|sdd|workflow-enforcer)'

# Manually trigger migration
adbs setup
```

### Work Not Showing

```bash
# Check work directory
ls .adbs/work/

# Check if it was archived
ls .adbs/archive/

# Check backup
ls .openspec.backup/changes/
```

### Tasks Missing

```bash
# Check new task file
cat .adbs-tasks.json

# Check backup
cat tasks.json.backup
```

### IDE Rules Not Working

```bash
# Regenerate rules
adbs setup

# Check rules were generated
ls .cursor/rules/  # or .windsurf/rules/, etc.
```

## Reverting Migration

If you need to revert to the old structure:

```bash
# Restore backups
mv .openspec.backup .openspec
mv .sdd.backup .sdd
mv .workflow-enforcer.backup .workflow-enforcer
mv tasks.json.backup tasks.json

# Remove new structure
rm -rf .adbs
rm -f .adbs-tasks.json

# Downgrade ADbS
cd ~/.adbs
git checkout v0.1.0
```

## FAQ

### Q: Will my work history be preserved?

**A:** Yes! All work items, tasks, and history are preserved during migration.

### Q: Can I use old commands?

**A:** No, old commands have been removed in 1.0. Use the new command structure.

### Q: What if I have custom scripts using old commands?

**A:** You'll need to update your scripts to use new commands. See the command mapping table above.

### Q: Can I keep using OpenSpec terminology?

**A:** Internally, yes (for developers). But user-facing commands no longer expose this terminology.

### Q: Will this break my CI/CD?

**A:** If you're using ADbS commands in CI/CD, you'll need to update them. The new commands are simpler and more stable.

## What's New in 1.0

Beyond the command changes, 1.0 includes:

- ✨ Simplified user experience
- 🎯 Intent-based commands
- 🔄 Automatic workflow detection
- 📦 Better IDE integration
- 🚀 Faster setup
- 📚 Improved documentation

---

**Welcome to ADbS 1.0! 🎉**

