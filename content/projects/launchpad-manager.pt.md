---
title: "LaunchPad Manager"
date: 2026-03-15
tags: ["swift", "macos", "app-nativo", "devtools"]
draft: false
---

## Um app nativo macOS para gerenciar serviços launchd

O macOS usa `launchd` para gerenciar serviços em background, tarefas agendadas e daemons. A ferramenta nativa para isso é o `launchctl` — um CLI com sintaxe inconsistente e sem interface visual. O LaunchPad Manager resolve isso.

**O que faz:**

Um app SwiftUI com três seções principais:

**Dashboard** — Mostra todos os serviços registrados com indicadores de status em tempo real, filtragem por domínio (user/system/global), ordenação por nome ou status, e ações acessíveis por hover (iniciar, parar, descarregar). O status é atualizado automaticamente a cada 10 segundos via actor `launchctl`.

**Visual Builder** — Uma interface baseada em formulário para criar property lists do launchd. Em vez de editar XML manualmente, você preenche seções recolhíveis para identidade, argumentos do programa, agendamento (com presets e seletores de calendário), variáveis de ambiente e throttling de recursos. Um preview XML mostra exatamente o que será escrito no disco.

**Detalhe do Serviço** — Resumo completo da configuração de qualquer serviço, mais um visualizador de logs com busca, auto-refresh e destaque de erros.

**Arquitetura:** 3.300 linhas de Swift em 16 arquivos em três camadas — Models (tipo LaunchJob, PlistParser para plists XML/binário, actor LaunchctlService), ViewModels (DashboardViewModel com descoberta e auto-refresh, BuilderViewModel com validação e geração XML), e Views (shell NavigationSplitView com navegação por sidebar).

**Stack:** Swift, SwiftUI, macOS 13+, Concurrency (actors)
