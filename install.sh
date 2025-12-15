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

  [ -f "$SCRIPT_DIR/.claude/settings.json" ] &&
    cp "$SCRIPT_DIR/.claude/settings.json" "$target/.claude/settings.json" &&
    echo -e "${GREEN}✅ Claude settings${NC}"

  [ -f "$SCRIPT_DIR/CLAUDE.md" ] &&
    cp "$SCRIPT_DIR/CLAUDE.md" "$target/CLAUDE.md" &&
    echo -e "${GREEN}✅ Claude instructions${NC}"

  if [ -d "$SCRIPT_DIR/.task-flow" ]; then
    mkdir -p "$target/.task-flow/scripts"
    [ -d "$SCRIPT_DIR/.task-flow/scripts" ] && {
      cp "$SCRIPT_DIR/.task-flow/scripts/"* "$target/.task-flow/scripts/" 2>/dev/null
      chmod +x "$target/.task-flow/scripts/"*.sh 2>/dev/null
    }
    [ ! -f "$target/.task-flow/.task-flow-tasks.txt" ] &&
      [ -f "$SCRIPT_DIR/.task-flow/.task-flow-tasks.txt" ] &&
      cp "$SCRIPT_DIR/.task-flow/.task-flow-tasks.txt" "$target/.task-flow/.task-flow-tasks.txt"
    echo -e "${GREEN}✅ Task Flow scripts${NC}"
  fi

  [ ! -f "$target/.gitignore" ] && touch "$target/.gitignore"

  # Remove old entries if they exist
  sed -i.bak '/^\.claude\/$/d' "$target/.gitignore" 2>/dev/null
  sed -i.bak '/^\.cursor\/$/d' "$target/.gitignore" 2>/dev/null
  sed -i.bak '/^\.task-flow\/$/d' "$target/.gitignore" 2>/dev/null
  sed -i.bak '/^CLAUDE\.md$/d' "$target/.gitignore" 2>/dev/null
  sed -i.bak '/^# Rubinho Task Flow/d' "$target/.gitignore" 2>/dev/null
  sed -i.bak '/^\.cursor\/rules\/$/d' "$target/.gitignore" 2>/dev/null
  sed -i.bak '/^\.task-flow\/scripts\/tasks\.json$/d' "$target/.gitignore" 2>/dev/null
  sed -i.bak '/^\.task-flow\/scripts\/status\.json$/d' "$target/.gitignore" 2>/dev/null
  sed -i.bak '/^\.cursor\/rules\/\*\.local\.mdc$/d' "$target/.gitignore" 2>/dev/null
  sed -i.bak '/^rubinho-task-flow\.sh$/d' "$target/.gitignore" 2>/dev/null
  rm -f "$target/.gitignore.bak" 2>/dev/null

  # Add entries without comments
  {
    echo ""
    echo ".claude/"
    echo ".cursor/"
    echo ".task-flow/"
    echo "CLAUDE.md"
  } >> "$target/.gitignore"

  echo -e "${GREEN}✅ .gitignore updated${NC}"

  echo -e "\n${GREEN}✨ Done!${NC}\n"
  echo -e "${BLUE}Next steps:${NC}"
  echo -e "   ${YELLOW}cd $target${NC}"
  echo -e "   ${YELLOW}.task-flow/scripts/task-flow.sh${NC}\n"
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
