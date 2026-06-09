$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot
$TomcatDir = Join-Path $ProjectRoot "server\tomcat"
$JavaHome = "C:\Program Files\Java\jdk-21.0.10"
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
                    Write-Host "Stopping Tomcat PID $procId on port $port..."
                    Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
                }
            } catch {}
        }
    }
    Start-Sleep -Seconds 2
}

& (Join-Path $ProjectRoot "build-app.ps1")
Stop-OurTomcat

Write-Host ""
Write-Host "Starting Tomcat on http://localhost:$TomcatPort/ipl/"
Write-Host "Login credentials: admin / admin123"
Write-Host ""

$env:JAVA_HOME = $JavaHome
$env:CATALINA_HOME = $TomcatDir
& (Join-Path $TomcatDir "bin\catalina.bat") run
