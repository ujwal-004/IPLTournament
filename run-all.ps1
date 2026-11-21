$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot
& (Join-Path $ProjectRoot "build-app.ps1")
& (Join-Path $ProjectRoot "run-server.ps1")
