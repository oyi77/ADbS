# Tutorial 1: Getting Started with ADbS

## Objective
Learn how to initialize ADbS in a new project and complete the first workflow stages.

## Prerequisites
- ADbS installed (see QUICKSTART.md)
- A terminal (Bash or PowerShell)

## Steps

### 1. Initialize Project
Create a new directory and initialize ADbS:
```bash
mkdir my-new-project
cd my-new-project
adbs init
```

### 2. The Explore Phase
Start the explore phase to define your goal:
```bash
adbs start explore
```
Edit the `explore.md` file (found in `.sdd/explore/` or similar) to describe what you want to build.

### 3. Move to Planning
Once satisfied:
```bash
adbs next
```
This moves you to the Plan phase.

### 4. Create a Plan
Create your first plan:
```bash
adbs plan create "My First Feature" "Implement a basic login system"
```

### 5. Validate
Check if everything is correct:
```bash
adbs validate
```

Congratulations! You've started your journey with ADbS.
