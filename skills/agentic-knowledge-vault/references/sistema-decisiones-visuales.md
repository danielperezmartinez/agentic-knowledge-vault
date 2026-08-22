# Decisiones visuales y de estilos (Paso 6)

Móntalo solo si el usuario lo eligió. Al terminar, añade su enlace en `Inicio.md`
y sus reglas de estado en la sección "Sistemas disponibles" del `README.md`.

Dos formas, según lo que pida el usuario:

- **Como sistema tipo ADR**: reutiliza la estructura de `references/sistema-adr.md`
  en una carpeta `{{BÓVEDA}}/Decisiones visuales/` con su propio `.base`. Estados
  sugeridos: `Propuesta` · `Aceptada` · `Reemplazada`. Añade propiedades propias
  del dominio visual si aportan (p. ej. `Ámbito`: tokens, componente, layout).
- **Como lista ligera**: una única nota-índice con tabla Markdown si el volumen
  es bajo. Migra a `.base` cuando crezca.

No inventes un tercer patrón: cualquier sistema de "decisiones" comparte el
principio de frontmatter YAML + `.base`.
