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

Este repositorio es a la vez un **skill** instalable (en `skills/`) y un **plugin
/ marketplace de Claude**. Elige la vía según tu herramienta.

### Claude (terminal + app de escritorio) — vía plugin *(recomendado para Claude)*

En Claude Code, añade este repo como marketplace e instala el plugin. Es la
**única vía que llega a la app de escritorio de Claude** (que no lee carpetas de
skills de disco), y también funciona en el terminal de Claude Code:

```
/plugin marketplace add danielperezmartinez/agentic-knowledge-vault
/plugin install agentic-knowledge-vault@agentic-knowledge-vault
```

### Otros CLIs — instalador interactivo

Para Codex, Antigravity CLI (`agy`), Cursor, GitHub Copilot — y el terminal de
Claude Code, si prefieres ficheros al plugin — usa el instalador. Pregunta
**ámbito** (usuario/proyecto), **qué CLIs** (multi-selección) y **método** —
*symlink* (recomendado) o *copia* — y escribe el skill en la carpeta de cada CLI.

macOS / Linux / Git Bash:

```bash
curl -fsSL https://raw.githubusercontent.com/danielperezmartinez/agentic-knowledge-vault/main/install.sh | bash
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/danielperezmartinez/agentic-knowledge-vault/main/install.ps1 | iex
```

> En Windows, los symlinks requieren Modo desarrollador (o admin); si no está
> disponible, el instalador cae automáticamente a copia y te avisa.

Dónde lee cada CLI el skill (`<dir>/agentic-knowledge-vault/SKILL.md`):

| CLI | Usuario (global) | Proyecto | Superficie |
| --- | --- | --- | --- |
| Claude Code | `$CLAUDE_CONFIG_DIR/skills` o `~/.claude/skills` | `.claude/skills` | terminal (para la **app**, usa el plugin de arriba) |
| Cursor | `~/.cursor/skills` | `.cursor/skills` | — |
| Codex | `~/.codex/skills` | `.agents/skills` | app de escritorio; **terminal** vía ámbito proyecto |
| Antigravity CLI (`agy`) | `~/.gemini/skills` | `.gemini/skills` | solo terminal (su IDE de escritorio no se cubre aquí) |
| GitHub Copilot | `~/.copilot/skills` | `.github/skills` | — |

> **El descubrimiento es por herramienta e incluso por superficie.** El *mismo*
> producto suele leer una carpeta distinta en terminal que en su app de
> escritorio, y algunos CLIs encuentran `.agents/skills` solo **subiendo** desde
> el proyecto (así que una instalación de usuario en tu home solo les llega para
> proyectos que cuelgan de tu carpeta de usuario). Por eso **ninguna instalación
> de ámbito usuario cubre todas las superficies**. El único método fiable e
> independiente de la unidad es la instalación de ámbito **proyecto** en cada
> repo — muy recomendada si tus proyectos viven en una unidad distinta a la de tu
> perfil (habitual en Windows, p. ej. `P:\`).
>
> Si defines `CLAUDE_CONFIG_DIR`, Claude Code lee las skills de usuario de
> `$CLAUDE_CONFIG_DIR/skills` (no de `~/.claude/skills`). El instalador lo
> respeta automáticamente.

No interactivo (CI / automatización):

```bash
# bash: flags
./install.sh --scope user --agents claude,cursor,codex,antigravity,copilot --method symlink
./install.sh --scope project --agents all --method copy -y
```

```powershell
# PowerShell: variables de entorno
$env:AKV_SCOPE='user'; $env:AKV_AGENTS='claude,cursor'; $env:AKV_METHOD='symlink'; irm .../install.ps1 | iex
```

> El patrón `curl … | bash` / `irm … | iex` ejecuta un script remoto; ambos
> scripts son cortos y auditables en este repo antes de ejecutarlos.

### Actualizar

- **Plugin (Claude)** — `/plugin marketplace update agentic-knowledge-vault` y
  reinstala el plugin si ofrece versión nueva.
- **Instalador (symlink)** — reejecuta el instalador; solo cambia la copia
  canónica y todos los CLIs enlazados la ven.
- **Instalador (copia)** — reejecuta el instalador para refrescar la copia de
  cada CLI.

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
