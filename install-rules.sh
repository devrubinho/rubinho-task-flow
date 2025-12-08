#!/bin/bash

# Script para instalar regras de desenvolvimento do repositório vibe-coding-rules
# Uso: ./install-rules.sh [caminho-do-projeto]

set -e

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Diretório do repositório de regras (onde este script está)
RULES_REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-$(pwd)}"

echo -e "${BLUE}🚀 Instalando regras de desenvolvimento...${NC}\n"

# Verificar se o diretório de destino existe
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}⚠️  Diretório não encontrado: $TARGET_DIR${NC}"
    exit 1
fi

# Criar estrutura de diretórios
echo -e "${BLUE}📁 Criando estrutura de diretórios...${NC}"
mkdir -p "$TARGET_DIR/.cursor/rules/taskmaster"

# Copiar regras do Cursor
echo -e "${BLUE}📋 Copiando regras do Cursor...${NC}"
if [ -d "$RULES_REPO_DIR/.cursor/rules" ]; then
    cp -r "$RULES_REPO_DIR/.cursor/rules/"* "$TARGET_DIR/.cursor/rules/"
    echo -e "${GREEN}✅ Regras do Cursor copiadas${NC}"
else
    echo -e "${YELLOW}⚠️  Diretório .cursor/rules não encontrado no repositório de regras${NC}"
fi

# Copiar configuração MCP (template)
echo -e "${BLUE}⚙️  Copiando configuração MCP...${NC}"
if [ -f "$RULES_REPO_DIR/.cursor/mcp.json.example" ]; then
    if [ -f "$TARGET_DIR/.cursor/mcp.json" ]; then
        echo -e "${YELLOW}⚠️  .cursor/mcp.json já existe. Não sobrescrevendo.${NC}"
        echo -e "${YELLOW}   Você pode usar como referência: $RULES_REPO_DIR/.cursor/mcp.json.example${NC}"
    else
        cp "$RULES_REPO_DIR/.cursor/mcp.json.example" "$TARGET_DIR/.cursor/mcp.json"
        echo -e "${GREEN}✅ Configuração MCP copiada (edite e adicione suas API keys)${NC}"
    fi
elif [ -f "$RULES_REPO_DIR/.mcp.json" ]; then
    # Fallback para o formato antigo
    if [ -f "$TARGET_DIR/.cursor/mcp.json" ]; then
        echo -e "${YELLOW}⚠️  .cursor/mcp.json já existe. Não sobrescrevendo.${NC}"
    else
        cp "$RULES_REPO_DIR/.mcp.json" "$TARGET_DIR/.cursor/mcp.json"
        echo -e "${GREEN}✅ Configuração MCP copiada${NC}"
    fi
fi

# Criar .gitignore se não existir ou atualizar
echo -e "${BLUE}📝 Atualizando .gitignore...${NC}"
if [ ! -f "$TARGET_DIR/.gitignore" ]; then
    if [ -f "$RULES_REPO_DIR/.gitignore" ]; then
        cp "$RULES_REPO_DIR/.gitignore" "$TARGET_DIR/.gitignore"
        echo -e "${GREEN}✅ .gitignore criado${NC}"
    fi
else
    # Adicionar entradas do template se não existirem
    if ! grep -q "# Taskmaster" "$TARGET_DIR/.gitignore" 2>/dev/null; then
        echo "" >> "$TARGET_DIR/.gitignore"
        echo "# Taskmaster" >> "$TARGET_DIR/.gitignore"
        echo ".taskmaster/tasks/" >> "$TARGET_DIR/.gitignore"
        echo ".taskmaster/state.json" >> "$TARGET_DIR/.gitignore"
        echo ".taskmaster/config.json" >> "$TARGET_DIR/.gitignore"
        echo ".taskmaster/CLAUDE.md" >> "$TARGET_DIR/.gitignore"
        echo -e "${GREEN}✅ Entradas do Taskmaster adicionadas ao .gitignore${NC}"
    fi
fi

# Copiar CLAUDE.md de exemplo (opcional)
echo -e "${BLUE}📄 Copiando CLAUDE.md de exemplo...${NC}"
if [ -f "$RULES_REPO_DIR/CLAUDE.md.example" ]; then
    if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
        echo -e "${YELLOW}⚠️  CLAUDE.md já existe. Não sobrescrevendo.${NC}"
    else
        cp "$RULES_REPO_DIR/CLAUDE.md.example" "$TARGET_DIR/CLAUDE.md"
        echo -e "${GREEN}✅ CLAUDE.md de exemplo copiado${NC}"
    fi
fi

echo -e "\n${GREEN}✨ Instalação concluída!${NC}\n"
echo -e "${BLUE}📚 Próximos passos:${NC}"
echo -e "   1. Configure suas API keys em .cursor/mcp.json (para Cursor) ou .env (para CLI)"
echo -e "   2. Reinicie o Cursor para carregar o MCP server do Taskmaster"
echo -e "   3. Execute 'task-master init' para inicializar o Taskmaster no projeto"
echo -e "   4. As regras já estão ativas no Cursor!\n"
echo -e "${BLUE}💡 Dica:${NC} Veja SETUP.md para um guia completo de configuração.\n"

