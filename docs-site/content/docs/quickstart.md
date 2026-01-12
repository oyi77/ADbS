---
title: "Quick Start"
description: "Get started with ADbS quickly"
date: 2025-01-01
---

# Quick Start Guide

Get up and running with ADbS in minutes.

## Installation

Choose your preferred method:

**Linux/macOS:**
```bash
curl -sSL https://raw.githubusercontent.com/oyi77/ADbS/main/distribution/install.sh | bash
```

**Windows (PowerShell):**
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/oyi77/ADbS/main/distribution/install.ps1" -UseBasicParsing | Invoke-Expression
```

See the [Installation Guide](/installation/) for more options.

## Initialization

Navigate to your project root and run:

```bash
adbs setup
```

This will:
- Create the `.adbs/` directory structure
- Detect your IDE (Cursor, Windsurf, Zed, etc.)
- Generate IDE-specific rules automatically
- Set up everything you need

## Your First Work Item

Start working on something:

```bash
adbs new "my first feature"
```

This creates a structured work item that your AI assistant can see.

## Check Status

See what you're working on:

```bash
adbs status
```

## Add Tasks

Keep track of things to do:

```bash
adbs todo "Write tests"
adbs todo "Update documentation"
```

## Complete Work

When you're done:

```bash
adbs done "my first feature"
```

## Next Steps

- Read the [Usage Guide](/usage/) for detailed instructions
- Check out the [Demo](/demo/) to see more examples
- Explore the [Documentation](/docs/) for advanced features

---

**That's it!** You're ready to use ADbS. Your AI assistant will now stay focused on your work.

