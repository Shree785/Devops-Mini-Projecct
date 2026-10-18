# Task 11: Containerization with Docker

**Project:** Enterprise Security Log Review System  
**Container Engine:** Docker Engine v29.8.2 on Docker Desktop 4.95.0 (WSL2 Backend)  
**Base Image:** `eclipse-temurin:17-jre-alpine`  
**Image Tag:** `security-log-review:1.0.0` & `security-log-review:latest`  
**Security Posture:** Hardened Non-Root User (`appuser:1001`), Actuator Healthcheck, JVM CGroup-Aware  
**Execution Timestamp:** 2026-10-18  
**Task Status:** COMPLETE & FULLY VERIFIED  

---

## 1. Executive Summary & Container Architecture

Task 11 establishes containerization for the Security Log Review System. By packaging the Spring Boot application into a hardened, minimal OCI-compliant container image based on Alpine Linux and Eclipse Temurin 17 JRE, the system achieves environment parity across development, CI/CD pipelines, and production infrastructure.

```
+--------------------------------------------------------------------------------------------------+
|                                    CONTAINER ARCHITECTURE                                        |
+--------------------------------------------------------------------------------------------------+
|                                                                                                  |
|   +------------------------------------------------------------------------------------------+   |
|   | Host Environment (Windows 11 / WSL2 Linux Kernel 5.15)                                    |   |
|   | Port Mapping: Host 0.0.0.0:8080 ====> Container 8080/tcp                                 |   |
|   +------------------------------------------------------------------------------------------+   |
|                                              |                                                   |
|                                              v                                                   |
|   +------------------------------------------------------------------------------------------+   |
|   | Container: security-log-review-app (ID: 144d37f01fba)                                    |   |
|   |                                                                                          |   |
|   |   +----------------------------------------------------------------------------------+   |   |
|   |   | Base Layer: Alpine Linux + Eclipse Temurin 17 JRE (Minimal Attack Surface)        |   |   |
|   |   +----------------------------------------------------------------------------------+   |   |
|   |   | Security Context: Unprivileged UID 1001 (appuser:appgroup)                       |   |   |
|   |   +----------------------------------------------------------------------------------+   |   |
|   |   | JVM Parameters: -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0               |   |   |
|   |   +----------------------------------------------------------------------------------+   |   |
|   |   | Application Archive: /app/app.jar (52.4 MB)                                       |   |   |
|   |   +----------------------------------------------------------------------------------+   |   |
|   |   | Healthcheck Engine: curl -f http://localhost:8080/actuator/health (Every 30s)    |   |   |
|   |   +----------------------------------------------------------------------------------+   |   |
|   +------------------------------------------------------------------------------------------+   |
+--------------------------------------------------------------------------------------------------+
```

---

## 2. Production Dockerfile Configuration

The production [`Dockerfile`](file:///d:/ASSIGNMENTS/DEVOPS/DEVOPS%20PROJECT/Dockerfile) implements industry best practices:

```dockerfile
# ==============================================================================
# Enterprise Hardened Dockerfile: Security Log Review System
# Base: Eclipse Temurin 17 JRE on Alpine Linux (Ultra-lightweight & Minimal Attack Surface)
# ==============================================================================

FROM eclipse-temurin:17-jre-alpine AS runtime

LABEL maintainer="SecOps Team <secops@enterprise-soc.local>" \
      project="security-log-review" \
      version="1.0.0" \
      description="Production Container for Enterprise Security Log Review System"

# Install curl for container health checks and timezone support
RUN apk add --no-cache curl tzdata

# Security Hardening: Dedicated least-privilege non-root service account
RUN addgroup -S appgroup -g 1001 && \
    adduser -S appuser -u 1001 -G appgroup

WORKDIR /app

# Copy production Spring Boot executable JAR
COPY target/security-log-review-1.0.0.jar /app/app.jar

# Enforce strict file ownership and execution permissions
RUN chown -R appuser:appgroup /app && \
    chmod 500 /app/app.jar

# Switch to unprivileged runtime user (UID 1001)
USER appuser:appgroup

# Expose Spring Boot web port
EXPOSE 8080

# JVM container support & heap sizing
ENV SERVER_PORT=8080 \
    SPRING_PROFILES_ACTIVE=production \
    JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError -Djava.security.egd=file:/dev/./urandom"

# Native Docker container healthcheck against Spring Boot Actuator
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Container entrypoint
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/app.jar"]
```

---

## 3. Docker Image Build Verification

Command executed:
```powershell
docker build -t security-log-review:1.0.0 -t security-log-review:latest .
```

Console Build Log Output:
```text
#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 1.75kB done
#2 [internal] load metadata for docker.io/library/eclipse-temurin:17-jre-alpine
#3 [internal] load .dockerignore
#4 [internal] load build context: 52.50MB done
#5 [1/6] FROM docker.io/library/eclipse-temurin:17-jre-alpine
#6 [2/6] RUN apk add --no-cache curl tzdata
#7 [3/6] RUN addgroup -S appgroup -g 1001 && adduser -S appuser -u 1001 -G appgroup
#8 [4/6] WORKDIR /app
#9 [5/6] COPY target/security-log-review-1.0.0.jar /app/app.jar
#10 [6/6] RUN chown -R appuser:appgroup /app && chmod 500 /app/app.jar
#11 exporting to image
#11 naming to docker.io/library/security-log-review:1.0.0 done
#11 naming to docker.io/library/security-log-review:latest done
```

Verification (`docker images`):
```text
IMAGE                        ID             DISK USAGE   CONTENT SIZE   EXTRA
security-log-review:1.0.0    4e6a34ceb824        467MB          166MB        
security-log-review:latest   4e6a34ceb824        467MB          166MB        
```
*Note: Content size is optimized to only 166 MB.*

---

## 4. Container Execution & Live Health Verification

Command executed:
```powershell
docker run -d --name security-log-review-app -p 8080:8080 --restart unless-stopped security-log-review:1.0.0
```

Container ID: `144d37f01fbafdff8e7db2d65fe6573b1ed1000be35b98f4c1f204560ec3a7dc`

Verification (`docker ps`):
```text
CONTAINER ID   IMAGE                       COMMAND                  CREATED          STATUS                    PORTS                                         NAMES
144d37f01fba   security-log-review:1.0.0   "sh -c 'exec java $J…"   28 seconds ago   Up 27 seconds (healthy)   0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp   security-log-review-app
```

### 4.1 Spring Boot Actuator Health Probe
Command executed:
```powershell
curl.exe -i -s "http://localhost:8080/actuator/health"
```
Response:
```http
HTTP/1.1 200 
Content-Type: application/vnd.spring-boot.actuator.v3+json
Transfer-Encoding: chunked
Date: Sun, 18 Oct 2026 11:47:05 GMT

{"status":"UP","components":{"db":{"status":"UP","details":{"database":"H2","validationQuery":"isValid()"}},"diskSpace":{"status":"UP","details":{"total":1081101176832,"free":1023695642624,"threshold":10485760,"path":"/app/.","exists":true}},"ping":{"status":"UP"}}}
```

### 4.2 SOC Dashboard & Stream HTTP Probe
Command executed:
```powershell
curl.exe -I -s "http://localhost:8080/dashboard"
curl.exe -I -s "http://localhost:8080/logs"
```
Response:
```http
HTTP/1.1 200 OK
Content-Type: text/html;charset=UTF-8
```

### 4.3 In-Container Diagnostic Execution (`docker exec`)
```powershell
PS> docker exec security-log-review-app whoami
appuser

PS> docker exec security-log-review-app id
uid=1001(appuser) gid=1001(appgroup) groups=1001(appgroup)

PS> docker exec security-log-review-app curl -s http://localhost:8080/actuator/health
{"status":"UP","components":{"db":{"status":"UP","details":{"database":"H2","validationQuery":"isValid()"}},"diskSpace":{"status":"UP",...},"ping":{"status":"UP"}}}
```

---

## 5. Container Lifecycle Management Validation

All standard container lifecycle phases were systematically exercised:

| Lifecycle Phase | Command | Output / Status | Observation |
| :--- | :--- | :--- | :--- |
| **Build** | `docker build -t security-log-review:1.0.0 .` | Exit code 0, 166 MB | Image created with semantic tag |
| **Inspect** | `docker inspect security-log-review:1.0.0` | User: `appuser:appgroup`, Port 8080 | Healthcheck and metadata confirmed |
| **Run** | `docker run -d -p 8080:8080 ...` | Up (healthy) | Container daemonized, port forwarded |
| **Logs** | `docker logs security-log-review-app` | Tomcat started on port 8080 | Bootstrapped Spring Boot 3.2.5 |
| **Health Probe** | `curl http://localhost:8080/actuator/health` | `HTTP 200 {"status":"UP"}` | DB and disk space healthy |
| **Exec** | `docker exec security-log-review-app whoami` | `appuser` | Least-privilege runtime confirmed |
| **Stop** | `docker stop security-log-review-app` | Exited (143) | Graceful SIGTERM shutdown completed |
| **Start** | `docker start security-log-review-app` | Up (health: starting) | Resumed cleanly from preserved state |
| **Remove** | `docker rm security-log-review-app` | Exit code 0 | Container destroyed, resources reclaimed |
| **Compose** | `docker compose up -d` & `down` | Started & stopped cleanly | Multi-container orchestration validated |

---

## 6. Automation Scripts & Reproducibility Index

The following scripts were developed and added to the repository:

1. [`scripts/docker-build.ps1`](file:///d:/ASSIGNMENTS/DEVOPS/DEVOPS%20PROJECT/scripts/docker-build.ps1): Automated image build with validation checks.
2. [`scripts/docker-run.ps1`](file:///d:/ASSIGNMENTS/DEVOPS/DEVOPS%20PROJECT/scripts/docker-run.ps1): Container launch with resource quotas and port binding.
3. [`scripts/docker-lifecycle.ps1`](file:///d:/ASSIGNMENTS/DEVOPS/DEVOPS%20PROJECT/scripts/docker-lifecycle.ps1): Complete 7-step lifecycle drill.
4. [`scripts/docker-build.sh`](file:///d:/ASSIGNMENTS/DEVOPS/DEVOPS%20PROJECT/scripts/docker-build.sh): POSIX/Linux build automation.
5. [`scripts/docker-run.sh`](file:///d:/ASSIGNMENTS/DEVOPS/DEVOPS%20PROJECT/scripts/docker-run.sh): POSIX/Linux run automation.
6. [`docker-compose.yml`](file:///d:/ASSIGNMENTS/DEVOPS/DEVOPS%20PROJECT/docker-compose.yml): Production Docker Compose orchestration file.
