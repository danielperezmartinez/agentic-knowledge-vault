#!/usr/bin/env pwsh
# Instalador interactivo del skill agentic-knowledge-vault.
#
# Interactivo (navegación con flechas):
#   irm .../install.ps1 | iex
#   ↑/↓ mover · espacio marcar (multi) · enter confirmar
#
# No interactivo (variables de entorno):
#   $env:AKV_SCOPE='user'; $env:AKV_AGENTS='claude,cursor'; $env:AKV_METHOD='symlink'; irm .../install.ps1 | iex
$ErrorActionPreference = 'Stop'

$SkillName = 'agentic-knowledge-vault'
$RepoUrl   = 'https://github.com/danielperezmartinez/agentic-knowledge-vault.git'

$Agents = [ordered]@{
  claude  = @{ label = 'Claude Code';    user = "$HOME/.claude/skills";  project = ".claude/skills" }
  cursor  = @{ label = 'Cursor';         user = "$HOME/.cursor/skills";  project = ".cursor/skills" }
  codex   = @{ label = 'Codex';          user = "$HOME/.codex/skills";   project = ".agents/skills" }
  gemini  = @{ label = 'Gemini CLI';     user = "$HOME/.gemini/skills";  project = ".gemini/skills" }
  copilot = @{ label = 'GitHub Copilot'; user = "$HOME/.copilot/skills"; project = ".github/skills" }
}
$Order = @('claude', 'cursor', 'codex', 'gemini', 'copilot')

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
        { $_ -in @('1', 'claude', 'claude-code') } { $selected += 'claude' }
        { $_ -in @('2', 'cursor') }                { $selected += 'cursor' }
        { $_ -in @('3', 'codex') }                 { $selected += 'codex' }
        { $_ -in @('4', 'gemini') }                { $selected += 'gemini' }
        { $_ -in @('5', 'copilot') }               { $selected += 'copilot' }
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

# Conserva el orden canónico y elimina duplicados.
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

# --- Origen del SKILL.md (repo local o clon temporal) -----------------------
$TmpDir = $null
if (Test-Path 'SKILL.md') {
  $SrcDir = (Get-Location).Path
} elseif ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot 'SKILL.md'))) {
  $SrcDir = $PSScriptRoot
} else {
  $TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("akv-" + [System.Guid]::NewGuid().ToString('N'))
  Write-Host "Descargando el skill…"
  git clone --depth 1 $RepoUrl $TmpDir *> $null
  $SrcDir = $TmpDir
}
$SrcSkill = Join-Path $SrcDir 'SKILL.md'
if (-not (Test-Path $SrcSkill)) { Write-Error "No se encontró SKILL.md en el origen."; return }

# --- Instalación ------------------------------------------------------------
function Install-Copy([string]$dir) {
  $dest = Join-Path $dir $SkillName
  if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Copy-Item $SrcSkill (Join-Path $dest 'SKILL.md') -Force
  return (Resolve-Path $dest).Path
}

try {
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
      if (-not $canonical) {
        $canonical = Install-Copy $Agents[$a].$Scope
        Write-Host ("  [ok] {0} (canónica): {1}" -f $Agents[$a].label, (Join-Path $canonical 'SKILL.md'))
        continue
      }
      $dir  = $Agents[$a].$Scope
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
} finally {
  if ($TmpDir -and (Test-Path $TmpDir)) { Remove-Item -Recurse -Force $TmpDir }
}
