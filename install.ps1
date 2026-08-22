#!/usr/bin/env pwsh
# Instalador interactivo del skill agentic-knowledge-vault.
#
# Interactivo (navegación con flechas):
#   irm .../install.ps1 | iex
#   ↑/↓ mover · espacio marcar (multi) · enter confirmar
#
# No interactivo (variables de entorno):
#   $env:AKV_SCOPE='user'; $env:AKV_AGENTS='claude,codex'; $env:AKV_METHOD='symlink'; irm .../install.ps1 | iex
#
# Actualizar lo ya instalado (detecta CLIs y ámbito automáticamente y actualiza todo):
#   $env:AKV_ACTION='update'; irm .../install.ps1 | iex
#
# Cada CLI escribe en su carpeta nativa y, además, siempre en el hub compartido
# .agents/skills (que varios CLIs leen). Para proyectos en otra unidad que tu
# perfil (p. ej. P:\) usa ámbito proyecto.
$ErrorActionPreference = 'Stop'

$SkillName = 'agentic-knowledge-vault'
$RepoUrl   = 'https://github.com/danielperezmartinez/agentic-knowledge-vault.git'

# Claude Code respeta CLAUDE_CONFIG_DIR (si está, sus skills viven ahí, no en ~/.claude).
$ClaudeUserDir = if ($env:CLAUDE_CONFIG_DIR) { Join-Path $env:CLAUDE_CONFIG_DIR 'skills' } else { "$HOME/.claude/skills" }

# Carpeta nativa de cada CLI (user/project).
$Agents = [ordered]@{
  claude      = @{ label = 'Claude Code (terminal)';          user = $ClaudeUserDir;          project = ".claude/skills" }
  cursor      = @{ label = 'Cursor';                          user = "$HOME/.cursor/skills";  project = ".cursor/skills" }
  codex       = @{ label = 'Codex';                           user = "$HOME/.codex/skills";   project = ".agents/skills" }
  antigravity = @{ label = 'Antigravity CLI (agy, terminal)'; user = "$HOME/.gemini/skills";  project = ".gemini/skills" }
  copilot     = @{ label = 'GitHub Copilot';        user = "$HOME/.copilot/skills"; project = ".github/skills" }
}
$Order = @('claude', 'cursor', 'codex', 'antigravity', 'copilot')

try { $Interactive = -not [Console]::IsInputRedirected } catch { $Interactive = $false }

# --- Motor de menús por teclado (flechas) -----------------------------------
function Show-MenuSingle {
  param([string]$Title, [string[]]$Options)
  $cur = 0; $total = $Options.Count + 2; $first = $true
  [Console]::CursorVisible = $false
  try {
    while ($true) {
      if (-not $first) { [Console]::SetCursorPosition(0, [Console]::CursorTop - $total) }
      $first = $false
      $w = [Console]::WindowWidth - 1; if ($w -lt 1) { $w = 80 }
      Write-Host ($Title.PadRight($w))
      Write-Host (("  ↑/↓ mover · enter confirmar").PadRight($w)) -ForegroundColor DarkGray
      for ($i = 0; $i -lt $Options.Count; $i++) {
        if ($i -eq $cur) { Write-Host (("  > " + $Options[$i]).PadRight($w)) -ForegroundColor Cyan }
        else { Write-Host (("    " + $Options[$i]).PadRight($w)) }
      }
      $k = [Console]::ReadKey($true)
      switch ($k.Key) {
        'UpArrow'   { $cur = ($cur - 1 + $Options.Count) % $Options.Count }
        'DownArrow' { $cur = ($cur + 1) % $Options.Count }
        'Enter'     { return $cur }
        default {
          if ($k.KeyChar -in 'k', 'K') { $cur = ($cur - 1 + $Options.Count) % $Options.Count }
          elseif ($k.KeyChar -in 'j', 'J') { $cur = ($cur + 1) % $Options.Count }
        }
      }
    }
  } finally { [Console]::CursorVisible = $true }
}

function Show-MenuMulti {
  param([string]$Title, [string[]]$Options)
  $cur = 0; $total = $Options.Count + 2; $first = $true
  $sel = New-Object bool[] $Options.Count
  [Console]::CursorVisible = $false
  try {
    while ($true) {
      if (-not $first) { [Console]::SetCursorPosition(0, [Console]::CursorTop - $total) }
      $first = $false
      $w = [Console]::WindowWidth - 1; if ($w -lt 1) { $w = 80 }
      Write-Host ($Title.PadRight($w))
      Write-Host (("  ↑/↓ mover · espacio marcar · enter confirmar").PadRight($w)) -ForegroundColor DarkGray
      for ($i = 0; $i -lt $Options.Count; $i++) {
        $box = if ($sel[$i]) { '[x]' } else { '[ ]' }
        $line = "$box " + $Options[$i]
        if ($i -eq $cur) { Write-Host (("  > " + $line).PadRight($w)) -ForegroundColor Cyan }
        else { Write-Host (("    " + $line).PadRight($w)) }
      }
      $k = [Console]::ReadKey($true)
      switch ($k.Key) {
        'UpArrow'   { $cur = ($cur - 1 + $Options.Count) % $Options.Count }
        'DownArrow' { $cur = ($cur + 1) % $Options.Count }
        'Spacebar'  { $sel[$cur] = -not $sel[$cur] }
        'Enter'     { if ($sel -contains $true) { return @(0..($Options.Count - 1) | Where-Object { $sel[$_] }) } }
        default {
          if ($k.KeyChar -in 'k', 'K') { $cur = ($cur - 1 + $Options.Count) % $Options.Count }
          elseif ($k.KeyChar -in 'j', 'J') { $cur = ($cur + 1) % $Options.Count }
        }
      }
    }
  } finally { [Console]::CursorVisible = $true }
}

# --- Acción: instalar o actualizar ------------------------------------------
$Action = $env:AKV_ACTION
if ($Action) { $Action = $Action.Trim().ToLower() }
if     ($Action -in @('update', 'actualizar', 'u')) { $Action = 'update' }
elseif ($Action -in @('install', 'instalar', 'i'))  { $Action = 'install' }
elseif ($Interactive) {
  $idx = Show-MenuSingle "¿Qué quieres hacer?" @('Instalar', 'Actualizar instalaciones existentes')
  $Action = if ($idx -eq 1) { 'update' } else { 'install' }
} else { $Action = 'install' }

# Las preguntas de ámbito, CLIs y método solo aplican al instalar. Al actualizar
# se detectan automáticamente las instalaciones existentes (ver bloque try).
if ($Action -eq 'install') {

# --- Ámbito -----------------------------------------------------------------
$Scope = $env:AKV_SCOPE
if (-not $Scope) {
  if ($Interactive) {
    $idx = Show-MenuSingle "Ámbito de instalación:" @('Usuario (global, todos tus proyectos)', 'Proyecto (este repositorio)')
    $Scope = if ($idx -eq 1) { 'project' } else { 'user' }
  } else { $Scope = 'user' }
}
if ($Scope -notin @('user', 'project')) { $Scope = 'user' }

# --- Selección de CLIs ------------------------------------------------------
$selected = @()
if ($env:AKV_AGENTS) {
  if ($env:AKV_AGENTS -in @('a', 'all', 'todos', '*')) { $selected = $Order }
  else {
    foreach ($tok in ($env:AKV_AGENTS -split ',')) {
      switch ($tok.Trim().ToLower()) {
        { $_ -in @('1', 'claude', 'claude-code') }        { $selected += 'claude' }
        { $_ -in @('2', 'cursor') }                       { $selected += 'cursor' }
        { $_ -in @('3', 'codex') }                        { $selected += 'codex' }
        { $_ -in @('4', 'antigravity', 'agy', 'gemini') } { $selected += 'antigravity' }
        { $_ -in @('5', 'copilot') }                      { $selected += 'copilot' }
      }
    }
  }
} elseif ($Interactive) {
  $labels = $Order | ForEach-Object { $Agents[$_].label }
  $idxs = Show-MenuMulti "¿Para qué CLIs quieres instalar el skill?" $labels
  $selected = @($idxs | ForEach-Object { $Order[$_] })
} else {
  $selected = @('claude')
}

$selected = $Order | Where-Object { $selected -contains $_ }
if (-not $selected) { Write-Error "No se seleccionó ningún CLI. Nada que hacer."; return }

# --- Método -----------------------------------------------------------------
$Method = $env:AKV_METHOD
if (-not $Method) {
  if ($Interactive) {
    $idx = Show-MenuSingle "Método de instalación:" @(
      'Symlink (recomendado): una copia canónica y el resto enlazado',
      'Copia: una copia independiente por CLI')
    $Method = if ($idx -eq 1) { 'copy' } else { 'symlink' }
  } else { $Method = 'symlink' }
}
if ($Method -ne 'copy') { $Method = 'symlink' }

} # fin del bloque solo-instalar

# --- Origen del skill: la carpeta completa (repo local o clon temporal) ------
# El skill vive en skills/<name>/ (estructura de plugin): SKILL.md + references/.
$TmpDir = $null
function Get-SourceDir {
  $reldir = Join-Path 'skills' $SkillName
  if (Test-Path (Join-Path $reldir 'SKILL.md')) { return (Resolve-Path $reldir).Path }
  if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot (Join-Path $reldir 'SKILL.md')))) { return (Resolve-Path (Join-Path $PSScriptRoot $reldir)).Path }
  $script:TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("akv-" + [System.Guid]::NewGuid().ToString('N'))
  Write-Host "Descargando el skill…"
  git clone --depth 1 $RepoUrl $script:TmpDir *> $null
  $d = Join-Path $script:TmpDir $reldir
  if (-not (Test-Path (Join-Path $d 'SKILL.md'))) { throw "No se encontró SKILL.md en el origen." }
  return $d
}

# --- Instalación ------------------------------------------------------------
function Install-Copy([string]$dir) {
  $dest = Join-Path $dir $SkillName
  if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Copy-Item (Join-Path $SrcDir '*') $dest -Recurse -Force
  return (Resolve-Path $dest).Path
}

try {
  if ($Action -eq 'update') {
    $locs = @()
    foreach ($a in $Order) {
      foreach ($sc in @('user', 'project')) {
        $skdir  = Join-Path $Agents[$a].$sc $SkillName
        $skfile = Join-Path $skdir 'SKILL.md'
        if (Test-Path $skfile) { $locs += [pscustomobject]@{ agent = $a; scope = $sc; dir = $skdir; file = $skfile } }
      }
    }
    if (-not $locs) {
      Write-Host "No se encontró ninguna instalación de '$SkillName' (ni en ámbito usuario, ni de proyecto en este directorio)."
      Write-Host "Ejecuta de nuevo y elige «Instalar»."
      return
    }
    $SrcDir = Get-SourceDir
    Write-Host ""
    Write-Host "Actualizando instalaciones existentes de '$SkillName':"
    foreach ($l in $locs) {
      # Refresca la carpeta completa (SKILL.md + references/). En instalaciones
      # por symlink, esto escribe a través del enlace sobre la copia canónica.
      $refs = Join-Path $l.dir 'references'
      if (Test-Path $refs) { Remove-Item -Recurse -Force $refs }
      Copy-Item (Join-Path $SrcDir '*') $l.dir -Recurse -Force
      $isLink = $false
      try { $isLink = ((Get-Item $l.dir -Force).LinkType -eq 'SymbolicLink') } catch { }
      $tag = if ($isLink) { 'symlink -> canónica' } else { 'copia' }
      Write-Host ("  [ok] {0} [{1}] ({2}): {3}" -f $Agents[$l.agent].label, $l.scope, $tag, $l.file)
    }
    Write-Host ""
    Write-Host "Actualización completa."
    return
  }

  $SrcDir = Get-SourceDir
  Write-Host ""
  Write-Host "Instalando '$SkillName' (ámbito: $Scope, método: $Method) en:"

  if ($Method -eq 'copy') {
    foreach ($a in $selected) {
      $dest = Install-Copy $Agents[$a].$Scope
      Write-Host ("  [ok] {0}: {1}" -f $Agents[$a].label, (Join-Path $dest 'SKILL.md'))
    }
  } else {
    $canonical = $null
    foreach ($a in $selected) {
      $dir = $Agents[$a].$Scope
      if (-not $canonical) {
        $canonical = Install-Copy $dir
        Write-Host ("  [ok] {0} (canónica): {1}" -f $Agents[$a].label, (Join-Path $canonical 'SKILL.md'))
        continue
      }
      $dest = Join-Path $dir $SkillName
      New-Item -ItemType Directory -Force -Path $dir | Out-Null
      if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
      try {
        New-Item -ItemType SymbolicLink -Path $dest -Target $canonical -ErrorAction Stop | Out-Null
        Write-Host ("  [ok] {0} (symlink): {1} -> {2}" -f $Agents[$a].label, $dest, $canonical)
      } catch {
        $dest = Install-Copy $dir
        Write-Warning ("{0}: symlink no permitido (activa el Modo desarrollador); copiado en {1}" -f $Agents[$a].label, (Join-Path $dest 'SKILL.md'))
      }
    }
  }

  Write-Host ""
  Write-Host "Listo. Invócalo en el CLI correspondiente (p. ej. /$SkillName en Claude Code)."
  Write-Host "Nota: si tu proyecto está en otra unidad que tu perfil, usa ámbito proyecto."
} finally {
  if ($TmpDir -and (Test-Path $TmpDir)) { Remove-Item -Recurse -Force $TmpDir }
}
