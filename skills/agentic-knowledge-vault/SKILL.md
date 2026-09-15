---
name: agentic-knowledge-vault
description: >-
  Monta desde cero el sistema de memoria y documentación viva basado en Obsidian
  que el usuario usa en sus proyectos: una bóveda `docs/` que es simultáneamente
  fuente de verdad, documentación y memoria compartida entre personas, CLIs y
  agentes. Incluye los punteros de arranque `AGENTS.md`/`CLAUDE.md`, el protocolo
  obligatorio para agentes, y sistemas de conocimiento formados por notas con
  frontmatter YAML e índices `.base` de Obsidian Bases (Tareas, ADR de
  arquitectura, decisiones visuales, catálogo técnico, y otros extensibles).
  Úsalo para INSTAURAR este sistema en un repositorio nuevo, para AMPLIAR una
  bóveda existente con sistemas nuevos, o para SINCRONIZAR en una bóveda ya
  montada los cambios hechos en las instrucciones de un sistema (versionado por
  sistema + guías de migración). No sirve para *usar* a diario una bóveda
  existente, sino para *construir* y *mantener* su andamiaje mediante una
  entrevista guiada.
---

# Montar la bóveda de memoria del proyecto

## Qué es este sistema (contexto para ti, el agente)

Este skill te enseña a **construir el andamiaje** de un sistema de memoria en 
un repositorio nuevo. El sistema tiene tres capas:

1. **Punteros de arranque**: un fichero mínimo en la raíz por cada CLI o agente
   que use el usuario (cada herramienta lee el suyo; ver Paso 1), todos con el
   mismo contenido. Obligan a cualquier agente a leer la fuente de verdad antes
   de actuar. **No contienen reglas**; solo apuntan. Las reglas nunca se duplican
   fuera de la fuente de verdad.
2. **La bóveda `docs/`**: a la vez bóveda de Obsidian, documentación viva y
   memoria compartida. Su `README.md` es la única fuente de verdad; `Inicio.md`
   es el nexo de navegación humano.
3. **Sistemas de conocimiento**: cada uno es una carpeta de notas Markdown con
   frontmatter YAML, indexadas por un fichero `.base` (Obsidian Bases) que
   genera vistas de tabla filtradas por estado. Todos los sistemas (Tareas, ADR,
   decisiones visuales, catálogo técnico y otros) son opcionales y extensibles;
   se montan solo los que el usuario elija.

El principio rector de toda la bóveda: **una sola fuente de verdad por cada
unidad de conocimiento**; nunca se crean copias paralelas de una regla o
decisión, se enlaza a su origen con wikilinks.

### Cómo está organizado este skill (léelo antes de montar nada)

Para no cargar tu contexto con instrucciones que no vas a usar, el skill está
**fragmentado**: este `SKILL.md` contiene solo la **entrevista** (Paso 0), el
**mapa de montaje** y la **verificación**. El procedimiento concreto de cada
pieza vive en un fichero aparte dentro de `references/`, y **solo debes abrirlo
cuando lo vayas a montar**:

- Los pasos de construcción de la base y de cada sistema NO están aquí. Están en
  `references/` (ver "Cómo montar: mapa de ficheros" más abajo).
- Flujo correcto: completa la entrevista → determina qué montar → **lee solo los
  ficheros de `references/` que correspondan** → aplícalos en orden → verifica.
- Si el usuario solo quiere, por ejemplo, el sistema de Tareas, abrirás
  `references/base-compartida.md` y `references/sistema-tareas.md`, y **ningún
  otro**: las instrucciones de ADR, catálogo, etc. serían ruido.

---

## Paso 0 — Detectar el modo y entrevista guiada (OBLIGATORIO antes de escribir nada)

Este skill funciona en **tres modos**: _montaje inicial_ (repo sin bóveda),
_ampliación_ (bóveda existente, añadir sistemas nuevos) y _sincronización_ (bóveda
existente, actualizar sistemas ya montados cuyas instrucciones han cambiado en el
plano). **Detecta primero cuál aplica** y solo entonces haz las preguntas que
correspondan. No montes nada por inferencia; usa el mecanismo de preguntas de tu
herramienta si lo tienes, o el chat, y espera respuesta antes de crear ficheros.

### 0a. Detectar si la bóveda ya existe

Comprueba si el repo ya tiene este mecanismo montado. Señales:

- Existe `{{BÓVEDA}}/README.md` (busca primero en `docs/`) con la sección
  "Protocolo obligatorio para agentes".
- Existen ficheros puntero en la raíz (`CLAUDE.md`, `AGENTS.md`, etc.) que apuntan
  a ese README.

Según el resultado:

- **No existe → modo _montaje inicial_.** Haz todas las preguntas (1–5) y monta
  desde cero: la base compartida y los sistemas elegidos (ver "Cómo montar: mapa
  de ficheros").
- **Ya existe → modo _ampliación_ y/o _sincronización_.** NO rehagas el montaje ni
  los punteros ni el README base. **Lee el README e `Inicio` existentes** para
  conocer los parámetros reales (ruta de la bóveda, idioma, nombre del proyecto) y
  qué sistemas ya están montados **y con qué versión**; NO los vuelvas a preguntar.
  Luego determina el alcance con la **Pregunta 0b**.

### 0b. Con bóveda existente: ampliar, sincronizar o ambos · _solo si la bóveda ya existe_

Antes de preguntar, **compara versiones** para saber qué ofrecer:

1. En la sección "Sistemas disponibles" del README, lee cada sistema montado y su
   línea `_Versión del sistema: N._`. Si un sistema montado no la tiene (bóveda
   anterior al versionado), trátalo como `N = 1`.
2. Para cada sistema montado, abre **solo** su `references/sistema-*.md` y lee la
   `version` de su frontmatter (la del plano). Anota los que tengan
   `instalada < plano`: son los **desactualizados**.

Con eso, pregunta el alcance en una sola pregunta (ofrece solo lo que aplique):

- **Añadir sistemas nuevos** (ampliación) — si quedan sistemas sin montar.
- **Sincronizar sistemas desactualizados** — solo si el paso 2 encontró alguno;
  nómbralos con su salto (p. ej. "Tareas v1 → v2").
- **Ambos**.

Enruta según la respuesta:

- **Ampliación** → NO rehagas base ni punteros. (1) Haz solo la **Pregunta 2b**,
  limitada a los sistemas que **aún no existen** (NO hagas la compuerta 2a).
  (2) Si el sistema nuevo necesita contenido, aplica la **Pregunta 3** solo para
  él. (3) Lee y aplica **solo** el/los `references/sistema-*.md` nuevo(s); NO abras
  `references/base-compartida.md`. (4) Actualiza "Sistemas disponibles" del README
  (con su línea `_Versión del sistema: N._`) y los enlaces de `Inicio`. **No
  toques los sistemas existentes.**
- **Sincronización** → abre `references/sincronizacion.md` y sigue su
  procedimiento. NO abras `base-compartida.md` ni los ficheros de los sistemas que
  estén al día.
- **Ambos** → primero sincroniza los desactualizados, luego amplía con los nuevos.

Si no hay sistemas nuevos por montar ni desactualizados, la bóveda está completa y
al día: infórmalo y termina sin cambios.

> Por qué reinvocar el skill para añadir un sistema es lo correcto: el skill es el
> *plano* de todos los sistemas posibles; el README de la bóveda solo documenta
> los sistemas **ya instalados**. Por eso un agente no puede conocer las
> instrucciones de, p. ej., ADR mirando una bóveda donde ADR no está montado: esa
> fuente vive aquí. El skill instala; el README opera lo instalado. Lo mismo vale
> para la sincronización: la bóveda solo sabe qué versión tiene instalada de cada
> sistema; las **guías de migración** entre versiones viven en el plano (en el
> `## Cambios y migraciones` de cada `references/sistema-*.md`).

### 0c. Idioma de la bóveda · _solo montaje inicial_

En modo montaje inicial, **antes de empezar la entrevista**, pregunta al usuario
en qué idioma quiere la bóveda (notas, propiedades del frontmatter, protocolo y
plantillas). Por defecto, español. Realiza **el resto de la entrevista y todo el
contenido que generes en ese idioma**.

En modo ampliación no preguntes esto: reutiliza el idioma de la bóveda existente
(dedúcelo del README e `Inicio`).

### Pregunta 1 — ¿Qué CLIs o agentes usará el usuario? (selección múltiple) · _solo montaje inicial_

Determina qué ficheros puntero de arranque hay que crear en la raíz del repo.
Puede ser más de uno: crea uno por cada herramienta seleccionada, todos con el
**mismo contenido puntero** (ver Paso 1). Mapeo herramienta → fichero:

- **Claude Code** → `CLAUDE.md`
- **Codex (OpenAI)** → `AGENTS.md`
- **Cursor** → `AGENTS.md` (o `.cursor/rules/*.mdc` si el usuario lo prefiere)
- **Antigravity CLI (agy, terminal)** → `GEMINI.md`
- **GitHub Copilot** → `.github/copilot-instructions.md`
- **Otro** → pregunta qué fichero de instrucciones lee esa herramienta y créalo.

Si dos herramientas comparten fichero (p. ej. Codex y Cursor usan `AGENTS.md`),
se crea una sola vez. Todos los punteros son idénticos entre sí.

### Pregunta 2 — Sistemas a montar · _partida en dos: 2a compuerta + 2b sistemas_

**Concepto clave que debes tener claro antes de preguntar:** la **base
compartida** (punteros + `README.md` + `Inicio.md`) se monta **siempre** — es el
núcleo del skill. Los sistemas de conocimiento (Tareas, ADR, etc.) son añadidos
**opcionales encima** de esa base. Por tanto **"cero sistemas" es una respuesta
legítima y completa**: significa montar solo la base compartida entre CLIs. Este
mismo repo es un ejemplo de ese estado final (su `README.md` lista "ningún
sistema montado").

Por eso la pregunta se hace en **dos pasos**, para no depender de que el usuario
"deje vacía" una selección múltiple (eso es ambiguo y **nunca** debe interpretarse
como que falta respuesta).

#### Pregunta 2a — Compuerta (selección única, 2 opciones) · _solo montaje inicial_

Pregunta primero el alcance:

- **Solo la base compartida (sin sistemas)** — monta únicamente el mecanismo de
  memoria compartida entre CLIs/agentes. Es una opción de primera clase, no un
  "no sé".
- **Montar también sistemas de conocimiento** — además de la base, uno o más
  sistemas; continúa con la Pregunta 2b.

Si elige **"Solo la base compartida"**: monta **solo** `references/base-compartida.md`
(y, si el usuario usa Obsidian, `references/obsidian.md`); deja la sección
"Sistemas disponibles" del README indicando que aún no hay sistemas montados (como
en este repo) y en `Inicio` lista bajo "Próximos sistemas" los que podrían
añadirse reinvocando el skill en modo ampliación. **No hagas la Pregunta 2b ni
ninguna pregunta de sistemas.** Da el montaje por terminado; no reabras la
decisión.

#### Pregunta 2b — Qué sistemas (selección múltiple) · _montaje inicial y ampliación_

Solo si en 2a eligió montar sistemas (o si estás en modo ampliación). En modo
ampliación, ofrece solo los sistemas que aún no estén montados.

- **Tareas** — gestión de trabajos como notas con estado. *Recomendado en la
  mayoría de proyectos, pero opcional.*
- **ADR (decisiones de arquitectura)** — para proyectos medianos/grandes.
  Registra decisiones técnicas duraderas con contexto, alternativas y
  consecuencias. Tiene su propio `.base`.
- **Decisiones visuales y de estilos** — acuerdos sobre lenguaje visual, tokens,
  componentes. Puede compartir patrón con ADR o ser una lista más ligera.
- **Catálogo técnico** — superficie pública reutilizable (UI, servicios,
  contratos). Carpeta de notas estructuradas por pieza + `.base` + nota-índice.
- **Otros** — pregunta libre por sistemas adicionales que el usuario quiera.

> **Regla defensiva (obligatoria).** Si en cualquier momento la respuesta de
> sistemas vuelve **vacía** (el usuario no seleccionó ninguno), **no reintentes ni
> vuelvas a preguntar en bucle**: interprétala como "solo la base compartida",
> confírmalo en una sola frase ("Monto solo la base compartida, sin sistemas,
> ¿de acuerdo?") y procede con el camino de "solo la base" descrito en 2a. En modo
> ampliación, una respuesta vacía significa que no se añade ningún sistema:
> informa de ello y termina sin cambios.

### Pregunta 3 — ¿Rellenar el andamio ahora o dejarlo como plantilla? · _montaje inicial y ampliación_

- **Rellenar ahora**: además del andamiaje, completas las reglas fundamentales y,
  si procede, migras conocimiento existente a notas reales.
- **Dejar como plantilla**: montas la estructura con marcadores `<!-- TODO -->`
  y secciones vacías listas para rellenar más adelante. El sistema queda
  funcional y navegable, pero sin contenido de dominio.

### Pregunta 3b — Si "rellenar ahora": ¿cómo quieres rellenarlo? · _montaje inicial y ampliación_

Si el usuario eligió "rellenar ahora" en la Pregunta 3, **antes de escribir
ningún contenido** pregúntale explícitamente cómo quiere que se rellene. No
asumas "automático" por defecto: es una elección tan explícita como la propia
Pregunta 3.

- **Automático**: tú infieres el contenido a partir del contexto del proyecto
  (código, ficheros de configuración, historial, etc.) sin pedir cada dato uno
  a uno.
- **Guiado por el usuario**: el usuario te da las indicaciones/reglas; tú solo
  las estructuras y las escribes, sin inventar ni inferir nada por tu cuenta.
- **Mixto**: propones un borrador inferido del contexto y el usuario lo
  corrige o completa antes de darlo por bueno.

Aplica el modo elegido a todo el contenido que rellenes en esta sesión
(reglas fundamentales, migración de conocimiento existente, y cualquier
sistema nuevo que también deba rellenarse en modo ampliación).

### Pregunta 4 — Reglas fundamentales del proyecto (solo si "rellenar ahora") · _solo montaje inicial_

Las "Reglas fundamentales" son específicas de cada proyecto y viven en
`docs/README.md`. Complétalas según el modo elegido en la **Pregunta 3b**
(automático, guiado o mixto); **monta solo las que apliquen**, no claves un
conjunto fijo. Cubre al menos:

- **Gestor de paquetes y política** (p. ej. pnpm exclusivo, prohibición de
  npm/npx, lockfile, cuarentena de versiones, scripts de instalación).
- **Framework/stack y sus reglas** (p. ej. Angular zoneless + Signals, o el
  stack que sea).
- **Política de versionado y despliegue** (SemVer, cuándo incrementar, dónde y
  cómo se despliega, cómo se verifica).
- **Idioma** de código, identificadores, comentarios y documentación.
- **Propósito del proyecto y arquitectura objetivo** (taxonomía, estructura de
  carpetas, reglas de dependencia).

Si el usuario no quiere entrar en esto ahora, trátalo como "dejar como
plantilla" para la sección de reglas y continúa.

### Pregunta 5 — Parámetros de la bóveda · _solo montaje inicial_

- **Ruta de la bóveda**: por defecto `docs/`.
- **Nombre del proyecto** para los encabezados.

Registra las respuestas y úsalas como parámetros en todo lo que sigue. En las
plantillas de los ficheros de `references/`, sustituye `{{PROYECTO}}`,
`{{BÓVEDA}}` (por defecto `docs`) y demás marcadores.

---

## Cómo montar: mapa de ficheros de `references/`

Terminada la entrevista, ya sabes qué montar. **Lee y aplica solo** los ficheros
de esta tabla que correspondan, en este orden. No abras los que no vas a usar.

| Qué vas a montar | Fichero a leer y aplicar | Cuándo |
| --- | --- | --- |
| Punteros + `README.md` + `Inicio.md` (Pasos 1–3) | `references/base-compartida.md` | **Siempre en montaje inicial.** Nunca en ampliación (ya existe). |
| Sistema de Tareas (Paso 4) | `references/sistema-tareas.md` | Solo si se eligió Tareas. |
| Sistema ADR (Paso 5) | `references/sistema-adr.md` | Solo si se eligió ADR. |
| Decisiones visuales (Paso 6) | `references/sistema-decisiones-visuales.md` | Solo si se eligió. |
| Catálogo técnico (Paso 7) | `references/sistema-catalogo-tecnico.md` | Solo si se eligió. |
| Configuración de Obsidian (Paso 8) | `references/obsidian.md` | Opcional; si el usuario usa Obsidian. |
| Sincronizar sistemas montados (Modo 3) | `references/sincronizacion.md` | Solo en modo sincronización (ver Pregunta 0b). |

Orden de aplicación:

1. **Montaje inicial**: primero `base-compartida.md`; después, un fichero por cada
   sistema elegido; al final `obsidian.md` si aplica. Cada fichero de sistema te
   dice qué añadir a "Sistemas disponibles" del `README.md` (incluida su línea
   `_Versión del sistema: N._`) y a `Inicio.md`.
2. **Ampliación**: NO leas `base-compartida.md`. Lee solo el/los fichero(s) del/de
   los sistema(s) nuevo(s), móntalos y actualiza `README.md` e `Inicio.md`.
3. **Sincronización**: NO leas `base-compartida.md`. Abre `references/sincronizacion.md`
   y, guiado por él, solo el/los `references/sistema-*.md` de los sistemas
   desactualizados (para leer su `## Cambios y migraciones`).

---

## Verificación final

En **modo sincronización**, usa la checklist de verificación de
`references/sincronizacion.md` (Paso S5): versiones selladas al día, canónico
regenerado, notas migradas solo con aprobación y todo lo marcado "NO tocar"
intacto.

En **modo ampliación**, comprueba solo lo relativo al sistema nuevo: que su
carpeta, plantilla y `.base` existen, que el README ("Sistemas disponibles") e
`Inicio` lo enlazan, que lleva su línea `_Versión del sistema: N._`, y que
**ningún sistema ni puntero previo ha cambiado**.

En **modo montaje inicial**, comprueba todo lo siguiente:

- [ ] Existe un fichero puntero en la raíz por cada CLI/agente elegido en la
      Pregunta 1, todos idénticos y apuntando solo a `{{BÓVEDA}}/README.md` (no
      duplican reglas).
- [ ] `{{BÓVEDA}}/README.md` contiene el protocolo obligatorio, las convenciones,
      la lista de sistemas montados y la sección de reglas (rellenas o como
      plantilla, según lo acordado).
- [ ] `{{BÓVEDA}}/Inicio.md` enlaza cada sistema montado **solo con referencias**
      a su `.base`/nota-índice, sin incrustar vistas (`![[...#Todo]]`).
- [ ] Cada sistema con `.base` tiene su carpeta, al menos su plantilla y su
      fichero `.base` con la vista `Todo`.
- [ ] Cada sistema montado lleva, en "Sistemas disponibles", su línea
      `_Versión del sistema: N._` con la versión que declara su fichero de
      `references/`.
- [ ] Todas las fechas usan formato ISO; los wikilinks resuelven.
- [ ] Si se eligió "dejar como plantilla", los marcadores `<!-- TODO -->` están
      presentes y el sistema es navegable pese a no tener contenido de dominio.

Informa al usuario de qué se montó, qué quedó como plantilla y cuáles son los
"próximos sistemas" pendientes para futuras sesiones.

---

## Principios que NUNCA debes romper al montar

1. **Fuente única de verdad.** Las reglas viven solo en `README.md`. Los punteros
   apuntan; no copian.
2. **Nada por inferencia.** Si la entrevista no cubrió algo, pregunta o déjalo
   como plantilla explícita; no inventes reglas de proyecto.
3. **Antes de crear, buscar.** Toda entrada nueva exige revisar las existentes
   para no duplicar conocimiento.
4. **Mismo patrón para todo sistema de decisiones**: frontmatter YAML + `.base`
   con vistas por estado. No proliferes formatos distintos.
5. **Resúmenes autoexplicativos.** El `Resumen` de cada nota debe bastar para
   entenderla sin abrirla.
6. **Carga solo lo necesario.** Abre únicamente los ficheros de `references/` de
   lo que vayas a montar; no cargues instrucciones de sistemas que el usuario no
   ha pedido.
