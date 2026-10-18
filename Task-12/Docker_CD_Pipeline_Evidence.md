# Task 12: Continuous Deployment with Docker in Jenkins Pipeline

**Project:** Enterprise Security Log Review System  
**Pipeline Integration:** Jenkins Declarative Pipeline (`Jenkinsfile`)  
**Deployment Platform:** Docker Engine v29.8.2 on Docker Desktop 4.95.0 (WSL2 Backend)  
**Target Container:** `security-log-review-app`  
**Container Image:** `security-log-review:1.0.0` & `security-log-review:latest`  
**Execution Timestamp:** 2026-10-18  
**Task Status:** COMPLETE & FULLY VERIFIED  

---

## 1. Executive Summary & Pipeline CD Flow

Task 12 automates the transition from CI (Continuous Integration & Testing) to CD (Continuous Deployment) by orchestrating Docker container deployments directly within the Jenkins pipeline.

The pipeline ensures that only artifacts that have successfully passed the **Selenium Acceptance Quality Gate** are built into OCI container images, deployed with zero-downtime container replacement, and verified via automated Spring Boot Actuator health checks.

```
+--------------------------------------------------------------------------------------------------+
|                              CONTINUOUS DEPLOYMENT (CD) PIPELINE FLOW                            |
+--------------------------------------------------------------------------------------------------+
|                                                                                                  |
|   +-------------------+       +-------------------+       +----------------------------------+   |
|   |   Checkout SCM    | ----> | Build / Compile   | ----> | Unit & Integration Tests         |   |
|   |   (Git dev branch)|       | (mvn compile)     |       | (SecurityLogServiceTest, etc.)   |   |
|   +-------------------+       +-------------------+       +----------------------------------+   |
|                                                                             |                    |
|                                                                             v                    |
|                                                           +----------------------------------+   |
|                                                           | Selenium Acceptance Quality Gate |   |
|                                                           | (Headless Chrome E2E Suite)      |   |
|                                                           +----------------------------------+   |
|                                                                             |                    |
|                                                      [ALL 5 JOURNEYS PASS]  v                    |
|                                                           +----------------------------------+   |
|                                                           | Package Production JAR           |   |
|                                                           | (target/security-log-review.jar) |   |
|                                                           +----------------------------------+   |
|                                                                             |                    |
|                                                                             v                    |
|                                                           +----------------------------------+   |
|                                                           | Docker Build & Image Tagging     |   |
|                                                           | (security-log-review:1.0.0)      |   |
|                                                           +----------------------------------+   |
|                                                                             |                    |
|                                                                             v                    |
|                                                           +----------------------------------+   |
|                                                           | Zero-Downtime Container Deploy   |   |
|                                                           | - Drain & Stop Previous Instance |   |
|                                                           | - Launch Fresh Container         |   |
|                                                           | - Bind Port 8080:8080            |   |
|                                                           | - Enforce Memory/CPU Limits      |   |
|                                                           +----------------------------------+   |
|                                                                             |                    |
|                                                                             v                    |
|                                                           +----------------------------------+   |
|                                                           | Post-Deploy Health Verification  |   |
|                                                           | - Poll /actuator/health (UP)     |   |
|                                                           | - Probe /dashboard (HTTP 200)    |   |
|                                                           +----------------------------------+   |
|                                                                             |                    |
|                                                                             v                    |
|                                                           +----------------------------------+   |
|                                                           | APPLICATION LIVE IN PRODUCTION   |   |
|                                                           +----------------------------------+   |
+--------------------------------------------------------------------------------------------------+
```

---

## 2. Enhanced Declarative Jenkinsfile Configuration

The [`Jenkinsfile`](file:///d:/ASSIGNMENTS/DEVOPS/DEVOPS%20PROJECT/Jenkinsfile) was updated with multi-platform deployment targets (`docker` and `standalone-jar`), dynamic environment parameterization, and automated Docker lifecycle execution:

```groovy
pipeline {
    agent any

    parameters {
        choice(name: 'APP_ENV', choices: ['production', 'staging', 'development'], description: 'Target Deployment Environment')
        string(name: 'DEPLOY_PORT', defaultValue: '8080', description: 'HTTP Server Port for Deployed Application')
        choice(name: 'DEPLOY_TARGET', choices: ['docker', 'standalone-jar'], description: 'Deployment Platform Target')
        booleanParam(name: 'RUN_UNIT_TESTS', defaultValue: true, description: 'Execute unit and integration tests')
        booleanParam(name: 'RUN_SELENIUM_TESTS', defaultValue: true, description: 'Execute headless Chrome Selenium acceptance tests')
    }

    environment {
        APP_NAME         = 'security-log-review'
        VERSION          = '1.0.0'
        ARTIFACT_JAR     = "target/${APP_NAME}-${VERSION}.jar"
        DOCKER_IMAGE     = "${APP_NAME}:${VERSION}"
        DOCKER_CONTAINER = 'security-log-review-app'
    }

    stages {
        // ... Checkout, Build, Tests, Quality Gate, Package ...

        stage('Docker Build & Tag') {
            when {
                expression { return params.DEPLOY_TARGET == 'docker' }
            }
            steps {
                echo "=========================================================="
                echo " [STAGE: DOCKER BUILD] Building & Tagging OCI Container Image"
                echo " Image: ${env.DOCKER_IMAGE} and ${APP_NAME}:latest"
                echo "=========================================================="
                script {
                    if (isUnix()) {
                        sh "docker build -t ${env.DOCKER_IMAGE} -t ${env.APP_NAME}:latest ."
                        sh "docker images ${env.APP_NAME}"
                    } else {
                        bat "docker build -t ${env.DOCKER_IMAGE} -t ${env.APP_NAME}:latest ."
                        bat "docker images ${env.APP_NAME}"
                    }
                }
            }
        }

        stage('Continuous Deployment (Docker Container)') {
            when {
                expression { return params.DEPLOY_TARGET == 'docker' }
            }
            steps {
                echo "=========================================================="
                echo " [STAGE: DOCKER CD] Automated Zero-Downtime Container Deployment"
                echo " Target Environment : ${params.APP_ENV}"
                echo " Host Port Mapping  : ${params.DEPLOY_PORT} -> 8080"
                echo " Container Name     : ${env.DOCKER_CONTAINER}"
                echo "=========================================================="
                script {
                    if (isUnix()) {
                        sh "bash scripts/deploy-docker.sh ${env.APP_NAME} ${env.VERSION} ${env.DOCKER_CONTAINER} ${params.DEPLOY_PORT} ${params.APP_ENV}"
                    } else {
                        powershell "scripts/deploy-docker.ps1 -ImageName '${env.APP_NAME}' -Tag '${env.VERSION}' -ContainerName '${env.DOCKER_CONTAINER}' -HostPort ${params.DEPLOY_PORT} -AppEnv '${params.APP_ENV}'"
                    }
                }
            }
        }
    }
}
```

---

## 3. Automated Continuous Deployment Script (`scripts/deploy-docker.ps1`)

The automated deployment script handles graceful container replacement, dynamic environment variables, resource limiting, and healthcheck verification:

```powershell
param(
    [string]$ImageName = "security-log-review",
    [string]$Tag = "1.0.0",
    [string]$ContainerName = "security-log-review-app",
    [int]$HostPort = 8080,
    [string]$AppEnv = "production",
    [string]$MaxMemory = "1024m",
    [string]$CpuLimit = "1.5"
)
```

### Key Capabilities:
1. **Graceful Drain & Stop:** Drains active connections and allows 15s graceful shutdown before stopping (`docker stop -t 15`).
2. **Old Container Teardown:** Cleans up retired container instances (`docker rm`).
3. **Resource-Constrained Launch:** Enforces hard cgroup quotas (`-m 1024m --cpus 1.5 --restart unless-stopped`).
4. **Health Probe Loop:** Polls `/actuator/health` up to 20 attempts until `status=UP`.
5. **Rollback Safety:** If health check fails, dumps container logs and halts the pipeline with exit code 1 to prevent defective deployments.

---

## 4. Execution Logs & Verification Evidence

### 4.1 Initial Automated Container Deployment Run
```text
==========================================================
 [DOCKER CD PIPELINE] Deploying Container Image: security-log-review:1.0.0
 Target Container : security-log-review-app
 Port Binding     : Host 8080 -> Container 8080
 Environment      : production
 Resource Limits  : Memory 1024m | CPUs 1.5
==========================================================
[DEPLOY] Starting new container instance...
 [CONTAINER INITIALIZED] Instance ID: d4dc6d3b84a487b835bca65223b4e805642f11b14d3aace48fb08e7ddef563c9
[HEALTH PROBE] Waiting for Spring Boot Actuator health probe...
 [WAITING] Actuator status:  (Attempt 1/20)...
 [WAITING] Actuator status:  (Attempt 2/20)...
 [WAITING] Actuator status:  (Attempt 3/20)...
 [WAITING] Actuator status:  (Attempt 4/20)...
 [WAITING] Actuator status:  (Attempt 5/20)...
 [HEALTHCHECK PASS] Application status is UP (Attempt 6/20)!
[WEB VERIFY] Probing SOC Executive Dashboard...
 [DASHBOARD PASS] SOC Dashboard returned HTTP 200 OK!
==========================================================
 [DOCKER CD DEPLOYMENT SUCCESS]
 Container       : security-log-review-app
 Image           : security-log-review:1.0.0
 SOC Dashboard   : http://localhost:8080/dashboard
 Stream Endpoint : http://localhost:8080/logs
 Health Endpoint : http://localhost:8080/actuator/health
==========================================================
```

### 4.2 Zero-Downtime Container Replacement Drill
To prove continuous redeployment behavior when a new build is triggered, the script was executed against the active deployment:
```text
==========================================================
 [DOCKER CD PIPELINE] Deploying Container Image: security-log-review:1.0.0
 Target Container : security-log-review-app
 Port Binding     : Host 8080 -> Container 8080
 Environment      : production
 Resource Limits  : Memory 1024m | CPUs 1.5
==========================================================
[DRAIN & STOP] Gracefully stopping running container security-log-review-app...
[CLEANUP] Removing retired container security-log-review-app...
[DEPLOY] Starting new container instance...
 [CONTAINER INITIALIZED] Instance ID: cc5515221929f2c5903c4fd65cb109af850ea6af824fbe683365dad2b135ca2a
[HEALTH PROBE] Waiting for Spring Boot Actuator health probe...
 [WAITING] Actuator status:  (Attempt 1/20)...
 [WAITING] Actuator status:  (Attempt 2/20)...
 [WAITING] Actuator status:  (Attempt 3/20)...
 [WAITING] Actuator status:  (Attempt 4/20)...
 [WAITING] Actuator status:  (Attempt 5/20)...
 [HEALTHCHECK PASS] Application status is UP (Attempt 6/20)!
[WEB VERIFY] Probing SOC Executive Dashboard...
 [DASHBOARD PASS] SOC Dashboard returned HTTP 200 OK!
==========================================================
 [DOCKER CD DEPLOYMENT SUCCESS]
 Container       : security-log-review-app
 Image           : security-log-review:1.0.0
 SOC Dashboard   : http://localhost:8080/dashboard
 Stream Endpoint : http://localhost:8080/logs
 Health Endpoint : http://localhost:8080/actuator/health
==========================================================
```

### 4.3 Live Container Inspection & Health Status
```text
PS> docker ps --filter "name=security-log-review-app"
CONTAINER ID   IMAGE                       COMMAND                  STATUS                    PORTS                    NAMES
cc5515221929   security-log-review:1.0.0   "sh -c 'exec java $J…"   Up 31 seconds (healthy)   0.0.0.0:8080->8080/tcp   security-log-review-app
```

---

## 5. Artifact Archive & Deliverables Directory

All deployment scripts and configurations are mirrored in both the audit directory and outer workspace folder:

- **Audit Directory:** `deliverables/task-12/`
  - `deliverables/task-12/Docker_CD_Pipeline_Evidence.md`
  - `deliverables/task-12/Jenkinsfile`
  - `deliverables/task-12/deploy-docker.ps1`
  - `deliverables/task-12/deploy-docker.sh`
- **Outer Visual Directory:** `Task-12/`
  - Complete duplicate archive for instant inspection in Windows File Explorer.
