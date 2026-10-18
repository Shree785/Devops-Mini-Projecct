<#
.SYNOPSIS
    Automated Docker Image Build Script for Security Log Review System
.DESCRIPTION
    Builds the production-hardened multi-stage container image with semantic versioning.
#>

param(
    [string]$ImageName = "security-log-review",
    [string]$Version = "1.0.0"
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [DOCKER BUILD] Building Container Image: $ImageName:$Version" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Ensure target jar exists
if (-not (Test-Path "target\security-log-review-1.0.0.jar")) {
    Write-Host "[PRE-BUILD] Compiling and packaging Spring Boot JAR..." -ForegroundColor Yellow
    & ".\tools\mvn.cmd" -B package -DskipTests
}

Write-Host "[BUILD] Executing docker build with build context..." -ForegroundColor Green
docker build -t "${ImageName}:${Version}" -t "${ImageName}:latest" -f Dockerfile .

Write-Host "[INSPECT] Verifying built image layers..." -ForegroundColor Green
docker images "${ImageName}:${Version}"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [DOCKER BUILD SUCCESS] Image ${ImageName}:${Version} is ready!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
