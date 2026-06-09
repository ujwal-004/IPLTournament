$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot
$ServerDir = Join-Path $ProjectRoot "server"
$TomcatDir = Join-Path $ServerDir "tomcat"
$WebappDir = Join-Path $ServerDir "webapp"
$LibDir = Join-Path $WebappDir "WEB-INF\lib"
$ClassesDir = Join-Path $WebappDir "WEB-INF\classes"
$SrcDir = Join-Path $ProjectRoot "src"
$JavaHome = "C:\Program Files\Java\jdk-21.0.10"
$TomcatPort = 8081
$ShutdownPort = 8006

function Ensure-Directory($path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

Ensure-Directory $ServerDir
Ensure-Directory $LibDir
Ensure-Directory $ClassesDir
Ensure-Directory (Join-Path $WebappDir "css")
Ensure-Directory (Join-Path $WebappDir "js")

$MysqlJar = Join-Path $LibDir "mysql-connector-j.jar"
if (-not (Test-Path $MysqlJar)) {
    Write-Host "Downloading MySQL connector..."
    Invoke-WebRequest -Uri "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar" -OutFile $MysqlJar
}

if (-not (Test-Path (Join-Path $TomcatDir "bin\catalina.bat"))) {
    Write-Host "Downloading Apache Tomcat 9..."
    $TomcatZip = Join-Path $ServerDir "tomcat.zip"
    Invoke-WebRequest -Uri "https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.98/bin/apache-tomcat-9.0.98.zip" -OutFile $TomcatZip
    Expand-Archive -Path $TomcatZip -DestinationPath $ServerDir -Force
    Rename-Item -Path (Join-Path $ServerDir "apache-tomcat-9.0.98") -NewName "tomcat" -Force
    Remove-Item $TomcatZip -Force
}

$ServerXml = Join-Path $TomcatDir "conf\server.xml"
$xml = Get-Content $ServerXml -Raw
$xml = $xml -replace '<Server port="\d+" shutdown="SHUTDOWN">', "<Server port=`"$ShutdownPort`" shutdown=`"SHUTDOWN`">"
$xml = $xml -replace '<Connector port="\d+" protocol="HTTP/1.1"', "<Connector port=`"$TomcatPort`" protocol=`"HTTP/1.1`""
Set-Content $ServerXml $xml -NoNewline

Write-Host "Building web application..."
Copy-Item (Join-Path $SrcDir "web.xml") (Join-Path $WebappDir "WEB-INF\web.xml") -Force
Copy-Item (Join-Path $SrcDir "*.jsp") $WebappDir -Force
Copy-Item (Join-Path $SrcDir "css\style.css") (Join-Path $WebappDir "css\style.css") -Force
Copy-Item (Join-Path $SrcDir "js\validation.js") (Join-Path $WebappDir "js\validation.js") -Force

$ServletApi = Join-Path $TomcatDir "lib\servlet-api.jar"
$JspApi = Join-Path $TomcatDir "lib\jsp-api.jar"
$Classpath = "$ServletApi;$JspApi;$MysqlJar"

$JavaFiles = @(
    (Join-Path $SrcDir "dao\DBConnection.java"),
    (Join-Path $SrcDir "dao\LoginDAO.java"),
    (Join-Path $SrcDir "dao\TeamDAO.java"),
    (Join-Path $SrcDir "dao\MatchDAO.java"),
    (Join-Path $SrcDir "dao\PlayerDAO.java"),
    (Join-Path $SrcDir "model\Team.java"),
    (Join-Path $SrcDir "model\Player.java"),
    (Join-Path $SrcDir "model\Match.java"),
    (Join-Path $SrcDir "controller\LoginServlet.java"),
    (Join-Path $SrcDir "controller\TeamServlet.java"),
    (Join-Path $SrcDir "controller\PlayerServlet.java"),
    (Join-Path $SrcDir "controller\MatchServlet.java")
)

& "$JavaHome\bin\javac" -encoding UTF-8 -cp $Classpath -d $ClassesDir $JavaFiles
if ($LASTEXITCODE -ne 0) { throw "Compilation failed" }

$DeployDir = Join-Path $TomcatDir "webapps\ipl"
if (Test-Path $DeployDir) {
    Remove-Item $DeployDir -Recurse -Force
}
Copy-Item $WebappDir $DeployDir -Recurse -Force
Write-Host "Build complete."
