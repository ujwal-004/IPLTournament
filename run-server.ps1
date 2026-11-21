$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot
$TomcatHome = $env:CATALINA_HOME

if (-not $TomcatHome -or -not (Test-Path (Join-Path $TomcatHome "bin\catalina.bat"))) {
    throw "Set CATALINA_HOME to an Apache Tomcat 9 installation before running this script."
}
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    throw "Java is not available on PATH. Install JDK 17+ and try again."
}

& (Join-Path $ProjectRoot "build-app.ps1")
$War = Join-Path $ProjectRoot "target\ipl-tournament.war"
$DeployWar = Join-Path $TomcatHome "webapps\ipl-tournament.war"
Copy-Item $War $DeployWar -Force

Write-Host "Starting IPL Tournament Manager at http://localhost:8080/ipl-tournament/login.jsp" -ForegroundColor Green
& (Join-Path $TomcatHome "bin\catalina.bat") run
