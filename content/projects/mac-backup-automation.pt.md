---
title: "Automação de Backup Mac"
date: 2026-03-08
tags: ["bash", "macos", "automação", "devops"]
draft: false
summary: "Um script abrangente de backup para ambientes de desenvolvimento macOS — chaves SSH, dotfiles, Homebrew, agentes Claude, volumes Docker, e mais."
---

## Backup automatizado para ambientes de dev macOS

Time Machine é ótimo para backups gerais, mas não resolve o problema de saber *o que importa* em uma configuração de desenvolvedor. Este script resolve.

**O problema:** Antes de uma reinstalação limpa do macOS, eu precisava garantir que tudo importante fosse capturado — não apenas arquivos, mas configuração, listas de pacotes, credenciais e as diversas peças de estado espalhadas pela máquina de um desenvolvedor.

**O que ele faz backup:**

O script percorre cada categoria sistematicamente:

- **Chaves SSH** — copia `~/.ssh/` e alerta se alguma chave não tem passphrase
- **Dotfiles** — `.zshrc`, `.zprofile`, `.gitconfig`, `.npmrc` e outras configurações
- **Configs de agentes Claude** — o diretório completo `~/.claude/` com agentes, estruturas de memória e skills
- **Homebrew** — fórmulas, casks, taps, e um `Brewfile` completo para restauração com um comando via `brew bundle install`
- **LaunchAgents** — property lists para serviços em background
- **VS Code / Cursor** — listas de extensões, configurações, keybindings e snippets
- **npm / Python / pyenv** — pacotes globais e listas de versões
- **Docker** — lista volumes e imprime comandos exatos de dump para cada um (não faz auto-dump devido ao tamanho potencial)
- **Repos Git** — verifica mudanças não commitadas em vez de copiar repos inteiros

No final, imprime um checklist manual para coisas que um script não pode automatizar — desativar apps licenciados, sair do iCloud, desabilitar o Find My Mac.

**Stack:** Bash
