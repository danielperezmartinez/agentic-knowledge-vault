#!/usr/bin/env sh
# Instala o actualiza el skill agentic-knowledge-vault.
#
# Uso:
#   curl -fsSL .../install.sh | bash            # personal: ~/.claude/skills
#   curl -fsSL .../install.sh | bash -s -- --project   # proyecto: ./.claude/skills
#   ./install.sh /ruta/a/skills                 # carpeta de skills a medida
set -eu

REPO_URL="https://github.com/danielperezmartinez/agentic-knowledge-vault.git"
SKILL_NAME="agentic-knowledge-vault"

case "${1:-}" in
  --project) BASE=".claude/skills" ;;
  "")        BASE="$HOME/.claude/skills" ;;
  *)         BASE="$1" ;;
esac

DEST="$BASE/$SKILL_NAME"
mkdir -p "$BASE"

if [ -d "$DEST/.git" ]; then
  echo "Actualizando skill en $DEST"
  git -C "$DEST" pull --ff-only
else
  echo "Instalando skill en $DEST"
  git clone --depth 1 "$REPO_URL" "$DEST"
fi

echo "Listo. Invócala con /$SKILL_NAME en Claude Code."
