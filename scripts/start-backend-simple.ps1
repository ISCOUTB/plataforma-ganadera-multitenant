# Script simple para iniciar Backend NestJS en Windows

$rootDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$backendDir = Join-Path $rootDir "Backend"
$logFile = Join-Path $rootDir ".run" "backend.log"

# Crear directorio de logs si no existe
$runDir = Join-Path $rootDir ".run"
if (-not (Test-Path $runDir)) {
    New-Item -ItemType Directory -Path $runDir -Force | Out-Null
}

# Detener procesos node previos
Write-Host "Deteniendo procesos Node previos..."
Get-Process | Where-Object { $_.ProcessName -eq "node" } | Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2

# Ir al directorio Backend
Set-Location $backendDir

Write-Host "Iniciando Backend NestJS..."
Write-Host "Logs: $logFile"
Write-Host ""

# Iniciar npm run start:dev
& npm run start:dev 2>&1 | Tee-Object -FilePath $logFile
