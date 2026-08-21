# agentic-knowledge-vault

**Léelo en:** [English](README.md) · Español

Un **skill de agente** portable que andamia una *bóveda de conocimiento*
compartida en cualquier proyecto: una única fuente de verdad, documentación viva
y memoria compartida para las personas **y** los CLIs/agentes (Claude Code,
Codex, Cursor, Gemini, Copilot…) que trabajan en un repositorio.

> **Este repositorio es el instalador, no la bóveda.** No contiene una bóveda de
> conocimiento — contiene un skill (`SKILL.md`) que *construye* una dentro de
> otros proyectos mediante una entrevista guiada.

## Qué construye

Dentro del repositorio destino, el skill monta:

- **Punteros de arranque** — un fichero mínimo por cada CLI/agente en uso
  (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, …), todos idénticos, que obligan a
  cualquier agente a leer la fuente de verdad antes de actuar. Apuntan; nunca
  duplican reglas.
- **La bóveda** (`docs/` por defecto) — a la vez bóveda de Obsidian,
  documentación viva y memoria compartida. Su `README.md` es la única fuente de
  verdad (con un protocolo obligatorio para agentes) e `Inicio.md` es el nexo de
  navegación.
- **Sistemas de conocimiento opcionales**, cada uno una carpeta de notas Markdown
  con frontmatter YAML indexadas por una vista de Obsidian **Bases** (`.base`):
  - **Tareas** — trabajos con estado.
  - **ADR** — registros de decisiones de arquitectura.
  - **Decisiones visuales y de estilos**.
  - **Catálogo técnico** — índice de la superficie pública reutilizable.
  - …y más; el conjunto es extensible.

El principio rector: **una sola fuente de verdad por cada unidad de
conocimiento** — nunca copias paralelas de una regla o decisión; se enlaza al
origen con wikilinks.

## Dos modos

El skill detecta el estado del repositorio y se adapta:

- **Montaje inicial** — no hay bóveda: entrevista guiada completa, monta todo
  desde cero.
- **Ampliación** — ya existe una bóveda: reutiliza sus parámetros y solo pregunta
  qué sistema *nuevo* añadir, sin tocar lo ya existente.

Reinvocar el skill para añadir un sistema es el flujo previsto: el skill es el
*plano* de todos los sistemas posibles, mientras que el README de la bóveda solo
documenta los sistemas ya instalados.

## Multi-herramienta por diseño

Hoy no existe un formato de skill universal entre proveedores. Instalado como
skill de **Claude Code** está disponible en todos tus proyectos de Claude Code;
para otras herramientas, los ficheros puntero que genera (`AGENTS.md`, etc.)
hacen que el sistema montado sea respetado por cualquier agente que los lea.

## Instalación

El repositorio **es** el skill (`SKILL.md` en su raíz), así que instalarlo es
solo colocarlo dentro de una carpeta de skills. Elige un método.

### A. Un comando — `git clone` (lo más simple)

Personal, disponible en todos tus proyectos de Claude Code:

```bash
git clone https://github.com/danielperezmartinez/agentic-knowledge-vault.git ~/.claude/skills/agentic-knowledge-vault
```

En un proyecto concreto (desde la raíz del proyecto):

```bash
git clone https://github.com/danielperezmartinez/agentic-knowledge-vault.git .claude/skills/agentic-knowledge-vault
```

### B. Script de instalación (instala o actualiza)

Los scripts clonan el skill la primera vez y lo actualizan (fast-forward) en
ejecuciones posteriores.

macOS / Linux / Git Bash:

```bash
curl -fsSL https://raw.githubusercontent.com/danielperezmartinez/agentic-knowledge-vault/main/install.sh | bash
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/danielperezmartinez/agentic-knowledge-vault/main/install.ps1 | iex
```

Ambos instalan en `~/.claude/skills/` por defecto. Para instalar en el proyecto
actual: pasa `-s -- --project` al one-liner de bash, o define
`$env:AKV_DEST = ".claude/skills"` antes del one-liner de PowerShell. Al
`install.sh` también puedes darle una carpeta destino como primer argumento.

> El patrón `curl … | bash` / `irm … | iex` ejecuta un script remoto; ambos
> scripts son cortos y auditables en este repo antes de ejecutarlos.

### Actualizar

Reejecuta el script de instalación, o `git -C <carpeta-instalada> pull`.

### Usarlo

Invoca el skill por su nombre — `/agentic-knowledge-vault` en Claude Code — y
sigue la entrevista guiada.

## Idioma

La entrevista y la bóveda generada van en **español** por defecto (se pregunta al
inicio y es totalmente configurable por proyecto).

## Licencia

[MIT](LICENSE) © 2026 Daniel Pérez Martínez. Libre para usar, modificar y
redistribuir; la atribución (conservar el aviso de copyright y licencia) es
obligatoria.
