@echo off
title Push DevOps Project to GitHub
cd /d "D:\ASSIGNMENTS\DEVOPS\DEVOPS PROJECT"
echo ============================================================
echo        PUSH SECURITY LOG REVIEW SYSTEM TO GITHUB
echo ============================================================
echo.
echo All 14 tasks, source code, Dockerfile, Ansible, and slides 
echo have already been committed to your local Git repository!
echo.
set /p REPO_URL="Paste your GitHub Repository URL and press ENTER: "
if "%REPO_URL%"=="" (
    echo [ERROR] No GitHub URL provided. Please run again and paste your URL.
    pause
    exit /b
)

echo.
echo [*] Configuring GitHub remote...
tools\git\cmd\git.exe remote remove origin 2>nul
tools\git\cmd\git.exe remote add origin %REPO_URL%

echo.
echo [*] Pushing 'main' branch (all folders, code, tests, docs)...
tools\git\cmd\git.exe push -u origin main

echo.
echo [*] Pushing 'dev' branch...
tools\git\cmd\git.exe push -u origin dev

echo.
echo ============================================================
echo  SUCCESS! Open your GitHub repository to see all files & folders.
echo ============================================================
pause
