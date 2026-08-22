#!/usr/bin/env bash
# Instalador interactivo del skill agentic-knowledge-vault.
#
# Interactivo (navegación con flechas):
#   curl -fsSL .../install.sh | bash
#   ↑/↓ mover · espacio marcar (multi) · enter confirmar
#
# No interactivo (CI / automatización):
#   ./install.sh --scope user --agents claude,cursor,codex,antigravity,copilot --method symlink
#   ./install.sh --scope project --agents all --method copy -y
#
# Cada CLI escribe en su carpeta nativa y, además, siempre en el hub compartido
# .agents/skills (que varios CLIs leen). Para proyectos en otra unidad que tu
# perfil (p. ej. P:\ en Windows) usa --scope project.
set -eu

SKILL_NAME="agentic-knowledge-vault"
REPO_URL="https://github.com/danielperezmartinez/agentic-knowledge-vault.git"

SCOPE=""
AGENTS_ARG=""
METHOD=""
ASSUME_YES=0
CLEANUP_TMP=""
STTY_SAVE=""
have_tty=0

cleanup() {
  if [ "$have_tty" -eq 1 ]; then
    [ -n "$STTY_SAVE" ] && stty "$STTY_SAVE" </dev/tty 2>/dev/null || true
    printf '\033[?25h' >/dev/tty 2>/dev/null || true
  fi
  [ -n "$CLEANUP_TMP" ] && rm -rf "$CLEANUP_TMP" 2>/dev/null || true
}
trap cleanup EXIT

# --- Flags ------------------------------------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
    --scope)   SCOPE="${2:-}"; shift 2 ;;
    --agents)  AGENTS_ARG="${2:-}"; shift 2 ;;
    --method)  METHOD="${2:-}"; shift 2 ;;
    -y|--yes)  ASSUME_YES=1; shift ;;
    --project) SCOPE="project"; shift ;;
    -h|--help)
      echo "Uso: install.sh [--scope user|project] [--agents lista|all] [--method symlink|copy] [-y]"
      exit 0 ;;
    *) echo "Opción desconocida: $1" >&2; exit 2 ;;
  esac
done

[ -r /dev/tty ] && [ -t 1 ] && have_tty=1
interactive=0
[ "$have_tty" -eq 1 ] && [ "$ASSUME_YES" -eq 0 ] && interactive=1

# --- Datos de agentes -------------------------------------------------------
AGENT_ARR="claude cursor codex antigravity copilot"
agent_label() { case "$1" in
  claude) echo "Claude Code" ;; cursor) echo "Cursor" ;; codex) echo "Codex" ;;
  antigravity) echo "Antigravity CLI (agy)" ;; copilot) echo "GitHub Copilot" ;; esac; }
# Carpeta nativa de cada CLI (donde su global la busca).
native_dir() { case "$1:$2" in
  claude:user)         echo "$HOME/.claude/skills" ;;
  claude:project)      echo ".claude/skills" ;;
  cursor:user)         echo "$HOME/.cursor/skills" ;;
  cursor:project)      echo ".cursor/skills" ;;
  codex:user)          echo "$HOME/.codex/skills" ;;
  codex:project)       echo ".agents/skills" ;;
  antigravity:user)    echo "$HOME/.gemini/skills" ;;
  antigravity:project) echo ".gemini/skills" ;;
  copilot:user)        echo "$HOME/.copilot/skills" ;;
  copilot:project)     echo ".github/skills" ;;
esac; }
id_from_token() { case "$(echo "$1" | tr -d ' ' | tr 'A-Z' 'a-z')" in
  1|claude|claude-code) echo claude ;; 2|cursor) echo cursor ;; 3|codex) echo codex ;;
  4|antigravity|agy|gemini) echo antigravity ;; 5|copilot) echo copilot ;; *) echo "" ;;
esac; }

# --- Motor de menús por teclado (flechas) -----------------------------------
_begin_raw() { STTY_SAVE="$(stty -g </dev/tty)"; stty -echo -icanon min 1 time 0 </dev/tty; printf '\033[?25l' >/dev/tty; }
_end_raw()   { stty "$STTY_SAVE" </dev/tty; STTY_SAVE=""; printf '\033[?25h' >/dev/tty; }

read_key() {
  local c rest
  IFS= read -rsn1 c </dev/tty || { echo enter; return; }
  case "$c" in
    "")  echo enter; return ;;
    " ") echo space; return ;;
    j|J) echo down;  return ;;
    k|K) echo up;    return ;;
    q|Q) echo quit;  return ;;
    $'\033')
      IFS= read -rsn2 -t 1 rest </dev/tty || rest=""
      case "$rest" in
        "[A") echo up ;; "[B") echo down ;; "[C") echo right ;; "[D") echo left ;; *) echo other ;;
      esac
      return ;;
    *) echo other; return ;;
  esac
}

menu_single() {
  local title="$1"; shift
  local opts=("$@") n=$# cur=0 total=$(( $# + 2 )) i first=1
  _begin_raw
  while true; do
    [ "$first" -eq 0 ] && printf '\033[%dA\033[J' "$total" >/dev/tty
    first=0
    printf '%s\r\n' "$title" >/dev/tty
    printf '  \033[2m↑/↓ mover · enter confirmar\033[0m\r\n' >/dev/tty
    for i in $(seq 0 $((n-1))); do
      if [ "$i" -eq "$cur" ]; then printf '  \033[36m> %s\033[0m\r\n' "${opts[$i]}" >/dev/tty
      else printf '    %s\r\n' "${opts[$i]}" >/dev/tty; fi
    done
    case "$(read_key)" in
      up)   cur=$(( (cur-1+n)%n )) ;;
      down) cur=$(( (cur+1)%n )) ;;
      enter) break ;;
      quit) _end_raw; echo "Cancelado." >&2; exit 1 ;;
    esac
  done
  _end_raw
  MENU_INDEX=$cur
}

menu_multi() {
  local title="$1"; shift
  local opts=("$@") n=$# cur=0 total=$(( $# + 2 )) i first=1 any box
  local sel=(); for i in $(seq 0 $((n-1))); do sel[$i]=0; done
  _begin_raw
  while true; do
    [ "$first" -eq 0 ] && printf '\033[%dA\033[J' "$total" >/dev/tty
    first=0
    printf '%s\r\n' "$title" >/dev/tty
    printf '  \033[2m↑/↓ mover · espacio marcar · enter confirmar\033[0m\r\n' >/dev/tty
    for i in $(seq 0 $((n-1))); do
      if [ "${sel[$i]}" -eq 1 ]; then box="[x]"; else box="[ ]"; fi
      if [ "$i" -eq "$cur" ]; then printf '  \033[36m> %s %s\033[0m\r\n' "$box" "${opts[$i]}" >/dev/tty
      else printf '    %s %s\r\n' "$box" "${opts[$i]}" >/dev/tty; fi
    done
    case "$(read_key)" in
      up)    cur=$(( (cur-1+n)%n )) ;;
      down)  cur=$(( (cur+1)%n )) ;;
      space) if [ "${sel[$cur]}" -eq 1 ]; then sel[$cur]=0; else sel[$cur]=1; fi ;;
      enter)
        any=0; for i in $(seq 0 $((n-1))); do [ "${sel[$i]}" -eq 1 ] && any=1; done
        [ "$any" -eq 1 ] && break ;;
      quit) _end_raw; echo "Cancelado." >&2; exit 1 ;;
    esac
  done
  _end_raw
  MENU_LIST=""
  for i in $(seq 0 $((n-1))); do [ "${sel[$i]}" -eq 1 ] && MENU_LIST="$MENU_LIST $i"; done
}

# --- Ámbito -----------------------------------------------------------------
if [ -z "$SCOPE" ]; then
  if [ "$interactive" -eq 1 ]; then
    menu_single "Ámbito de instalación:" "Usuario (global, todos tus proyectos)" "Proyecto (este repositorio)"
    [ "$MENU_INDEX" -eq 1 ] && SCOPE="project" || SCOPE="user"
  else
    SCOPE="user"
  fi
fi
[ "$SCOPE" = "project" ] || SCOPE="user"

# --- Selección de CLIs ------------------------------------------------------
selected=""
if [ -n "$AGENTS_ARG" ]; then
  case "$AGENTS_ARG" in
    a|all|todos|"*") selected="$AGENT_ARR" ;;
    *) old_ifs="$IFS"; IFS=","
       for tok in $AGENTS_ARG; do id="$(id_from_token "$tok")"
         [ -n "$id" ] && selected="$selected $id" || echo "Aviso: CLI no reconocido '$tok'." >&2
       done; IFS="$old_ifs" ;;
  esac
elif [ "$interactive" -eq 1 ]; then
  menu_multi "¿Para qué CLIs quieres instalar el skill?" \
    "Claude Code" "Cursor" "Codex" "Antigravity CLI (agy)" "GitHub Copilot"
  set -- $AGENT_ARR
  for idx in $MENU_LIST; do eval "id=\${$((idx+1))}"; selected="$selected $id"; done
else
  selected="claude"
fi

ordered=""
for a in $AGENT_ARR; do
  case " $selected " in *" $a "*) ordered="$ordered $a" ;; esac
done
selected="$(echo "$ordered" | awk '{$1=$1};1')"
[ -n "$selected" ] || { echo "No se seleccionó ningún CLI. Nada que hacer." >&2; exit 1; }

# --- Método -----------------------------------------------------------------
if [ -z "$METHOD" ]; then
  if [ "$interactive" -eq 1 ]; then
    menu_single "Método de instalación:" \
      "Symlink (recomendado): una copia canónica y el resto enlazado" \
      "Copia: una copia independiente por CLI"
    [ "$MENU_INDEX" -eq 1 ] && METHOD="copy" || METHOD="symlink"
  else
    METHOD="symlink"
  fi
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
install_copy() { # install_copy <dir> -> ruta absoluta del skill
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
    dest="$(install_copy "$(native_dir "$a" "$SCOPE")")"
    echo "  ✓ $(agent_label "$a"): $dest/SKILL.md"
  done
else
  canonical=""
  for a in $selected; do
    dir="$(native_dir "$a" "$SCOPE")"
    if [ -z "$canonical" ]; then
      canonical="$(install_copy "$dir")"
      echo "  ✓ $(agent_label "$a") (canónica): $canonical/SKILL.md"
      continue
    fi
    dest="$dir/$SKILL_NAME"
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
echo "Nota: si tu proyecto está en otra unidad que tu perfil, usa --scope project."
