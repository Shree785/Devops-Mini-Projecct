#!/usr/bin/env bash
# ==============================================================================
# Automated Docker Continuous Deployment Script (POSIX/Linux/WSL)
# ==============================================================================
set -euo pipefail

IMAGE_NAME="${1:-security-log-review}"
TAG="${2:-1.0.0}"
CONTAINER_NAME="${3:-security-log-review-app}"
HOST_PORT="${4:-8080}"
APP_ENV="${5:-production}"
MAX_MEMORY="${6:-1024m}"
CPU_LIMIT="${7:-1.5}"

FULL_IMAGE="${IMAGE_NAME}:${TAG}"

echo "=========================================================="
echo " [DOCKER CD PIPELINE] Deploying Image: ${FULL_IMAGE}"
echo " Container Name   : ${CONTAINER_NAME}"
echo " Port Mapping     : Host ${HOST_PORT} -> Container 8080"
echo " Target Env       : ${APP_ENV}"
echo " Resource Limits  : Memory ${MAX_MEMORY} | CPUs ${CPU_LIMIT}"
echo "=========================================================="

# Check existing container
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
    echo "[DRAIN & STOP] Gracefully stopping retired container ${CONTAINER_NAME}..."
    docker stop -t 15 "${CONTAINER_NAME}" || true
    docker rm "${CONTAINER_NAME}" || true
fi

# Launch new container
echo "[DEPLOY] Starting new container instance..."
CONTAINER_ID=$(docker run -d \
    --name "${CONTAINER_NAME}" \
    -p "${HOST_PORT}:8080" \
    -e SERVER_PORT=8080 \
    -e SPRING_PROFILES_ACTIVE="${APP_ENV}" \
    -m "${MAX_MEMORY}" \
    --cpus "${CPU_LIMIT}" \
    --restart unless-stopped \
    "${FULL_IMAGE}")

echo " [CONTAINER INITIALIZED] Instance ID: ${CONTAINER_ID}"

# Health Probe Loop
echo "[HEALTH PROBE] Waiting for Spring Boot Actuator health probe..."
HEALTH_URL="http://localhost:${HOST_PORT}/actuator/health"
DASH_URL="http://localhost:${HOST_PORT}/dashboard"

MAX_ATTEMPTS=20
ATTEMPT=0
HEALTHY=false

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    sleep 3
    ATTEMPT=$((ATTEMPT + 1))
    STATUS=$(curl -s "${HEALTH_URL}" | grep -o '"status":"UP"' || true)
    if [ -n "${STATUS}" ]; then
        echo " [HEALTHCHECK PASS] Application is UP (Attempt ${ATTEMPT}/${MAX_ATTEMPTS})!"
        HEALTHY=true
        break
    else
        echo " [WAITING] Warming up (Attempt ${ATTEMPT}/${MAX_ATTEMPTS})..."
    fi
done

if [ "$HEALTHY" = false ]; then
    echo "=========================================================="
    echo " [DEPLOYMENT FAILURE] Application failed health probe!"
    docker logs --tail 30 "${CONTAINER_NAME}"
    echo "=========================================================="
    exit 1
fi

DASH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${DASH_URL}")
if [ "${DASH_STATUS}" = "200" ]; then
    echo " [DASHBOARD PASS] SOC Dashboard returned HTTP 200 OK!"
fi

echo "=========================================================="
echo " [DOCKER CD DEPLOYMENT SUCCESS]"
echo " Container   : ${CONTAINER_NAME}"
echo " Image       : ${FULL_IMAGE}"
echo " Dashboard   : ${DASH_URL}"
echo " Stream URL  : http://localhost:${HOST_PORT}/logs"
echo " Health URL  : ${HEALTH_URL}"
echo "=========================================================="
