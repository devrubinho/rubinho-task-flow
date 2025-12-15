#!/bin/bash

ROOT_DIR=$(pwd)
TASKS_INPUT="$ROOT_DIR/.task-flow/.task-flow-tasks.txt"
TASKS_OUTPUT="$ROOT_DIR/.task-flow/scripts/tasks.json"
STATUS_OUTPUT="$ROOT_DIR/.task-flow/scripts/status.json"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

[ ! -f "$TASKS_INPUT" ] && {
  echo "❌ Error: .task-flow-tasks.txt not found in .task-flow/"
  exit 1
}

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}📋 Tasks found in .task-flow/.task-flow-tasks.txt:${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
cat "$TASKS_INPUT"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}🤖 To generate tasks:${NC}"
echo ""
echo -e "${CYAN}1. Open another terminal${NC}"
echo -e "${CYAN}2. Ask for claude or cursor: Read .task-flow-tasks.txt and generate detailed subtasks updating task status${NC}"
echo ""
echo -e "${YELLOW}Press ENTER when Claude has finished generating...${NC}"
read -r

if [ -f "$TASKS_OUTPUT" ] && [ -f "$STATUS_OUTPUT" ]; then
  echo ""
  echo -e "${GREEN}✅ Tasks generated successfully!${NC}"
  echo ""
else
  echo ""
  echo -e "${YELLOW}⚠️  Files not found. Make sure Claude Code created:${NC}"
  echo "   - .task-flow/scripts/tasks.json"
  echo "   - .task-flow/scripts/status.json"
  echo ""
fi
