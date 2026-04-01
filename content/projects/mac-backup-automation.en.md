---
title: "Mac Backup Automation"
date: 2026-03-08
tags: ["bash", "macos", "automation", "devops"]
draft: false
summary: "A comprehensive backup script for macOS developer environments — SSH keys, dotfiles, Homebrew, Claude agents, Docker volumes, and more."
---

## Automated backup for macOS dev environments

Time Machine is great for general backups, but it doesn't solve the problem of knowing *what matters* in a developer setup. This script does.

**The problem:** Before a clean macOS reinstall, I needed to make sure everything important was captured — not just files, but configuration, package lists, credentials, and the various pieces of state scattered across a developer machine.

**What it backs up:**

The script runs through each category systematically:

- **SSH keys** — copies `~/.ssh/` and warns if any key lacks a passphrase
- **Dotfiles** — `.zshrc`, `.zprofile`, `.gitconfig`, `.npmrc`, and other configuration
- **Claude agent configs** — the full `~/.claude/` directory with agents, memory structures, and skills
- **Homebrew** — formulas, casks, taps, and a full `Brewfile` for one-command restore via `brew bundle install`
- **LaunchAgents** — property lists for background services
- **VS Code / Cursor** — extension lists, settings, keybindings, and snippets
- **npm / Python / pyenv** — global packages and version lists
- **Docker** — lists volumes and prints exact dump commands for each (doesn't auto-dump due to potential size)
- **Git repos** — checks for uncommitted changes rather than copying entire repos

At the end, it prints a manual checklist for things a script can't automate — deactivating licensed apps, signing out of iCloud, disabling Find My Mac.

**Stack:** Bash
