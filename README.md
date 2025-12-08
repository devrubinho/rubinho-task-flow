# Vibe Coding Rules

Repositório centralizado de regras de desenvolvimento para uso em todos os projetos. Este repositório contém templates e padrões que podem ser facilmente instalados em qualquer projeto.

## 📋 Conteúdo

Este repositório contém:

- **Regras do Cursor** (`.cursor/rules/`): Padrões de desenvolvimento, workflows e melhores práticas
- **Configuração MCP** (`.mcp.json`): Template de configuração para integração com Task Master AI
- **Scripts de Instalação**: Scripts para copiar regras para outros projetos

## 🚀 Instalação Rápida

> **Nota**: Este template é otimizado para projetos que sempre usam **Claude**, **Taskmaster** e **Cursor**.

### ⚡ Instalação em 2 Comandos

```bash
# 1. Clonar este repo (apenas uma vez)
git clone <url-do-repositorio> ~/.vibe-coding-rules

# 2. Em qualquer projeto novo, executar:
~/.vibe-coding-rules/install-rules.sh
```

## ⚙️ Configuração Inicial (2 minutos)

Após instalar as regras:

### 1. Adicionar API Keys

Edite `.cursor/mcp.json` e adicione suas chaves:

```json
{
  "mcpServers": {
    "task-master-ai": {
      "env": {
        "ANTHROPIC_API_KEY": "sua-chave-aqui",
        "PERPLEXITY_API_KEY": "sua-chave-aqui"
      }
    }
  }
}
```

### 2. Reiniciar Cursor

Reinicie o Cursor para carregar o MCP server do Taskmaster.

### 3. (Opcional) Inicializar Taskmaster

```bash
task-master init
task-master models --setup
```

## 📁 Estrutura de Arquivos

```
vibe-coding-rules/
├── .cursor/
│   ├── mcp.json.example            # Template de configuração MCP
│   └── rules/                       # Regras de desenvolvimento
│       ├── cursor_rules.mdc         # Guia de formatação de regras
│       ├── self_improve.mdc         # Processo de melhoria contínua
│       ├── code_comments.mdc        # Regras de comentários
│       ├── commit_practices.mdc     # Práticas de commit
│       ├── git_control.mdc          # Controle de comandos git
│       ├── task_execution.mdc       # Gerenciamento de execução de tasks
│       └── taskmaster/
│           ├── dev_workflow.mdc     # Workflow de desenvolvimento
│           ├── taskmaster.mdc       # Referência de comandos
│           └── hamster.mdc         # Integração com Hamster
├── .gitignore                       # Template de .gitignore
├── CLAUDE.md.example                # Template de instruções Claude
├── install-rules.sh                 # Script de instalação
└── README.md                        # Este arquivo
```


## 📝 Adicionando Novas Regras

Para adicionar novas regras a este repositório:

1. Crie um novo arquivo `.mdc` em `.cursor/rules/` ou em um subdiretório apropriado
2. Siga o formato definido em `cursor_rules.mdc`
3. Use `globs` para especificar em quais arquivos a regra se aplica
4. Commit e push das mudanças

### Exemplo de Nova Regra

```markdown
---
description: Regras de estilo para TypeScript
globs: **/*.ts, **/*.tsx
alwaysApply: true
---

- **TypeScript Best Practices:**
  - Sempre use tipos explícitos em funções públicas
  - Prefira `interface` sobre `type` para objetos
  - Use `const` assertions quando apropriado
```

## 🔄 Atualizando Regras em Projetos

Para atualizar as regras em um projeto existente:

```bash
# Executar o script de instalação novamente
~/.vibe-coding-rules/install-rules.sh /caminho/para/seu/projeto
```

O script irá:
- ✅ Copiar novas regras
- ✅ Atualizar regras existentes
- ✅ Preservar configurações locais (como `.cursor/mcp.json` se já existir)

## 📚 Regras Incluídas

### Regras Base
- **cursor_rules.mdc**: Formatação e estrutura de regras
- **self_improve.mdc**: Processo de melhoria contínua de regras
- **code_comments.mdc**: Regras sobre comentários e documentação
- **commit_practices.mdc**: Práticas de commit após tarefas
- **git_control.mdc**: Controle de comandos git
- **task_execution.mdc**: Gerenciamento automático de status de tasks

### Taskmaster
- **dev_workflow.mdc**: Workflow completo de desenvolvimento com Task Master
- **taskmaster.mdc**: Referência completa de comandos e ferramentas
- **hamster.mdc**: Integração com Hamster briefs

## 🤝 Contribuindo

Para melhorar este repositório de regras:

1. Identifique padrões que se repetem em múltiplos projetos
2. Crie uma regra seguindo o formato em `cursor_rules.mdc`
3. Adicione exemplos práticos do código real
4. Teste a regra em um projeto antes de adicionar aqui
5. Faça commit e push

## 📖 Referências

- [Cursor Rules Documentation](https://cursor.sh/docs)
- [Task Master AI](https://github.com/taskmaster-ai/taskmaster)
- [MCP Protocol](https://modelcontextprotocol.io)

## ⚠️ Notas Importantes

- Este repositório contém apenas **templates e padrões reutilizáveis**
- Arquivos específicos de projeto (como `.taskmaster/config.json`) não são incluídos
- Cada projeto deve ter seu próprio `.env` com API keys
- O script de instalação preserva configurações existentes quando apropriado

