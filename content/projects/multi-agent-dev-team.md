---
title: "Multi-Agent Dev Team"
date: 2026-03-10
tags: ["ai", "agents", "architecture", "devtools", "productivity"]
draft: false
---

## Structured AI agent teams with memory and coordination

Most people interact with AI assistants one prompt at a time. I wanted to see what happens when you design a full development team of AI agents — each with a defined role, personality, diagnostic methodology, and persistent memory — and have them collaborate on real engineering work.

**The setup:**

Five specialized agents, each with a distinct archetype and working style:

- **Leader** — Delegation, scoping, planning. Operates through a 5-field briefing format and dual quality gates.
- **Backend** — Django/DRF/Postgres specialist with a diagnostic loop that has a hard stop: after 2 failed hypotheses, escalate instead of brute-forcing.
- **Frontend** — Next.js/TypeScript, 4-states rendering rule, and a QA checklist that runs before any PR.
- **Designer** — Full state specifications and a feasibility gate that forces consideration of edge cases before committing to designs.
- **Security** — 7-category Django-aware review that runs after every Backend or Frontend task, before the second quality gate.

**Memory architecture:**

Two tiers. User-level memory (`~/.claude/agents/memory/[role]/`) stores cross-project patterns — things each agent has learned from debugging, testing, reviewing. These accumulate over time. When a category file gets long (~30 entries), the agent splits it rather than deleting anything.

Project-level memory (`.claude/context.md` in each repo) stores project-specific context. Every agent checks for this at session start and creates it if missing.

**Edge case methodology:**

A reference document covers three types of edge cases (boundary, invalid input, state conflict), five discovery methods with concrete examples, and context-specific checklists for API endpoints, UI components, database operations, auth flows, and async tasks.

**Why this matters:**

The diagnostic loop alone changes how debugging sessions go — the 2-failure escalation stop prevents the rabbit-hole pattern where an agent keeps trying variations of the same broken approach. The security-as-first-class-citizen pattern (review after every task, not as an afterthought) catches issues that would otherwise make it to PR.

**Stack:** Claude agents, Markdown-based configuration, role-based memory hierarchies
