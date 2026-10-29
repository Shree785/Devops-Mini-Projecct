@echo off
title Stop Security Log Review System
echo Stopping any running Security Log Review System processes...
powershell -Command "Get-Process java -ErrorAction SilentlyContinue | Stop-Process -Force"
docker stop security-log-review 2>nul
docker rm security-log-review 2>nul
echo Done! Application stopped.
timeout /t 3 >nul
