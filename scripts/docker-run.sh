#!/usr/bin/env bash
# ==============================================================================
# Automated Docker Run Script (POSIX/Linux/WSL)
# ==============================================================================
set -euo pipefail

CONTAINER_NAME="${1:-security-log-review-app}"
IMAGE_NAME="${2:-security-log-review:1.0.0}"
HOST_PORT="${3:-8080}"
CONTAINER_PORT="${4:-8080}"

echo "=========================================================="
echo " [DOCKER RUN] Starting Container: ${CONTAINER_NAME}"
echo "=========================================================="

if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
    echo "[CLEANUP] Stopping and removing existing container ${CONTAINER_NAME}..."
    docker stop "${CONTAINER_NAME}" || true
    docker rm "${CONTAINER_NAME}" || true
fi

docker run -d \
    --name "${CONTAINER_NAME}" \
    -p "${HOST_PORT}:${CONTAINER_PORT}" \
    -e SERVER_PORT="${CONTAINER_PORT}" \
    -e SPRING_PROFILES_ACTIVE=production \
    -m 1024m \
    --cpus 1.5 \
    --restart unless-stopped \
    "${IMAGE_NAME}"

docker ps --filter "name=^/${CONTAINER_NAME}$"

echo "=========================================================="
echo " [CONTAINER RUNNING] Access: http://localhost:${HOST_PORT}/dashboard"
echo "=========================================================="
