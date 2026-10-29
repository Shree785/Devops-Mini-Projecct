@echo off
title Security Log Review System (Docker)
cd /d "%~dp0"
echo ==========================================================
echo  Deploying Container via Docker (Continuous Deployment)
echo ==========================================================
echo.
powershell -ExecutionPolicy Bypass -File scripts\deploy-docker.ps1
echo.
echo Opening browser...
start "" "http://localhost:8080/dashboard"
echo.
echo Done! Container is running in background.
echo To stop container later, run STOP_DOCKER.bat
pause
