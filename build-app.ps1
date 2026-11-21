$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot

if (-not (Get-Command mvn -ErrorAction SilentlyContinue)) {
    throw "Maven is not available on PATH. Install Maven 3.9+ and try again."
}
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    throw "Java is not available on PATH. Install JDK 17+ and try again."
}

Push-Location $ProjectRoot
try {
    mvn clean package
    if ($LASTEXITCODE -ne 0) {
        throw "Maven build failed."
    }
    Write-Host "Build successful: target\ipl-tournament.war" -ForegroundColor Green
}
finally {
    Pop-Location
}
