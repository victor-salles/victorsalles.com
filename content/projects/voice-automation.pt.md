---
title: "Voice Automation"
date: 2026-03-01
tags: ["python", "macos", "ai", "tts", "stt", "automação"]
draft: false
---

## Voz I/O offline para macOS

Um sistema completo de text-to-speech e speech-to-text para macOS que roda inteiramente no dispositivo. Sem APIs na nuvem, sem assinaturas — apenas modelos de IA locais fazendo trabalho real.

**O problema:** Passo horas lendo e escrevendo texto na tela. Queria uma forma de fazer meu Mac ler qualquer coisa com um único atalho, e transcrever áudio sem enviar dados para servidores externos.

**O que faz:**

Pressione `⌥S` e qualquer texto selecionado (ou copiado) é lido em voz alta usando Kokoro-82M, um modelo TTS de 82 milhões de parâmetros rodando localmente no Apple Silicon. O sistema detecta automaticamente se o texto é português ou inglês e escolhe a voz correta. O áudio começa a ser transmitido em menos de um segundo — sem arquivos temporários, sem esperar a síntese completa.

Clique com botão direito em qualquer arquivo de áudio e ele é transcrito localmente usando mlx-whisper (Whisper-turbo).

**Arquitetura:**

O sistema tem três camadas. Uma camada de orquestração em shell (`speak.sh`) cuida da captura de texto e chamadas à API. Um pipeline de processamento em Python remove formatação markdown, expande extensões de arquivo para texto falável (`.py` vira "dot P Y"), humaniza identificadores (`HTTP_CODE` vira "H T T P Code"), e detecta idioma usando heurísticas a nível de caractere. Uma integração com Hammerspoon fornece os atalhos de teclado, uma UI na barra de menu com gerenciamento de fila, histórico de reprodução e seleção de voz entre 16 vozes em 4 variantes de idioma.

**Testes:** 2.375 linhas de testes em 17 arquivos cobrindo edge cases de detecção de idioma, preservação de acentos, o pipeline completo de limpeza de texto, e cenários de integração.

**Stack:** Python, Bash, Lua (Hammerspoon), Kokoro-82M (TTS), mlx-whisper (STT), macOS LaunchAgents

[GitHub](https://github.com/victor-salles/voice-automation)
