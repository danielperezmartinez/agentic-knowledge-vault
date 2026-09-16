---
sistema: catalogo-tecnico
version: 1
---

# Catálogo técnico (Paso 7)

Móntalo solo si el usuario lo eligió. Sigue **el mismo principio que Tareas/ADR**:
una carpeta de notas estructuradas con frontmatter YAML (una por pieza
reutilizable) + un `.base` que las indexa, **más** una nota-índice fuera de la
carpeta. Cada nota es un puntero corto: la **implementación** sigue siendo la
fuente de verdad técnica del contrato. Al terminar, añade su enlace en `Inicio.md`
y sus reglas de estado en la sección "Sistemas disponibles" del `README.md`.
Bajo el encabezado del sistema en esa sección, escribe además la línea
`_Versión del sistema: 1._` (la `version` del frontmatter de este fichero): es la
marca que el modo sincronización usa para saber qué versión hay instalada.

Estructura:

- `{{BÓVEDA}}/Catálogo técnico/` — una nota por pieza + `Catálogo técnico.base`.
- `{{BÓVEDA}}/Catálogo técnico.md` — nota-índice (enlace al `.base` + cómo usarlo
  + política de evolución).

## 7a. Plantilla de nota de pieza

Nombre de fichero = nombre de la pieza (`DataListComponent.md`, `.ui-button`
→ `ui-button.md`). Frontmatter (adapta los vocabularios a tu proyecto):

```markdown
---
Nombre: "<NombreDeLaPieza>"
Tipo: "<Componente | Servicio | Fachada | Directiva | Utilidad | Primitiva CSS | Token | Guard>"
Área: "<Global | ... según tu taxonomía>"
Feature: "<Shared UI | ... según tu taxonomía>"
Estado: "Vigente"
Ámbito: "<Aplicación | Feature | Shell>"
Fuente: "<ruta/a/la/implementación>"
Entrada pública: "<entrypoint de import, si aplica>"
Resumen: "<Qué hace y su contrato, entendible sin abrir la fuente.>"
Última modificación: "<AAAA-MM-DDTHH:mm:ss+ZZ:ZZ>"
---

# <NombreDeLaPieza>

Después de descubrir esta pieza en el catálogo, consulta [su implementación](<ruta relativa a la fuente>)
como fuente de verdad de su contrato detallado.
```

Reglas de estado (documéntalas en el README, sección Catálogo técnico):

- `Estado` ∈ `Vigente` · `En revisión` · `Obsoleta`. Se evita depender de piezas
  `En revisión` salvo que el trabajo incluya estabilizarlas.
- Se añade o actualiza la entrada **en el mismo cambio** que crea o altera una
  superficie reutilizable.
- `Tipo`, `Área`, `Feature` y `Ámbito` son vocabularios propios del proyecto:
  defínelos con el usuario y mantenlos consistentes.

## 7b. Índice `Catálogo técnico.base`

```yaml
filters:
  and:
    - file.inFolder("Catálogo técnico")
    - file.ext == "md"
    - Nombre != null
properties:
  file.name:
    displayName: Pieza
  Tipo: { displayName: Tipo }
  Área: { displayName: Área }
  Feature: { displayName: Feature }
  Estado: { displayName: Estado }
  Ámbito: { displayName: Ámbito }
  Resumen: { displayName: Propósito y contrato }
  Fuente: { displayName: Fuente }
  Entrada pública: { displayName: Entrada pública }
views:
  - type: table
    name: Todo
    order: [file.name, Tipo, Área, Feature, Estado, Ámbito, Resumen, Fuente, Entrada pública]
    sort:
      - property: Área
        direction: ASC
      - property: Feature
        direction: ASC
      - property: Nombre
        direction: ASC
  - type: table
    name: Vigentes
    filters:
      and:
        - Estado == "Vigente"
    order: [file.name, Tipo, Área, Feature, Ámbito, Resumen, Fuente, Entrada pública]
  - type: table
    name: En revisión
    filters:
      and:
        - Estado == "En revisión"
    order: [file.name, Tipo, Área, Feature, Resumen, Fuente]
```

Añade vistas filtradas propias del proyecto cuando aporten (p. ej. por `Feature`,
por `Área` o por `Tipo`), siguiendo el mismo patrón.

## 7c. Nota-índice `Catálogo técnico.md`

```markdown
# Catálogo técnico

Este sistema permite descubrir la superficie reutilizable de {{PROYECTO}} antes de
buscar por todo el repositorio o crear una implementación nueva. Cada fila enlaza
con su nota estructurada; después de localizar una candidata se abre su
implementación, que continúa siendo la fuente de verdad técnica.

[[Catálogo técnico/Catálogo técnico.base|Abrir la vista completa del catálogo]]

## Cómo utilizarlo

1. Filtrar la vista por tipo, área, feature o estado.
2. Evitar las piezas `En revisión` salvo que el trabajo incluya estabilizarlas.
3. Abrir la fuente antes de depender de los detalles del contrato o modificarla.
4. Añadir o actualizar la entrada en el mismo cambio que altere una superficie
   reutilizable.

## Política de evolución

- Se amplía una pieza existente cuando el nuevo caso conserva su responsabilidad y
  un contrato claro.
- Se crea una pieza nueva solo cuando representa un patrón estable diferente y se
  registra en el catálogo en el mismo cambio.
- Las adaptaciones de datos de dominio se realizan en el consumidor; las
  primitivas compartidas no conocen modelos de un área.

<!-- Opcional: si el proyecto tiene una comprobación automatizada del catálogo
(p. ej. un script que valida propiedades, fuentes y entrypoints), documéntala
aquí en una sección "Verificación automática". -->
```

## Cambios y migraciones

<!-- OBLIGATORIO al modificar este sistema: sube `version` en el frontmatter de
     arriba y añade aquí una entrada `### vN → vN+1` (formato en
     `references/sincronizacion.md`). Un cambio sin su entrada de migración está
     incompleto (ver "Versionado y despliegue" en la memoria del repo). El modo
     sincronización lee estas entradas para actualizar bóvedas ya montadas sin
     pisar su contenido de dominio. -->

### v1 — baseline

Primera versión bajo el esquema de versionado por sistema; sin migraciones
anteriores.

> Nota histórica (anterior al versionado): el commit `7624b35` (2026-08-22)
> reescribió este sistema de "nota-índice con tabla Markdown" a "carpeta + `.base`
> + nota-índice". Esa deriva **no** se cubre con una migración de versión (el sync
> no puede distinguir por número las bóvedas afectadas); es **revisión manual**.
> Ver "Limitación conocida" en `references/sincronizacion.md`.
