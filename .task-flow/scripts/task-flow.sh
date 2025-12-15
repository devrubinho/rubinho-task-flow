#!/bin/bash

TASK_FLOW_DIR="$(pwd)/.task-flow"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

show_header() {
  clear
  echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC}        ${MAGENTA}✨ Rubinho Task Flow - Task Manager ✨${NC}          ${CYAN}║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

pause() {
  echo -e "\n${YELLOW}Press ENTER to continue...${NC}"
  read -r
}

[ ! -d "$TASK_FLOW_DIR" ] && {
  show_header
  echo -e "${RED}❌ Error: Rubinho Task Flow not found in this directory${NC}\n"
  echo -e "${YELLOW}This script must be run in a project where Task Flow is installed.${NC}\n"
  echo -e "${CYAN}To install, run: ${BLUE}~/.rubinho-task-flow/install.sh${NC}\n"
  exit 1
}

while true; do
  show_header
  echo -e "${GREEN}📋 What do you want to do?${NC}\n"
  echo -e "${BLUE}1.${NC} ${CYAN}Generate tasks from .task-flow-tasks.txt${NC}"
  echo -e "${BLUE}2.${NC} ${CYAN}View all tasks status${NC}"
  echo -e "${BLUE}3.${NC} ${CYAN}View task details${NC}"
  echo -e "${BLUE}4.${NC} ${CYAN}Mark subtask as done${NC}"
  echo -e "${BLUE}5.${NC} ${CYAN}Edit tasks.txt${NC}"
  echo -e "${BLUE}0.${NC} ${RED}Exit${NC}\n"

  read -r -p "$(echo -e ${YELLOW}Choose an option [0-5]: ${NC})" choice
  echo ""

  case $choice in
    1)
      show_header
      [ -x "$TASK_FLOW_DIR/scripts/generate.sh" ] && bash "$TASK_FLOW_DIR/scripts/generate.sh" || echo -e "${RED}❌ Error: generate.sh not found${NC}"
      pause
      ;;

    2)
      show_header
      [ -x "$TASK_FLOW_DIR/scripts/status.sh" ] && bash "$TASK_FLOW_DIR/scripts/status.sh" || echo -e "${RED}❌ Error: status.sh not found${NC}"
      pause
      ;;

    3)
      show_header
      echo -e "${YELLOW}Enter task ID:${NC}\n"
      read -r -p "ID: " task_id
      [ -z "$task_id" ] && echo -e "\n${RED}❌ ID cannot be empty${NC}" || bash "$TASK_FLOW_DIR/scripts/show.sh" "$task_id"
      pause
      ;;

    4)
      show_header
      echo -e "${YELLOW}Enter subtask ID (format: task_id.subtask_id):${NC}"
      echo -e "${CYAN}Example: 1.2${NC}\n"
      read -r -p "ID: " subtask_id
      [ -z "$subtask_id" ] && echo -e "\n${RED}❌ ID cannot be empty${NC}" || bash "$TASK_FLOW_DIR/scripts/done.sh" "$subtask_id"
      pause
      ;;

    5)
      show_header
      TASKS_FILE="$TASK_FLOW_DIR/.task-flow-tasks.txt"

      [ ! -f "$TASKS_FILE" ] && {
        echo -e "${YELLOW}.task-flow-tasks.txt not found. Creating...${NC}\n"
        cat > "$TASKS_FILE" << 'EOF'
# Rubinho Task Flow - Task Definitions

## How to use:
# 1. Add tasks using: - [ ] Task description
# 2. Run 'Generate tasks' from menu

## Tasks:

EOF
      }

      if command -v nano &> /dev/null; then
        nano "$TASKS_FILE"
      elif command -v vim &> /dev/null; then
        vim "$TASKS_FILE"
      elif command -v vi &> /dev/null; then
        vi "$TASKS_FILE"
      else
        echo -e "${YELLOW}No text editor found.${NC}"
        echo -e "${CYAN}File located at: $TASKS_FILE${NC}\n"
        echo -e "${YELLOW}Edit manually and add tasks in format:${NC}"
        echo -e "- [ ] My first task"
        echo -e "- [ ] Second task\n"
      fi
      ;;

    0)
      show_header
      echo -e "${GREEN}👋 Goodbye!${NC}\n"
      exit 0
      ;;

    *)
      echo -e "${RED}❌ Invalid option. Try again.${NC}"
      sleep 1
      ;;
  esac
done
