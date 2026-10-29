@echo off
title Security Log Review System
cd /d "%~dp0"
echo ==========================================================
echo  Starting Security Log Review System (Java 17 Spring Boot)
echo ==========================================================
echo.
echo Application will be available at:
echo   - SOC Dashboard: http://localhost:8080/dashboard
echo   - Log Stream:    http://localhost:8080/logs
echo.
echo Opening browser in 5 seconds...
start "" "http://localhost:8080/dashboard"
echo.
echo Press Ctrl+C in this window to stop the application.
echo ==========================================================
java -jar target\security-log-review-1.0.0.jar
pause
