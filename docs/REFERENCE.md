# ADbS Reference Guide

## Command Reference

### General
| Command | Description |
| :--- | :--- |
| `adbs init` | Initialize Classic SDD workflow. |
| `adbs status` | Show current workflow stage and active tasks. |
| `adbs validate` | Check if current SDD stage requirements are met. |
| `adbs next` | Advance to next SDD stage. |

### OpenSpec Workflow
| Command | Description |
| :--- | :--- |
| `adbs openspec init` | Initialize OpenSpec workflow in `.openspec/`. |
| `adbs openspec status` | Show active proposals and specs. |
| `adbs openspec propose <name>` | Create a new change proposal. |
| `adbs openspec archive <id>` | Archive a completed change proposal. |
| `adbs openspec specs` | List current system specifications. |

### Rules Generator
| Command | Description |
| :--- | :--- |
| `adbs rules generate [platform]` | Generate/update IDE rule files. |
| `adbs rules check` | Check what rules would be generated. |
| `adbs rules list` | Alias for check. |

### Task Management
| Command | Description |
| :--- | :--- |
| `adbs task create <desc> [opts]` | Create a new task. |
| `adbs task list` | List tasks (supports filtering). |
| `adbs task update <id> [opts]` | Update task status or details. |
| `adbs task comment <id> <msg>` | Add a comment to a task. |

### Plan Management
| Command | Description |
| :--- | :--- |
| `adbs plan generate` | Generate next plan ID. |
| `adbs plan current` | Get current active plan ID. |
| `adbs plan create` | Create new plan and return ID. |
| `adbs plan get <id>` | Display content of a plan. |
| `adbs plan list` | List all plans. |
| `adbs plan link <id> <type> <file>` | Link artifact (reqs/design) to plan. |

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
*   **`tests/`**: BATS test suite.
