# Claude Code Instructions

## Development Rules

All development rules are automatically loaded from `.cursor/rules/` directory. These rules include:
- Cursor rules formatting guidelines
- Self-improvement processes
- Code commenting standards
- Commit practices
- Git command control
- Task execution management with Rubinho Task Flow

## Rubinho Task Flow

This project uses Rubinho Task Flow for task management:
- **Task Definition**: Edit `.task-flow/.task-flow-tasks.txt` using format `- [ ] Task description`
- **CLI**: Use `.task-flow/scripts/task-flow.sh` for all task management operations
- **Interactive Menu**: The script provides an interactive menu with options to:
  - Generate tasks from .task-flow-tasks.txt using AI
  - View task status and progress
  - View detailed task instructions
  - Mark subtasks as done
  - Edit .task-flow-tasks.txt directly

Follow all rules defined in `.cursor/rules/` for consistent development practices.
