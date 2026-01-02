# ADbS: AI Development Assistant

**Keep your AI focused. Stay organized. Ship faster.**

![Tests](https://github.com/oyi77/ADbS/workflows/Tests/badge.svg)
![Coverage](https://img.shields.io/badge/coverage-65%20tests-brightgreen)

ADbS helps you work with AI coding assistants (Cursor, Windsurf, Zed, and more) by keeping them focused on your goals and preventing hallucinations.

---

## 🚀 Quick Start

### Installation

One command to rule them all. Detects your OS and IDE automatically.

```bash
curl -sSL https://raw.githubusercontent.com/oyi77/ADbS/main/install.sh | bash
```

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/oyi77/ADbS/main/install.ps1" -UseBasicParsing | Invoke-Expression
```

### First Steps

```bash
# Initialize ADbS in your project
adbs setup

# Start working on something
adbs new "user authentication"

# Check what you're working on
adbs status

# Add a reminder
adbs todo "Write tests for login"

# Mark work as complete
adbs done "user authentication"
```

That's it! No configuration needed.

---

## 💡 What is ADbS?

When working with AI coding assistants, you've probably experienced:
- 🤯 AI forgetting what you asked it to do
- 🔄 AI going in circles or hallucinating solutions
- 📝 Losing track of what needs to be done
- 🎯 Difficulty keeping AI focused on the goal

**ADbS solves this** by:
- ✅ Keeping AI focused with structured work items
- ✅ Organizing your work automatically
- ✅ Preventing AI hallucinations with clear context
- ✅ Working seamlessly with your IDE

---

## 📖 Commands

### Work Management
```bash
adbs new <name>              # Start new feature or fix
adbs status                  # Show current work
adbs done <name>             # Mark work as complete
adbs show <name>             # Show work details
```

### Task Management
```bash
adbs todo <description>      # Add a task or reminder
adbs list                    # List all work and tasks
adbs update <id> <field>     # Update a task
```

### Setup & Maintenance
```bash
adbs setup                   # Initialize ADbS
adbs check                   # Validate current work
adbs version                 # Show version
adbs help                    # Show help
```

---

## 🎯 How It Works

1. **Start Work**: `adbs new "feature name"` creates a structured work item
2. **AI Reads Context**: Your AI assistant automatically sees what you're working on
3. **Stay Focused**: AI stays on track with clear goals and context
4. **Track Progress**: Use `adbs status` to see what's active
5. **Complete**: `adbs done "feature name"` archives the work

---

## 🧩 IDE Integration

ADbS works with:
- **Cursor**: Auto-generates `.cursor/rules`
- **Windsurf**: Native Cascade support
- **Zed**: Project-specific rules
- **VS Code**: Full integration
- **Other AI IDEs**: Universal support

Rules are generated automatically when you run `adbs setup`.

---

## 📚 Documentation

- **[User Guide](docs/USER_GUIDE.md)**: Detailed usage instructions
- **[Reference](docs/REFERENCE.md)**: Complete command reference
- **[Architecture](docs/ARCHITECTURE.md)**: Technical deep dive (for developers)
- **[Contributing](docs/CONTRIBUTING.md)**: How to contribute

---

## 🎨 Example Workflow

```bash
# Start a new feature
$ adbs new "add payment processing"
✓ Started new work: add payment processing

Next steps:
  1. Edit the work plan: .adbs/work/2025-12-30-add-payment-processing/proposal.md
  2. Check status: adbs status
  3. Mark done: adbs done "add payment processing"

# Add some tasks
$ adbs todo "Research payment providers"
✓ Added task: Research payment providers

$ adbs todo "Implement Stripe integration"
✓ Added task: Implement Stripe integration

# Check status
$ adbs status
ADbS Status
===========

Active work: 1
Completed: 0

Active Work:

  • add payment processing

# Work on it with your AI assistant...
# AI stays focused on the payment processing feature

# Mark as done
$ adbs done "add payment processing"
✓ Completed: add payment processing

Archived to: .adbs/archive/2025-12-30-add-payment-processing
```

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](docs/CONTRIBUTING.md).

---

## 📄 License

MIT

---

**Made with ❤️ for developers working with AI assistants**
