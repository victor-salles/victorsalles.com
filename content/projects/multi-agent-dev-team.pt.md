---
title: "Multi-Agent Dev Team"
date: 2026-03-10
tags: ["ia", "agentes", "arquitetura", "devtools", "produtividade"]
draft: false
---

## Times estruturados de agentes de IA com memória e coordenação

A maioria das pessoas interage com assistentes de IA um prompt por vez. Eu queria ver o que acontece quando você projeta um time completo de desenvolvimento com agentes de IA — cada um com papel definido, personalidade, metodologia de diagnóstico e memória persistente — e faz eles colaborarem em trabalho real de engenharia.

**A configuração:**

Cinco agentes especializados, cada um com um arquétipo e estilo de trabalho distintos:

- **Líder** — Delegação, escopo, planejamento. Opera através de um formato de briefing de 5 campos e duas gates de qualidade.
- **Backend** — Especialista em Django/DRF/Postgres com um loop de diagnóstico que tem um hard stop: após 2 hipóteses falhadas, escala em vez de forçar.
- **Frontend** — Next.js/TypeScript, regra de renderização de 4 estados, e um checklist de QA que roda antes de qualquer PR.
- **Designer** — Especificações completas de estado e uma gate de viabilidade que força a consideração de edge cases antes de se comprometer com designs.
- **Segurança** — Review de 7 categorias com awareness de Django que roda após cada tarefa de Backend ou Frontend, antes da segunda gate de qualidade.

**Arquitetura de memória:**

Dois tiers. Memória a nível de usuário (`~/.claude/agents/memory/[role]/`) armazena padrões cross-project — coisas que cada agente aprendeu debugando, testando, revisando. Estas acumulam com o tempo. Quando um arquivo de categoria fica longo (~30 entradas), o agente divide em vez de deletar.

Memória a nível de projeto (`.claude/context.md` em cada repo) armazena contexto específico do projeto. Todo agente verifica isso no início da sessão e cria se não existir.

**Metodologia de edge cases:**

Um documento de referência cobre três tipos de edge cases (boundary, input inválido, conflito de estado), cinco métodos de descoberta com exemplos concretos, e checklists específicos de contexto para endpoints de API, componentes de UI, operações de banco de dados, fluxos de auth e tarefas async.

**Por que isso importa:**

O loop de diagnóstico sozinho muda como sessões de debugging funcionam — o stop de escalação após 2 falhas previne o padrão rabbit-hole onde um agente fica tentando variações da mesma abordagem quebrada. O padrão de segurança-como-cidadão-de-primeira-classe (review após cada tarefa, não como afterthought) pega issues que de outra forma chegariam ao PR.

**Stack:** Agentes Claude, configuração baseada em Markdown, hierarquias de memória baseadas em papel
