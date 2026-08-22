# agentic-knowledge-vault

**Read this in:** English · [Español](README.es.md)

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

## Installation

### Recommended — interactive installer

The installer asks **which scope** (user/global or the current project), **for
which CLIs** you want the skill (multi-select), and **which method** — *symlink*
(recommended: one canonical copy, the rest linked to it, so updating one updates
all) or *copy* (an independent copy per CLI). It then creates the skill in the
directory each selected CLI expects. Works run locally or piped.

> On Windows, symlinks need Developer Mode (or admin); if unavailable the
> installer falls back to a copy automatically and tells you.

macOS / Linux / Git Bash:

```bash
curl -fsSL https://raw.githubusercontent.com/danielperezmartinez/agentic-knowledge-vault/main/install.sh | bash
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/danielperezmartinez/agentic-knowledge-vault/main/install.ps1 | iex
```

Each selected CLI is installed into the folder it reads. Files land at
`<dir>/agentic-knowledge-vault/SKILL.md`.

| CLI | User (global) | Project |
| --- | --- | --- |
| Claude Code | `~/.claude/skills` | `.claude/skills` |
| Cursor | `~/.cursor/skills` | `.cursor/skills` |
| Codex | `~/.codex/skills` | `.agents/skills` |
| Antigravity CLI (`agy`) | `~/.gemini/skills` | `.gemini/skills` |
| GitHub Copilot | `~/.copilot/skills` | `.github/skills` |

> **Discovery is per-tool and even per-surface.** The *same* product often reads
> a different folder in its terminal vs. its desktop app: e.g. **Claude Code**
> (terminal) reads only `~/.claude/skills`, while the **Claude desktop app** does
> not use these filesystem folders at all — it uses the skills enabled for your
> claude.ai account (Customize). Some tools find `.agents/skills` only by walking
> **up** from the project folder, so a home-based user install reaches them only
> for projects under your home directory. Because of this, **no single user-scope
> install covers every surface**. The one reliable, drive-independent method is a
> **project-scope** install in each repo — strongly recommended when your
> projects live on a different drive than your user profile (common on Windows,
> e.g. `P:\`).
>
> If you set `CLAUDE_CONFIG_DIR`, Claude Code reads user skills from
> `$CLAUDE_CONFIG_DIR/skills` (not `~/.claude/skills`). The installer honors it
> automatically.

Non-interactive (CI / automation):

```bash
# bash: flags
./install.sh --scope user --agents claude,cursor,codex,antigravity,copilot --method symlink
./install.sh --scope project --agents all --method copy -y
```

```powershell
# PowerShell: environment variables
$env:AKV_SCOPE='user'; $env:AKV_AGENTS='claude,cursor'; $env:AKV_METHOD='symlink'; irm .../install.ps1 | iex
```

> The `curl … | bash` / `irm … | iex` pattern runs a remote script; both scripts
> are short and auditable in this repo before you run them.

### Manual — `git clone` (Claude Code only)

If you only use Claude Code, cloning into its skills directory is enough:

```bash
git clone https://github.com/danielperezmartinez/agentic-knowledge-vault.git ~/.claude/skills/agentic-knowledge-vault
```

### Updating

- **Installer (symlink)** — re-run the installer; only the canonical copy changes
  and every linked CLI sees it. You can also edit the canonical `SKILL.md`
  directly and all links reflect it.
- **Installer (copy)** — re-run the installer to refresh each CLI's copy.
- **Manual `git clone`** — `git -C <install-dir> pull`.

### Use it

Invoke the skill by name — `/agentic-knowledge-vault` in Claude Code — and follow
the guided interview.

## Language

The interview and the generated vault default to **Spanish** (this is asked up
front and is fully configurable per project).

## License

[MIT](LICENSE) © 2026 Daniel Pérez Martínez. Free to use, modify and
redistribute; attribution (keeping the copyright and license notice) is required.
