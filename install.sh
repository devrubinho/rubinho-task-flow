#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
  echo -e "${CYAN}║${NC}        ${MAGENTA}✨ Rubinho Task Flow - Installation ✨${NC}          ${CYAN}║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

pause() {
  echo -e "\n${YELLOW}Press ENTER to continue...${NC}"
  read -r
}

install_to_project() {
  local target="$1"

  [ ! -d "$target" ] && echo -e "${RED}❌ Directory not found: $target${NC}" && exit 1
  [ ! -w "$target" ] && echo -e "${RED}❌ No write permission${NC}" && exit 1

  target="$(cd "$target" && pwd 2>/dev/null)"

  if [ "$target" = "$SCRIPT_DIR" ]; then
    echo -e "${YELLOW}⚠️  Installing in repository itself. Continue? (y/N)${NC}"
    read -r response
    [[ ! "$response" =~ ^[yY]$ ]] && echo -e "${BLUE}Cancelled.${NC}" && exit 0
  fi

  echo -e "${BLUE}🚀 Installing...${NC}"
  echo -e "${BLUE}📁 Target: $target${NC}\n"

  mkdir -p "$target"/{.cursor/rules,.claude,.task-flow}

  [ -d "$SCRIPT_DIR/.cursor/rules" ] &&
    cp -r "$SCRIPT_DIR/.cursor/rules/"* "$target/.cursor/rules/" &&
    echo -e "${GREEN}✅ Cursor rules${NC}"

  [ -d "$SCRIPT_DIR/.claude" ] &&
    cp -r "$SCRIPT_DIR/.claude/"* "$target/.claude/" 2>/dev/null &&
    echo -e "${GREEN}✅ Claude settings${NC}"

  if [ -d "$SCRIPT_DIR/.task-flow" ]; then
    cp "$SCRIPT_DIR/.task-flow/"*.{js,sh} "$target/.task-flow/" 2>/dev/null
    chmod +x "$target/.task-flow/"*.sh 2>/dev/null
    [ ! -f "$target/.task-flow/tasks.txt" ] &&
      [ -f "$SCRIPT_DIR/.task-flow/tasks.txt" ] &&
      cp "$SCRIPT_DIR/.task-flow/tasks.txt" "$target/.task-flow/tasks.txt"
    echo -e "${GREEN}✅ Task Flow scripts${NC}"
  fi

  cp "$SCRIPT_DIR/rubinho-task-flow.sh" "$target/rubinho-task-flow.sh"
  chmod +x "$target/rubinho-task-flow.sh"
  echo -e "${GREEN}✅ CLI${NC}"

  [ ! -f "$target/.gitignore" ] && touch "$target/.gitignore"

  if ! grep -q "^\.task-flow/tasks\.json$" "$target/.gitignore" 2>/dev/null; then
    cat >> "$target/.gitignore" << 'EOF'

# IDE and tools
.claude/
.cursor/rules/*.local.mdc

# Task management
.task-flow/tasks.json
.task-flow/status.json
EOF
    echo -e "${GREEN}✅ .gitignore${NC}"
  fi

  echo -e "\n${GREEN}✨ Done!${NC}\n"
  echo -e "${BLUE}Next steps:${NC}"
  echo -e "   ${YELLOW}cd $target${NC}"
  echo -e "   ${YELLOW}./rubinho-task-flow.sh${NC}\n"
}

main() {
  show_header
  echo -e "${YELLOW}🚀 Install in a project${NC}\n"
  echo -e "${BLUE}Project path:${NC}"
  echo -e "${CYAN}(press ENTER to exit)${NC}\n"
  read -r -p "Path: " path

  [ -z "$path" ] && show_header && echo -e "${GREEN}👋 Goodbye!${NC}\n" && exit 0

  install_to_project "$path"
  pause

  show_header
  echo -e "${CYAN}Install in another project? (y/N)${NC}\n"
  read -r response

  [[ "$response" =~ ^[yY]$ ]] && main || (show_header && echo -e "${GREEN}👋 Goodbye!${NC}\n")
}

main
