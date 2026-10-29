@echo off
title Start Project and Jenkins Pipeline
cd /d "%~dp0"
echo ==========================================================
echo  Starting Security Log Review System and Jenkins Pipeline
echo ==========================================================
echo.

:: 1. Open Docker Desktop
docker ps >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [1/3] Starting Docker Desktop...
    start "" "C:\Users\ardes\AppData\Local\Programs\DockerDesktop\Docker Desktop.exe"
    echo Waiting for Docker engine to initialize...
    powershell -Command "Start-Sleep -Seconds 15"
)

:: 2. Start both containers in Docker
echo [2/3] Starting containers (security-log-review-app and jenkins-server)...
docker start security-log-review-app jenkins-server >nul 2>&1

:: If Docker not ready yet, fallback to standalone Java
docker ps 2>nul | findstr "security-log-review-app" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Starting standalone Java application on port 8080...
    start "Security-Log-Review-App" "C:\Program Files\Java\jdk-17\bin\java.exe" -jar "target\security-log-review-1.0.0.jar"
    powershell -Command "Start-Sleep -Seconds 8"
)

:: 3. Open both browser tabs
echo [3/3] Opening browser tabs...
start "" "http://localhost:8080/dashboard"
start "" "http://localhost:8081/job/Security-Log-Review-Pipeline/"

echo.
echo ==========================================================
echo  DONE! Both tabs opened:
echo   - Tab 1 (App):     http://localhost:8080/dashboard
echo   - Tab 2 (Jenkins): http://localhost:8081/job/Security-Log-Review-Pipeline/
echo ==========================================================
powershell -Command "Start-Sleep -Seconds 3"
