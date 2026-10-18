@echo off
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "PATH=%~dp0tools\apache-maven-3.9.9\bin;%JAVA_HOME%\bin;%PATH%"
"%~dp0tools\apache-maven-3.9.9\bin\mvn.cmd" -Dmaven.repo.local="%~dp0.m2\repository" %*
