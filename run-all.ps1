$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot
$JavaHome = "C:\Program Files\Java\jdk-21.0.10"
$MysqlJar = Join-Path $ProjectRoot "server\webapp\WEB-INF\lib\mysql-connector-j.jar"
$TomcatDir = Join-Path $ProjectRoot "server\tomcat"
$TomcatPort = 8081
$ShutdownPort = 8006

function Stop-OurTomcat {
    foreach ($port in @($TomcatPort, $ShutdownPort)) {
        $matches = netstat -ano | Select-String ":$port\s" | Select-String "LISTENING"
        foreach ($line in $matches) {
            $procId = [int](($line -split '\s+')[-1])
            try {
                $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId=$procId").CommandLine
                if ($cmd -like "*$TomcatDir*") {
                    Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
                }
            } catch {}
        }
    }
    Start-Sleep -Seconds 2
}

Write-Host "=== Step 1: Build application ==="
& (Join-Path $ProjectRoot "build-app.ps1")

Write-Host ""
Write-Host "=== Step 2: Run Main.java ==="
$OutDir = Join-Path $ProjectRoot "out"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
& "$JavaHome\bin\javac" -encoding UTF-8 -cp $MysqlJar (Join-Path $ProjectRoot "src\Main.java") -d $OutDir
if ($LASTEXITCODE -ne 0) { throw "Main.java compilation failed" }
& "$JavaHome\bin\java" -cp "$MysqlJar;$OutDir" Main

Write-Host ""
Write-Host "=== Step 3: Start Tomcat server ==="
Stop-OurTomcat

$env:JAVA_HOME = $JavaHome
$env:CATALINA_HOME = $TomcatDir
Start-Process -FilePath (Join-Path $TomcatDir "bin\catalina.bat") -ArgumentList "run" -WorkingDirectory (Join-Path $TomcatDir "bin") -WindowStyle Hidden

$ready = $false
for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep -Seconds 1
    try {
        $resp = Invoke-WebRequest -Uri "http://localhost:$TomcatPort/ipl/login.jsp" -UseBasicParsing -TimeoutSec 3
        if ($resp.StatusCode -eq 200) { $ready = $true; break }
    } catch {}
}

Write-Host ""
if ($ready) {
    Write-Host "All services running successfully."
    Write-Host "Open: http://localhost:$TomcatPort/ipl/"
    Write-Host "Login: admin / admin123"
} else {
    throw "Tomcat did not start correctly on port $TomcatPort"
}
