# Contributing to ADbS

We welcome contributions! ADbS is designed to be a lightweight, shell-based "context manager" for AI coding.

## Core Principles

1.  **Dogfooding**: Use ADbS to build ADbS.
    *   For small features, use **OpenSpec** (`adbs openspec propose`).
    *   For large changes, use **SDD** (`adbs init`).
2.  **Pure Shell**:
    *   Core logic (`lib/`) must be POSIX-compliant shell (`#!/bin/bash`).
    *   Avoid dependencies like Python/Node/Go for the core installation and validation loops if possible.
    *   If you need complex logic (like JSON parsing), provide fallbacks (jq -> python3 -> awk).
3.  **Platform Agnostic**:
    *   Must work on MacOS, Linux, Windows (via Git Bash/WSL).
    *   PowerShell scripts (`.ps1`) are maintained as wrappers for Windows users.

## Project Structure

*   `bin/`: Entry points.
*   `lib/`: Core logic.
*   `templates/`: Rule templates.
*   `docs/`: Documentation.

## Usage

1.  Fork & Clone.
2.  Run `adbs status` to check the current dev state.
3.  Submit a PR!
