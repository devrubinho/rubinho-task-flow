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
  echo -e "${CYAN}║${NC}        ${MAGENTA}✨ RBIN Task Flow - Installation ✨${NC}          ${CYAN}║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

pause() {
  echo -e "\n${YELLOW}Press ENTER to continue...${NC}"
  read -r
}

check_model_updates() {
  local target="$1"
  local versions_file="$SCRIPT_DIR/.model-versions.json"

  [ ! -f "$versions_file" ] && return

  local claude_latest=$(grep -A3 '"claude"' "$versions_file" | grep '"latest"' | sed 's/.*"latest": "\([^"]*\)".*/\1/')
  local cursor_latest=$(grep -A3 '"cursor"' "$versions_file" | grep '"latest"' | sed 's/.*"latest": "\([^"]*\)".*/\1/')
  local gemini_latest=$(grep -A3 '"gemini"' "$versions_file" | grep '"latest"' | sed 's/.*"latest": "\([^"]*\)".*/\1/')

  if [ -f "$SCRIPT_DIR/.claude/settings.json" ]; then
    local installed=$(grep -o '"model": "[^"]*"' "$SCRIPT_DIR/.claude/settings.json" | cut -d'"' -f4)
    if [ -n "$installed" ] && [ -n "$claude_latest" ] && [ "$installed" != "$claude_latest" ]; then
      echo ""
      echo -e "${YELLOW}⚠️  Claude: New version available${NC}"
      echo -e "   ${CYAN}Current: ${installed}${NC}"
      echo -e "   ${CYAN}Latest: ${claude_latest}${NC}"
      read -r -p "$(echo -e ${BLUE}Update Claude to latest version? [y/N]: ${NC})" response
      if [[ "$response" =~ ^[yY]$ ]]; then
        local settings_file="$SCRIPT_DIR/.claude/settings.json"
        mkdir -p "$(dirname "$settings_file")"
        printf '{\n  "model": "%s"\n}\n' "$claude_latest" > "$settings_file"
        if [ -f "$settings_file" ]; then
          local verify=$(grep -o '"model": "[^"]*"' "$settings_file" | cut -d'"' -f4)
          if [ "$verify" = "$claude_latest" ]; then
            echo -e "${GREEN}✅ Claude template updated to ${claude_latest}${NC}"
            echo -e "${CYAN}   (Repository template updated - run install.sh on projects to apply)${NC}"
          else
            echo -e "${RED}❌ Error: Update failed${NC}"
          fi
        else
          echo -e "${RED}❌ Error: Could not write to $settings_file${NC}"
        fi
      else
        echo -e "${CYAN}   Skipped Claude update${NC}"
      fi
    fi
  fi

  if [ -f "$SCRIPT_DIR/.cursor/settings.json" ]; then
    local installed=$(grep -o '"model": "[^"]*"' "$SCRIPT_DIR/.cursor/settings.json" | cut -d'"' -f4)
    if [ -n "$installed" ] && [ -n "$cursor_latest" ] && [ "$installed" != "$cursor_latest" ]; then
      echo ""
      echo -e "${YELLOW}⚠️  Cursor: New version available${NC}"
      echo -e "   ${CYAN}Current: ${installed}${NC}"
      echo -e "   ${CYAN}Latest: ${cursor_latest}${NC}"
      read -r -p "$(echo -e ${BLUE}Update Cursor to latest version? [y/N]: ${NC})" response
      if [[ "$response" =~ ^[yY]$ ]]; then
        local settings_file="$SCRIPT_DIR/.cursor/settings.json"
        mkdir -p "$(dirname "$settings_file")"
        printf '{\n  "model": "%s"\n}\n' "$cursor_latest" > "$settings_file"
        if [ -f "$settings_file" ]; then
          local verify=$(grep -o '"model": "[^"]*"' "$settings_file" | cut -d'"' -f4)
          if [ "$verify" = "$cursor_latest" ]; then
            echo -e "${GREEN}✅ Cursor template updated to ${cursor_latest}${NC}"
            echo -e "${CYAN}   (Repository template updated - run install.sh on projects to apply)${NC}"
          else
            echo -e "${RED}❌ Error: Update failed${NC}"
          fi
        else
          echo -e "${RED}❌ Error: Could not write to $settings_file${NC}"
        fi
      else
        echo -e "${CYAN}   Skipped Cursor update${NC}"
      fi
    fi
  fi

  if [ -f "$SCRIPT_DIR/.gemini/settings.json" ]; then
    local installed=""
    if command -v jq >/dev/null 2>&1; then
      installed=$(jq -r 'if .model | type == "string" then .model else .model.name // "" end' "$SCRIPT_DIR/.gemini/settings.json" 2>/dev/null)
    else
      installed=$(grep -o '"name": "[^"]*"' "$SCRIPT_DIR/.gemini/settings.json" | cut -d'"' -f4)
      if [ -z "$installed" ]; then
        installed=$(grep -o '"model": "[^"]*"' "$SCRIPT_DIR/.gemini/settings.json" | cut -d'"' -f4)
      fi
    fi
    if [ -n "$installed" ] && [ -n "$gemini_latest" ] && [ "$installed" != "$gemini_latest" ]; then
      echo ""
      echo -e "${YELLOW}⚠️  Gemini: New version available${NC}"
      echo -e "   ${CYAN}Current: ${installed}${NC}"
      echo -e "   ${CYAN}Latest: ${gemini_latest}${NC}"
      read -r -p "$(echo -e ${BLUE}Update Gemini to latest version? [y/N]: ${NC})" response
      if [[ "$response" =~ ^[yY]$ ]]; then
        local settings_file="$SCRIPT_DIR/.gemini/settings.json"
        mkdir -p "$(dirname "$settings_file")"
        if command -v jq >/dev/null 2>&1; then
          local is_object=$(jq -r 'if .model | type == "object" then "true" else "false" end' "$settings_file" 2>/dev/null || echo "false")
          if [ "$is_object" = "true" ]; then
            jq ".model.name = \"$gemini_latest\"" "$settings_file" > "$settings_file.tmp" && mv "$settings_file.tmp" "$settings_file"
          else
            printf '{\n  "model": {\n    "name": "%s"\n  }\n}\n' "$gemini_latest" > "$settings_file"
          fi
        else
          printf '{\n  "model": {\n    "name": "%s"\n  }\n}\n' "$gemini_latest" > "$settings_file"
        fi
        if [ -f "$settings_file" ]; then
          local verify=""
          if command -v jq >/dev/null 2>&1; then
            verify=$(jq -r 'if .model | type == "string" then .model else .model.name // "" end' "$settings_file" 2>/dev/null)
          else
            verify=$(grep -o '"name": "[^"]*"' "$settings_file" | cut -d'"' -f4)
          fi
          if [ "$verify" = "$gemini_latest" ]; then
            echo -e "${GREEN}✅ Gemini template updated to ${gemini_latest}${NC}"
            echo -e "${CYAN}   (Repository template updated - run install.sh on projects to apply)${NC}"
          else
            echo -e "${RED}❌ Error: Update failed${NC}"
          fi
        else
          echo -e "${RED}❌ Error: Could not write to $settings_file${NC}"
        fi
      else
        echo -e "${CYAN}   Skipped Gemini update${NC}"
      fi
    fi
  fi
}

show_model_versions() {
  local target="$1"

  echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
  echo -e "${MAGENTA}📋 Model Versions Configured:${NC}"
  echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
  echo ""

  if [ -f "$target/.claude/settings.json" ]; then
    local claude_model=$(grep -o '"model": "[^"]*"' "$target/.claude/settings.json" | cut -d'"' -f4)
    if [ -n "$claude_model" ]; then
      echo -e "${BLUE}Claude:${NC} ${YELLOW}$claude_model${NC}"
    else
      echo -e "${BLUE}Claude:${NC} ${YELLOW}Default (recommended)${NC}"
    fi
  fi

  if [ -f "$target/.cursor/settings.json" ]; then
    local cursor_model=$(grep -o '"model": "[^"]*"' "$target/.cursor/settings.json" | cut -d'"' -f4)
    if [ -n "$cursor_model" ]; then
      echo -e "${BLUE}Cursor:${NC} ${YELLOW}$cursor_model${NC}"
    fi
  fi

  if [ -f "$target/.gemini/settings.json" ]; then
    if command -v jq >/dev/null 2>&1; then
      local gemini_model=$(jq -r 'if .model | type == "string" then .model else .model.name // "Default (recommended)" end' "$target/.gemini/settings.json" 2>/dev/null)
    else
      local gemini_model=$(grep -o '"name": "[^"]*"' "$target/.gemini/settings.json" | cut -d'"' -f4)
      if [ -z "$gemini_model" ]; then
        local gemini_model=$(grep -o '"model": "[^"]*"' "$target/.gemini/settings.json" | cut -d'"' -f4)
      fi
    fi
    if [ -n "$gemini_model" ] && [ "$gemini_model" != "null" ]; then
      echo -e "${BLUE}Gemini:${NC} ${YELLOW}$gemini_model${NC}"
    else
      echo -e "${BLUE}Gemini:${NC} ${YELLOW}Default (recommended)${NC}"
    fi
  fi

  echo ""

  check_model_updates "$target"

  echo ""
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

  echo -e "${BLUE}🚀 Installing/Updating...${NC}"
  echo -e "${BLUE}📁 Target: $target${NC}\n"

  mkdir -p "$target"/{.cursor/rules,.claude,.gemini,.task-flow}

  [ -d "$SCRIPT_DIR/.cursor/rules" ] &&
    cp -r "$SCRIPT_DIR/.cursor/rules/"* "$target/.cursor/rules/" &&
    echo -e "${GREEN}✅ Cursor rules${NC}"


  [ -f "$SCRIPT_DIR/.cursor/settings.json" ] &&
    cp "$SCRIPT_DIR/.cursor/settings.json" "$target/.cursor/settings.json" &&
    echo -e "${GREEN}✅ Cursor settings${NC}"

  [ -f "$SCRIPT_DIR/.claude/settings.json" ] &&
    cp "$SCRIPT_DIR/.claude/settings.json" "$target/.claude/settings.json" &&
    echo -e "${GREEN}✅ Claude settings${NC}"

  [ -f "$SCRIPT_DIR/CLAUDE.md" ] &&
    cp "$SCRIPT_DIR/CLAUDE.md" "$target/CLAUDE.md" &&
    echo -e "${GREEN}✅ Claude instructions${NC}"

  [ -f "$SCRIPT_DIR/.gemini/settings.json" ] &&
    cp "$SCRIPT_DIR/.gemini/settings.json" "$target/.gemini/settings.json" &&
    echo -e "${GREEN}✅ Gemini settings${NC}"

  [ -f "$SCRIPT_DIR/GEMINI.md" ] &&
    cp "$SCRIPT_DIR/GEMINI.md" "$target/GEMINI.md" &&
    echo -e "${GREEN}✅ Gemini instructions${NC}"

  
  if [ -d "$SCRIPT_DIR/.task-flow" ]; then
    mkdir -p "$target/.task-flow"
    echo -e "${GREEN}✅ Task Flow directory${NC}"
    echo -e "${CYAN}   ℹ️  Note: .internal/tasks.json and .internal/status.json are NOT overwritten (your data is safe)${NC}"
    [ ! -f "$target/.task-flow/tasks.input.txt" ] &&
      [ -f "$SCRIPT_DIR/.task-flow/tasks.input.txt" ] &&
      cp "$SCRIPT_DIR/.task-flow/tasks.input.txt" "$target/.task-flow/tasks.input.txt"
    [ ! -f "$target/.task-flow/tasks.status.md" ] &&
      [ -f "$SCRIPT_DIR/.task-flow/tasks.status.md" ] &&
      cp "$SCRIPT_DIR/.task-flow/tasks.status.md" "$target/.task-flow/tasks.status.md"
    [ -f "$SCRIPT_DIR/.task-flow/README.md" ] &&
      cp "$SCRIPT_DIR/.task-flow/README.md" "$target/.task-flow/README.md" &&
      echo -e "${GREEN}✅ Task Flow README${NC}"
    mkdir -p "$target/.task-flow/screens" &&
      echo -e "${GREEN}✅ Screenshots directory (.task-flow/screens/)${NC}"
    mkdir -p "$target/.task-flow/docs" &&
      echo -e "${GREEN}✅ Documentation directory (.task-flow/docs/)${NC}"
  fi

  [ ! -f "$target/.gitignore" ] && touch "$target/.gitignore"

  # Remove old entries if they exist
  sed -i '' '/^\.claude\/$/d' "$target/.gitignore" 2>/dev/null
  sed -i '' '/^\.gemini\/$/d' "$target/.gitignore" 2>/dev/null
  sed -i '' '/^\.cursor\/$/d' "$target/.gitignore" 2>/dev/null
  sed -i '' '/^\.task-flow\/$/d' "$target/.gitignore" 2>/dev/null
  sed -i '' '/^CLAUDE\.md$/d' "$target/.gitignore" 2>/dev/null
  sed -i '' '/^GEMINI\.md$/d' "$target/.gitignore" 2>/dev/null
  sed -i '' '/^# RBIN Task Flow/d' "$target/.gitignore" 2>/dev/null
  sed -i '' '/^\.cursor\/rules\/$/d' "$target/.gitignore" 2>/dev/null
  sed -i '' '/^\.task-flow\/scripts\/tasks\.json$/d' "$target/.gitignore" 2>/dev/null
  sed -i '' '/^\.task-flow\/scripts\/status\.json$/d' "$target/.gitignore" 2>/dev/null
  sed -i '' '/^\.cursor\/rules\/\*\.local\.mdc$/d' "$target/.gitignore" 2>/dev/null

  # Add entries without comments
  {
    echo ""
    echo ".claude/"
    echo ".gemini/"
    echo ".cursor/"
    echo ".task-flow/"
    echo "CLAUDE.md"
    echo "GEMINI.md"
  } >> "$target/.gitignore"

  echo -e "${GREEN}✅ .gitignore updated${NC}"

  echo -e "\n${GREEN}✨ Done!${NC}\n"

  show_model_versions "$target"

  echo -e "${BLUE}Next steps:${NC}"
  echo -e "   ${YELLOW}cd $target${NC}"
  echo -e "   ${CYAN}Use AI commands: task-flow: sync, task-flow: run X, etc.${NC}"
  echo -e "   ${CYAN}See .task-flow/README.md for all commands${NC}\n"
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
