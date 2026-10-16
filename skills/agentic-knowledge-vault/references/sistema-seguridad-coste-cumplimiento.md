---
sistema: seguridad-coste-cumplimiento
version: 1
---

# Seguridad, coste y cumplimiento (Paso 9)

Móntalo solo si el usuario lo eligió en la Pregunta 2b. A diferencia del resto de
sistemas, no es solo un registro de notas: aporta **reglas** (que van al
`README.md` de la bóveda), **comprobaciones ejecutables** (que viven en el código
del proyecto y en su CI) y una **checklist de lanzamiento** para lo que vive fuera
del código (paneles de Supabase, Vercel, etc.).

Al terminar, añade su enlace en `Inicio.md` y sus reglas en la sección "Sistemas
disponibles" del `README.md`. Bajo el encabezado del sistema en esa sección,
escribe además la línea `_Versión del sistema: 1._` (la `version` del frontmatter
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
5. **¿Qué hacer con las comprobaciones ejecutables?**
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

_Versión del sistema: 1._

Carpeta [[Seguridad/Seguridad.base|Seguridad/]]: excepciones justificadas a estas
reglas y la [[Seguridad/Checklist de lanzamiento|checklist de lanzamiento]].
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
  `e2e/a11y.spec.ts`, ambos en `.github/workflows/seguridad.yml` -->
- **Una tarea que toque backend o UI no pasa a `Hecha`** hasta que esas
  comprobaciones estén en verde, y su sección "Verificación" lo deja escrito (qué
  se ejecutó y dónde). Si el cambio añade tablas, políticas, funciones o rutas,
  añade también su test en el mismo cambio.
- Una excepción a estas reglas es una nota `Excepción` en `Seguridad/` con su
  justificación. Sin nota, no hay excepción.
````

Si el sistema de Tareas no está montado, la compuerta se aplica igual al criterio
de "terminado" que use el proyecto (merge del PR, despliegue, etc.); redáctala así.

## 9c. Comprobaciones ejecutables

Ficheros que se proponen o montan en el repo del proyecto (según la Pregunta 5 de
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
```

Cuando los jobs estén verdes, márcalos como obligatorios en la protección de la
rama principal. Hasta entonces la compuerta de "Hecha" sigue aplicando.

## 9d. Carpeta `Seguridad/`

```
{{BÓVEDA}}/Seguridad/
├── Seguridad.base
├── Checklist de lanzamiento.md
└── Excepción - <objeto>.md      (una por excepción, solo si hacen falta)
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
Resumen: Estado de la configuración fuera del código (gasto, Auth, firewall, secretos, plan y legal) que ningún test del repo comprueba.
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
```

### Enlace en `Inicio.md`

```markdown
### Seguridad, coste y cumplimiento

[[Seguridad/Seguridad.base|Abrir el panel de seguridad]] ·
[[Seguridad/Checklist de lanzamiento|Checklist de lanzamiento]]
```

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
