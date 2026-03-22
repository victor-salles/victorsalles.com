---
title: "Voice Automation"
date: 2026-03-01
tags: ["python", "macos", "ai", "tts", "stt", "automation"]
draft: false
---

## Offline voice I/O for macOS

A complete text-to-speech and speech-to-text system for macOS that runs entirely on-device. No cloud APIs, no subscriptions — just local AI models doing real work.

**The problem:** I spend hours reading and writing text on screen. I wanted a way to have my Mac read anything to me with a single hotkey, and transcribe audio without sending data to external servers.

**What it does:**

Press `⌥S` and whatever text you've selected (or copied) gets read aloud using Kokoro-82M, an 82-million parameter TTS model running locally on Apple Silicon. The system automatically detects whether the text is Portuguese or English and picks the right voice. Audio starts streaming in under a second — no temp files, no waiting for the full synthesis to finish.

Right-click any audio file and it gets transcribed locally using mlx-whisper (Whisper-turbo).

**Architecture:**

The system has three layers. A shell orchestration layer (`speak.sh`) handles text capture and API calls. A Python processing pipeline strips markdown formatting, expands file extensions into speakable text (`.py` becomes "dot P Y"), humanizes identifiers (`HTTP_CODE` becomes "H T T P Code"), and detects language using character-level heuristics. A Hammerspoon integration provides the hotkey bindings, a menu bar UI with queue management, playback history, and voice selection across 16 voices in 4 language variants.

**Testing:** 2,375 lines of tests across 17 test files covering language detection edge cases, accent preservation, the full text cleaning pipeline, and integration scenarios.

**Stack:** Python, Bash, Lua (Hammerspoon), Kokoro-82M (TTS), mlx-whisper (STT), macOS LaunchAgents

[GitHub](https://github.com/victor-salles/voice-automation)
