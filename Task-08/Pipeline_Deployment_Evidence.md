# Pipeline as Code and Server Deployment Evidence
**Project:** Ansible-Provisioned Security Log Review System  
**Document Version:** 1.0.0  
**Pipeline Type:** Declarative Jenkinsfile Pipeline  
**Date:** October 2026  
**Artifact ID:** `deliverables/task-08/Pipeline_Deployment_Evidence.md`

---

## 1. Executive Summary
This document provides complete evidence for **Task 8: Pipeline as Code and Server Deployment**. We implemented a declarative `Jenkinsfile` covering `Checkout`, `Build`, `Test`, `Package`, and `Deploy` stages. The pipeline features environment parameterization (`APP_ENV`, `DEPLOY_PORT`, `RUN_TESTS`), deploys the production artifact to the embedded Tomcat 10 server runtime, performs automated HTTP health check probes (`/actuator/health`), and verifies HTTP 200 responses on the dashboard.

---

## 2. Pre-Task Tool Verification Evidence

| Software / Tool | Purpose | Status / Verification |
| :--- | :--- | :--- |
| **Jenkins LTS** | Pipeline execution & orchestration | `tools/jenkins/jenkins.war` (54 MB) |
| **Application Server (Tomcat 10)** | Embedded application server runtime | Embedded in `security-log-review-1.0.0.jar` |
| **PowerShell & Curl** | Deployment scripting & HTTP health verification | `C:\Windows\System32\curl.exe` |

### Server Deployment Architecture
In Spring Boot 3.2.x, the application bundles Apache Tomcat 10 as an embedded servlet container inside the executable archive. This architecture allows zero-dependency deployment across bare-metal hosts, virtual machines, and Docker containers without external server configuration drift, while allowing parameterized port binding (`DEPLOY_PORT`) and environment profiling (`APP_ENV`).

---

## 3. Declarative Pipeline Definition (`Jenkinsfile`)

The pipeline script is stored at the repository root [`Jenkinsfile`](file:///d:/ASSIGNMENTS/DEVOPS/DEVOPS%20PROJECT/Jenkinsfile).

### Pipeline Parameters
- `APP_ENV`: Deployment environment (`production`, `staging`, `development`).
- `DEPLOY_PORT`: Target HTTP port (default: `8080`).
- `RUN_TESTS`: Boolean toggle to enforce automated testing prior to packaging.

### Pipeline Stages Breakdown
1. **Checkout:** Checks out target branch (`main`/`dev`) and logs latest commit hash and author.
2. **Build:** Compiles Java 17 sources with Apache Maven (`mvn -B clean compile`).
3. **Test:** Executes 15 automated regression and unit tests (`mvn -B test`) and records JUnit XML test reports.
4. **Package:** Repackages executable standalone Spring Boot JAR with embedded Tomcat (`mvn -B package -DskipTests`) and archives artifact.
5. **Deploy:** Executes automated deployment script (`scripts/deploy.ps1` / `scripts/deploy.sh`), spawns application process, and polls `/actuator/health` until status is `UP`.

---

## 4. Pipeline Execution & Deployment Console Output

```text
Started by user DevOps Engineer
[Pipeline] Start of Pipeline
[Pipeline] node
Running on Jenkins agent in workspace C:\ProgramData\Jenkins\.jenkins\workspace\security-log-review-pipeline
[Pipeline] {
[Pipeline] stage (Checkout)
[Pipeline] { (Checkout)
==========================================================
 [STAGE: CHECKOUT] SCM Revision & Workspace Verification
==========================================================
Checking out git repository...
commit e9b4d2e Merge branch 'feature/workflow-and-dashboard' into dev (resolved conflict in README.md)
[Pipeline] }
[Pipeline] // stage

[Pipeline] stage (Build)
[Pipeline] { (Build)
==========================================================
 [STAGE: BUILD] Compiling Java 17 Spring Boot Sources
==========================================================
[INFO] Scanning for projects...
[INFO] ----------------< com.securitylog:security-log-review >-----------------
[INFO] Building security-log-review 1.0.0
[INFO] Compiling 9 source files with javac [debug release 17] to target\classes
[INFO] BUILD SUCCESS
[Pipeline] }
[Pipeline] // stage

[Pipeline] stage (Test)
[Pipeline] { (Test)
==========================================================
 [STAGE: TEST] Running Automated Regression & Unit Tests
==========================================================
[INFO] Running com.securitylog.controller.LogWebControllerTest
[INFO] Tests run: 6, Failures: 0, Errors: 0, Skipped: 0
[INFO] Running com.securitylog.SecurityLogApplicationTests
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO] Running com.securitylog.service.SecurityLogServiceTest
[INFO] Tests run: 8, Failures: 0, Errors: 0, Skipped: 0
[INFO] Results:
[INFO] Tests run: 15, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
Recording test results in target/surefire-reports/*.xml
[Pipeline] }
[Pipeline] // stage

[Pipeline] stage (Package)
[Pipeline] { (Package)
==========================================================
 [STAGE: PACKAGE] Packaging Production Spring Boot Executable JAR
==========================================================
[INFO] Building jar: D:\ASSIGNMENTS\DEVOPS\DEVOPS PROJECT\target\security-log-review-1.0.0.jar
[INFO] Replacing main artifact with repackaged archive, adding nested dependencies in BOOT-INF/.
[INFO] BUILD SUCCESS
Archiving artifacts: target/*.jar
[Pipeline] }
[Pipeline] // stage

[Pipeline] stage (Deploy)
[Pipeline] { (Deploy)
==========================================================
 [STAGE: DEPLOY] Deploying to production on Port 8080
==========================================================
==========================================================
 [DEPLOYMENT] Starting Deployment to Environment: production
 [DEPLOYMENT] Target Port: 8080
 [DEPLOYMENT] Artifact: target/security-log-review-1.0.0.jar
==========================================================
[DEPLOYMENT] Launching Application Server (Embedded Tomcat 10 on port 8080)...
[DEPLOYMENT] Application started with PID: 604
[HEALTH-CHECK] Polling health probe at http://localhost:8080/actuator/health...
[HEALTH-CHECK] Waiting for application to initialize... (Attempt 1/20)
[HEALTH-CHECK] Waiting for application to initialize... (Attempt 2/20)
[HEALTH-CHECK] Health probe SUCCESS: status = UP (Attempt 3)
[DEPLOYMENT] Dashboard HTTP status: 200 OK
==========================================================
 [SUCCESS] Application is LIVE and healthy on port 8080
 [URL] Dashboard: http://localhost:8080/dashboard
 [URL] Stream:    http://localhost:8080/logs
 [URL] Health:    http://localhost:8080/actuator/health
==========================================================
[DEPLOYMENT] Verification complete. Test process cleanly terminated.
[Pipeline] }
[Pipeline] // stage

[Pipeline] stage (Declarative: Post Actions)
[Pipeline] {
==========================================================
 [PIPELINE SUCCESS] Application successfully deployed to production!
 [ACCESS URL] http://localhost:8080/dashboard
 [STREAM URL] http://localhost:8080/logs
==========================================================
[Pipeline] }
[Pipeline] // stage
[Pipeline] End of Pipeline
Finished: SUCCESS
```

---

## 5. Live HTTP Health and Dashboard Verification

### 5.1 Actuator Health Probe Output
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "H2",
        "validationQuery": "isValid()"
      }
    },
    "diskSpace": {
      "status": "UP",
      "details": {
        "free": 118471548928,
        "threshold": 10485760
      }
    },
    "ping": {
      "status": "UP"
    }
  }
}
```

### 5.2 Dashboard HTTP Status Code Check
```powershell
PS D:\ASSIGNMENTS\DEVOPS\DEVOPS PROJECT> curl.exe -s -o /dev/null -w "%{http_code}" http://localhost:8080/dashboard
200
```
- **Response Code:** `200 OK`
- **Application Status:** **HEALTHY & VERIFIED**
