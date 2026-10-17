---
sistema: seguridad-coste-cumplimiento
version: 3
requiere: []
se_integra_con: [tareas, publicacion]
---

# Seguridad, coste y cumplimiento (Paso 9)

Móntalo solo si el usuario lo eligió en la Pregunta 2b. A diferencia del resto de
sistemas, no es solo un registro de notas: aporta **reglas** (que van al
`README.md` de la bóveda), **comprobaciones ejecutables** (que viven en el código
del proyecto y en su CI) y una **checklist de lanzamiento** para lo que vive fuera
del código (paneles de Supabase, Vercel, etc.).

Al terminar, añade su enlace en `Inicio.md` y sus reglas en la sección "Sistemas
disponibles" del `README.md`. Bajo el encabezado del sistema en esa sección,
escribe además la línea `_Versión del sistema: 3._` (la `version` del frontmatter
de este fichero): es la marca que el modo sincronización usa para saber qué
versión hay instalada.

## Por qué existe

Una auditoría de cuatro apps web reales (Angular + Supabase + Vercel), todas con
bóveda montada por esta skill, encontró fallos que sus reglas no cubrían:

- Políticas RLS `USING (true)` para `anon` que permitían listar y modificar todos
  los datos. Las creó un agente con el MCP de Supabase y las dio por "permisos
  mínimos" porque el Security Advisor no avisaba: una política `true` cuenta como
  política.
- Buckets de Storage sin límite de tamaño ni cuota en un proyecto gratuito
  compartido por varias apps: un solo usuario podía agotar la cuota de todas.
- Funciones `SECURITY DEFINER` con `search_path` mutable y `pg_net` accesible a
  `anon`, en un repo que tenía instaladas las skills oficiales de Supabase.
- Ubicación del usuario enviada a un tercero sin aviso, sin aviso legal, y
  scraping contra `robots.txt` con user-agents falsos.

Además, esos repos son públicos. Todo lo que se sube (código, la propia bóveda
`docs/`, mensajes de commit, nombres de rama, PR y logs de CI) queda expuesto, y
borrarlo después no lo quita del historial, de los forks ni de las cachés. Un
secreto, un dato del entorno personal o una vulnerabilidad sin corregir se filtra
con un solo push.

Y una lección transversal: **una regla escrita sin comprobación no basta**. La
app que exigía WCAG AA sin comprobarlo no lo cumplía; la que tenía AXE en su CI,
sí. Por eso este sistema monta comprobaciones, no solo reglas.

## 9a. Entrevista específica del sistema

Antes de escribir nada, pregunta (en una sola tanda si tu herramienta lo permite).
Si el `README.md` o el código ya responden alguna, propón la respuesta y pide
confirmación en vez de preguntar en blanco:

1. **Backend con datos de usuarios**: Supabase · otro backend con base de datos ·
   ninguno. Decide qué bloque de reglas de backend se incluye.
2. **¿El proyecto de backend se comparte con otras apps?** (mismo proyecto de
   Supabase, misma cuenta del plan gratuito, etc.). Si sí, la regla de recursos
   compartidos se escribe con los nombres de las otras apps.
3. **¿Tiene interfaz web pública?** Si sí, se incluye accesibilidad y AXE en CI.
4. **¿Hace scraping o consume webs de terceros?** Si sí, se incluyen las reglas de
   scraping.
5. **¿El repositorio es público** (o lo será)? Las reglas de "Repositorio y
   publicación" se incluyen siempre. Si es público, se incluye también
   "Vulnerabilidades y hallazgos sensibles" (avisos privados de GitHub y notas
   opacas en la bóveda). Compruébalo si puedes (p. ej. la visibilidad del remoto)
   y pide confirmación.
6. **Patrones personales para la revisión de fugas.** Explica que los hooks de 9c
   usan dos listas: los patrones genéricos, versionados en el repo, y los
   personales (nombres de máquina, usuario del sistema, unidades y carpetas
   propias, correos, dominios y redes), que viven en un fichero **fuera del
   repo**. Pregunta si ya tiene ese fichero (por defecto
   `~/.config/gitleaks/personal.toml`, o la ruta de `GITLEAKS_PERSONAL_CONFIG`).
   Si no lo tiene, ofrécete a crear la plantilla de 9c con marcadores. Los
   valores reales los pone el usuario, o tú con su OK explícito y sin
   repetirlos en el chat, en los mensajes ni en la bóveda.
7. **¿Qué hacer con las comprobaciones ejecutables?**
   - **Montarlas ahora** (recomendado): escribes los ficheros de 9c en el repo.
     Escriben fuera de la bóveda: enumera las rutas y pide confirmación antes de
     crearlas. Respeta el gestor de paquetes y las reglas de dependencias que ya
     fije el `README.md` del proyecto.
   - **Registrarlas como tareas**: si el sistema de Tareas está montado, crea una
     tarea `Pendiente` por comprobación, con los ficheros de 9c como punto de
     partida.
   - **Solo reglas**: avisa en una frase de que, sin comprobación, la regla no se
     cumple de forma fiable, y respeta la decisión.

Las reglas legales se incluyen siempre que la app sea pública y trate datos
personales de personas en la UE (por defecto, sí).

## 9b. Reglas para el `README.md` (sección "Sistemas disponibles")

Copia este bloque bajo el encabezado del sistema, después de la línea de versión.
Incluye solo los apartados que la entrevista haya activado y sustituye los
marcadores. Estas reglas son **canónicas** (el modo sincronización puede
regenerarlas); lo específico del proyecto (excepciones, estado de la checklist)
vive en notas de la carpeta del sistema, nunca editando este bloque.

````markdown
### Seguridad, coste y cumplimiento

_Versión del sistema: 3._

Carpeta [[Seguridad/Seguridad.base|Seguridad/]]: excepciones justificadas a estas
reglas, la [[Seguridad/Checklist de lanzamiento|checklist de lanzamiento]] y,
si el repo es público, las referencias opacas a hallazgos privados.
Estas reglas aplican a todo cambio, lo haga una persona o un agente, y también a
lo que se haga con MCP, CLI o panel.

#### Backend y datos (Supabase)

- **RLS activado no basta.** Cada política expresa quién puede hacer qué sobre
  qué filas; lo normal es `owner_id = (select auth.uid())`.
- Prohibido `USING (true)` o `WITH CHECK (true)` en políticas de `INSERT`,
  `UPDATE`, `DELETE` o `ALL`. En `SELECT` solo con una excepción escrita en
  `Seguridad/` y referenciada en la política
  (`comment on policy … is 'excepcion: <nombre de la nota>'`).
- Los datos compartidos por enlace se sirven con una función RPC que recibe el
  token y devuelve solo esa fila. La tabla nunca es listable por `anon`.
- Las funciones `SECURITY DEFINER` llevan `set search_path = ''` y nombres
  cualificados con esquema, y se revoca `EXECUTE` a `anon` (y a `public`) salvo
  excepción escrita. Si no necesitan saltarse RLS, se usa `SECURITY INVOKER`.
- Las extensiones con efectos fuera de la base de datos (`pg_net`, `http`) quedan
  fuera del alcance de `anon` y `authenticated`.
- Los esquemas expuestos por la API son los mínimos. Lo interno vive en un
  esquema `*_private` no expuesto.
- **Todo el DDL** (tablas, políticas, funciones, grants, buckets y sus límites)
  vive en migraciones versionadas del repo. Nada se hace solo en el panel ni solo
  por MCP; si se hizo, se vuelca a una migración en el mismo cambio.
- "El Security Advisor no da avisos" **no** cuenta como verificación. La
  verificación son los tests de `supabase/tests/` (ver "Comprobaciones").

#### Backend y datos (otro backend)

<!-- Usar en lugar del bloque Supabase si el backend es otro. -->
- Toda lectura o escritura comprueba en el servidor que el usuario autenticado
  es el dueño del recurso o tiene permiso explícito. El cliente nunca decide
  permisos.
- Los datos compartidos por enlace se sirven por token, nunca con listados
  abiertos.
- El esquema y los permisos se versionan en migraciones del repo.

#### Coste y abuso

- Todo lo que un usuario puede crear tiene **tope de tamaño y de cantidad**:
  buckets con `file_size_limit` y `allowed_mime_types`, cuota por usuario
  (comprobada en la política de Storage o en un trigger), `CHECK` de longitud en
  columnas de texto y tope de filas por usuario en tablas que crecen.
- Nada de llamadas recursivas ni bucles sin tope: triggers que llaman a funciones
  HTTP, funciones que se invocan a sí mismas, reintentos sin límite, efectos del
  cliente que se disparan en bucle. Todo reintento tiene un máximo y espera entre
  intentos.
- Los endpoints públicos (funciones serverless, Edge Functions, RPC accesibles a
  `anon`) tienen límite de peticiones.
- <!-- Si el proyecto de backend es compartido: --> Este proyecto comparte
  {{RECURSOS_COMPARTIDOS}} con {{OTRAS_APPS}}. Agotar Auth, Storage o la cuota
  del plan aquí deja sin servicio a todas: cualquier límite se diseña pensando en
  el conjunto.

#### Secretos

- La clave publicable (`anon` / `sb_publishable_…`) puede ir en el cliente.
- La clave secreta (`service_role` / `sb_secret_…`) y cualquier otro secreto solo
  viven en el servidor o en el CI, nunca en el código del cliente ni en el repo.
- Cada secreto está solo en los entornos que lo necesitan (p. ej. Production y no
  Preview si las previews no lo usan), marcado como sensible donde la plataforma
  lo permita.
- Los ficheros de secretos locales (`.env*` salvo `.env.example`, keystores,
  claves) están en `.gitignore`.

#### Repositorio y publicación

- Todo lo que se sube queda expuesto y **no se puede retirar**: el código, esta
  bóveda `docs/`, los mensajes de commit, los nombres de rama, los títulos y
  cuerpos de PR, las issues, los workflows, los logs y artefactos de CI. Borrarlo
  después no lo quita del historial, de los forks ni de las cachés.
- **Nunca se sube:**
  - Secretos: claves, contraseñas, tokens, ficheros `.env`, keystores.
  - Datos del entorno personal: nombres de host, de máquina o de dispositivo,
    usuarios del sistema operativo, IP (de red local, VPN o públicas), dominios y
    redes propios, rutas personales (`C:\Users\<nombre>`, `/home/<nombre>`,
    unidades y carpetas propias) y correos personales.
  - Vulnerabilidades sin corregir <!-- si el repo es público: --> (ver
    "Vulnerabilidades y hallazgos sensibles").
- En la documentación se usan **marcadores genéricos** (`<usuario>`,
  `<host-de-pruebas>`, `<ruta-al-proyecto>`). Los valores reales viven fuera del
  repo: variables de entorno, la memoria local del agente (que no se versiona) o
  el fichero de patrones personales.
- **Antes de cada commit y de cada push** se revisan el diff y los mensajes. Los
  hooks versionados en `.githooks/` lo comprueban con gitleaks (patrones
  genéricos de `.gitleaks.toml` y patrones personales fuera del repo), y el CI lo
  repite. Los hooks no se saltan (`--no-verify`) sin permiso explícito del
  usuario. Un falso positivo se resuelve ajustando el patrón o con
  `gitleaks:allow` en esa línea, nunca desactivando la revisión.
- Los logs de CI no imprimen secretos ni datos personales. Los secretos de CI van
  en los secretos de la plataforma (GitHub Secrets), y el CI no depende de
  máquinas, redes ni cuentas personales del usuario.
- **Si algo sensible llega a subirse:** se avisa al usuario **de inmediato**. No
  se reescribe el historial ni se fuerza un push sin su permiso explícito. Si era
  un secreto, se da por comprometido y se revoca o se rota, aunque se borre del
  repo.

#### Vulnerabilidades y hallazgos sensibles

<!-- Incluir si el repositorio es público. -->
- **Criterio.** Un hallazgo es sensible si describe cómo dañar, espiar o engañar
  a usuarios de la versión publicada y todavía no hay una versión publicada que
  lo corrija. Ante la duda, es sensible.
- **Dónde vive.** Cada hallazgo sensible es un **aviso privado de GitHub**
  (*Security Advisory* en borrador, pestaña *Security* del repo), uno por
  hallazgo. Es su única fuente de verdad mientras no se publique.
- **Qué nunca lo cuenta** mientras no se publique el arreglo: esta bóveda, los
  mensajes de commit, los nombres de rama, los títulos y cuerpos de PR, las
  issues, los comentarios de código y los nombres de test.
- **En la bóveda** solo hay una referencia opaca: una nota `SEC-AAAA-NN`
  (correlativo por año, no se reutiliza) de tipo `Hallazgo` en `Seguridad/`, con
  severidad, estado, el ID `GHSA-…` del aviso y la versión que lo corrige. Nunca
  un título ni una descripción.
- **El arreglo** se prepara en local, con mensajes de commit, nombres de rama y
  nombres de test neutros que no expliquen el fallo, y se sube junto con la
  publicación de la versión que lo corrige. Entonces se publica el aviso y la
  nota pasa a `Publicado`; desde ese momento ya se puede describir.
- **Los agentes no crean, publican ni cierran avisos por su cuenta.** Preparan el
  borrador del aviso y el usuario lo da de alta, o lo autoriza en esa sesión.
  Publicar un aviso es irreversible.
- Lo no sensible (endurecimiento, CVE públicos de dependencias) se gestiona con
  tareas normales.

#### Legal y privacidad (UE / España)

> Estas reglas resumen obligaciones habituales y no son asesoramiento legal. Ante
> dudas concretas, consulta a un profesional.

- Antes de publicar: **aviso legal** (LSSI-CE, art. 10) y **política de
  privacidad** (RGPD, art. 13), enlazados desde todas las páginas.
- No se envían datos personales ni la ubicación a terceros (APIs de mapas, de
  analítica, de IA…) sin avisar antes en la interfaz y sin una acción explícita
  del usuario que lo dispare. Cada tercero que reciba datos aparece en la
  política de privacidad.
- Las comunicaciones comerciales (emails, notificaciones push) requieren
  consentimiento expreso, separado de aceptar los términos, y una forma sencilla
  de darse de baja.
- El banner de cookies solo es necesario si hay cookies o almacenamiento no
  técnicos (analítica, publicidad, terceros). Si existe, rechazar es tan fácil
  como aceptar y nada no técnico se carga antes del consentimiento.

#### Scraping

<!-- Incluir solo si el proyecto hace scraping. -->
- Se respetan `robots.txt` y los términos de uso del sitio.
- User-agent identificable y veraz, con forma de contacto. Prohibido suplantar
  navegadores u otros bots.
- No se evaden protecciones (CAPTCHAs, bloqueos, límites, inicios de sesión
  ajenos).
- Retrasos razonables entre peticiones, caché de lo ya descargado y reintentos
  con tope.

#### Accesibilidad

<!-- Incluir si hay interfaz web. -->
- Objetivo: **WCAG 2.2 nivel AA**. AXE en el CI sin infracciones; además,
  revisión manual de teclado y foco en los flujos nuevos (AXE no detecta todo).

#### Comprobaciones y compuerta de "Hecha"

- Comprobaciones del proyecto: {{LISTA_DE_COMPROBACIONES}}
  <!-- p. ej. `supabase test db` (tests RLS en `supabase/tests/`), test de AXE en
  `e2e/a11y.spec.ts`, gitleaks en `.githooks/` y en CI, todo en
  `.github/workflows/seguridad.yml` -->
- **Una tarea que toque backend o UI no pasa a `Hecha`** hasta que esas
  comprobaciones estén en verde, y su sección "Verificación" lo deja escrito (qué
  se ejecutó y dónde). Si el cambio añade tablas, políticas, funciones o rutas,
  añade también su test en el mismo cambio.
- **Ninguna tarea pasa a `Hecha` con commits sin revisar:** los hooks de gitleaks
  han pasado en cada commit y push, y el job de fugas del CI está en verde.
- Una excepción a estas reglas es una nota `Excepción` en `Seguridad/` con su
  justificación. Sin nota, no hay excepción.
````

Las dos viñetas de la compuerta están redactadas para cuando Tareas está montado;
si no lo está, ver "Integración con Tareas". Si Publicación está montado, ver
también "Integración con Publicación".

## 9c. Comprobaciones ejecutables

Ficheros que se proponen o montan en el repo del proyecto (según la Pregunta 7 de
9a). Son plantillas: adapta los marcadores `{{…}}` a las tablas y rutas reales.
Si el proyecto ya tiene tests o CI, intégralos ahí en vez de duplicar.

### Supabase: test de catálogo (genérico)

`supabase/tests/00_seguridad_catalogo.test.sql`. Revisa el catálogo de Postgres
y falla ante los patrones prohibidos, sin tener que escribir un test por tabla.
Se ejecuta con `supabase test db` (pgTAP) contra la base local, que se construye
solo con las migraciones del repo. Así comprueba también que nada vive solo en el
panel.

```sql
begin;
create extension if not exists pgtap with schema extensions;
select plan(7);

-- Esquemas propios del proyecto (expuestos y privados). Ajustar.
create temp table _esquemas(nombre text) on commit drop;
insert into _esquemas values {{ESQUEMAS_PROPIOS}}; -- p. ej. ('public'), ('app_private')

-- 1. Toda tabla propia tiene RLS activado.
select is_empty($$
  select n.nspname || '.' || c.relname
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
  where c.relkind in ('r', 'p')
    and n.nspname in (select nombre from _esquemas)
    and not c.relrowsecurity
$$, 'Toda tabla propia tiene RLS activado');

-- 2. Ninguna política de escritura es USING/WITH CHECK (true).
select is_empty($$
  select n.nspname || '.' || c.relname || ' · ' || p.polname
  from pg_policy p
  join pg_class c on c.oid = p.polrelid
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname in (select nombre from _esquemas)
    and p.polcmd in ('a', 'w', 'd', '*')
    and (pg_get_expr(p.polqual, p.polrelid) in ('true', '(true)')
      or pg_get_expr(p.polwithcheck, p.polrelid) in ('true', '(true)'))
$$, 'Ninguna política de INSERT/UPDATE/DELETE/ALL es (true)');

-- 3. Una política SELECT (true) solo existe con excepción escrita.
select is_empty($$
  select n.nspname || '.' || c.relname || ' · ' || p.polname
  from pg_policy p
  join pg_class c on c.oid = p.polrelid
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname in (select nombre from _esquemas)
    and p.polcmd = 'r'
    and pg_get_expr(p.polqual, p.polrelid) in ('true', '(true)')
    and coalesce(obj_description(p.oid, 'pg_policy'), '') not like 'excepcion:%'
$$, 'Las políticas SELECT (true) tienen excepción escrita');

-- 4. Toda función SECURITY DEFINER fija search_path vacío.
select is_empty($$
  select p.oid::regprocedure::text
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where p.prosecdef
    and n.nspname in (select nombre from _esquemas)
    and not exists (
      select 1 from unnest(coalesce(p.proconfig, '{}')) cfg
      where cfg in ('search_path=""', 'search_path=')
    )
$$, 'Las funciones SECURITY DEFINER tienen search_path vacío');

-- 5. anon no ejecuta funciones SECURITY DEFINER salvo excepción escrita.
select is_empty($$
  select p.oid::regprocedure::text
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where p.prosecdef
    and n.nspname in (select nombre from _esquemas)
    and has_function_privilege('anon', p.oid, 'EXECUTE')
    and coalesce(obj_description(p.oid, 'pg_proc'), '') not like 'excepcion:%'
$$, 'anon no ejecuta funciones SECURITY DEFINER sin excepción');

-- 6. Extensiones con salida a red fuera del alcance de anon y authenticated.
--    Al instalar pg_net, Supabase concede acceso a anon y authenticated por
--    defecto, así que este test falla hasta que una migración lo revoca:
--      revoke usage on schema net from anon, authenticated;
--      revoke execute on all functions in schema net from anon, authenticated;
--    Si la extensión se reinstala, los permisos vuelven y el test lo detecta.
select is_empty($$
  select r.rolname || ' → ' || p.oid::regprocedure::text
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  cross join (values ('anon'), ('authenticated')) r(rolname)
  where n.nspname in ('net', 'http')
    and has_schema_privilege(r.rolname, n.oid, 'USAGE')
    and has_function_privilege(r.rolname, p.oid, 'EXECUTE')
$$, 'pg_net/http no son ejecutables por anon ni authenticated');

-- 7. Todo bucket tiene límite de tamaño.
select is_empty($$
  select id from storage.buckets where file_size_limit is null
$$, 'Todo bucket tiene file_size_limit');

select * from finish();
rollback;
```

### Supabase: test de aislamiento entre usuarios (uno por tabla con datos de usuario)

`supabase/tests/10_aislamiento_{{TABLA}}.test.sql`. Actúa como `anon` y como un
segundo usuario y comprueba que no pueden leer, listar ni modificar los datos de
otro. Duplica el fichero por cada tabla con datos de usuario (o agrupa varias
tablas en uno).

```sql
begin;
create extension if not exists pgtap with schema extensions;
select plan(7);

-- Dos usuarios de prueba (todo se revierte al final).
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-00000000000a', 'a@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000000000b', 'b@test.local', 'authenticated', 'authenticated');

-- Usuario A crea una fila suya. Se fijan las dos variantes de claims porque,
-- según la versión, auth.uid() lee request.jwt.claim.sub o request.jwt.claims.
set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-00000000000a';
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';
insert into {{TABLA}} ({{COL_DUENO}}, {{COLUMNAS}})
values ('00000000-0000-0000-0000-00000000000a', {{VALORES}});

-- Usuario B no ve, no modifica, no borra ni suplanta a A.
set local request.jwt.claim.sub = '00000000-0000-0000-0000-00000000000b';
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}';
select is_empty(
  $$ select 1 from {{TABLA}} where {{COL_DUENO}} = '00000000-0000-0000-0000-00000000000a' $$,
  'B no lee filas de A');
select is_empty(
  $$ update {{TABLA}} set {{COL_DUENO}} = {{COL_DUENO}}
     where {{COL_DUENO}} = '00000000-0000-0000-0000-00000000000a' returning 1 $$,
  'B no modifica filas de A');
select is_empty(
  $$ delete from {{TABLA}}
     where {{COL_DUENO}} = '00000000-0000-0000-0000-00000000000a' returning 1 $$,
  'B no borra filas de A');
select throws_ok(
  $$ insert into {{TABLA}} ({{COL_DUENO}}, {{COLUMNAS}})
     values ('00000000-0000-0000-0000-00000000000a', {{VALORES}}) $$,
  '42501', null, 'B no inserta en nombre de A');

-- anon no lista ni modifica nada.
-- Si anon no tiene GRANT sobre la tabla, cambia is_empty por
-- throws_ok($$ … $$, '42501', null, '…'): un "permission denied" también vale.
set local request.jwt.claim.sub = '';
set local request.jwt.claims = '{"role":"anon"}';
set local role anon;
select is_empty($$ select 1 from {{TABLA}} $$, 'anon no lista la tabla');
select is_empty(
  $$ update {{TABLA}} set {{COL_DUENO}} = {{COL_DUENO}} returning 1 $$,
  'anon no modifica la tabla');

-- A sigue viendo su fila (las políticas no son simplemente "nadie").
set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-00000000000a';
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';
select isnt_empty(
  $$ select 1 from {{TABLA}} where {{COL_DUENO}} = '00000000-0000-0000-0000-00000000000a' $$,
  'A sí ve su propia fila');

select * from finish();
rollback;
```

Para datos compartidos por enlace, añade al test de esa tabla: `anon` no la lista
(como arriba) y la RPC devuelve la fila con el token correcto y nada con uno
inventado.

Sin pila local de Supabase (Docker), los mismos ficheros se pueden ejecutar
contra una rama de Supabase o una base de pruebas con `psql -f`. Nunca contra
producción: insertan en `auth.users`, aunque acaben en `rollback`.

### Accesibilidad: AXE

`e2e/a11y.spec.ts` (Playwright + `@axe-core/playwright`, instalados con el gestor
de paquetes del proyecto). Recorre las rutas principales y falla ante cualquier
infracción de WCAG A/AA:

```ts
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

const RUTAS = [{{RUTAS}}]; // p. ej. ['/', '/login', '/aviso-legal']

for (const ruta of RUTAS) {
  test(`WCAG AA sin infracciones: ${ruta}`, async ({ page }) => {
    await page.goto(ruta);
    const { violations } = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'])
      .analyze();
    expect(violations).toEqual([]);
  });
}
```

Las rutas tras inicio de sesión necesitan un usuario de prueba (`storageState`
de Playwright). AXE solo analiza lo que está renderizado: abre diálogos y menús
en tests aparte si son parte del flujo.

### Secretos en el bundle

Paso de CI tras el build del cliente, para que ninguna clave secreta acabe en el
bundle:

```bash
! grep -rIE "sb_secret_|SERVICE_ROLE" {{DIR_BUILD}}
```

### Fugas: gitleaks antes de cada commit y push

[gitleaks](https://github.com/gitleaks/gitleaks) (8.19 o posterior) revisa el
contenido de los commits, y con `gitleaks stdin` también los mensajes y los
nombres de rama, que por sí solo no revisa. Usa dos ficheros de patrones:

- `.gitleaks.toml`, **versionado**: las reglas por defecto de gitleaks más
  patrones genéricos que no revelan nada de nadie.
- Un fichero **personal fuera del repo**, con los nombres concretos del entorno
  del usuario. Solo lo usan los hooks locales, nunca el CI.

Todas las órdenes llevan `--redact`, para que ni la salida local ni los logs de CI
repitan lo encontrado.

`.gitleaks.toml` (las descripciones van entre comillas simples porque TOML no
admite `\U` en comillas dobles):

```toml
title = "Patrones genéricos del proyecto"

[extend]
useDefault = true

[[rules]]
id = "supabase-clave-secreta"
description = "Clave secreta de Supabase"
regex = '''sb_secret_[A-Za-z0-9_-]{16,}'''
keywords = ["sb_secret_"]

[[rules]]
id = "ruta-personal-windows"
description = 'Ruta personal de Windows (C:\Users\<nombre>)'
regex = '''(?i)\b[a-z]:[\\/]+users[\\/]+[a-z0-9._-]+'''
keywords = ["users"]
[[rules.allowlists]]
stopwords = ["public", "default"]

# secretGroup es necesario: la lista de permitidos global de gitleaks ignora
# cualquier secreto que empiece por /home/ o /Users/.
[[rules]]
id = "ruta-personal-unix"
description = "Ruta personal de Linux o macOS (/home/<nombre>, /Users/<nombre>)"
regex = '''/(?:home|Users)/([A-Za-z0-9._-]+)'''
secretGroup = 1
keywords = ["/home/", "/users/"]
[[rules.allowlists]]
stopwords = ["runner", "shared"]

[[rules]]
id = "ip-privada"
description = "IP de red local o de Tailscale"
regex = '''\b(?:10\.\d{1,3}|192\.168|172\.(?:1[6-9]|2\d|3[01])|100\.(?:6[4-9]|[7-9]\d|1[01]\d|12[0-7]))\.\d{1,3}\.\d{1,3}\b'''
```

Los marcadores (`C:\Users\<nombre>`, `/home/<usuario>`) no disparan las reglas,
y las rutas de CI (`/home/runner`) tampoco. Añade reglas propias del stack si
hacen falta, siempre genéricas.

**Plantilla de patrones personales**, fuera del repo, en
`~/.config/gitleaks/personal.toml` o en la ruta de `GITLEAKS_PERSONAL_CONFIG`.
Las reglas van comentadas para que no salten con los propios marcadores: el
usuario descomenta las que use y pone sus valores.

```toml
title = "Patrones personales (fuera del repo; no versionar ni copiar al chat)"

# [[rules]]
# id = "personal-maquinas"
# description = "Nombres de máquina, host o dispositivo"
# regex = '''(?i)\b(?:<maquina-1>|<maquina-2>)\b'''

# [[rules]]
# id = "personal-usuarios"
# description = "Usuarios del sistema y alias"
# regex = '''(?i)\b(?:<usuario-del-sistema>|<alias>)\b'''

# [[rules]]
# id = "personal-unidades"
# description = "Unidades y carpetas propias"
# regex = '''(?i)\b<letra>:[\\/]'''

# [[rules]]
# id = "personal-correos"
# description = "Correos personales"
# regex = '''(?i)(?:<correo-1>|<correo-2>)'''

# [[rules]]
# id = "personal-redes"
# description = "Dominios, redes de VPN y tailnet propios"
# regex = '''(?i)(?:<dominio-propio>|<tailnet>\.ts\.net)'''
```

**Hooks versionados** en `.githooks/`. Se activan una vez por clon con
`git config core.hooksPath .githooks`; en proyectos con gestor de paquetes, en un
script `prepare` para que ocurra al instalar. Si el proyecto ya usa husky,
lefthook o pre-commit, añade estas órdenes allí en vez de crear `.githooks/`.
Marca los hooks como ejecutables (`git update-index --chmod=+x .githooks/*`) y
fija sus finales de línea en `.gitattributes` con `.githooks/* text eol=lf`: con
CRLF fallan en Linux y macOS. Si falta gitleaks, los hooks bloquean el commit: una
revisión que se salta sola no es una comprobación. Si Publicación está montado,
su guarda va en el mismo `pre-push` (ver "Integración con Publicación").

`.githooks/_gitleaks.sh` (funciones comunes; no es un hook):

```sh
# Funciones comunes de los hooks de gitleaks (no es un hook: lo cargan los demás).
# Reglas en docs/README.md, sección "Repositorio y publicación".

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "gitleaks no está instalado: no se puede revisar lo que se va a subir." >&2
  echo "Instálalo (https://github.com/gitleaks/gitleaks) y repite." >&2
  exit 1
fi

# Patrones personales: fuera del repo, nunca versionados.
PERSONAL="${GITLEAKS_PERSONAL_CONFIG:-$HOME/.config/gitleaks/personal.toml}"

# escanear <args de gitleaks>: revisa con los patrones del repo y con los personales.
escanear() {
  gitleaks "$@" --redact --no-banner --config .gitleaks.toml || exit 1
  if [ -f "$PERSONAL" ]; then
    gitleaks "$@" --redact --no-banner --config "$PERSONAL" || exit 1
  else
    echo "Aviso: no hay patrones personales en $PERSONAL; solo se han revisado los genéricos." >&2
  fi
}

# escanear_texto: revisa un texto recibido por stdin (mensajes, nombres de rama).
escanear_texto() {
  tmp=$(mktemp)
  cat > "$tmp"
  gitleaks stdin --redact --no-banner --config .gitleaks.toml < "$tmp" || { rm -f "$tmp"; exit 1; }
  if [ -f "$PERSONAL" ]; then
    gitleaks stdin --redact --no-banner --config "$PERSONAL" < "$tmp" || { rm -f "$tmp"; exit 1; }
  fi
  rm -f "$tmp"
}
```

`.githooks/pre-commit`:

```sh
#!/bin/sh
# Revisa lo preparado para el commit en busca de secretos y datos personales.
. "$(dirname "$0")/_gitleaks.sh"
escanear git --pre-commit --staged
```

`.githooks/commit-msg`:

```sh
#!/bin/sh
# Revisa el mensaje del commit: también es público.
. "$(dirname "$0")/_gitleaks.sh"
escanear_texto < "$1"
```

`.githooks/pre-push`:

```sh
#!/bin/sh
# Revisa los commits que se van a subir, sus mensajes y los nombres de rama.
# git pasa por stdin una línea por rama: <ref local> <sha local> <ref remota> <sha remota>.
. "$(dirname "$0")/_gitleaks.sh"
cero=0000000000000000000000000000000000000000
while read -r ref_local sha_local ref_remota sha_remota; do
  [ "$sha_local" = "$cero" ] && continue # borrado de rama: no se sube contenido
  if [ "$sha_remota" = "$cero" ]; then
    rango="$sha_local --not --remotes"
  else
    rango="$sha_remota..$sha_local"
  fi
  escanear git --log-opts="$rango"
  { git log --format=%B $rango; printf '%s\n%s\n' "$ref_local" "$ref_remota"; } | escanear_texto || exit 1
done
```

El `pre-push` vuelve a revisar el contenido aunque el `pre-commit` ya lo hiciera:
cubre commits hechos con `--no-verify`, en otro clon o con otra herramienta.

**Revisión inicial del historial** (solo lectura, al adoptar el sistema):
`gitleaks git --redact --config .gitleaks.toml`, después con el fichero personal,
y `git log --all --format=%B | gitleaks stdin --redact …` para los mensajes. Lo
que aparezca ya está publicado: se aplica "Si algo sensible llega a subirse"
(avisar al usuario, no reescribir el historial sin su permiso y rotar los
secretos).

### CI

`.github/workflows/seguridad.yml` (o un job en el workflow existente). Fija la
versión de la CLI de Supabase que use el proyecto:

```yaml
name: Seguridad
on: [pull_request, push]
jobs:
  rls:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: supabase/setup-cli@v1
        with:
          version: {{VERSION_SUPABASE_CLI}}
      - run: supabase db start
      - run: supabase test db
  a11y:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      # Instalar dependencias, compilar y servir la app con el gestor del proyecto,
      # instalar navegadores de Playwright y ejecutar e2e/a11y.spec.ts.
      # Tras el build, el paso de "Secretos en el bundle".
  fugas:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: gitleaks (historial, mensajes, rama y PR)
        env:
          GITLEAKS_VERSION: {{VERSION_GITLEAKS}} # p. ej. 8.28.0
          # El texto del PR va por variable de entorno, nunca interpolado en el script.
          PR_TEXTO: ${{ github.event.pull_request.title }} ${{ github.event.pull_request.body }}
          RAMA: ${{ github.head_ref || github.ref_name }}
        run: |
          curl -sSfL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" | tar -xz gitleaks
          ./gitleaks git --redact --no-banner --config .gitleaks.toml
          { git log --format=%B; printf '%s\n%s\n' "$RAMA" "$PR_TEXTO"; } | ./gitleaks stdin --redact --no-banner --config .gitleaks.toml
```

El job `fugas` solo conoce los patrones genéricos: los personales no se suben ni
como secreto de CI. Por eso los hooks locales son la primera barrera, y el job la
red para lo que se haya subido sin pasar por ellos.

Cuando los jobs estén verdes, márcalos como obligatorios en la protección de la
rama principal. Hasta entonces la compuerta de "Hecha" sigue aplicando. Si
Publicación está montado, la protección de la rama es suya: ver "Integración con
Publicación".

## 9d. Carpeta `Seguridad/`

```
{{BÓVEDA}}/Seguridad/
├── Seguridad.base
├── Checklist de lanzamiento.md
├── Excepción - <objeto>.md      (una por excepción, solo si hacen falta)
└── SEC-AAAA-NN.md               (una por hallazgo privado, solo en repos públicos)
```

### Plantilla de nota de excepción

Nombre de fichero: `Excepción - <esquema.objeto>.md`. El objeto de base de datos
lleva un comentario `excepcion: <Nombre>` que apunta a esta nota.

```markdown
---
Nombre: Excepción - <esquema.objeto>
Tipo: Excepción
Estado: Vigente
Regla: <Regla de la que se exceptúa, p. ej. "SELECT (true) solo con justificación".>
Objeto: <esquema.tabla · política, o esquema.función(args)>
Resumen: <Por qué es seguro y qué datos expone, entendible sin abrir la nota.>
Revisar antes de: <AAAA-MM-DD>
Última modificación: <AAAA-MM-DDTHH:mm:ss+ZZ:ZZ>
---

# Excepción - <esquema.objeto>

## Justificación

<Qué datos quedan expuestos, a quién, y por qué no hay alternativa razonable.>

## Mitigaciones

<Límites, columnas excluidas, vistas, etc.>
```

Reglas de estado (documéntalas en el README, dentro de la sección del sistema, si
el proyecto llega a tener excepciones):

- `Estado` ∈ `Vigente` · `Retirada`. Al retirar una excepción se quita también el
  comentario `excepcion:` del objeto.
- Una excepción vencida (`Revisar antes de` en el pasado) se revisa antes de
  cualquier otro cambio sobre ese objeto.

### Plantilla de nota de hallazgo privado (solo si el repo es público)

Nombre de fichero: `SEC-AAAA-NN.md` (correlativo por año, no se reutiliza). Es
una referencia **opaca**: el detalle vive solo en el aviso privado de GitHub. No
lleva título descriptivo, cuerpo explicativo ni nada que permita deducir el fallo.

```markdown
---
Nombre: SEC-AAAA-NN
Tipo: Hallazgo
Estado: Abierto
Severidad: <Alta | Media | Baja>
Aviso: <GHSA-xxxx-xxxx-xxxx>
Versión del arreglo: <vacío hasta publicarse>
Resumen: Hallazgo privado; el detalle está en su aviso de GitHub.
Última modificación: <AAAA-MM-DDTHH:mm:ss+ZZ:ZZ>
---

# SEC-AAAA-NN

| Fecha | Cambio |
| --- | --- |
| <AAAA-MM-DD> | <Abierto / Corregido en local / Publicado con la versión X> |
```

Reglas de estado (documéntalas en el README, dentro de la sección del sistema, si
el repo es público):

- `Estado` ∈ `Abierto` · `Corregido` · `Publicado` · `Descartado`. `Corregido`
  significa que el arreglo está listo pero aún no publicado: sigue siendo
  sensible.
- Al pasar a `Publicado` (arreglo publicado y aviso publicado por el usuario), la
  nota ya puede enlazar el aviso y describir el fallo.

### Nota `Checklist de lanzamiento.md`

Recoge lo que vive fuera del código y que ningún test del repo ve. Se revisa antes
del primer lanzamiento, al cambiar de plan y, como mínimo, una vez por trimestre.
Quita los bloques que no apliquen y añade los de otros proveedores que use el
proyecto.

```markdown
---
Nombre: Checklist de lanzamiento
Tipo: Checklist
Estado: Pendiente
Resumen: Estado de la configuración fuera del código (gasto, Auth, firewall, secretos, plan, GitHub y legal) que ningún test del repo comprueba.
Última revisión: <AAAA-MM-DD>
Última modificación: <AAAA-MM-DDTHH:mm:ss+ZZ:ZZ>
---

# Checklist de lanzamiento

Marca cada punto al revisarlo en el panel y anota el valor real. Al terminar,
`Estado: Revisada` y actualiza `Última revisión`.

## Supabase ({{PROYECTO_SUPABASE}})

- [ ] Plan actual y sus límites anotados (BD, Storage, egress, MAU). En el plan
      gratuito, superar un límite restringe **todo** el proyecto, no solo esta
      app. Apps que lo comparten: <…>.
- [ ] Tope de gasto (Spend Cap) activado o, si se desactiva, decisión escrita.
- [ ] Alertas de uso o de facturación configuradas y con destinatario real.
- [ ] Auth: el registro abierto/cerrado es intencionado; solo están activos los
      proveedores que se usan; URLs de redirección limitadas a los dominios
      propios.
- [ ] Auth: confirmación de email, protección contra contraseñas filtradas,
      CAPTCHA y límites de envío de emails/OTP revisados.
- [ ] Auth: SMTP propio si se envían correos a usuarios reales.
- [ ] Esquemas expuestos por la API: solo los necesarios.
- [ ] Copias de seguridad: lo que incluye el plan y si basta.

## Vercel ({{PROYECTO_VERCEL}})

- [ ] Plan adecuado al uso (Hobby no admite uso comercial).
- [ ] Spend Management: tope y alertas configurados, y acción al superarlo.
- [ ] Firewall: reglas de límite de peticiones en rutas públicas y de API.
- [ ] Deployment Protection en Preview si las previews no deben ser públicas.
- [ ] Variables secretas solo en los entornos que las usan (no en Preview si no
      hace falta) y marcadas como sensibles.

## GitHub ({{REPOSITORIO}})

- [ ] Visibilidad del repo (público o privado) conocida y coherente con las
      reglas de "Repositorio y publicación".
- [ ] Secret scanning activado.
- [ ] Push protection activado (bloquea en el servidor los pushes con secretos
      conocidos).
- [ ] Private vulnerability reporting activado, si el repo es público.
- [ ] Protección de la rama principal con los jobs de seguridad (incluido
      `fugas`) como obligatorios.
- [ ] Hooks activos en cada clon de trabajo (`git config core.hooksPath`
      apunta a `.githooks`) y gitleaks instalado; fichero de patrones
      personales creado fuera del repo.
- [ ] Alertas de Dependabot activadas.

## Legal y privacidad

- [ ] Aviso legal y política de privacidad publicados y enlazados.
- [ ] Terceros que reciben datos (Supabase, Vercel, APIs) listados en la
      política, con región de los datos.
- [ ] Banner de cookies solo si hay cookies no técnicas, y funciona sin cargar
      nada antes del consentimiento.

## Accesibilidad

- [ ] Revisión manual con teclado y lector de pantalla de los flujos principales.

## Revisiones

| Fecha | Quién | Notas |
| --- | --- | --- |
| <AAAA-MM-DD> | <persona o agente> | <cambios detectados> |
```

### Índice `Seguridad.base`

```yaml
filters:
  and:
    - file.inFolder("Seguridad")
    - file.ext == "md"
    - Tipo != null
formulas:
  updated_display: note["Última modificación"].format("DD-MM-YYYY HH:mm")
properties:
  file.name:
    displayName: Nota
  Tipo: { displayName: Tipo }
  Estado: { displayName: Estado }
  Regla: { displayName: Regla }
  Objeto: { displayName: Objeto }
  Resumen: { displayName: Resumen }
  Revisar antes de: { displayName: Revisar antes de }
  Severidad: { displayName: Severidad }
  Aviso: { displayName: Aviso }
  Versión del arreglo: { displayName: Versión del arreglo }
  formula.updated_display: { displayName: Modificada }
views:
  - type: table
    name: Todo
    order: [file.name, Tipo, Estado, Resumen, formula.updated_display]
    sort:
      - property: Tipo
        direction: ASC
      - property: file.name
        direction: ASC
  - type: table
    name: Excepciones vigentes
    filters:
      and:
        - Tipo == "Excepción"
        - Estado == "Vigente"
    order: [file.name, Regla, Objeto, Resumen, Revisar antes de]
    sort:
      - property: Revisar antes de
        direction: ASC
  - type: table
    name: Checklists
    filters:
      and:
        - Tipo == "Checklist"
    order: [file.name, Estado, Resumen, formula.updated_display]
  - type: table
    name: Hallazgos privados
    filters:
      and:
        - Tipo == "Hallazgo"
    order: [file.name, Estado, Severidad, Aviso, Versión del arreglo, formula.updated_display]
    sort:
      - property: file.name
        direction: DESC
```

### Enlace en `Inicio.md`

```markdown
### Seguridad, coste y cumplimiento

[[Seguridad/Seguridad.base|Abrir el panel de seguridad]] ·
[[Seguridad/Checklist de lanzamiento|Checklist de lanzamiento]]
```

## Integración con Tareas

**Qué añade si Tareas está montado:** las dos viñetas de la compuerta de 9b tal
como están escritas ("Una tarea que toque backend o UI no pasa a `Hecha`…" y
"Ninguna tarea pasa a `Hecha` con commits sin revisar…").

**Si Tareas no está montado:** las mismas viñetas, aplicadas al criterio de
"terminado" que use el proyecto (integrar la PR, desplegar, etc.). Por ejemplo:
"Un cambio que toque backend o UI no se da por terminado hasta que…". Si Tareas
se monta después, la ampliación sustituye esa redacción por la de 9b.

**Señal de que ya está aplicada:** la sección del sistema contiene "no pasa a
`Hecha`".

## Integración con Publicación

**Qué añade si Publicación está montado:**

- En la sección del sistema, al final de "Comprobaciones y compuerta de
  'Hecha'", la viñeta:

  ```markdown
  - Sus jobs son checks obligatorios para integrar en la rama principal; el flujo
    de publicación está en la sección [[#Publicación]] y no se repite aquí.
  ```

- Los ficheros de hooks y CI se reparten así: la protección de la rama, el job
  `cambios` y la guarda de `pre-push` son de Publicación (ver su sección
  "Integración con Seguridad, coste y cumplimiento"). Si Seguridad se monta
  **después** de Publicación, su `pre-push` sustituye al de Publicación
  conservando la guarda: carga también `_rama_principal.sh` y llama a
  `comprobar_rama_principal` como primera línea del bucle. Sus jobs `rls` y `a11y`
  dependen de `cambios` con el mismo `if` que los demás jobs de código; `fugas`
  corre siempre. Al terminar, propón añadir sus jobs a la protección de la rama,
  con confirmación.

**Si Publicación no está montado:** no se añade nada; los jobs se marcan como
obligatorios a mano, como dice 9c.

**Señal de que ya está aplicada:** la sección del sistema contiene "Sus jobs son
checks obligatorios para integrar en la rama principal".

## 9e. Añadirlo a una bóveda ya montada

Para una bóveda existente, este sistema es **nuevo**: llega por **modo
ampliación**, no por sincronización (el sync solo actualiza sistemas ya
montados). Pasos:

1. Reinvoca la skill en el repo. El Paso 0 detecta la bóveda y la Pregunta 0b
   ofrece "Añadir sistemas nuevos" con este sistema. Si hay otros sistemas
   desactualizados o sin sellar, elige "Ambos": primero se sincronizan y después
   se amplía.
2. Haz la entrevista de 9a. Lee el `README.md` existente: si sus "Reglas
   fundamentales del proyecto" ya cubren algo de esto (p. ej. "WCAG AA"), **no
   lo dupliques**. Propón al usuario sustituir esa línea por un enlace a la
   sección de este sistema y aplícalo solo con su OK, porque las reglas
   fundamentales son contenido del proyecto.
3. Añade la sección de 9b al README con `_Versión del sistema: 1._`, crea la
   carpeta de 9d con su `.base` y la checklist, y enlázalo en `Inicio.md`. No
   toques los demás sistemas: la compuerta de "Hecha" vive en la sección de este
   sistema, no en la de Tareas.
4. **Auditoría inicial (solo lectura).** Antes de montar los tests, ejecuta las
   consultas de 9c (catálogo y aislamiento) contra la base local o una rama, o
   con consultas `select` de solo lectura contra el proyecto. Un proyecto que ya
   existía suele fallar alguna. No corrijas la base de datos en este paso.
   Presenta los hallazgos y, con el OK del usuario, conviértelos en tareas (si
   Tareas está montado) o en notas `Excepción` si de verdad están justificados.
   Haz también la revisión inicial del historial con gitleaks (9c). Lo que
   encuentre ya es público: avisa al usuario en cuanto lo veas, sin reescribir
   historial ni rotar nada por tu cuenta.
5. Monta las comprobaciones de 9c (o regístralas como tareas, según la entrevista).
   Si fallan por los hallazgos del paso anterior, no marques el job como
   obligatorio hasta que esté verde; las tareas de corrección van primero.
6. Rellena la checklist de lanzamiento con el estado real de los paneles, o déjala
   `Pendiente` con sus marcadores si el usuario no tiene acceso ahora.

Si varias apps comparten proyecto de backend, cada repo monta su propia sección y
checklist, pero la regla de recursos compartidos nombra a las demás, y conviene
revisar las checklists juntas.

## Verificación del sistema

- [ ] La sección del sistema está en "Sistemas disponibles" con su línea de
      versión, con solo los apartados que activó la entrevista y sin marcadores
      `{{…}}` sin sustituir.
- [ ] `Seguridad/` tiene `Seguridad.base` y `Checklist de lanzamiento.md`, y
      `Inicio.md` los enlaza.
- [ ] Las comprobaciones están montadas y se han ejecutado al menos una vez (con
      su resultado comunicado al usuario), o registradas como tareas, según lo
      elegido.
- [ ] Los hooks de gitleaks están activos en este clon y se ha comprobado que
      bloquean una fuga de prueba (preparada sin hacer commit y retirada
      después). El fichero de patrones personales existe fuera del repo y
      ningún valor personal ha llegado al repo, al chat ni a la bóveda.
- [ ] No se ha modificado la base de datos ni ningún panel externo sin OK
      explícito del usuario.

## Cambios y migraciones

<!-- OBLIGATORIO al modificar este sistema: sube `version` en el frontmatter de
     arriba y añade aquí una entrada `### vN → vN+1` (formato en
     `references/sincronizacion.md`). Un cambio sin su entrada de migración está
     incompleto (ver "Versionado y despliegue" en la memoria del repo). El modo
     sincronización lee estas entradas para actualizar bóvedas ya montadas sin
     pisar su contenido de dominio. -->

### v1 — baseline

Primera versión del sistema. No hay migraciones anteriores: en bóvedas que no lo
tienen se añade por modo ampliación, siguiendo 9e.

Para futuras entradas de este sistema, el reparto habitual es:

- **Canónico:** las reglas del bloque de 9b, la plantilla de excepción, la
  estructura de la checklist y las vistas de `Seguridad.base`.
- **Esquema de notas:** propiedades del frontmatter de las notas de `Seguridad/`.
- **NO tocar:** valores ya rellenados de la checklist y su tabla de revisiones,
  el cuerpo de las excepciones, los marcadores ya sustituidos (nombres de apps,
  recursos compartidos, lista de comprobaciones) y los ficheros de tests y CI del
  repo, que tras montarse son código del proyecto. Si una versión nueva cambia
  las plantillas de 9c, el sync **propone** el cambio en esos ficheros como
  diff, pero no lo aplica sin OK.

### v1 → v2

Añade la revisión de fugas antes de cada commit y push (secretos, datos del
entorno personal y vulnerabilidades sin corregir), con gitleaks como comprobación
ejecutable, y la gestión de hallazgos sensibles en repos públicos.

**Preguntas nuevas antes de migrar** (de 9a): la 5 (¿repo público?) y la 6
(fichero de patrones personales). Sin la respuesta a la 5 no se decide si entra
el apartado de vulnerabilidades.

**Canónico — regenerar en la bóveda:**

- Sección del sistema en el README: línea de versión a `2`; el párrafo de la
  carpeta menciona los hallazgos privados; apartado **Secretos** con la viñeta
  de `.gitignore`; apartado nuevo **Repositorio y publicación** (siempre);
  apartado nuevo **Vulnerabilidades y hallazgos sensibles** (solo si el repo es
  público); en **Comprobaciones y compuerta de "Hecha"**, la viñeta "Ninguna
  tarea pasa a `Hecha` con commits sin revisar" y gitleaks en la lista de
  ejemplo. Si el repo es público, añade también las reglas de estado de las
  notas `Hallazgo`.
- `Seguridad.base`: propiedades `Severidad`, `Aviso` y `Versión del arreglo`, y
  la vista `Hallazgos privados`.

**Esquema de notas — checklist (requiere OK del usuario):**

- `Checklist de lanzamiento.md`: añadir la sección `## GitHub` antes de
  `## Legal y privacidad` y la palabra "GitHub" al `Resumen`. Si la nota estaba
  `Revisada`, proponer pasarla a `Pendiente` hasta revisar la sección nueva, y
  actualizar su `Última modificación`. No cambiar nada más de la nota.
- **Ficheros del repo (propuesta como diff, con OK):** `.gitleaks.toml`,
  `.githooks/` (o la integración en husky, lefthook o pre-commit si el proyecto
  ya usa uno), la activación de `core.hooksPath` (o el script `prepare`) y el
  job `fugas` del CI. Con OK, crear fuera del repo la plantilla de patrones
  personales si no existe. Después, ejecutar en solo lectura la revisión inicial
  del historial de 9c y aplicar "Si algo sensible llega a subirse" a lo que
  aparezca.
- Si el repo ya tenía hallazgos sensibles anotados con otro formato, proponer
  convertirlos en notas `SEC-AAAA-NN` opacas, sin copiar su descripción a la
  nota nueva.

**NO tocar:** valores ya rellenados de la checklist y su tabla de revisiones;
notas `Excepción`; el resto de apartados de la sección del sistema; los tests de
`supabase/tests/`, el test de AXE y los jobs de CI existentes (solo se añade el
job `fugas`); las "Reglas fundamentales del proyecto". Si estas ya contienen una
regla equivalente sobre repos públicos o datos sensibles, el sync no la toca:
avisa al usuario de la duplicidad para que decida si la sustituye por un enlace
a "Repositorio y publicación".

### v2 → v3

Declara las relaciones del sistema (`se_integra_con: [tareas, publicacion]`) con
sus secciones "Integración con Tareas" e "Integración con Publicación", y fija los
finales de línea de los hooks. En una bóveda con Tareas montado y sin Publicación,
el contenido de la bóveda no cambia: solo se sella la versión.

**Canónico — regenerar en la bóveda:**

- Línea de versión de la sección del sistema a `3`.
- Si Tareas **no** está montado: redactar la compuerta según "Integración con
  Tareas" (versión independiente).
- Si Publicación está montado: añadir la viñeta "Sus jobs son checks obligatorios
  para integrar en la rama principal…" al final de "Comprobaciones y compuerta de
  'Hecha'".

**Esquema de notas — checklist (requiere OK del usuario):**

- **Ficheros del repo (propuesta como diff, con OK):** añadir
  `.githooks/* text eol=lf` a `.gitattributes` si los hooks de 9c están montados
  y la línea no existe. Si Publicación está montado y su guarda no está en el
  `pre-push`, encadenarla como dice "Integración con Publicación".

**NO tocar:** el resto de la sección del sistema, las notas de `Seguridad/`, los
tests, el resto de hooks, el CI y las "Reglas fundamentales del proyecto".
