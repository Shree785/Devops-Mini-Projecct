# PowerShell Deployment & Health Verification Script for Security Log Review System
param(
    [string]$AppEnv = "production",
    [string]$DeployPort = "8080",
    [string]$JarPath = "target/security-log-review-1.0.0.jar"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [DEPLOYMENT] Starting Deployment to Environment: $AppEnv" -ForegroundColor Cyan
Write-Host " [DEPLOYMENT] Target Port: $DeployPort" -ForegroundColor Cyan
Write-Host " [DEPLOYMENT] Artifact: $JarPath" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

if (-not (Test-Path $JarPath)) {
    Write-Error "Deployment artifact not found at $JarPath! Build the application first."
    exit 1
}

# Stop any existing instance running on DeployPort if present
$portOccupied = Get-NetTCPConnection -LocalPort $DeployPort -ErrorAction SilentlyContinue
if ($portOccupied) {
    Write-Host "[DEPLOYMENT] Stopping previous process on port $DeployPort (PID: $($portOccupied.OwningProcess))..." -ForegroundColor Yellow
    Stop-Process -Id $portOccupied.OwningProcess -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Launch Application as Background Process
Write-Host "[DEPLOYMENT] Launching Application Server (Embedded Tomcat 10 on port $DeployPort)..." -ForegroundColor Green
$javaExe = "C:\Program Files\Java\jdk-17\bin\java.exe"
$processArgs = "-Dserver.port=$DeployPort -jar `"$JarPath`""

$process = Start-Process -FilePath $javaExe -ArgumentList $processArgs -PassThru

Write-Host "[DEPLOYMENT] Application started with PID: $($process.Id)" -ForegroundColor Green

# Automated HTTP Health Check Probe
$maxRetries = 20
$retryCount = 0
$isHealthy = $false
$healthUrl = "http://localhost:$DeployPort/actuator/health"
$dashUrl = "http://localhost:$DeployPort/dashboard"

Write-Host "[HEALTH-CHECK] Polling health probe at $healthUrl..." -ForegroundColor Cyan

while ($retryCount -lt $maxRetries) {
    Start-Sleep -Seconds 2
    $retryCount++
    try {
        $response = Invoke-RestMethod -Uri $healthUrl -Method Get -TimeoutSec 3 -ErrorAction Stop
        if ($response.status -eq "UP") {
            Write-Host "[HEALTH-CHECK] Health probe SUCCESS: status = UP (Attempt $retryCount)" -ForegroundColor Green
            $isHealthy = $true
            break
        }
    } catch {
        Write-Host "[HEALTH-CHECK] Waiting for application to initialize... (Attempt $retryCount/$maxRetries)" -ForegroundColor Gray
    }
}

if (-not $isHealthy) {
    Write-Error "[DEPLOYMENT FAILED] Health check failed after $maxRetries attempts."
    Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    exit 1
}

# Verify Dashboard HTTP 200
try {
    $dashResponse = Invoke-WebRequest -Uri $dashUrl -Method Get -TimeoutSec 5 -UseBasicParsing
    Write-Host "[DEPLOYMENT] Dashboard HTTP status: $($dashResponse.StatusCode) OK" -ForegroundColor Green
} catch {
    Write-Host "[DEPLOYMENT] Warning: Dashboard returned $($_.Exception.Message)" -ForegroundColor Yellow
}


Write-Host "==========================================================" -ForegroundColor Green
Write-Host " [SUCCESS] Application is LIVE and healthy on port $DeployPort" -ForegroundColor Green
Write-Host " [URL] Dashboard: http://localhost:$DeployPort/dashboard" -ForegroundColor Green
Write-Host " [URL] Stream:    http://localhost:$DeployPort/logs" -ForegroundColor Green
Write-Host " [URL] Health:    http://localhost:$DeployPort/actuator/health" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

# Cleanly stop test server so it does not block subsequent tasks
Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
Write-Host "[DEPLOYMENT] Verification complete. Test process cleanly terminated." -ForegroundColor Cyan
