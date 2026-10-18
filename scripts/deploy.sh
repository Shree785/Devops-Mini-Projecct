#!/usr/bin/env bash
# Shell Deployment & Health Verification Script for Security Log Review System
set -e

APP_ENV=${1:-"production"}
DEPLOY_PORT=${2:-"8080"}
JAR_PATH=${3:-"target/security-log-review-1.0.0.jar"}

echo "=========================================================="
echo " [DEPLOYMENT] Environment: $APP_ENV"
echo " [DEPLOYMENT] Port:        $DEPLOY_PORT"
echo " [DEPLOYMENT] Artifact:    $JAR_PATH"
echo "=========================================================="

if [ ! -f "$JAR_PATH" ]; then
    echo "ERROR: Artifact $JAR_PATH not found!"
    exit 1
fi

echo "[DEPLOYMENT] Starting background application process..."
java -Dserver.port="$DEPLOY_PORT" -jar "$JAR_PATH" > app.log 2>&1 &
APP_PID=$!
echo "[DEPLOYMENT] Process spawned with PID: $APP_PID"

echo "[HEALTH-CHECK] Polling http://localhost:$DEPLOY_PORT/actuator/health..."
MAX_RETRIES=20
COUNT=0
HEALTHY=false

while [ $COUNT -lt $MAX_RETRIES ]; do
    sleep 2
    COUNT=$((COUNT + 1))
    if curl -s -f "http://localhost:$DEPLOY_PORT/actuator/health" | grep -q '"status":"UP"'; then
        echo "[HEALTH-CHECK] Health check PASSED: UP (Attempt $COUNT)"
        HEALTHY=true
        break
    else
        echo "[HEALTH-CHECK] Waiting for startup... ($COUNT/$MAX_RETRIES)"
    fi
done

if [ "$HEALTHY" = false ]; then
    echo "ERROR: Health probe failed!"
    kill -9 $APP_PID 2>/dev/null || true
    exit 1
fi

echo "=========================================================="
echo " [SUCCESS] Application is LIVE on port $DEPLOY_PORT"
echo "=========================================================="
kill -9 $APP_PID 2>/dev/null || true
