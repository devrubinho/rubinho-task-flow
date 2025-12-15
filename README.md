# Rubinho Task Flow

<div align="center">

![Claude](https://img.shields.io/badge/Claude-Sonnet%204.5-8A2BE2?style=for-the-badge&logo=anthropic&logoColor=white)
![Cursor](https://img.shields.io/badge/Cursor-IDE-blue?style=for-the-badge&logo=visual-studio-code&logoColor=white)
![Task Flow](https://img.shields.io/badge/Task%20Flow-AI%20Powered-green?style=for-the-badge)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)

**One-command setup for Claude Code, Cursor, and Rubinho Task Flow in any project**

</div>

---

## Overview

A centralized repository of development configurations and rules that can be instantly installed in any project. Provides complete setup for Claude Code, Cursor IDE, and Rubinho Task Flow - a simple AI-powered task management system.

### Key Features

- **One-Command Installation** - Complete setup with `./install-rules.sh`
- **Simple Task Management** - Define tasks in plain text, AI generates detailed subtasks
- **Claude as Default** - Claude Code Sonnet configured across all tools
- **Discrete .gitignore** - AI configs hidden with generic comments
- **Zero Configuration** - Ready to use immediately
- **Rubinho Task Flow** - AI-powered task management with simple text interface

## System Requirements

- **Operating System:** macOS, Linux, or Windows (WSL)
- **Tools:** Git, Bash, Node.js
- **Required:** Claude Code CLI or Cursor IDE (with Pro subscription)

## Installation

### Quick Start

```bash
# 1. Clone this repository (one time only)
git clone https://github.com/rubensdeoliveira/rubinho-task-flow.git ~/.rubinho-task-flow

# 2. Install in your project
~/.rubinho-task-flow/install.sh
# Enter your project path when prompted

# 3. Go to your project and run the task manager
cd /path/to/your/project
.task-flow/scripts/task-flow.sh
```

**That's it!** The interactive menu guides you through everything.

### What Gets Installed

The script creates and configures:

```
your-project/
├── .cursor/
│   ├── rules/                    # All development rules
│   │   ├── cursor_rules.mdc
│   │   ├── self_improve.mdc
│   │   ├── code_comments.mdc
│   │   ├── commit_practices.mdc
│   │   ├── git_control.mdc
│   │   └── task_execution.mdc
│   └── mcp.json                  # MCP server config
│
├── .claude/
│   └── settings.json             # Claude Code settings
│
├── .task-flow/                   # Rubinho Task Flow
│   ├── .task-flow-tasks.txt       # Plain text task definitions (edit this!)
│   └── scripts/                  # Management scripts (don't edit)
│       ├── task-flow.sh          # Task Flow CLI
│       ├── generate.sh           # Calls Claude Code to generate tasks
│       ├── status.sh             # Status viewer
│       ├── show.sh               # Task details viewer
│       ├── done.sh               # Mark tasks as done
│       ├── tasks.json            # Generated tasks (auto)
│       └── status.json           # Task status tracking (auto)
│
└── .gitignore                    # Updated with discrete entries
```

## Configuration

No additional configuration required! Just make sure you have:
- Claude Code CLI installed, OR
- Cursor IDE with an active Pro subscription

**You're ready!**

## Usage

### Rubinho Task Flow - Interactive Menu

Just run the script and navigate through the menu:

```bash
.task-flow/scripts/task-flow.sh
```

O menu apresenta as seguintes opções:

**Menu Principal** (quando executado fora de um projeto):
1. 🚀 **Instalar em um projeto** - Instala o Task Flow em qualquer projeto
2. 📋 **Gerenciar tasks** - Acessa o menu de gerenciamento de tasks
0. 🚪 **Sair**

**Menu de Gerenciamento** (quando executado dentro de um projeto):
1. 🤖 **Gerar tasks do arquivo .task-flow-tasks.txt** - AI transforma suas tasks em subtasks detalhadas
2. 📊 **Ver status de todas as tasks** - Visualiza progresso geral
3. 🔍 **Ver detalhes de uma task** - Mostra instruções detalhadas
4. ✅ **Marcar subtask como concluída** - Atualiza progresso
5. ✏️ **Editar .task-flow-tasks.txt** - Abre o editor para adicionar/modificar tasks
0. 🚪 **Sair**

**Complete workflow:**

```bash
# 1. Clone the repository (one time)
git clone https://github.com/rubensdeoliveira/rubinho-task-flow.git ~/.rubinho-task-flow

# 2. Install in your project
~/.rubinho-task-flow/install.sh
# Enter: /path/to/my-project

# 3. Go to your project
cd /path/to/my-project

# 4. Run the task manager
.task-flow/scripts/task-flow.sh

# 5. Use the menu options:
#    - Option 5: Edit .task-flow-tasks.txt and add your tasks
#    - Option 1: Generate tasks with AI
#    - Option 2: View status
#    - Option 3: View task details
#    - Option 4: Mark subtask as done
```

**Key features:**
- ✅ **.task-flow/** directory is automatically **gitignored**
- ✅ Your task progress stays **local and private**
- ✅ Team members can use their own tasks without conflicts
- ✅ AI generates detailed, actionable subtasks from simple descriptions

### Cursor Integration

All rules are automatically active in Cursor. The IDE will:
- Follow coding standards from `.cursor/rules/`
- Integrate with Rubinho Task Flow workflows
- Follow commit and git practices

### Claude Code Integration

Claude Code is pre-configured with:
- Custom settings
- Rubinho Task Flow integration
- Development best practices

## What's Configured

### Development Rules

Included rules for:
- Cursor rule formatting
- Self-improvement processes
- Code commenting standards
- Commit practices
- Git command control
- Task execution management

### Rubinho Task Flow

Simple yet powerful task management:
- **Plain Text Input**: Write tasks in `.task-flow/.task-flow-tasks.txt` using simple format
- **AI-Powered Generation**: Transforms simple tasks into detailed, actionable subtasks
- **Smart Instructions**: Each subtask includes context, objectives, implementation steps, and validation
- **Simple Tracking**: JSON-based status management with easy CLI commands
- **Progress Monitoring**: Clear visual feedback on task completion

## Discrete .gitignore

The installer adds these entries to `.gitignore`:

```gitignore
.claude/
.cursor/
.task-flow/
CLAUDE.md
```

**Why discrete?**
- No comments explaining what they are
- No mention of "AI", "Claude", or "Anthropic"
- Everything related to Rubinho Task Flow stays local
- Clean git history without AI tooling files

## Updating Projects

To update configs in an existing project:

```bash
~/.rubinho-task-flow/install.sh
# Enter the project path
```

The installer will:
- ✅ Copy new rules
- ✅ **Overwrite all configs** with latest versions
- ✅ Update .gitignore if needed
- ✅ Update Task Flow scripts

**Note**: The installer automatically adds `.task-flow/` to `.gitignore`, keeping your task progress private and out of version control.

## Project Structure

This repository contains:

```
rubinho-task-flow/
├── .cursor/
│   ├── mcp.json.example          # MCP config template
│   └── rules/                    # All development rules
│
├── .claude/
│   └── settings.json             # Claude Code settings
│
├── .task-flow/
│   ├── .task-flow-tasks.txt      # Task definitions template
│   └── scripts/                  # Management scripts
│       ├── task-flow.sh          # Task Flow CLI (copied to projects)
│       ├── generate.sh           # Calls Claude Code to generate tasks
│       ├── status.sh             # Status viewer
│       ├── show.sh               # Task details viewer
│       ├── done.sh               # Mark tasks as done
│       ├── tasks.json            # Generated tasks (auto)
│       └── status.json           # Task status tracking (auto)
│
├── .gitignore                    # Template gitignore
├── CLAUDE.md                     # Main Claude instructions
├── install.sh                    # Installation script
└── README.md                     # This file
```

## Important Notes

- ⚠️ This is a **template repository** - don't use Rubinho Task Flow here
- ✅ Use Rubinho Task Flow in **projects that receive** the configs via installation
- 🔄 Installer **always overwrites** existing configs
- 🤫 .gitignore entries are **discrete** (no AI mentions)
- 🎯 Works with **Claude Code CLI** or **Cursor Pro**
- 📦 Task Flow directory (`.task-flow/`) is **automatically gitignored**
- 📝 Define tasks in `.task-flow/.task-flow-tasks.txt` using simple format: `- [ ] Task description`
- 🚀 Simple installation with `install.sh`, management with `.task-flow/scripts/task-flow.sh`
- 🔒 **No API keys needed** - uses Claude Code or Cursor Pro built-in AI

## Contributing

Contributions welcome! To add new rules or improve templates:

1. Fork this repository
2. Create a feature branch
3. Add your rules/templates following existing formats
4. Test in a real project
5. Submit a Pull Request

## License

MIT License - See LICENSE file for details

## Support

For issues or questions:
- Open an issue on GitHub
- Check existing issues for solutions
- Refer to CHANGELOG.md for recent updates

---

<div align="center">

**Made with ❤️ for developers who love simple, AI-powered workflows**

[⬆ Back to top](#rubinho-task-flow)

</div>
