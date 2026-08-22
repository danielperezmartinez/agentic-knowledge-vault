---
title: agentic-knowledge-vault
description: Un skill de agente portable que andamia una bóveda de conocimiento compartida en cualquier proyecto.
---

# agentic-knowledge-vault

Un **skill de agente** portable que andamia una *bóveda de conocimiento*
compartida en cualquier proyecto: una única fuente de verdad, documentación viva
y memoria compartida para las personas **y** los CLIs/agentes (Claude Code,
Codex, Cursor, Gemini, Copilot…) que trabajan en un repositorio.

> **Este sitio documenta el skill; el repositorio es el instalador, no la
> bóveda.** Contiene un skill (`SKILL.md`) que *construye* una bóveda dentro de
> otros proyectos mediante una entrevista guiada.

## Qué construye

- **Punteros de arranque** — un fichero mínimo por cada CLI/agente en uso
  (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, …), todos idénticos, que obligan a
  cualquier agente a leer la fuente de verdad antes de actuar.
- **La bóveda** (`docs/` por defecto) — bóveda de Obsidian + documentación viva +
  memoria compartida. Su `README.md` es la única fuente de verdad; `Inicio.md` es
  el nexo de navegación.
- **Sistemas de conocimiento opcionales** — Tareas, ADR (decisiones de
  arquitectura), decisiones visuales y de estilos, catálogo técnico… cada uno una
  carpeta de notas con frontmatter YAML indexadas por una vista de Obsidian
  **Bases** (`.base`). El conjunto es extensible.

Principio rector: **una sola fuente de verdad por cada unidad de conocimiento** —
nunca copias paralelas; se enlaza al origen con wikilinks.

## Dos modos

- **Montaje inicial** — no hay bóveda: entrevista guiada completa, monta todo.
- **Ampliación** — ya existe una bóveda: reutiliza sus parámetros y solo pregunta
  qué sistema *nuevo* añadir, sin tocar lo ya existente.

## Instalación

Para Claude (terminal + app de escritorio), instálala como plugin:

```
/plugin marketplace add danielperezmartinez/dlperezmartinez-claude-marketplace
/plugin install agentic-knowledge-vault@danielperezmartinez
```

Para otros CLIs (Codex, Antigravity `agy`, Cursor, Copilot), usa el instalador de
un comando. Las instrucciones completas están en el
[README de GitHub](https://github.com/danielperezmartinez/agentic-knowledge-vault/blob/main/README.es.md#instalaci%C3%B3n).

Luego invoca `/agentic-knowledge-vault` y sigue la entrevista.

## Licencia

[MIT](https://github.com/danielperezmartinez/agentic-knowledge-vault/blob/main/LICENSE)
© 2026 Daniel Pérez Martínez.
