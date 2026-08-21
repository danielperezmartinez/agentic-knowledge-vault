#!/usr/bin/env pwsh
# Instalador interactivo del skill agentic-knowledge-vault.
#
# Pregunta ámbito (usuario/proyecto) y para qué CLIs instalar, y copia el skill
# en el directorio que cada CLI espera.
#
# Uso interactivo:
#   irm .../install.ps1 | iex
#
# Uso no interactivo (variables de entorno):
#   $env:AKV_SCOPE='user'; $env:AKV_AGENTS='claude,cursor,codex,gemini,copilot'; irm .../install.ps1 | iex
#   $env:AKV_SCOPE='project'; $env:AKV_AGENTS='all'; irm .../install.ps1 | iex
$ErrorActionPreference = 'Stop'

$SkillName = 'agentic-knowledge-vault'
$RepoUrl   = 'https://github.com/danielperezmartinez/agentic-knowledge-vault.git'

# --- Ámbito -----------------------------------------------------------------
$Scope = $env:AKV_SCOPE
if (-not $Scope) {
  Write-Host ""
  Write-Host "Ámbito de instalación:"
  Write-Host "  1) Usuario (global, todos tus proyectos)"
  Write-Host "  2) Proyecto (este repositorio)"
  $ans = Read-Host "Elige [1]"
  $Scope = if ($ans -in @('2', 'project', 'proyecto')) { 'project' } else { 'user' }
}
if ($Scope -notin @('user', 'project')) { $Scope = 'user' }

# --- Mapa de agentes --------------------------------------------------------
$Agents = [ordered]@{
  claude  = @{ label = 'Claude Code';    user = "$HOME/.claude/skills";  project = ".claude/skills" }
  cursor  = @{ label = 'Cursor';         user = "$HOME/.cursor/skills";  project = ".cursor/skills" }
  codex   = @{ label = 'Codex';          user = "$HOME/.agents/skills";  project = ".agents/skills" }
  gemini  = @{ label = 'Gemini CLI';     user = "$HOME/.gemini/skills";  project = ".gemini/skills" }
  copilot = @{ label = 'GitHub Copilot'; user = "$HOME/.copilot/skills"; project = ".github/skills" }
}
$Order = @('claude', 'cursor', 'codex', 'gemini', 'copilot')

# --- Selección de CLIs ------------------------------------------------------
$AgentsArg = $env:AKV_AGENTS
if (-not $AgentsArg) {
  Write-Host ""
  Write-Host "¿Para qué CLIs quieres instalar el skill?"
  for ($i = 0; $i -lt $Order.Count; $i++) {
    Write-Host ("  {0}) {1}" -f ($i + 1), $Agents[$Order[$i]].label)
  }
  Write-Host "Varios separados por coma (p. ej. 1,3) o 'a' para todos."
  $AgentsArg = Read-Host "Elige [a]"
  if (-not $AgentsArg) { $AgentsArg = 'a' }
}

$selected = New-Object System.Collections.Generic.List[string]
if ($AgentsArg -in @('a', 'all', 'todos', '*')) {
  $Order | ForEach-Object { $selected.Add($_) }
} else {
  foreach ($tok in ($AgentsArg -split ',')) {
    switch ($tok.Trim().ToLower()) {
      { $_ -in @('1', 'claude', 'claude-code') } { $selected.Add('claude'); break }
      { $_ -in @('2', 'cursor') }                { $selected.Add('cursor'); break }
      { $_ -in @('3', 'codex') }                 { $selected.Add('codex'); break }
      { $_ -in @('4', 'gemini') }                { $selected.Add('gemini'); break }
      { $_ -in @('5', 'copilot') }               { $selected.Add('copilot'); break }
      '' { }
      default { Write-Warning "CLI no reconocido '$tok', se ignora." }
    }
  }
}
# Conserva el orden de $Order y elimina duplicados.
$selected = $Order | Where-Object { $selected -contains $_ }
if (-not $selected) { Write-Error "No se seleccionó ningún CLI. Nada que hacer."; return }

# --- Método: symlink o copia ------------------------------------------------
$Method = $env:AKV_METHOD
if (-not $Method) {
  Write-Host ""
  Write-Host "Método de instalación:"
  Write-Host "  1) Symlink (recomendado): una copia canónica y el resto enlazado;"
  Write-Host "     actualizar una actualiza todas."
  Write-Host "  2) Copia: una copia independiente por CLI."
  $ans = Read-Host "Elige [1]"
  $Method = if ($ans -in @('2', 'copy', 'copia')) { 'copy' } else { 'symlink' }
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
    # El primer CLI es la copia canónica; los demás se enlazan a ella.
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
