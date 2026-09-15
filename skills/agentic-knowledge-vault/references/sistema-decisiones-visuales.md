---
sistema: decisiones-visuales
version: 1
---

# Decisiones visuales y de estilos (Paso 6)

Móntalo solo si el usuario lo eligió. Al terminar, añade su enlace en `Inicio.md`
y sus reglas de estado en la sección "Sistemas disponibles" del `README.md`.
Bajo el encabezado del sistema en esa sección, escribe además la línea
`_Versión del sistema: 1._` (la `version` del frontmatter de este fichero): es la
marca que el modo sincronización usa para saber qué versión hay instalada.

Dos formas, según lo que pida el usuario:

- **Como sistema tipo ADR**: reutiliza la estructura de `references/sistema-adr.md`
  en una carpeta `{{BÓVEDA}}/Decisiones visuales/` con su propio `.base`. Estados
  sugeridos: `Propuesta` · `Aceptada` · `Reemplazada`. Añade propiedades propias
  del dominio visual si aportan (p. ej. `Ámbito`: tokens, componente, layout).
- **Como lista ligera**: una única nota-índice con tabla Markdown si el volumen
  es bajo. Migra a `.base` cuando crezca.

No inventes un tercer patrón: cualquier sistema de "decisiones" comparte el
principio de frontmatter YAML + `.base`.

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
