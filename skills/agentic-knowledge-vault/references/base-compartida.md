# Base compartida (Pasos 1–3)

Este fichero contiene el montaje del **núcleo** del sistema: los punteros de
arranque y los dos ficheros raíz de la bóveda (`README.md` e `Inicio.md`). Se
monta **siempre** que haya que instaurar la bóveda, elija el usuario cero o
varios sistemas. Sustituye `{{PROYECTO}}` y `{{BÓVEDA}}` (por defecto `docs`) por
los parámetros recogidos en la entrevista.

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

Cuando montes un sistema de conocimiento, añade sus **reglas de estado** a la
sección "Sistemas disponibles" de este README (cada fichero de sistema en
`references/` indica qué reglas documentar).

---

## Paso 3 — El nexo de navegación: `{{BÓVEDA}}/Inicio.md`

Enlaza cada sistema montado con una **referencia al `.base`** (o a la nota-índice).
**No incrustes vistas** (`![[...#Todo]]`): un preview de la tabla es ruido para el
agente y, si el sistema crece, hace el archivo ineficiente. Deja solo los enlaces.

```markdown
# Inicio

Este es el nexo de navegación de la memoria del proyecto.

## Sistemas

### Tareas

[[Tareas/Tareas.base|Abrir el panel de tareas]]

<!-- Añade aquí una sección por cada sistema montado (ADR, Decisiones
visuales, Catálogo técnico...), solo con el enlace a su .base o nota-índice. -->

## Próximos sistemas

- <Sistemas previstos aún no montados.>
```
