#!/usr/bin/env bash
# Instalador interactivo del skill agentic-knowledge-vault.
#
# Pregunta ámbito (usuario/proyecto) y para qué CLIs instalar, y copia el skill
# en el directorio que cada CLI espera. Funciona en local y vía `curl | bash`
# (lee de /dev/tty). Para CI/uso no interactivo, usa flags.
#
# Uso interactivo:
#   curl -fsSL .../install.sh | bash
#
# Uso no interactivo:
#   ./install.sh --scope user --agents claude,cursor,codex,gemini,copilot
#   ./install.sh --scope project --agents all -y
set -eu

SKILL_NAME="agentic-knowledge-vault"
REPO_URL="https://github.com/danielperezmartinez/agentic-knowledge-vault.git"

SCOPE=""
AGENTS_ARG=""
METHOD=""
ASSUME_YES=0
CLEANUP_TMP=""

cleanup() { [ -n "$CLEANUP_TMP" ] && rm -rf "$CLEANUP_TMP" 2>/dev/null || true; }
trap cleanup EXIT

# --- Flags ------------------------------------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
    --scope)   SCOPE="${2:-}"; shift 2 ;;
    --agents)  AGENTS_ARG="${2:-}"; shift 2 ;;
    --method)  METHOD="${2:-}"; shift 2 ;;
    -y|--yes)  ASSUME_YES=1; shift ;;
    --project) SCOPE="project"; shift ;;   # atajo retrocompatible
    -h|--help)
      echo "Uso: install.sh [--scope user|project] [--agents lista|all] [--method symlink|copy] [-y]"
      exit 0 ;;
    *) echo "Opción desconocida: $1" >&2; exit 2 ;;
  esac
done

# --- Lectura interactiva (desde /dev/tty para soportar curl | bash) ---------
have_tty=0
[ -r /dev/tty ] && have_tty=1

ask() { # ask "prompt" "default" -> stdout
  local prompt="$1" def="$2" ans=""
  if [ "$have_tty" -eq 1 ] && [ "$ASSUME_YES" -eq 0 ]; then
    printf "%s" "$prompt" > /dev/tty
    read -r ans < /dev/tty || ans=""
  fi
  [ -z "$ans" ] && ans="$def"
  printf "%s" "$ans"
}

# --- Ámbito -----------------------------------------------------------------
if [ -z "$SCOPE" ]; then
  {
    echo ""
    echo "Ámbito de instalación:"
    echo "  1) Usuario (global, todos tus proyectos)"
    echo "  2) Proyecto (este repositorio)"
  } > /dev/tty 2>/dev/null || true
  case "$(ask "Elige [1]: " "1")" in
    2|project|proyecto) SCOPE="project" ;;
    *) SCOPE="user" ;;
  esac
fi

# --- Selección de CLIs ------------------------------------------------------
# id | etiqueta | dir usuario | dir proyecto
AGENT_IDS="claude cursor codex gemini copilot"
agent_label() { case "$1" in
  claude) echo "Claude Code" ;; cursor) echo "Cursor" ;; codex) echo "Codex" ;;
  gemini) echo "Gemini CLI" ;; copilot) echo "GitHub Copilot" ;; esac; }
agent_dir() { # agent_dir <id> <scope>
  case "$1:$2" in
    claude:user)     echo "$HOME/.claude/skills" ;;
    claude:project)  echo ".claude/skills" ;;
    cursor:user)     echo "$HOME/.cursor/skills" ;;
    cursor:project)  echo ".cursor/skills" ;;
    codex:user)      echo "$HOME/.agents/skills" ;;
    codex:project)   echo ".agents/skills" ;;
    gemini:user)     echo "$HOME/.gemini/skills" ;;
    gemini:project)  echo ".gemini/skills" ;;
    copilot:user)    echo "$HOME/.copilot/skills" ;;
    copilot:project) echo ".github/skills" ;;
  esac; }

if [ -z "$AGENTS_ARG" ]; then
  {
    echo ""
    echo "¿Para qué CLIs quieres instalar el skill?"
    i=1; for a in $AGENT_IDS; do echo "  $i) $(agent_label "$a")"; i=$((i+1)); done
    echo "Varios separados por coma (p. ej. 1,3) o 'a' para todos."
  } > /dev/tty 2>/dev/null || true
  AGENTS_ARG="$(ask "Elige [a]: " "a")"
fi

# Normaliza la selección (números, nombres o 'a'/'all') a una lista de ids.
selected=""
case "$AGENTS_ARG" in
  a|all|todos|"*") selected="$AGENT_IDS" ;;
  *)
    old_ifs="$IFS"; IFS=","
    for tok in $AGENTS_ARG; do
      tok="$(echo "$tok" | tr -d ' ' | tr 'A-Z' 'a-z')"
      case "$tok" in
        1|claude|claude-code) selected="$selected claude" ;;
        2|cursor)             selected="$selected cursor" ;;
        3|codex)              selected="$selected codex" ;;
        4|gemini)             selected="$selected gemini" ;;
        5|copilot)            selected="$selected copilot" ;;
        "" ) ;;
        *) echo "Aviso: CLI no reconocido '$tok', se ignora." >&2 ;;
      esac
    done
    IFS="$old_ifs" ;;
esac

# Conserva el orden de $AGENT_IDS y elimina duplicados.
ordered=""
for a in $AGENT_IDS; do
  case " $selected " in *" $a "*) ordered="$ordered $a" ;; esac
done
selected="$(echo "$ordered" | awk '{$1=$1};1')"
if [ -z "$selected" ]; then
  echo "No se seleccionó ningún CLI. Nada que hacer." >&2
  exit 1
fi

# --- Método: symlink o copia ------------------------------------------------
if [ -z "$METHOD" ]; then
  {
    echo ""
    echo "Método de instalación:"
    echo "  1) Symlink (recomendado): una copia canónica y el resto enlazado;"
    echo "     actualizar una actualiza todas."
    echo "  2) Copia: una copia independiente por CLI."
  } > /dev/tty 2>/dev/null || true
  case "$(ask "Elige [1]: " "1")" in
    2|copy|copia) METHOD="copy" ;;
    *) METHOD="symlink" ;;
  esac
fi
[ "$METHOD" = "copy" ] || METHOD="symlink"

# --- Origen del SKILL.md (repo local o clon temporal) -----------------------
SRC_DIR=""
if [ -f "SKILL.md" ]; then
  SRC_DIR="$(pwd)"
elif [ -n "${BASH_SOURCE:-}" ] && [ -f "$(dirname "${BASH_SOURCE:-}")/SKILL.md" ]; then
  SRC_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
else
  CLEANUP_TMP="$(mktemp -d)"
  echo "Descargando el skill…"
  git clone --depth 1 "$REPO_URL" "$CLEANUP_TMP" >/dev/null 2>&1
  SRC_DIR="$CLEANUP_TMP"
fi
[ -f "$SRC_DIR/SKILL.md" ] || { echo "No se encontró SKILL.md en el origen." >&2; exit 1; }

# --- Instalación ------------------------------------------------------------
# Instala una copia real del skill en <dir>/<name> y devuelve la ruta absoluta.
install_copy() { # install_copy <dir>
  local dest="$1/$SKILL_NAME"
  rm -rf "$dest" 2>/dev/null || true
  mkdir -p "$dest"
  cp "$SRC_DIR/SKILL.md" "$dest/SKILL.md"
  ( cd "$dest" && pwd )
}

echo ""
echo "Instalando '$SKILL_NAME' (ámbito: $SCOPE, método: $METHOD) en:"

if [ "$METHOD" = "copy" ]; then
  for a in $selected; do
    dest="$(install_copy "$(agent_dir "$a" "$SCOPE")")"
    echo "  ✓ $(agent_label "$a"): $dest/SKILL.md"
  done
else
  # El primer CLI es la copia canónica; los demás se enlazan a ella.
  canonical=""
  for a in $selected; do
    if [ -z "$canonical" ]; then
      canonical="$(install_copy "$(agent_dir "$a" "$SCOPE")")"
      echo "  ✓ $(agent_label "$a") (canónica): $canonical/SKILL.md"
      continue
    fi
    dir="$(agent_dir "$a" "$SCOPE")"; dest="$dir/$SKILL_NAME"
    mkdir -p "$dir"; rm -rf "$dest" 2>/dev/null || true
    if ln -s "$canonical" "$dest" 2>/dev/null; then
      echo "  ✓ $(agent_label "$a") (symlink): $dest -> $canonical"
    else
      dest="$(install_copy "$dir")"
      echo "  ! $(agent_label "$a"): symlink no permitido; copiado en $dest/SKILL.md"
    fi
  done
fi

echo ""
echo "Listo. Invócalo en el CLI correspondiente (p. ej. /$SKILL_NAME en Claude Code)."
