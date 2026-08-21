# agentic-knowledge-vault

A portable **agent skill** that scaffolds a shared *knowledge vault* into any
project: a single source of truth, living documentation and shared memory for the
people **and** the CLIs/agents (Claude Code, Codex, Cursor, Gemini, Copilot…)
that work on a repository.

> **This repository is the installer, not the vault.** It does not contain a
> knowledge vault — it contains a skill (`SKILL.md`) that *builds* one inside
> other projects through a guided interview.

## What it builds

Inside a target repository, the skill sets up:

- **Bootstrap pointers** — one minimal file per CLI/agent in use (`CLAUDE.md`,
  `AGENTS.md`, `GEMINI.md`, …), all identical, that force any agent to read the
  source of truth before acting. They point; they never duplicate rules.
- **The vault** (`docs/` by default) — simultaneously an Obsidian vault, living
  documentation and shared memory. Its `README.md` is the single source of truth
  (with a mandatory agent protocol) and `Inicio.md` is the navigation hub.
- **Optional knowledge systems**, each a folder of Markdown notes with YAML
  frontmatter indexed by an Obsidian **Bases** (`.base`) view:
  - **Tasks** — work items with state.
  - **ADR** — architecture decision records.
  - **Visual/style decisions**.
  - **Technical catalog** — index of the reusable public surface.
  - …and more; the set is extensible.

The guiding principle throughout: **one source of truth per unit of knowledge** —
never parallel copies of a rule or decision; link to the origin with wikilinks.

## Two modes

The skill detects the repository state and adapts:

- **Bootstrap** — no vault yet: full guided interview, mounts everything from
  scratch.
- **Extend** — a vault already exists: reuses its parameters and only asks which
  *new* system to add, without touching what is already there.

Re-invoking the skill to add a system is the intended workflow: the skill is the
*blueprint* for every possible system, while the vault's README only documents
the systems already installed.

## Cross-tool by design

There is no universal cross-vendor skill format today. Installed as a
**Claude Code** skill it is available across all your Claude Code projects; for
other tools, the pointer files it generates (`AGENTS.md`, etc.) make the mounted
system respected by any agent that reads them.

## Install as a Claude Code skill

Personal (all your projects):

```bash
git clone git@github.com:danielperezmartinez/agentic-knowledge-vault.git ~/.claude/skills/agentic-knowledge-vault
```

Or per-project, under the repo's `.claude/skills/`. Then invoke it by name
(`/agentic-knowledge-vault`) and follow the guided interview.

## Language

The interview and the generated vault default to **Spanish** (this is asked up
front and is fully configurable per project).

## License

_TBD._
