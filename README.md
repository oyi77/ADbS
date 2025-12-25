# ADbS: The Agentic Workflow Enforcer

**Prevents AI hallucinations by forcing your agents to "Think Before They Code".**

ADbS (Ai Dont be Stupid) is a cross-platform context manager and workflow enforcer designed for the new generation of AI-powered IDEs (**Cursor**, **Windsurf**, **Trae**, **Zed**). It injects structured rules into your environment, ensuring your AI follows a strict **Specification-Driven Development (SDD)** or **OpenSpec** process.

---

### 🚀 Why ADbS?

*   **🧠 Context Mastery**: Stops your AI from forgetting the plan. ADbS manages the "context window" effectively using structured markdown files.
*   **🤖 Universal Agent Support**: Automatically detects your environment and generates the correct `.mdc` or `.cursor/rules` files.
*   **🛡️ Hallucination Shield**: Forces a "Validation" step. The AI cannot write code until it has proven it understands the requirements.
*   **⚡ Two Powerful Workflows**:
    *   **OpenSpec**: Agile, proposal-based workflow for rapid feature iteration.
    *   **Classic SDD**: Robust, stage-based workflow (Requirements -> Design -> Tasks) for complex architecture.

### 📦 Installation

One command to rule them all. Detects your OS (Mac/Linux/Windows) and IDE automatically.

```bash
curl -sSL https://raw.githubusercontent.com/your-username/ADbS/main/install.sh | bash
```

### 📚 Documentation

Detailed documentation is available in the **`docs/`** directory:

*   **[User Guide](docs/USER_GUIDE.md)**: Instructions for OpenSpec and Classic workflows.
*   **[Reference Guide](docs/REFERENCE.md)**: Commands, configuration, and directory structure.
*   **[Architecture](docs/ARCHITECTURE.md)**: Deep dive into ADbS internals.
*   **[Contributing](docs/CONTRIBUTING.md)**: How to help build ADbS.

### 🧩 Integrations

*   **Cursor**: Auto-generates `.cursor/rules`.
*   **Windsurf**: Supports native Cascade flows.
*   **Trae & Zed**: Full project rule support.
*   **Beads**: Optional integration with the [Beads](https://github.com/steveyegge/beads) task manager.

### 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](docs/CONTRIBUTING.md).

---

**License**: MIT


