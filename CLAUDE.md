# Claude Code Instructions

## Models

Claude and Cursor use the **default model** of each environment. No specific model is set in this project; do not specify or require a particular model.

## Development Rules

All development rules are automatically loaded from `.cursor/rules/` directory. These rules include:
- Cursor rules formatting guidelines
- Self-improvement processes
- Code commenting standards
- Commit practices
- Git command control
- Task execution management with RBIN Task Flow

## RBIN Task Flow

This project uses RBIN Task Flow for task management:
- **Task Definition**: Edit `.task-flow/tasks.input.txt` using simple format: `- Task description`
- **AI Commands**: Use AI-powered commands for task management:
  - `task-flow: sync` - Synchronize tasks from tasks.input.txt
  - `task-flow: think` - Analyze code and suggest new tasks
  - `task-flow: status` - View current task status
  - `task-flow: run next X` - Work on next X subtasks
  - `task-flow: run X` - Execute all pending subtasks of task X (simplified - no "task" needed)
  - `task-flow: run X,Y` - Execute multiple tasks (comma-separated)
  - `task-flow: run all` - Execute all tasks
  - `task-flow: review X` - Review specific task(s) (comma-separated or "all")
  - `task-flow: refactor X` - Refactor specific task(s) (comma-separated or "all")
  - `task-flow: estimate X` - Estimate time for task X (simplified - no "task" needed)
  - `task-flow: estimate X,Y` - Estimate multiple tasks (comma-separated)
  - `task-flow: estimate all` - Estimate all tasks
  - `task-flow: report X` - Generate implementation report for task X (simplified - no "task" needed)
  - `task-flow: report X,Y` - Generate reports for multiple tasks (comma-separated)
  - `task-flow: report all` - Generate reports for all tasks
- **Files**:
  - `.task-flow/tasks.input.txt` - Define your tasks here
  - `.task-flow/tasks.status.md` - Auto-generated status (DO NOT EDIT manually)
  - `.task-flow/.internal/` - Internal system files (ignore)

Follow all rules defined in `.cursor/rules/` for consistent development practices.
