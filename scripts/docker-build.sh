#!/usr/bin/env bash
# ==============================================================================
# Automated Docker Build Script (POSIX/Linux/WSL)
# ==============================================================================
set -euo pipefail

IMAGE_NAME="${1:-security-log-review}"
VERSION="${2:-1.0.0}"

echo "=========================================================="
echo " [DOCKER BUILD] Building Container: ${IMAGE_NAME}:${VERSION}"
echo "=========================================================="

if [ ! -f "target/security-log-review-1.0.0.jar" ]; then
    echo "[PRE-BUILD] Compiling JAR..."
    mvn -B package -DskipTests
fi

docker build -t "${IMAGE_NAME}:${VERSION}" -t "${IMAGE_NAME}:latest" -f Dockerfile .
docker images "${IMAGE_NAME}:${VERSION}"

echo "=========================================================="
echo " [DOCKER BUILD SUCCESS] ${IMAGE_NAME}:${VERSION} created"
echo "=========================================================="
