#!/usr/bin/env pwsh
# Instala o actualiza el skill agentic-knowledge-vault.
#
# Uso:
#   irm .../install.ps1 | iex                        # personal: ~/.claude/skills
#   $env:AKV_DEST=".claude/skills"; irm .../install.ps1 | iex   # proyecto
$ErrorActionPreference = 'Stop'

$RepoUrl   = 'https://github.com/danielperezmartinez/agentic-knowledge-vault.git'
$SkillName = 'agentic-knowledge-vault'

$Base = if ($env:AKV_DEST) { $env:AKV_DEST } else { Join-Path $HOME '.claude/skills' }
$Dest = Join-Path $Base $SkillName
New-Item -ItemType Directory -Force -Path $Base | Out-Null

if (Test-Path (Join-Path $Dest '.git')) {
  Write-Host "Actualizando skill en $Dest"
  git -C $Dest pull --ff-only
} else {
  Write-Host "Instalando skill en $Dest"
  git clone --depth 1 $RepoUrl $Dest
}

Write-Host "Listo. Invócala con /$SkillName en Claude Code."
