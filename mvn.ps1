$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$PSScriptRoot\tools\apache-maven-3.9.9\bin;" + "$env:JAVA_HOME\bin;" + $env:PATH
& "$PSScriptRoot\tools\apache-maven-3.9.9\bin\mvn.cmd" "-Dmaven.repo.local=$PSScriptRoot\.m2\repository" @args
