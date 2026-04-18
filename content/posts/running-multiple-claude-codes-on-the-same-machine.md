---
title: "Rodando duas contas Claude ao mesmo tempo no Mac"
date: 2026-04-17
tags: ["claude", "macos", "ia", "claude-code"]
draft: false
summary: "Como rodar duas contas Claude em paralelo no Mac, com configuração compartilhada e histórico completo de conversas."
---

Se você usa o Claude tanto para pessoal quanto para trabalho, provavelmente encontrou o seguinte problema: uma conta, uma sessão, login e logout o tempo todo. Aqui vou falar como rodar as duas em paralelo — com configuração compartilhada e histórico completo de conversas — no mesmo Mac.

## ⚠️ Aviso

A técnica central depende de `CLAUDE_CONFIG_DIR`, uma **variável de ambiente não documentada** no Claude Code. Atualmente funcional (em abril de 2026 - v2.1.113), mas a Anthropic pode mudar ou remover isso sem aviso. Tudo aqui foi testado na prática, mas trate como um atalho para usuários avançados, não como recurso oficial.

---

## A configuração

**App de desktop:** não há suporte a várias contas. É uma conta por vez. O jeito é simples — use o app de desktop para uma conta e `claude.ai` no navegador para a outra. Não é ideal, mas dá para viver.

**CLI do Claude Code:** é aqui que está a solução de verdade. O Claude Code armazena todo o estado — configurações, credenciais, histórico de conversas, plugins — em um diretório de configuração. Por padrão é `~/.claude`. Aponte para outro lugar e você ganha uma instância totalmente isolada.

```bash
# Personal account (default)
claude

# Work account (separate config directory)
CLAUDE_CONFIG_DIR=~/.claude-work claude
```

Na primeira vez que rodar a instância de trabalho, será necessário fazer a autenticação. Depois disso, as duas rodam de forma independente em sessões diferentes de terminal, cada uma com credenciais, histórico e estado próprios.

Coloque aliases no seu `~/.zshrc` para não ter que pensar nisso:

```bash
alias claude-personal='claude'
alias claude-work='CLAUDE_CONFIG_DIR=~/.claude-work claude'
```

---

## Compartilhando configuração entre contas

Ter dois diretórios de configuração separados significa duplicar preferências. A maior parte — configurações, instruções, hooks, skills — costuma ser igual entre as contas. O truque é escolher um diretório como fonte da verdade e criar symlinks dos itens compartilhados no outro.

Aqui, o diretório pessoal é a fonte da verdade e o diretório de trabalho aponta para ele com symlinks:

```bash
PERSONAL="$HOME/.claude"
WORK="$HOME/.claude-work"

SHARED=(
  "settings.json"       # Theme, status line, all preferences
  "CLAUDE.md"           # Global AI instructions
  "MEMORY.md"           # Persistent memory
  "rules"               # Rule files
  "hooks"               # Hooks config
  "skills"              # Skills
  "agents"              # Custom agents
  "statusline-command.sh"
)

for item in "${SHARED[@]}"; do
  src="$PERSONAL/$item"
  dst="$WORK/$item"

  [ ! -e "$src" ] && continue
  [ -L "$dst" ] && continue
  [ -e "$dst" ] && rm -rf "$dst"

  ln -s "$src" "$dst" && echo "Linked: $item"
done
```

Qualquer alteração na configuração compartilhada em uma das sessões passa a valer nas duas.

**O que manter separado:**

| Arquivo/Dir | Motivo |
|---|---|
| `plugins/` | Pode ter tokens de autenticação MCP específicos para cada conta |
| `history.jsonl` | Histórico de prompts específico para cada conta |
| `sessions/` | PIDs de sessão ativa |
| `projects/` | Transcrições de conversa (veja abaixo) |
| `policy-limits.json` | Limites específicos para cada conta |
| `cache/`, `backups/` | Gerados em tempo de execução |

---

## Migrando conversas antigas

As transcrições de conversas ficam armazenadas em `~/.claude/projects/`, organizadas por path de projeto. A nova conta de trabalho começa com `~/.claude-work/projects/` vazio. Se quiser acessar conversas antigas pela instância de trabalho, será preciso copiar os projetos entre contas.

**Importante: copie, não faça symlink.** O Claude Code resolve symlinks para o caminho real e rejeita diretórios de sessão que ficam fora do diretório de configuração ativo. Com symlink, aparece silenciosamente “No conversations found.”

```bash
PERSONAL="$HOME/.claude/projects"
WORK="$HOME/.claude-work/projects"

# List your personal projects and identify which ones are work-related
ls "$PERSONAL"

# Copy the relevant ones
for project in "-Users-you-code-your-work-project"; do
  mkdir -p "$WORK/$project"
  cp -R "$PERSONAL/$project"/. "$WORK/$project/"
  echo "Copied: $project"
done
```

Depois de copiar os projetos, se executar `/resume` na instância Claude de trabalho, será possível ver o histórico completo daqueles projetos.

Observação: daqui em diante, novas sessões são gravadas no diretório de configuração que estiver ativo. Os históricos pessoal e de trabalho seguem separados, o que em geral é o que você quer.

---

## Sobre o histórico de comandos

O Claude Code também mantém um arquivo `history.jsonl` — um log de todo prompt que você digitou, parecido com o histórico do shell. Se você usou uma conta só por um tempo, esse arquivo mistura entradas de todos os projetos.

Cada entrada tem mais ou menos a seguinte estrutura:
```json
{"timestamp": 1234567890, "project": "/Users/you/code/some-project", "display": "your prompt", "sessionId": "..."}
```

Não há campo de conta. A única forma de separar é pelo caminho do projeto. Se quiser copiar o arquivo de histórico de trabalho com prompts antigos só dos projetos de trabalho:

```bash
cat ~/.claude/history.jsonl | python3 -c "
import sys
work_projects = ['/Users/you/code/your-work-project']
for line in sys.stdin:
    if any(p in line for p in work_projects):
        print(line, end='')
" > ~/.claude-work/history.jsonl
```

---

## O layout final

```
~/.claude.json              ← Personal account metadata (created by Claude Code)
~/.claude/                  ← Personal config dir
  settings.json             ← Source of truth (shared via symlink)
  CLAUDE.md                 ← Source of truth (shared via symlink)
  rules/ hooks/ skills/     ← Source of truth (shared via symlinks)
  plugins/                  ← Personal MCP auth
  projects/                 ← Personal conversation history

~/.claude-work/             ← Work config dir (CLAUDE_CONFIG_DIR=~/.claude-work)
  .claude.json              ← Work account metadata
  settings.json             ── symlink → ~/.claude/settings.json
  CLAUDE.md                 ── symlink → ~/.claude/CLAUDE.md
  rules/ hooks/ skills/     ── symlinks → ~/.claude/...
  plugins/                  ← Work MCP auth (kept separate)
  projects/                 ← Work conversation history (real dirs, not symlinks)
```

---

## Referência rápida

```bash
# First-time work account setup
CLAUDE_CONFIG_DIR=~/.claude-work claude  # authenticate when prompted

# Daily use
claude              # personal
claude-work         # work (after adding alias to ~/.zshrc)

# Resume a past conversation (from inside the project directory)
/resume
```

É isso. Duas contas em paralelo, configuração compartilhada, cada uma com histórico e credenciais próprios.
