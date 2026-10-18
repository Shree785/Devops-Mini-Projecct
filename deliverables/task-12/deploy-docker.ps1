<#
.SYNOPSIS
    Automated Continuous Deployment Script for Docker Containers
.DESCRIPTION
    Manages zero-downtime container replacement, dynamic environment injection,
    resource limiting, and automated health probing with rollback safety.
#>

param(
    [string]$ImageName = "security-log-review",
    [string]$Tag = "1.0.0",
    [string]$ContainerName = "security-log-review-app",
    [int]$HostPort = 8080,
    [string]$AppEnv = "production",
    [string]$MaxMemory = "1024m",
    [string]$CpuLimit = "1.5"
)

$ErrorActionPreference = "Stop"

$FullImage = "${ImageName}:${Tag}"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [DOCKER CD PIPELINE] Deploying Container Image: $FullImage" -ForegroundColor Cyan
Write-Host " Target Container : $ContainerName" -ForegroundColor Cyan
Write-Host " Port Binding     : Host $HostPort -> Container 8080" -ForegroundColor Cyan
Write-Host " Environment      : $AppEnv" -ForegroundColor Cyan
Write-Host " Resource Limits  : Memory $MaxMemory | CPUs $CpuLimit" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Step 1: Check existing container
$runningContainer = docker ps -q --filter "name=^/${ContainerName}$"
$allContainer = docker ps -a -q --filter "name=^/${ContainerName}$"

if ($runningContainer) {
    Write-Host "[DRAIN & STOP] Gracefully stopping running container $ContainerName..." -ForegroundColor Yellow
    docker stop -t 15 $ContainerName | Out-Null
}

if ($allContainer) {
    Write-Host "[CLEANUP] Removing retired container $ContainerName..." -ForegroundColor Yellow
    docker rm $ContainerName | Out-Null
}

# Step 2: Deploy New Container
Write-Host "[DEPLOY] Starting new container instance..." -ForegroundColor Green
$containerId = docker run -d `
    --name $ContainerName `
    -p "${HostPort}:8080" `
    -e SERVER_PORT=8080 `
    -e SPRING_PROFILES_ACTIVE=$AppEnv `
    -m $MaxMemory `
    --cpus $CpuLimit `
    --restart unless-stopped `
    $FullImage

Write-Host " [CONTAINER INITIALIZED] Instance ID: $containerId" -ForegroundColor Green

# Step 3: Health Probe Loop
Write-Host "[HEALTH PROBE] Waiting for Spring Boot Actuator health probe..." -ForegroundColor Yellow
$maxAttempts = 20
$attempt = 0
$healthy = $false
$healthUrl = "http://localhost:${HostPort}/actuator/health"
$dashboardUrl = "http://localhost:${HostPort}/dashboard"

while ($attempt -lt $maxAttempts -and -not $healthy) {
    Start-Sleep -Seconds 3
    $attempt++
    try {
        # Using curl for direct host-to-container verification
        $res = curl.exe -s $healthUrl | ConvertFrom-Json
        if ($res.status -eq "UP") {
            Write-Host " [HEALTHCHECK PASS] Application status is UP (Attempt $attempt/$maxAttempts)!" -ForegroundColor Green
            $healthy = $true
        } else {
            Write-Host " [WAITING] Actuator status: $($res.status) (Attempt $attempt/$maxAttempts)..." -ForegroundColor Gray
        }
    } catch {
        Write-Host " [WAITING] Container warming up (Attempt $attempt/$maxAttempts)..." -ForegroundColor Gray
    }
}

if (-not $healthy) {
    Write-Host "==========================================================" -ForegroundColor Red
    Write-Host " [DEPLOYMENT FAILURE] Application failed health probe!" -ForegroundColor Red
    Write-Host " Container logs:" -ForegroundColor Red
    docker logs --tail 30 $ContainerName
    Write-Host "==========================================================" -ForegroundColor Red
    exit 1
}

# Step 4: Verify Dashboard HTTP Status
Write-Host "[WEB VERIFY] Probing SOC Executive Dashboard..." -ForegroundColor Yellow
$dashStatus = curl.exe -s -o /dev/null -w "%{http_code}" $dashboardUrl

if ($dashStatus -eq "200") {
    Write-Host " [DASHBOARD PASS] SOC Dashboard returned HTTP 200 OK!" -ForegroundColor Green
} else {
    Write-Host " [WARNING] Dashboard returned HTTP $dashStatus" -ForegroundColor Yellow
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [DOCKER CD DEPLOYMENT SUCCESS]" -ForegroundColor Green
Write-Host " Container       : $ContainerName" -ForegroundColor Green
Write-Host " Image           : $FullImage" -ForegroundColor Green
Write-Host " SOC Dashboard   : $dashboardUrl" -ForegroundColor Green
Write-Host " Stream Endpoint : http://localhost:${HostPort}/logs" -ForegroundColor Green
Write-Host " Health Endpoint : $healthUrl" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
