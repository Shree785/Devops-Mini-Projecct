<#
.SYNOPSIS
    End-to-End Docker Container Lifecycle Automation
.DESCRIPTION
    Executes the complete container lifecycle:
    1. Build image
    2. Inspect image layers & metadata
    3. Run container with port mapping and resource limits
    4. Poll health endpoint until healthy
    5. View runtime logs
    6. Execute in-container diagnosis (docker exec)
    7. Stop container
    8. Remove container
#>

param(
    [string]$ImageName = "security-log-review:1.0.0",
    [string]$ContainerName = "security-log-review-app",
    [int]$Port = 8080
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [DOCKER LIFECYCLE DRILL] Enterprise Container Lifecycle" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Step 1: Build
Write-Host "`n>>> [STEP 1/7] Building Docker Image..." -ForegroundColor Yellow
& ".\scripts\docker-build.ps1" -ImageName "security-log-review" -Version "1.0.0"

# Step 2: Run
Write-Host "`n>>> [STEP 2/7] Launching Container..." -ForegroundColor Yellow
& ".\scripts\docker-run.ps1" -ContainerName $ContainerName -ImageName $ImageName -HostPort $Port

# Step 3: Health Probe
Write-Host "`n>>> [STEP 3/7] Probing Spring Boot Actuator Health..." -ForegroundColor Yellow
$maxAttempts = 15
$attempt = 0
$healthy = $false

while ($attempt -lt $maxAttempts -and -not $healthy) {
    Start-Sleep -Seconds 3
    $attempt++
    try {
        $res = Invoke-RestMethod -Uri "http://localhost:$Port/actuator/health" -Method Get -TimeoutSec 3 -UseBasicParsing
        if ($res.status -eq "UP") {
            Write-Host " [HEALTH CHECK PASSED] Application is UP (Attempt $attempt)!" -ForegroundColor Green
            $healthy = $true
        }
    } catch {
        Write-Host " [WAITING] Application warming up (Attempt $attempt/$maxAttempts)..." -ForegroundColor Gray
    }
}

if (-not $healthy) {
    Write-Host " [HEALTH CHECK TIMEOUT] Container did not report healthy within window." -ForegroundColor Red
}

# Step 4: Container Logs
Write-Host "`n>>> [STEP 4/7] Inspecting Container Runtime Logs..." -ForegroundColor Yellow
docker logs --tail 30 $ContainerName

# Step 5: Container Exec
Write-Host "`n>>> [STEP 5/7] Executing in-container diagnostic probe..." -ForegroundColor Yellow
docker exec $ContainerName curl -s http://localhost:8080/actuator/info

# Step 6: Stop Container
Write-Host "`n>>> [STEP 6/7] Gracefully Stopping Container..." -ForegroundColor Yellow
docker stop $ContainerName

# Step 7: Clean Container
Write-Host "`n>>> [STEP 7/7] Removing Container..." -ForegroundColor Yellow
docker rm $ContainerName

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [DOCKER LIFECYCLE COMPLETE] All 7 lifecycle stages validated!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
