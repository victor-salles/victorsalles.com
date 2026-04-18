---
title: "Running Two Claude Accounts Simultaneously on a Mac"
date: 2026-04-17
tags: ["claude", "macos", "ia", "claude-code"]
draft: false
summary: "How to run two Claude accounts simultaneously on a Mac, with shared configuration and full conversation history."
---

If you use Claude for both personal and work projects, you've probably hit the same wall: one account, one session, constant sign-in/sign-out. Here's how to run both in parallel — with shared configuration and full conversation history — on the same Mac.

## ⚠️ Disclaimer

The core technique relies on `CLAUDE_CONFIG_DIR`, an **undocumented environment variable** in Claude Code. It works as of April 2026 (v2.1.113), but Anthropic could change or remove it without notice. Everything described here was verified hands-on, but treat it as a power-user workaround, not an official feature.

---

## The Setup

**Desktop app:** No multi-account support. It's one account at a time. The workaround here is simple — use the desktop app for one account and `claude.ai` in a browser for the other. Not ideal, but workable.

**Claude Code CLI:** This is where the real solution lives. Claude Code stores all its state — settings, credentials, conversation history, plugins — in a config directory. By default that's `~/.claude`. Point it somewhere else and you get a fully isolated instance.

```bash
# Personal account (default)
claude

# Work account (separate config directory)
CLAUDE_CONFIG_DIR=~/.claude-work claude
```

The first time you run the work instance, it will prompt you to authenticate. After that, both run independently in different terminal sessions with their own credentials, history, and state.

Add aliases to your `~/.zshrc` so you don't have to think about it:

```bash
alias claude-personal='claude'
alias claude-work='CLAUDE_CONFIG_DIR=~/.claude-work claude'
```

---

## Sharing Configuration Between Accounts

Having two separate config directories means duplicating your preferences. Most things — your settings, instructions, hooks, skills — should be identical between accounts. The trick is to designate one directory as the source of truth and symlink the shared items into the other.

Here personal is the source of truth, and work symlinks to it:

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

Any change to shared config in either session automatically applies to both.

**What to keep separate:**

| File/Dir | Why |
|---|---|
| `plugins/` | May contain per-account MCP auth tokens |
| `history.jsonl` | Per-account conversation input history |
| `sessions/` | Active session PIDs |
| `projects/` | Conversation transcripts (see below) |
| `policy-limits.json` | Account-specific limits |
| `cache/`, `backups/` | Runtime-generated |

---

## Migrating Past Conversations

Conversation transcripts are stored in `~/.claude/projects/`, organized by project path. The new work account starts with an empty `~/.claude-work/projects/`. If you want past conversations accessible from the work instance, you need to copy them across.

**Important: copy, don't symlink.** Claude Code resolves symlinks to their real path and rejects session directories that fall outside the active config dir. Symlinks silently return "No conversations found."

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

After copying, `/resume` in your work Claude instance will show the full conversation history for those projects.

Note: from this point forward, new sessions are written to whichever config dir is active. Personal and work histories stay separate going forward, which is probably what you want.

---

## A Note on Command History

Claude Code also keeps a `history.jsonl` file — a log of every prompt you've typed, similar to shell history. If you've been using one account for a while, this file contains entries from all your projects mixed together.

Each entry looks like:
```json
{"timestamp": 1234567890, "project": "/Users/you/code/some-project", "display": "your prompt", "sessionId": "..."}
```

There's no account field. The only way to split it is by `project` path. If you want to seed your work history file with past work-project prompts:

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

## The Final Layout

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

## Quick Reference

```bash
# First-time work account setup
CLAUDE_CONFIG_DIR=~/.claude-work claude  # authenticate when prompted

# Daily use
claude              # personal
claude-work         # work (after adding alias to ~/.zshrc)

# Resume a past conversation (from inside the project directory)
/resume
```

That's it. Two accounts, running in parallel, sharing config, each with their own history and credentials.
