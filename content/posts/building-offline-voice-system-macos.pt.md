---
title: "Construindo um Sistema de Voz Offline para macOS"
date: 2026-03-22
tags: ["python", "macos", "ia", "tts", "stt", "kokoro", "whisper"]
draft: true
summary: "Como construí um sistema totalmente offline de text-to-speech e speech-to-text para macOS usando Kokoro-82M e mlx-whisper — sem APIs na nuvem, áudio streaming em menos de um segundo."
---

Passo muito tempo lendo texto na tela. Documentação, code reviews, threads longas no Slack, artigos. Em algum momento comecei a pensar: e se meu Mac pudesse simplesmente ler isso pra mim?

Existem várias soluções de TTS por aí. A maioria é baseada na nuvem, o que significa latência, assinaturas e enviar seu texto para o servidor de outra pessoa. Eu queria algo que rodasse localmente, começasse rápido, soasse bem e funcionasse em inglês e português.

Então eu construí um.

## A stack

O motor TTS é o **Kokoro-82M**, um modelo de 82 milhões de parâmetros que roda na CPU no Apple Silicon. É servido localmente via Kokoro-FastAPI na porta 8880, iniciado automaticamente como um macOS LaunchAgent para estar sempre pronto quando eu preciso.

Para speech-to-text, estou usando **mlx-whisper** (o modelo Whisper-turbo otimizado para Apple Silicon). Clique com botão direito em um arquivo de áudio e ele é transcrito localmente.

A cola entre eles é uma combinação de shell scripts, processamento Python e Hammerspoon para a camada de integração macOS.

## Como funciona

Pressione `⌥S` com texto selecionado (ou no clipboard). Eis o que acontece:

1. **Captura de texto** — Hammerspoon pega o texto selecionado ou faz fallback para o clipboard
2. **Detecção de idioma** — Um script Python pontua o texto por marcadores de português (ã, õ, ç, caracteres acentuados) versus frequência de palavras em inglês. Texto curto sem marcadores claros assume inglês como padrão.
3. **Limpeza de texto** — Um pipeline de processamento remove formatação markdown, remove blocos de código, expande extensões de arquivo para forma falável (`.py` vira "dot P Y"), e humaniza identificadores (`HTTP_CODE` vira "H T T P Code")
4. **Síntese em streaming** — Uma chamada `curl` para a API local do Kokoro faz streaming de mp3 direto para o `ffplay`. Sem arquivos temporários. O áudio começa a tocar em menos de um segundo enquanto o resto ainda está sendo sintetizado.

## O problema da limpeza de texto

Este acabou sendo o desafio de engenharia mais interessante. Texto voltado para desenvolvedores é cheio de coisas que soam terríveis quando lidas literalmente: headers markdown, backticks de código inline, URLs, emoji, caminhos de arquivo. O pipeline de limpeza trata cada um destes em sequência.

A parte mais complicada foram extensões de arquivo. Você não pode simplesmente removê-las — `.py` em uma frase como "renomeie o arquivo .py" carrega significado. Então em vez de removê-las, o pipeline as expande: `.py` vira "dot P Y", `.json` vira "dot J S O N". O mesmo para identificadores: `HTTP_CODE` vira "H T T P Code" porque ouvir "HTTP underline CODE" como uma palavra embolada é inútil.

Escrevi 2.375 linhas de testes em 17 arquivos de teste para cobrir os edge cases nesse pipeline. Detecção de idioma sozinha tem testes para caracteres acentuados, palavras específicas do português, pontuação de palavras em inglês e texto ambíguo de idioma misto.

## O sistema de fila

Uma funcionalidade que não planejei mas precisei imediatamente: gerenciamento de fila. Quando você pressiona `⌥S` enquanto áudio já está tocando, o novo texto entra na fila e toca automaticamente quando o item atual termina. A barra de menu do Hammerspoon mostra o que está tocando, o que está na fila, e um histórico de itens recentes que você pode clicar para reproduzir novamente.

O indicador da barra de menu também mostra o status do servidor — verde quando o Kokoro está rodando e saudável, azul quando processando, vermelho quando o servidor está fora. Health checks rodam a cada 30 segundos.

## O que aprendi

**Modelos locais são bons o suficiente para ferramentas de produtividade.** Kokoro-82M não soa como um humano, mas soa bem o suficiente para eu ouvir documentação enquanto faço outra coisa. A barra para "útil" é mais baixa que a barra para "impressionante."

**Suporte bilíngue é mais difícil do que parece.** Detecção de idioma é fácil quando você tem um parágrafo completo com marcadores claros. É difícil quando você tem um heading de três palavras que poderia ser qualquer idioma. A abordagem heurística (pontuação de caracteres + frequência de palavras) funciona bem o suficiente para meu caso de uso mas não é perfeita.

**Streaming muda a UX completamente.** A diferença entre "espere 3 segundos pelo áudio" e "áudio começa em menos de um segundo" é a diferença entre uma ferramenta que você usa e uma ferramenta que você esquece.

## Próximos passos

O backlog inclui um hook pós-resposta do Claude Code (auto-falar respostas de IA), uma extensão Chrome para ler páginas web, e eventualmente um loop completo de assistente de voz: STT → LLM → execução no SO → TTS.

O código está no [GitHub](https://github.com/victor-salles/voice-automation). Se você está construindo algo similar ou quer contribuir, abra uma issue.
