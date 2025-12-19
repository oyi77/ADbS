# ADbS Reference Guide

## Command Reference

| Command | Description |
| :--- | :--- |
| `adbs init` | Initialize Classic SDD workflow. |
| `adbs openspec init` | Initialize OpenSpec workflow. |
| `adbs status` | Show current workflow stage and active tasks. |
| `adbs propose <name>` | Create a new OpenSpec proposal. |
| `adbs archive <name>` | Archive an OpenSpec proposal. |
| `adbs validate` | Check if current SDD stage requirements are met. |
| `adbs next` | Advance to next SDD stage. |
| `adbs rules generate` | Regenerate IDE rule files. |
| `adbs task create` | Create a new task. |
| `adbs task list` | List tasks (supports filtering). |

## Configuration

Edit `config/workflow.yaml` to customize behavior:

```yaml
enforcement:
  strict: true            # Block execution if rules aren't met
  require_validation: true # Force `adbs validate` before `adbs next`
```

## Directory Structure

*   **`.sdd/`**: Storage for Classic SDD (Plans, Requirements, Designs).
*   **`.openspec/`**: Storage for OpenSpec (Specs, Changes, Archive).
*   **`.cursor/rules/`**: (or similar) generated rules for your IDE.
*   **`lib/`**: ADbS internal scripts.
*   **`bin/`**: Executable entry points.
