---
sistema: publicacion
version: 1
requiere: []
se_integra_con: [seguridad-coste-cumplimiento, tareas]
---

# Publicación (Paso 10)

Móntalo solo si el usuario lo eligió en la Pregunta 2b. Fija **cómo llega un
cambio a la rama principal y a producción**: el código por pull request con
checks obligatorios y versión nueva, la bóveda por push directo sin versión ni
despliegue, y cada despliegue verificado. Como Seguridad, no es solo una regla:
monta configuración del repo (protección de rama, CI, despliegue) y una guarda
local que impide subir código directo a la rama principal.

No tiene carpeta ni notas propias. Al terminar, añade sus reglas en la sección
"Sistemas disponibles" del `README.md`, con la línea `_Versión del sistema: 1._`
bajo su encabezado, y su enlace en `Inicio.md`.

## Por qué existe

Cuatro apps montadas con esta skill tenían la regla "todo push sube la versión y
despliega". Con agentes que actualizan la bóveda a menudo, eso producía versiones
y despliegues por cambios de documentación, y nada impedía subir código a la rama
principal sin esperar al CI. Las cuatro implantaron a mano este flujo; este
sistema lo generaliza con lo que aprendieron:

- En GitHub, si usuario y agentes comparten una cuenta de administrador, la
  protección de rama necesita `enforce_admins=false` para que la bóveda pueda
  publicarse con push directo. Entonces "el código va por PR" queda como norma
  escrita, salvo que algo local lo compruebe: de ahí la guarda de `pre-push`.
- Si el CI corre también en los push a la rama principal, un push de solo bóveda
  la deja en rojo (p. ej. la comprobación de versión) salvo que el CI distinga
  código de bóveda.
- Hay trampas fuera del código: `remote.origin.push`, referencias remotas
  desactualizadas, repos sin auto-merge, ramas que se quedan atrás con `strict`, y
  el correo personal que GitHub añade a los squash.

## 10a. Entrevista específica del sistema

Pregunta en una sola tanda si tu herramienta lo permite. Deduce del repo lo que
puedas (remoto, rama por defecto, `package.json`, `vercel.json`, workflows) y pide
confirmación en vez de preguntar en blanco:

1. **Dónde vive el repo**: GitHub · otra forja · solo local. Las piezas de GitHub
   (protección de rama con `gh`, ajustes del repo) solo se montan si es GitHub.
2. **Rama principal**: la que use el repo (`main`, `master`…). Se escribe en todas
   las plantillas en lugar de `{{RAMA}}`.
3. **Despliegue**: Vercel con integración de Git · otra plataforma que despliega
   desde Git · despliegue manual · nada que desplegar (librería, skill…).
4. **Versión**: dónde vive (`package.json`, otro fichero, tags) o si el proyecto
   no versiona. Por defecto, el incremento se acuerda con el usuario en cada PR.
5. **Estrategia de integración**: squash (recomendada: historial lineal) · merge
   commit · rebase.
6. **¿La bóveda se publica con push directo?** Sí (recomendado; exige
   `enforce_admins=false` si la cuenta es compartida) · no, también por PR (permite
   `enforce_admins=true`, a costa de una PR por cada nota).
7. **¿Quién integra las PR?** Por defecto, el agente solo integra con
   autorización explícita del usuario para esa PR; si no la tiene, se detiene con
   la PR abierta.
8. **¿Hay migraciones de base de datos en un backend compartido** con otras apps?
   Si sí, se incluye la regla de migraciones.
9. **¿Qué hacer con la configuración?** Montarla ahora (enumera cada cambio y pide
   confirmación: la protección de rama y los ajustes del repo son configuración
   externa y se confirman uno a uno) · registrarla como tareas · solo reglas.

## 10b. Reglas para el `README.md` (sección "Sistemas disponibles")

Copia este bloque bajo el encabezado del sistema. Incluye solo los apartados que
apliquen y sustituye los marcadores. Es la **única** regla de publicación del
proyecto: si las "Reglas fundamentales" o una sección de despliegue ya hablan de
cómo se publica, se sustituyen por un enlace a esta sección (con OK del usuario,
ver 10f).

````markdown
### Publicación

_Versión del sistema: 1._

Esta es la única regla de publicación del proyecto; las demás secciones la
enlazan en vez de repetirla.

| Cambio | Cómo se publica | Versión | Despliegue |
| --- | --- | --- | --- |
| **Código**: cualquier archivo fuera de `{{BÓVEDA}}/` | Rama corta y pull request contra `{{RAMA}}`, integrada con {{ESTRATEGIA}} | Sube en la propia PR | {{DESPLIEGUE_CODIGO}} |
| **Solo bóveda**: todo dentro de `{{BÓVEDA}}/` | Commit y push directo a `{{RAMA}}` | No cambia | Ninguno |

- Un commit o una PR que mezcle bóveda y código cuenta como **código**.
- **Nunca se hace push directo de código a `{{RAMA}}`**, aunque la plataforma lo
  permita a administradores. `{{RAMA}}` exige los checks {{CHECKS}},
  actualizados con `{{RAMA}}`, para integrar una PR; un push directo se
  desplegaría sin esperarlos. La guarda de `.githooks/pre-push` lo impide en
  local; no se salta (`--no-verify`) sin permiso explícito del usuario.
- **Cada PR de código sube la versión** ({{FICHERO_VERSION}}) y no se integra si
  no supera la de `{{RAMA}}` (lo comprueba el CI). El incremento y el número
  exacto se acuerdan con el usuario (`major` para cambios incompatibles, `minor`
  para funcionalidades compatibles, `patch` para correcciones), sin inferirlo
  del silencio, y el acuerdo queda en la PR.
- **Publicar código** significa: rama corta (`feat/*`, `fix/*`, `chore/*`,
  `docs/*`), PR contra `{{RAMA}}`, esperar los checks, integrarla solo si el
  usuario lo autorizó para esa PR (si no, detenerse con la PR abierta) y
  verificar el despliegue.
- **Publicar la bóveda** significa: commit y push directo a `{{RAMA}}`, sin PR,
  sin subir la versión y sin despliegue.
- **Verificar el despliegue**: localizar el despliegue del commit exacto y
  comprobar su estado final y sus logs. Ante un fallo, avisar al usuario con un
  reporte y detenerse: no reintentar, redesplegar ni hacer rollback por iniciativa
  propia. La corrección es una PR nueva con su propia versión.
- Los commits, incluidos los squash que hace la plataforma, usan el correo
  privado de la forja (p. ej. `…@users.noreply.github.com`), nunca uno personal.
- <!-- Si hay backend compartido con migraciones: --> Las migraciones del
  backend compartido {{BACKEND}} se aplican aparte, con autorización expresa,
  antes de integrar el código que las necesita. El fichero de migración del repo
  lleva la misma versión que el historial remoto; si la herramienta asigna otra,
  se renombra el fichero.
- Configuración: {{CONFIGURACION}}
  <!-- p. ej. protección de `main` con checks estrictos y enforce_admins=false;
  `ignoreCommand` en `vercel.json`; job `Cambios` en el CI; guarda en
  `.githooks/pre-push`. -->
````

Sustituciones habituales: `{{DESPLIEGUE_CODIGO}}` = "Production al integrar en
`main`" (Vercel), "lo publica el usuario" (manual) o "Ninguno"; `{{CHECKS}}` = los
nombres **reales** de los jobs (ver 10c). Si el proyecto no versiona, quita la
columna de versión y su viñeta. Si la bóveda también va por PR (pregunta 6), la
fila "Solo bóveda" dice "Rama y PR, integrada sin esperar versión".

Si el proyecto **no tiene ningún check en CI**, avisa al usuario en una frase: una
PR sin checks obligatorios solo es una norma escrita. Propón un job mínimo de
build y tests (o montar también Seguridad). Si no lo quiere, respétalo y escribe
en `{{CHECKS}}` "ninguno todavía".

## 10c. Configuración y comprobaciones

Plantillas que se proponen o montan según la pregunta 9 de 10a. Adapta los
marcadores. Si ya existe algo equivalente, intégralo en vez de duplicarlo.

### Protección de la rama principal (GitHub)

Primero, en solo lectura, los nombres reales de los checks de un commit reciente y
la protección actual:

```bash
gh api repos/{{DUENO}}/{{REPO}}/commits/{{SHA}}/check-runs -q '.check_runs[] | "\(.name) \(.app.id)"'
gh api repos/{{DUENO}}/{{REPO}}/branches/{{RAMA}}/protection
```

Después, **con confirmación del usuario para este repo**, la protección. `strict`
obliga a que la PR esté al día con la rama; `app_id` 15368 es GitHub Actions;
`enforce_admins` sigue la pregunta 6. Conserva los ajustes que ya tenga el repo
(revisiones, historial lineal, etc.) en vez de quitarlos:

```bash
gh api -X PUT repos/{{DUENO}}/{{REPO}}/branches/{{RAMA}}/protection \
  -H "Accept: application/vnd.github+json" --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "checks": [{ "context": "{{CHECK_1}}", "app_id": 15368 }]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```

`required_linear_history` solo con squash o rebase.

### CI: distinguir código de bóveda

Si el CI corre también en los push a `{{RAMA}}`, añade un job que detecte si hay
cambios fuera de la bóveda y haz depender de él los jobs pesados. Un check
obligatorio que se omite con `if` cuenta como superado, así que una PR o un push
de solo bóveda no queda en rojo. Los jobs que deben correr siempre (p. ej. el de
fugas de Seguridad) no dependen de él.

```yaml
concurrency:
  group: ci-${{ github.event.pull_request.number || github.ref }}
  # En la rama principal no se cancela: un push de la bóveda no debe interrumpir
  # el CI de una integración de código.
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

jobs:
  cambios:
    name: Cambios
    runs-on: ubuntu-latest
    outputs:
      codigo: ${{ steps.diff.outputs.codigo }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - id: diff
        env:
          BASE_SHA: ${{ github.event.pull_request.base.sha || github.event.before }}
        # Si el diff no se puede calcular, se trata como código.
        run: |
          if git diff --quiet "$BASE_SHA" HEAD -- . ':(exclude){{BÓVEDA}}' 2>/dev/null; then
            echo "codigo=false" >> "$GITHUB_OUTPUT"
          else
            echo "codigo=true" >> "$GITHUB_OUTPUT"
          fi

  verificar:
    name: Verificar
    needs: cambios
    if: needs.cambios.outputs.codigo == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: La versión supera la de la rama principal
        if: github.event_name == 'pull_request'
        run: sh scripts/comprobar-version.sh "${{ github.event.pull_request.base.sha }}"
      # … build y tests del proyecto
```

`scripts/comprobar-version.sh` (para `package.json`; si el proyecto ya tiene una
comprobación equivalente, usa esa). Compara `major.minor.patch` como números e
ignora las etiquetas de prerelease:

```sh
#!/bin/sh
# Falla si la versión de package.json no supera la de la rama principal.
# Uso: comprobar-version.sh <sha base>
set -e
base=$(git show "$1:package.json" | node -p "JSON.parse(require('fs').readFileSync(0, 'utf8')).version")
actual=$(node -p "require('./package.json').version")
node -e '
const [base, actual] = process.argv.slice(1);
const n = (v) => v.split(/[.+-]/).slice(0, 3).map(Number);
const [a, b] = [n(base), n(actual)];
for (let i = 0; i < 3; i++) {
  if (b[i] > a[i]) process.exit(0);
  if (b[i] < a[i]) break;
}
console.error(`La versión ${actual} debe superar la de la rama principal (${base}).`);
process.exit(1);
' "$base" "$actual"
```

### Vercel: no desplegar cambios de solo bóveda

En `vercel.json` (versionado, así no se toca el panel):

```json
{
  "ignoreCommand": "git diff --quiet HEAD^ HEAD -- . ':(exclude){{BÓVEDA}}'"
}
```

Si no hay cambios fuera de la bóveda, sale con 0 y Vercel omite la build; si los
hay, o si falla (sin commit anterior), construye. Limitación: solo mira el último
commit, así que una Preview cuyo último commit es solo de la bóveda no se
construye. Con squash o merge commit, en la rama principal el último commit
contiene toda la PR. En otras plataformas, usa su mecanismo equivalente.

### Guarda local: nada de código directo a la rama principal

`.githooks/_rama_principal.sh` (no es un hook: lo carga `pre-push`):

```sh
# Guarda de publicación: el código no se sube directo a la rama principal.
# Reglas en docs/README.md, sección "Publicación". La carga .githooks/pre-push.

RAMA_PRINCIPAL="{{RAMA}}"
RUTA_BOVEDA="{{BÓVEDA}}"
CERO=0000000000000000000000000000000000000000

# comprobar_rama_principal <ref local> <sha local> <ref remota> <sha remota>
comprobar_rama_principal() {
  [ "$3" = "refs/heads/$RAMA_PRINCIPAL" ] || return 0
  [ "$2" = "$CERO" ] && return 0 # borrado de la rama: lo impide la protección del servidor
  [ "$4" = "$CERO" ] && return 0 # la rama aún no existe en el remoto (primer push del repo)
  if ! git cat-file -e "$4^{commit}" 2>/dev/null; then
    echo "No tengo el commit remoto de $RAMA_PRINCIPAL. Haz git fetch y repite." >&2
    exit 1
  fi
  if ! git diff --quiet "$4" "$2" -- . ":(exclude)$RUTA_BOVEDA"; then
    echo "Este push cambia archivos fuera de $RUTA_BOVEDA/ directamente en $RAMA_PRINCIPAL." >&2
    echo "El código se publica por pull request (docs/README.md, sección Publicación)." >&2
    exit 1
  fi
}
```

`.githooks/pre-push`, si no existe ya (si existe, ver "Integración con
Seguridad, coste y cumplimiento"):

```sh
#!/bin/sh
# Comprueba qué se sube y a qué rama. Reglas en docs/README.md, sección "Publicación".
# git pasa por stdin una línea por rama: <ref local> <sha local> <ref remota> <sha remota>.
. "$(dirname "$0")/_rama_principal.sh"
while read -r ref_local sha_local ref_remota sha_remota; do
  comprobar_rama_principal "$ref_local" "$sha_local" "$ref_remota" "$sha_remota"
done
```

- Se activa una vez por clon con `git config core.hooksPath .githooks` (o con un
  script `prepare` del gestor de paquetes). Si el proyecto usa husky, lefthook o
  pre-commit, añade la llamada allí.
- Marca los hooks como ejecutables (`git update-index --chmod=+x .githooks/*`) y
  fija sus finales de línea en `.gitattributes` con `.githooks/* text eol=lf`:
  con CRLF fallan en Linux y macOS.
- La guarda compara el árbol remoto con el que se sube, así que un push de solo
  bóveda encima de una PR ya integrada pasa, y uno que mezcla código no.

### Comprobaciones de las trampas conocidas (solo lectura)

Al montar, y al adoptar el sistema en un repo existente:

- `git config --get-all remote.origin.push`: si fuerza un refspec hacia la rama
  principal (p. ej. `refs/heads/main:refs/heads/main`), un `git push` sin
  argumentos sube siempre esa rama. Propón quitarlo, con OK.
- Referencias remotas al día (`git fetch`). Si el push se hace por una URL
  distinta de `origin`, `origin/*` no se actualiza y los hooks revisan de más:
  actualízalas con `git fetch <url> +refs/heads/{{RAMA}}:refs/remotes/origin/{{RAMA}}`.
- ¿El repo permite auto-merge? Si no, la PR se integra a mano cuando los checks
  están en verde y el usuario lo autorizó.
- Con `strict`, cada integración (incluidas las de Dependabot) deja atrás las
  demás PR abiertas: hay que actualizarlas con la rama principal antes de
  integrarlas.
- Correo de los commits: en GitHub, *Settings → Emails → Keep my email address
  private*. Si no, los squash añaden `Co-authored-by` con el correo de la cuenta.
- Si una PR ya abierta sube la versión, apila la rama nueva encima para no chocar
  en el fichero de versión.

## Integración con Seguridad, coste y cumplimiento

**Qué añade si Seguridad está montada:**

- Sus jobs (`rls`, `a11y`, `fugas` o los nombres reales que tengan) entran en
  `{{CHECKS}}` y en la protección de la rama.
- En el CI, los jobs de Seguridad que no sean de fugas dependen de `cambios` con
  el mismo `if`; el de fugas corre siempre.
- La guarda se encadena en el `pre-push` que ya monta Seguridad, en vez de crear
  otro: añade `. "$(dirname "$0")/_rama_principal.sh"` después de cargar
  `_gitleaks.sh`, y `comprobar_rama_principal "$ref_local" "$sha_local"
  "$ref_remota" "$sha_remota"` como **primera línea** del bucle `while`. La guarda
  va antes del escaneo para que un push mal dirigido no espere a gitleaks. El
  escaneo de Seguridad se salta las ramas borradas con `continue`, así que la
  guarda debe ir antes de esa línea.

**Si Seguridad no está montada:** los checks son los del CI del proyecto, y la
guarda usa el `pre-push` propio de 10c. Recomienda Seguridad en una frase.

**Señal de que ya está aplicada:** el `pre-push` contiene `comprobar_rama_principal`
y `{{CHECKS}}` incluye los jobs de Seguridad.

## Integración con Tareas

**Qué añade si Tareas está montado:** una viñeta al final del bloque de 10b:

```markdown
- Una tarea de código no pasa a `Hecha` hasta que su PR está integrada y el
  despliegue verificado; su sección "Verificación" anota la PR, el commit y el
  estado del despliegue. Si la PR espera autorización, la tarea sigue `En curso`.
```

**Si Tareas no está montado:** no se añade nada.

**Señal de que ya está aplicada:** la sección del sistema contiene "Una tarea de
código no pasa a `Hecha`".

## Enlace en `Inicio.md`

```markdown
### Publicación

Reglas en [[README#Publicación|README → Publicación]].
```

## 10f. Añadirlo a una bóveda ya montada

Llega por **modo ampliación**. Muchos repos ya publican de una forma concreta, y
algunos ya implantaron este flujo a mano: la adopción **detecta por contenido** lo
que ya existe y lo sella en vez de rehacerlo.

1. Reinvoca la skill; en la Pregunta 0b, "Añadir sistemas nuevos" (o "Ambos" si
   hay sistemas por sincronizar).
2. **Inventario en solo lectura** antes de la entrevista:
   - Reglas sobre push, versión o despliegue en el `README.md` (en las "Reglas
     fundamentales" o en una sección de despliegue) y ADR que decidan el flujo.
   - Protección de la rama principal y nombres reales de los checks (10c).
   - `ignoreCommand` en `vercel.json`, job de cambios en el CI, guarda en
     `.githooks/`.
   - Las trampas de 10c.
3. Haz la entrevista de 10a, proponiendo como respuesta lo que el inventario
   encontró.
4. Monta la sección de 10b:
   - Si el README ya tiene una regla equivalente, **no la dupliques**: propón
     mover su contenido a la sección del sistema y dejar en su lugar un enlace.
     Las reglas fundamentales son del proyecto: cámbialas solo con OK.
   - Si una ADR decidió el flujo, enlázala desde la sección ("Fuente y
     justificación"). Si la ADR contradice este sistema, no la edites: propón una
     ADR nueva que la reemplace.
5. Para cada pieza de 10c: si ya existe y es equivalente, déjala; si falta o
   difiere, propón el cambio como diff, con confirmación por repo para la
   configuración externa.
6. Aplica las integraciones con Seguridad y Tareas si están montados.

## Verificación del sistema

- [ ] La sección está en "Sistemas disponibles" con su línea de versión, sin
      marcadores `{{…}}` sin sustituir, y ninguna otra parte del README repite la
      regla de publicación (solo la enlaza).
- [ ] La guarda está activa en este clon y se comprobó que bloquea un push de
      código a la rama principal (con un commit de prueba que no llega a subirse)
      y deja pasar uno de solo bóveda.
- [ ] La protección de la rama tiene los checks con sus nombres reales, o el
      usuario decidió no aplicarla.
- [ ] Si hay CI en los push a la rama principal, un cambio de solo bóveda no lo
      deja en rojo.
- [ ] Si hay despliegue automático, un cambio de solo bóveda no despliega
      (comprobar en el primer push real de la bóveda).
- [ ] Se aplicaron las integraciones que correspondían.

## Cambios y migraciones

<!-- OBLIGATORIO al modificar este sistema: sube `version` en el frontmatter de
     arriba y añade aquí una entrada `### vN → vN+1` (formato en
     `references/sincronizacion.md`). Un cambio sin su entrada de migración está
     incompleto (ver "Versionado y despliegue" en la memoria del repo). El modo
     sincronización lee estas entradas para actualizar bóvedas ya montadas sin
     pisar su contenido de dominio. -->

### v1 — baseline

Primera versión del sistema. En bóvedas que no lo tienen se añade por modo
ampliación, siguiendo 10f.

Reparto habitual para futuras entradas:

- **Canónico:** el bloque de 10b y las viñetas de las integraciones.
- **NO tocar:** los marcadores ya sustituidos (rama, checks, versión, backend,
  configuración) y los ficheros del repo (hooks, CI, `vercel.json`, scripts), que
  tras montarse son código del proyecto: si cambian las plantillas de 10c, el sync
  propone el diff y lo aplica solo con OK. La configuración externa (protección de
  rama) solo se cambia con confirmación por repo.
