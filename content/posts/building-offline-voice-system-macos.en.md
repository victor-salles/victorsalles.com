---
title: "Building an Offline Voice System for macOS"
date: 2026-03-22
tags: ["python", "macos", "ai", "tts", "stt", "kokoro", "whisper"]
draft: false
summary: "How I built a fully offline text-to-speech and speech-to-text system for macOS using Kokoro-82M and mlx-whisper — no cloud APIs, streaming audio in under a second."
---

I spend a lot of time reading text on screen. Documentation, code reviews, long Slack threads, articles. At some point I started wondering: what if my Mac could just read this to me?

There are plenty of TTS solutions out there. Most of them are cloud-based, which means latency, subscriptions, and sending your text to someone else's server. I wanted something that runs locally, starts fast, sounds good, and works in both English and Portuguese.

So I built one.

## The stack

The TTS engine is **Kokoro-82M**, an 82-million parameter model that runs on CPU on Apple Silicon. It's served locally via Kokoro-FastAPI on port 8880, auto-started as a macOS LaunchAgent so it's always ready when I need it.

For speech-to-text, I'm using **mlx-whisper** (the Whisper-turbo model optimized for Apple Silicon). Right-click an audio file and it gets transcribed locally.

The glue between them is a combination of shell scripts, Python processing, and Hammerspoon for the macOS integration layer.

## How it works

Press `⌥S` with text selected (or in clipboard). Here's what happens:

1. **Text capture** — Hammerspoon grabs the selected text or falls back to clipboard
2. **Language detection** — A Python script scores the text for Portuguese markers (ã, õ, ç, accent characters) versus English word frequency. Short text without clear markers defaults to English.
3. **Text cleaning** — A processing pipeline strips markdown formatting, removes code blocks, expands file extensions into speakable form (`.py` becomes "dot P Y"), and humanizes identifiers (`HTTP_CODE` becomes "H T T P Code")
4. **Streaming synthesis** — A `curl` call to the local Kokoro API streams mp3 directly to `ffplay`. No temp files. Audio starts playing in under a second while the rest is still being synthesized.

## The text cleaning problem

This turned out to be the most interesting engineering challenge. Developer-facing text is full of things that sound terrible when read literally: markdown headers, inline code backticks, URLs, emoji, file paths. The cleaning pipeline handles each of these in sequence.

The trickiest part was file extensions. You can't just strip them — `.py` in a sentence like "rename the .py file" carries meaning. So instead of removing them, the pipeline expands them: `.py` becomes "dot P Y", `.json` becomes "dot J S O N". Same for identifiers: `HTTP_CODE` becomes "H T T P Code" because hearing "HTTP underscore CODE" as a single garbled word is useless.

I wrote 2,375 lines of tests across 17 test files to cover the edge cases in this pipeline. Language detection alone has tests for accent characters, Portuguese-specific words, English word scoring, and ambiguous mixed-language text.

## The queue system

One feature I didn't plan but needed immediately: queue management. When you press `⌥S` while audio is already playing, the new text gets queued and plays automatically when the current item finishes. The Hammerspoon menu bar shows what's playing, what's queued, and a history of recent items you can click to replay.

The menu bar indicator also shows server status — green when Kokoro is running and healthy, blue when processing, red when the server is down. Health checks run every 30 seconds.

## What I learned

**Local models are good enough for productivity tools.** Kokoro-82M doesn't sound like a human, but it sounds good enough that I can listen to documentation while doing something else. The bar for "useful" is lower than the bar for "impressive."

**Bilingual support is harder than it looks.** Language detection is easy when you have a full paragraph with clear markers. It's hard when you have a three-word heading that could be either language. The heuristic approach (character scoring + word frequency) works well enough for my use case but isn't perfect.

**Streaming changes the UX completely.** The difference between "wait 3 seconds for audio" and "audio starts in under a second" is the difference between a tool you use and a tool you forget about.

## What's next

The backlog includes a Claude Code post-response hook (auto-speak AI responses), a Chrome extension for reading web pages, and eventually a full voice assistant loop: STT → LLM → OS execution → TTS.

The code is on [GitHub](https://github.com/victor-salles/voice-automation). If you're building something similar or want to contribute, open an issue.
