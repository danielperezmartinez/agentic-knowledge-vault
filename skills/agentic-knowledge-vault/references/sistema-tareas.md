# Sistema de Tareas (Paso 4)

Móntalo solo si el usuario lo eligió en la Pregunta 2b. Crea la carpeta
`{{BÓVEDA}}/Tareas/` con lo siguiente. Al terminar, añade su enlace en `Inicio.md`
y sus reglas de estado en la sección "Sistemas disponibles" del `README.md`.

## 4a. Plantilla de nota de tarea

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

## 4b. Índice `Tareas.base`

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
