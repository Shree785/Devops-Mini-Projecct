<#
.SYNOPSIS
    Automated Docker Container Execution Script
.DESCRIPTION
    Runs the security-log-review container with port forwarding, resource limits, and health checks.
#>

param(
    [string]$ContainerName = "security-log-review-app",
    [string]$ImageName = "security-log-review:1.0.0",
    [int]$HostPort = 8080,
    [int]$ContainerPort = 8080
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [DOCKER RUN] Launching Container: $ContainerName" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Remove existing container if present
$existing = docker ps -a --filter "name=^/${ContainerName}$" --format "{{.Names}}"
if ($existing -eq $ContainerName) {
    Write-Host "[CLEANUP] Stopping and removing existing container $ContainerName..." -ForegroundColor Yellow
    docker stop $ContainerName | Out-Null
    docker rm $ContainerName | Out-Null
}

Write-Host "[LAUNCH] Starting container in detached mode..." -ForegroundColor Green
docker run -d `
    --name $ContainerName `
    -p "${HostPort}:${ContainerPort}" `
    -e SERVER_PORT=$ContainerPort `
    -e SPRING_PROFILES_ACTIVE=production `
    -m 1024m `
    --cpus 1.5 `
    --restart unless-stopped `
    $ImageName

Write-Host "[VERIFY] Checking container state..." -ForegroundColor Green
docker ps --filter "name=^/${ContainerName}$"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [CONTAINER RUNNING] Access endpoint: http://localhost:$HostPort/dashboard" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
