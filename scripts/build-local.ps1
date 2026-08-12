[CmdletBinding()]
param(
    [string]$Python,
    [switch]$SkipInstall,
    [switch]$Serve,
    [int]$Port = 8000
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$VenvPython = Join-Path $Root '.venv\Scripts\python.exe'

function Invoke-Checked {
    param([string]$Executable, [string[]]$Arguments)
    & $Executable @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $Executable $Arguments"
    }
}

if (-not (Test-Path $VenvPython)) {
    if (-not $Python) {
        $Python = 'python'
    }
    Write-Host "Creating .venv with $Python"
    Invoke-Checked $Python @('-m', 'venv', (Join-Path $Root '.venv'))
}

if (-not $SkipInstall) {
    Write-Host 'Installing build dependencies'
    Invoke-Checked $VenvPython @('-m', 'pip', 'install', '--upgrade', 'pip')
    Invoke-Checked $VenvPython @('-m', 'pip', 'install', '-r', (Join-Path $Root 'requirements.txt'))
}

Invoke-Checked $VenvPython @((Join-Path $PSScriptRoot 'build_site.py'))

if ($Serve) {
    $Url = "http://127.0.0.1:$Port/lab/"
    Write-Host ''
    Write-Host 'JupyterLite is ready.' -ForegroundColor Green
    Write-Host "Open: $Url" -ForegroundColor Cyan
    Write-Host 'Keep this window open. Press Ctrl+C here to stop the server.'
    Invoke-Checked $VenvPython @('-m', 'jupyter', 'lite', 'serve', '--config', (Join-Path $Root 'jupyter_lite_config.json'), '--output-dir', (Join-Path $Root 'dist'), '--port', $Port)
}
