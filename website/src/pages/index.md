---
title: agentic-knowledge-vault
description: A portable agent skill that scaffolds a shared knowledge vault into any project.
---

# agentic-knowledge-vault

A portable **agent skill** that scaffolds a shared *knowledge vault* into any
project: a single source of truth, living documentation and shared memory for the
people **and** the CLIs/agents (Claude Code, Codex, Cursor, Gemini, Copilot…)
that work on a repository.

> **This site documents the skill; the repository is the installer, not the
> vault.** It contains a skill (`SKILL.md`) that *builds* a vault inside other
> projects through a guided interview.

## What it builds

- **Bootstrap pointers** — one minimal file per CLI/agent in use (`CLAUDE.md`,
  `AGENTS.md`, `GEMINI.md`, …), all identical, forcing any agent to read the
  source of truth before acting.
- **The vault** (`docs/` by default) — an Obsidian vault + living documentation +
  shared memory. Its `README.md` is the single source of truth; `Inicio.md` is
  the navigation hub.
- **Optional knowledge systems** — Tasks, ADR (architecture decisions),
  visual/style decisions, technical catalog… each a folder of YAML-frontmatter
  notes indexed by an Obsidian **Bases** (`.base`) view. The set is extensible.

Guiding principle: **one source of truth per unit of knowledge** — never parallel
copies; link to the origin with wikilinks.

## Two modes

- **Bootstrap** — no vault yet: full guided interview, mounts everything.
- **Extend** — a vault exists: reuses its parameters and only asks which *new*
  system to add, without touching what is already there.

## Install

For Claude (terminal + desktop app), install it as a plugin:

```
/plugin marketplace add danielperezmartinez/agentic-knowledge-vault
/plugin install agentic-knowledge-vault@danielperezmartinez
```

For other CLIs (Codex, Antigravity `agy`, Cursor, Copilot), use the one-command
installer. Full instructions are in the
[README on GitHub](https://github.com/danielperezmartinez/agentic-knowledge-vault#installation).

Then invoke `/agentic-knowledge-vault` and follow the interview.

## License

[MIT](https://github.com/danielperezmartinez/agentic-knowledge-vault/blob/main/LICENSE)
© 2026 Daniel Pérez Martínez.
