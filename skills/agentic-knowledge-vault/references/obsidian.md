# Configuración de Obsidian (Paso 8)

Opcional pero recomendado. Para que los `.base` rendericen como vistas, la bóveda
debe abrirse con Obsidian y el core plugin **Bases** habilitado. Crea
`{{BÓVEDA}}/.obsidian/` mínima:

- `app.json` → `{}`
- `appearance.json` → `{}`
- `core-plugins.json` → habilita al menos `bases` (y los que el usuario quiera).

No es imprescindible para que los agentes lean las notas (son Markdown plano),
pero sí para la experiencia humana en Obsidian. Si el usuario no usa Obsidian,
puedes omitir este paso; los `.base` seguirán siendo YAML legible.
