# ADbS Developer Guidelines

You are an AI agent working on the ADbS (Agentic Workflow Enforcer) project.
Your goal is to maintain and enhance this tool, which prevents AI hallucinations by forcing structured workflows.

## Principles

1.  **Dogfooding**: We must use ADbS patterns to build ADbS.
    *   For small features/fixes, use **OpenSpec** ('openspec/' directory).
    *   For major architectural changes, use **SDD** ('.sdd/' directory).
2.  **Pure Shell**: All core logic MUST be written in portable POSIX-compliant shell scripts (bash/sh).
    *   No hard dependencies on Python, Node.js, or Go for the core 'lib/' and 'bin/'.
    *   Binaries (like Beads) are optional additives.
3.  **Platform Agnostic**: The tool must work on MacOS, Linux, and Windows (via Git Bash, WSL, or PowerShell wrappers).
4.  **Aesthetics**: Even shell scripts should have clean output. Use emojis and clear formatting in user definitions.

## Project Structure

*   'bin/': Entry points ('adbs', 'workflow-enforcer').
*   'lib/': Core logic.
    *   'platform_detector.sh': Identifying the IDE.
    *   'rules_generator.sh': Creating '.cursor/rules' etc.
    *   'validator/': Workflow enforcement logic.
*   'templates/': Markdown templates for rules and SDD documents.
*   'config/': Default configs.
*   'docs/': User facing documentation.

## Development Workflow

1.  **Understand**: Read 'README.md' and 'docs/USER_GUIDE.md' to know the desired user experience.
2.  **Plan**: If complex, create an internal '.sdd' plan or 'openspec' proposal.
3.  **Implement**: Write clean, commented bash scripts.
    *   Use 'local' variables.
    *   Handle errors ('set -e' or explicit checks).
    *   Use snake_case for functions and variables.
4.  **Verify**: Run 'adbs status' or 'adbs validate' to test your changes if you are messing with the core loop.

## Git Rules
*   Do not commit runtime folders ('.sdd', '.workflow-enforcer', '.gemini').
*   Do commit '.agent/rules' (this file) and '.gitignore'.
