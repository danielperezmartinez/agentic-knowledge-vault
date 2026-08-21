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
  Úsalo cuando se quiera INSTAURAR este sistema en un proyecto o repositorio
  NUEVO. No sirve para *usar* una bóveda ya existente, sino para *construir* el
  andamiaje y sus sistemas mediante una entrevista guiada.
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

---

## Paso 0 — Detectar el modo y entrevista guiada (OBLIGATORIO antes de escribir nada)

Este skill funciona en dos modos. **Detecta primero cuál aplica** y solo entonces
haz las preguntas que correspondan. No montes nada por inferencia; usa el
mecanismo de preguntas de tu herramienta si lo tienes, o el chat, y espera
respuesta antes de crear ficheros.

### 0a. Detectar si la bóveda ya existe

Comprueba si el repo ya tiene este mecanismo montado. Señales:

- Existe `{{BÓVEDA}}/README.md` (busca primero en `docs/`) con la sección
  "Protocolo obligatorio para agentes".
- Existen ficheros puntero en la raíz (`CLAUDE.md`, `AGENTS.md`, etc.) que apuntan
  a ese README.

Según el resultado:

- **No existe → modo _montaje inicial_.** Haz todas las preguntas (1–5) y monta
  desde cero siguiendo los pasos 1–9.
- **Ya existe → modo _ampliación_.** NO rehagas el montaje ni los punteros ni el
  README base. **Lee el README e `Inicio` existentes** para conocer los parámetros
  reales (ruta de la bóveda, idioma, nombre del proyecto) y qué sistemas ya están
  montados; NO los vuelvas a preguntar. Luego:
  1. Haz solo la **Pregunta 2**, limitada a los sistemas que **aún no existen**.
  2. Si el sistema nuevo necesita definir contenido, aplica la **Pregunta 3**
     (rellenar ahora o dejar plantilla) solo para ese sistema.
  3. Ejecuta únicamente el paso de construcción del/los sistema(s) elegido(s).
  4. Actualiza la sección "Sistemas disponibles" del README y los enlaces de
     `Inicio` para incluir el sistema nuevo. **No toques los sistemas existentes.**

> Por qué reinvocar el skill para añadir un sistema es lo correcto: el skill es el
> *plano* de todos los sistemas posibles; el README de la bóveda solo documenta
> los sistemas **ya instalados**. Por eso un agente no puede conocer las
> instrucciones de, p. ej., ADR mirando una bóveda donde ADR no está montado: esa
> fuente vive aquí. El skill instala; el README opera lo instalado.

### 0b. Idioma de la bóveda · _solo montaje inicial_

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
- **Gemini CLI** → `GEMINI.md`
- **GitHub Copilot** → `.github/copilot-instructions.md`
- **Otro** → pregunta qué fichero de instrucciones lee esa herramienta y créalo.

Si dos herramientas comparten fichero (p. ej. Codex y Cursor usan `AGENTS.md`),
se crea una sola vez. Todos los punteros son idénticos entre sí.

### Pregunta 2 — Sistemas a montar (selección múltiple) · _ambos modos_

En modo ampliación, ofrece solo los sistemas que aún no estén montados.


- **Tareas** — gestión de trabajos como notas con estado. *Recomendado en la
  mayoría de proyectos, pero opcional.*
- **ADR (decisiones de arquitectura)** — para proyectos medianos/grandes.
  Registra decisiones técnicas duraderas con contexto, alternativas y
  consecuencias. Tiene su propio `.base`.
- **Decisiones visuales y de estilos** — acuerdos sobre lenguaje visual, tokens,
  componentes. Puede compartir patrón con ADR o ser una lista más ligera.
- **Catálogo técnico** — índice de la superficie pública reutilizable (UI,
  servicios, contratos). No usa `.base`; es una nota-índice con tabla Markdown.
- **Otros** — pregunta libre por sistemas adicionales que el usuario quiera.

### Pregunta 3 — ¿Rellenar el andamio ahora o dejarlo como plantilla? · _ambos modos_

- **Rellenar ahora**: además del andamiaje, completas las reglas fundamentales y,
  si procede, migras conocimiento existente a notas reales.
- **Dejar como plantilla**: montas la estructura con marcadores `<!-- TODO -->`
  y secciones vacías listas para rellenar más adelante. El sistema queda
  funcional y navegable, pero sin contenido de dominio.

### Pregunta 4 — Reglas fundamentales del proyecto (solo si "rellenar ahora") · _solo montaje inicial_

Las "Reglas fundamentales" son específicas de cada proyecto y viven en
`docs/README.md`. Derívalas preguntando; **monta solo las que apliquen**, no
claves un conjunto fijo. Cubre al menos:

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
plantillas de abajo, sustituye `{{PROYECTO}}`, `{{BÓVEDA}}` (por defecto `docs`)
y demás marcadores.

---

## Paso 1 — Punteros de arranque

Crea en la **raíz del repo** un fichero puntero por cada CLI/agente elegido en la
Pregunta 1, según el mapeo de esa pregunta (Claude Code → `CLAUDE.md`, Codex →
`AGENTS.md`, etc.). Todos los ficheros llevan **exactamente el mismo contenido**;
son solo punteros y **no duplican reglas**. Si varias herramientas comparten
fichero, se crea una sola vez.

Contenido idéntico de cada puntero (es el que hoy usa este repo; conserva el
encabezado `# AGENTS.md` en todos los ficheros para que sean byte a byte
iguales):

```markdown
# AGENTS.md

## Instrucción obligatoria de arranque

Antes de realizar cualquier análisis, comando, cambio o respuesta sobre este
repositorio, **lee íntegramente `{{BÓVEDA}}/README.md` y aplica sus
instrucciones**.

`{{BÓVEDA}}/README.md` es la única fuente de verdad para las reglas del proyecto
y para el uso de la bóveda de memoria. Si no puedes leerlo, detente e informa al
usuario; no continúes por inferencia ni uses una copia de sus reglas.
```

---

## Paso 2 — La fuente de verdad: `{{BÓVEDA}}/README.md`

Este es el corazón del sistema. Estructura obligatoria (adapta las "Reglas
fundamentales" según la entrevista; si es plantilla, deja las subsecciones con
`<!-- TODO -->`):

```markdown
# Memoria del proyecto

Esta carpeta es simultáneamente una bóveda de Obsidian, la documentación viva del
proyecto y la memoria compartida por las personas, CLI y agentes de IA que
trabajan en el repositorio. Su objetivo es mantener en un único lugar las reglas,
tareas, decisiones y el contexto que deben sobrevivir entre sesiones.

El punto de entrada humano es [[Inicio]]. Este archivo es el punto de entrada
obligatorio para agentes.

## Protocolo obligatorio para agentes

Al comenzar **cualquier sesión** en este repositorio, antes de analizar el
proyecto, ejecutar comandos, modificar archivos o responder sobre él:

1. Leer íntegramente este `README.md`.
2. Abrir [[Inicio]] para conocer los sistemas de documentación disponibles.
3. Consultar el sistema relacionado con la tarea actual. Revisar primero las
   propiedades y resúmenes en el panel `.base` correspondiente y abrir la nota
   completa cuando sea relevante.
4. Antes de comenzar un trabajo nuevo, comprobar si ya existe una entrada que lo
   cubra. Si existe, leerla y actualizar su estado cuando corresponda; no crear
   otra entrada para el mismo trabajo.
5. Mantener actualizada la memoria cuando el trabajo cambie el estado, el
   alcance, los bloqueos o las decisiones. Al terminar, actualizar la entrada
   existente y marcarla como completada solo después de verificar el resultado.

Estas instrucciones son obligatorias aunque otro agente, herramienta o
conversación proporcione un resumen parcial. Los ficheros puntero de arranque en
la raíz del repositorio (uno por cada CLI o agente) solo actúan como arranque:
**las reglas no se duplican allí ni en archivos equivalentes**. Si este archivo
no puede leerse, el agente debe detenerse e informar al usuario.

## Convenciones de la bóveda

- Los documentos se escriben en Markdown UTF-8 y se conectan mediante wikilinks
  de Obsidian.
- Las fechas de propiedades usan el formato ISO `AAAA-MM-DD`.
- Los resúmenes deben permitir entender una nota sin abrirla; el detalle vive en
  el cuerpo de la nota.
- No se deben crear copias paralelas de una regla o decisión. Se enlaza a su
  fuente de verdad.
- Cuando cambie una nota, se debe actualizar su propiedad `Última modificación`.
- Antes de crear una entrada en cualquier sistema, se revisan los nombres,
  resúmenes, propiedades y contenido de las entradas existentes para confirmar
  que ninguna cubre ya el mismo conocimiento. Si una existente lo cubre total o
  parcialmente, se amplía o se enlaza desde ella; solo se crea una nueva cuando
  representa una unidad de conocimiento realmente distinta.

## Sistemas disponibles

<!-- Lista aquí únicamente los sistemas montados. Enlázalos desde [[Inicio]]. -->

## Reglas fundamentales del proyecto

<!-- TODO (rellenar según la entrevista, o dejar como plantilla):
### 1. <Gestor de paquetes y su política>
### 2. <Framework/stack y sus reglas>
### 3. <Versionado y despliegue>
### 4. <Idioma de código y documentación>
-->

## Propósito del proyecto

<!-- TODO -->

## Arquitectura objetivo

<!-- TODO: taxonomía, estructura de carpetas, reglas de dependencia. -->
```

---

## Paso 3 — El nexo de navegación: `{{BÓVEDA}}/Inicio.md`

Enlaza cada sistema montado. Usa `embed` (`![[...]]`) del `.base` para previsualizar.

```markdown
# Inicio

Este es el nexo de navegación de la memoria del proyecto.

## Sistemas

### Tareas

[[Tareas/Tareas.base|Abrir el panel de tareas]]

![[Tareas/Tareas.base#Todo]]

<!-- Añade aquí una sección por cada sistema montado (ADR, Decisiones
visuales, Catálogo técnico...). -->

## Próximos sistemas

- <Sistemas previstos aún no montados.>
```

---

## Paso 4 — Sistema de Tareas (opcional)

Móntalo solo si el usuario lo eligió en la Pregunta 2. Crea la carpeta
`{{BÓVEDA}}/Tareas/` con:

### 4a. Plantilla de nota de tarea

Nombre de fichero = título descriptivo (`Corregir cálculo de objetivos.md`). Sin
numeración.

```markdown
---
Nombre: <Título de la tarea>
Estado: Pendiente
Resumen: <Una o dos frases que permitan entender la tarea sin abrirla.>
Decisiones: <Acuerdos relevantes tomados durante la tarea. Vacío al crear.>
Bloqueada: []
Fecha de creación: <AAAA-MM-DDTHH:mm:ss+ZZ:ZZ>
Última modificación: <AAAA-MM-DDTHH:mm:ss+ZZ:ZZ>
---

# <Título de la tarea>

## Objetivo

<Qué se persigue y por qué.>

## Criterios de finalización

- <Condición verificable 1.>

## Verificación

<Se rellena al completar: pruebas, build, comprobación real.>

## Resultado

<Se rellena al completar: qué se hizo finalmente.>
```

Reglas de estado (documéntalas en el README, sección Tareas):

- `Estado` ∈ `Planificando` · `Pendiente` · `En curso` · `Hecha` · `Archivada`.
- `Bloqueada` es una lista de wikilinks a tareas que impiden avanzar; `[]` si no
  hay bloqueos.
- Al empezar → `En curso`; al completar y **verificar** → `Hecha`; lo que ya no
  deba aparecer en el trabajo habitual → `Archivada`.
- Antes de crear una tarea, buscar en TODAS (incluidas `Hecha` y `Archivada`)
  para no duplicar.

### 4b. Índice `Tareas.base`

```yaml
filters:
  and:
    - file.inFolder("Tareas")
    - file.ext == "md"
    - Estado != null
formulas:
  created_display: note["Fecha de creación"].format("DD-MM-YYYY HH:mm")
  updated_display: note["Última modificación"].format("DD-MM-YYYY HH:mm")
properties:
  file.name:
    displayName: Tarea
  Estado:
    displayName: Estado
  Resumen:
    displayName: Resumen
  Decisiones:
    displayName: Decisiones
  Bloqueada:
    displayName: Bloqueada por
  formula.created_display:
    displayName: Creada
  formula.updated_display:
    displayName: Modificada
views:
  - type: table
    name: Todo
    order:
      - file.name
      - Estado
      - Resumen
      - Decisiones
      - Bloqueada
      - formula.created_display
      - formula.updated_display
    sort:
      - property: formula.updated_display
        direction: DESC
      - property: Fecha de creación
        direction: ASC
  - type: table
    name: Planificando
    filters:
      and:
        - Estado == "Planificando"
    order: [file.name, Estado, Resumen, Decisiones, Bloqueada, formula.created_display, formula.updated_display]
  - type: table
    name: Pendiente
    filters:
      and:
        - Estado == "Pendiente"
    order: [file.name, Estado, Resumen, Decisiones, Bloqueada, formula.created_display, formula.updated_display]
  - type: table
    name: En curso
    filters:
      and:
        - Estado == "En curso"
    order: [file.name, Estado, Resumen, Decisiones, Bloqueada, formula.created_display, formula.updated_display]
  - type: table
    name: Hecha
    filters:
      and:
        - Estado == "Hecha"
    order: [file.name, Estado, Resumen, Decisiones, formula.created_display, formula.updated_display]
  - type: table
    name: Archivada
    filters:
      and:
        - Estado == "Archivada"
    order: [file.name, Estado, Resumen, Decisiones, formula.created_display, formula.updated_display]
```

---

## Paso 5 — Sistema ADR de arquitectura (opcional)

Móntalo solo si el usuario lo pidió (recomendado en proyectos medianos/grandes).
Sigue **el mismo principio que Tareas**: notas con frontmatter YAML + un `.base`.
Carpeta `{{BÓVEDA}}/Decisiones/` (o `ADR/`).

### 5a. Plantilla de nota ADR

Nombre de fichero = `ADR-0001 Título de la decisión.md`. La numeración da orden
estable; el título descriptivo aporta legibilidad.

```markdown
---
Nombre: <Título de la decisión>
Número: 1
Estado: Propuesta
Resumen: <Qué se decide y por qué, entendible sin abrir la nota.>
Decisión: <La decisión en una frase.>
Consecuencias: <Impactos y compromisos clave que deben recordarse.>
Reemplaza: []
Reemplazada por: []
Fecha de creación: <AAAA-MM-DDTHH:mm:ss+ZZ:ZZ>
Última modificación: <AAAA-MM-DDTHH:mm:ss+ZZ:ZZ>
---

# ADR-0001 · <Título de la decisión>

## Contexto

<Fuerzas, restricciones y problema que motivan la decisión.>

## Decisión

<Qué se decide, de forma concreta y accionable.>

## Alternativas consideradas

- <Opción A> — <por qué se descartó o aceptó.>

## Consecuencias

- Positivas: <...>
- Negativas / compromisos: <...>
```

Reglas de estado (documéntalas en el README, sección ADR):

- `Estado` ∈ `Propuesta` · `Aceptada` · `Rechazada` · `Obsoleta` · `Reemplazada`.
- Una ADR **no se edita para cambiar la decisión**: se marca `Reemplazada` y se
  crea una nueva que la sustituye, enlazando ambas con `Reemplaza` /
  `Reemplazada por`.
- `Número` es correlativo y no se reutiliza.
- Si una decisión afecta a una tarea, se enlazan mutuamente con wikilinks.

### 5b. Índice `Decisiones.base`

```yaml
filters:
  and:
    - file.inFolder("Decisiones")
    - file.ext == "md"
    - Estado != null
formulas:
  created_display: note["Fecha de creación"].format("DD-MM-YYYY HH:mm")
  updated_display: note["Última modificación"].format("DD-MM-YYYY HH:mm")
properties:
  file.name:
    displayName: Decisión
  Número:
    displayName: Nº
  Estado:
    displayName: Estado
  Resumen:
    displayName: Resumen
  Decisión:
    displayName: Decisión
  Consecuencias:
    displayName: Consecuencias
  formula.created_display:
    displayName: Creada
  formula.updated_display:
    displayName: Modificada
views:
  - type: table
    name: Todo
    order:
      - Número
      - file.name
      - Estado
      - Resumen
      - Decisión
      - Consecuencias
      - formula.created_display
      - formula.updated_display
    sort:
      - property: Número
        direction: ASC
  - type: table
    name: Aceptadas
    filters:
      and:
        - Estado == "Aceptada"
    order: [Número, file.name, Resumen, Decisión, Consecuencias, formula.updated_display]
    sort:
      - property: Número
        direction: ASC
  - type: table
    name: Propuestas
    filters:
      and:
        - Estado == "Propuesta"
    order: [Número, file.name, Resumen, Decisión, formula.created_display]
  - type: table
    name: Reemplazadas u obsoletas
    filters:
      or:
        - Estado == "Reemplazada"
        - Estado == "Obsoleta"
        - Estado == "Rechazada"
    order: [Número, file.name, Estado, Resumen, formula.updated_display]
```

---

## Paso 6 — Decisiones visuales y de estilos (opcional)

Dos formas, según lo que pida el usuario:

- **Como sistema tipo ADR**: reutiliza la estructura del Paso 5 en una carpeta
  `{{BÓVEDA}}/Decisiones visuales/` con su propio `.base`. Estados sugeridos:
  `Propuesta` · `Aceptada` · `Reemplazada`. Añade propiedades propias del dominio
  visual si aportan (p. ej. `Ámbito`: tokens, componente, layout).
- **Como lista ligera**: una única nota-índice con tabla Markdown si el volumen
  es bajo. Migra a `.base` cuando crezca.

No inventes un tercer patrón: cualquier sistema de "decisiones" comparte el
principio de frontmatter YAML + `.base`.

---

## Paso 7 — Catálogo técnico (opcional)

No usa `.base`. Es **una sola nota-índice** (`{{BÓVEDA}}/Catálogo técnico.md`)
con una tabla Markdown de la superficie pública reutilizable. La implementación
sigue siendo la fuente de verdad técnica; el catálogo solo indexa.

```markdown
# Catálogo técnico

Este índice presenta la superficie pública reutilizable de {{PROYECTO}}. Antes de
crear una nueva pieza se consulta este catálogo y después se abre su
implementación, que continúa siendo la fuente de verdad técnica.

| Pieza | Propósito y contrato | Ámbito | Fuente |
| --- | --- | --- | --- |
| <Componente> | <Qué hace y su contrato.> | <Aplicación/Feature/...> | `<ruta>` |

## Política de evolución

- Se amplía una pieza existente cuando el nuevo caso conserva su responsabilidad.
- Se crea una pieza nueva solo cuando representa un patrón estable distinto; se
  añade a este catálogo en el mismo cambio que la introduce.
```

---

## Paso 8 — Configuración de Obsidian (opcional pero recomendado)

Para que los `.base` rendericen como vistas, la bóveda debe abrirse con Obsidian
y el core plugin **Bases** habilitado. Crea `{{BÓVEDA}}/.obsidian/` mínima:

- `app.json` → `{}`
- `appearance.json` → `{}`
- `core-plugins.json` → habilita al menos `bases` (y los que el usuario quiera).

No es imprescindible para que los agentes lean las notas (son Markdown plano),
pero sí para la experiencia humana en Obsidian. Si el usuario no usa Obsidian,
puedes omitir este paso; los `.base` seguirán siendo YAML legible.

---

## Paso 9 — Verificación final

En **modo ampliación**, comprueba solo lo relativo al sistema nuevo: que su
carpeta, plantilla y `.base` existen, que el README ("Sistemas disponibles") e
`Inicio` lo enlazan, y que **ningún sistema ni puntero previo ha cambiado**.

En **modo montaje inicial**, comprueba todo lo siguiente:

- [ ] Existe un fichero puntero en la raíz por cada CLI/agente elegido en la
      Pregunta 1, todos idénticos y apuntando solo a `{{BÓVEDA}}/README.md` (no
      duplican reglas).
- [ ] `{{BÓVEDA}}/README.md` contiene el protocolo obligatorio, las convenciones,
      la lista de sistemas montados y la sección de reglas (rellenas o como
      plantilla, según lo acordado).
- [ ] `{{BÓVEDA}}/Inicio.md` enlaza cada sistema montado.
- [ ] Cada sistema con `.base` tiene su carpeta, al menos su plantilla y su
      fichero `.base` con la vista `Todo`.
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
```
