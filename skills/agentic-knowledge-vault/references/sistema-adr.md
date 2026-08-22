# Sistema ADR de arquitectura (Paso 5)

Móntalo solo si el usuario lo pidió (recomendado en proyectos medianos/grandes).
Sigue **el mismo principio que Tareas**: notas con frontmatter YAML + un `.base`.
Carpeta `{{BÓVEDA}}/Decisiones/` (o `ADR/`). Al terminar, añade su enlace en
`Inicio.md` y sus reglas de estado en la sección "Sistemas disponibles" del
`README.md`.

## 5a. Plantilla de nota ADR

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

## 5b. Índice `Decisiones.base`

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
