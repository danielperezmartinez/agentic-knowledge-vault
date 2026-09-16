# Sincronización de sistemas montados (Modo 3)

Este fichero solo se usa en **modo sincronización**: cuando una bóveda ya existe y
hay que propagarle cambios hechos en las **instrucciones de sistemas que ya
estaban montados** allí. No sirve para montar la base (eso es montaje inicial) ni
para añadir sistemas nuevos (eso es ampliación). No lo abras salvo que el Paso 0
te haya enviado aquí.

El principio: el skill es el *plano* y declara la versión actual de cada sistema;
la bóveda registra la versión que tiene **instalada** de cada uno. El sync
compara ambas y, por cada sistema atrasado, aplica en orden las entradas de
migración que su fichero de `references/` documenta — regenerando lo canónico y
preservando el contenido de dominio del usuario.

---

## Cómo se declara y se registra la versión

- **En el plano:** cada `references/sistema-*.md` lleva frontmatter con
  `sistema:` y `version:` (entero que sube en cada cambio con impacto).
- **En la bóveda:** la sección "Sistemas disponibles" del `README.md` lleva, bajo
  el encabezado de cada sistema montado, la línea `_Versión del sistema: N._`.
- **Guías de migración:** cada `references/sistema-*.md` termina con una sección
  `## Cambios y migraciones` con una entrada `### vN → vN+1` por cada salto.

---

## Formato de una entrada de migración (fuente única)

Toda entrada `### vN → vN+1` en el `## Cambios y migraciones` de un sistema usa
estos tres bloques. Este es el formato canónico; los ficheros de sistema no lo
reproducen, enlazan aquí.

```markdown
### vN → vN+1
**Canónico — regenerar en la bóveda:** cambios en las reglas de estado del README,
la plantilla de nota y las vistas del `.base`. Son derivados del plano: el sync los
reescribe directamente.
**Esquema de notas — checklist (requiere OK del usuario):** cambios que afectan al
frontmatter de las notas YA existentes (nueva propiedad, renombrado, nuevo estado).
Se aplican nota a nota con visto bueno. Omite este bloque si el cambio no toca las
notas existentes.
**NO tocar:** todo lo que el sync debe dejar intacto (cuerpos de nota, propiedades
no afectadas, la sección "Reglas fundamentales del proyecto", notas en estados
terminales, etc.).
```

Regla de oro: si una entrada no lista algo bajo **Canónico** ni bajo **Esquema de
notas**, el sync **no lo cambia**. Ante ambigüedad, se pregunta; no se infiere.

---

## Procedimiento

### Paso S1 — Inventario y comparación

1. Lee la sección "Sistemas disponibles" del `README.md` de la bóveda: obtén la
   lista de sistemas montados y su `_Versión del sistema: N._`.
2. Para cada sistema montado, abre **solo** su `references/sistema-*.md` y lee la
   `version` del frontmatter (la del plano).
3. Construye la tabla de deriva:
   - **al día** → tiene línea e `instalada == plano`. No se toca.
   - **desactualizado** → tiene línea e `instalada < plano`. Hay salto: migra.
   - **sin sellar** → **no tiene** línea de versión (bóveda montada antes del
     versionado). Trátalo como `instalada = 1` (baseline). Aunque su contenido ya
     esté al día, **hay que estampar su línea de baseline** `_Versión del sistema:
     1._`: eso es un cambio real, **no** "nada que hacer". Y si además `1 < plano`,
     también migra (v1 → plano). Antes de sellar a ciegas, lee la **Limitación
     conocida** del final.

### Paso S2 — Presentar el plan (dry-run, obligatorio)

Muestra al usuario, antes de tocar nada:

- Qué sistemas están al día, cuáles se van a **sellar** (baseline, sin migración) y
  cuáles se van a **migrar** (y de qué versión a cuál).
- Por cada salto, un resumen de lo **Canónico** que se regenerará y de las notas
  afectadas por cambios de **Esquema**.

No apliques nada sin su confirmación. Si eligió sincronizar solo un subconjunto,
respétalo.

### Paso S3 — Aplicar, un sistema a la vez, en orden de versión

**Caso "sin sellar" sin salto** (instalada = 1 = plano): no hay nada que regenerar
ni migrar; la única acción es **sellar** su línea de baseline (Paso S4). No toques
reglas, plantilla, `.base` ni notas.

Para un sistema **desactualizado** (o "sin sellar" con `1 < plano`), por cada salto
`vN → vN+1` en orden ascendente:

1. **Canónico:** aplica los cambios del bloque a la bóveda (reglas de estado en el
   README, plantilla de nota, vistas del `.base`). Estos son derivados del plano y
   se reescriben directamente.
2. **Esquema de notas (si el bloque existe):**
   - Enumera las notas afectadas del sistema.
   - Propón el diff **nota a nota** (qué propiedad se añade/renombra y con qué
     valor por defecto).
   - Aplica solo tras el OK del usuario. Nunca reescribas frontmatter a ciegas.
   - Al modificar una nota, actualiza su `Última modificación` si el sistema la
     usa.
3. **NO tocar:** respeta escrupulosamente ese bloque.
4. Repite con el siguiente salto hasta alcanzar la versión del plano.

### Paso S4 — Sellar la versión

Actualiza la línea `_Versión del sistema: N._` del README al número del plano ya
alcanzado. Si la bóveda no tenía línea (sistema "sin sellar"), **créala** — este
sellado ocurre siempre, tanto tras una migración como en el caso baseline sin salto.

### Paso S5 — Verificación

- [ ] Cada sistema procesado —sellado o migrado— tiene su `_Versión del sistema:
      N._` igual a la `version` del plano; no queda ningún sistema montado sin
      línea de versión.
- [ ] Las reglas/plantilla/`.base` regenerados coinciden con el plano actual.
- [ ] Las notas afectadas por cambios de esquema se migraron con aprobación; el
      resto de notas y todo lo marcado como **NO tocar** quedó intacto.
- [ ] No se tocó ningún sistema que estuviera al día, ni la sección "Reglas
      fundamentales del proyecto", ni los punteros de arranque.
- [ ] Las fechas siguen en formato ISO; los wikilinks resuelven.

Informa al usuario de qué sistemas se sincronizaron, qué notas se migraron y qué
quedó igual.

---

## Guardarraíles

- **Nunca** reescribas cuerpos de nota ni contenido de dominio a ciegas: los
  cambios de esquema pasan siempre por la checklist con aprobación.
- **Nunca** toques "Reglas fundamentales del proyecto" (son del proyecto, no del
  sistema) ni los ficheros puntero de arranque.
- Un sistema **al día** no se toca, aunque otros del mismo repo se sincronicen.
- Si el plano de un sistema no tiene entrada de migración para un salto que
  detectas, **detente y avisa**: falta la guía (el autor incumplió la regla de
  versionado); no improvises la migración.

---

## Limitación conocida — deriva anterior al versionado

El versionado por sistema arrancó con **todos los sistemas en v1** (baseline). El
sync detecta saltos comparando números de versión, así que **no puede detectar por
sí solo la deriva de cambios hechos antes de que existiera el versionado**: una
bóveda "sin sellar" se trata como v1 tenga el contenido que tenga.

Consecuencia: si en el futuro un sistema sube a v2 con su guía, el sync **no puede
distinguir por el número** una bóveda antigua (que de verdad tiene la forma v1) de
una montada después del cambio pero aún sin sellar (que ya tiene la forma v2). Las
dos se ven igual: sin línea de versión. Un salto v1 → v2 basado solo en el número
les caería a ambas, y a la segunda **por error**.

Por eso, para deriva **anterior** al versionado, no se emiten migraciones de
versión retroactivas. Si algún día hiciera falta cubrir uno de esos saltos
históricos, su guía debe incluir una **comprobación por contenido** (no por número)
que decida a qué bóvedas aplica realmente.

**Caso concreto documentado (revisión manual, no automatizada):** el commit
`7624b35` (2026-08-22) reescribió el **Catálogo técnico** de "nota-índice con tabla
Markdown, sin `.base`" a "carpeta de notas + `.base` + nota-índice", y cambió
`Inicio.md` de vistas incrustadas (`![[...#Todo]]`) a solo enlaces. Una bóveda
montada **antes** de esa fecha con el Catálogo en forma de tabla (o con embeds en
`Inicio`) está desactualizada en esos dos puntos, pero el sync **no lo marcará**
(los ve como v1 = plano). Requiere revisión manual: si el Catálogo es una tabla
Markdown, rehacerlo con el patrón `.base` de `references/sistema-catalogo-tecnico.md`;
si `Inicio` tiene embeds, dejarlos en solo enlaces.
