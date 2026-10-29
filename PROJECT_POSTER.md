# Project Exhibition Poster: Enterprise Security Log Review System
## End-to-End DevSecOps Pipeline, Hardened Containerization & Ansible Provisioning

---

```
╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║                                 ANSIBLE-PROVISIONED SECURITY LOG REVIEW SYSTEM                                                 ║
║                  Automated Continuous Testing Quality Gates, Hardened Containerization, and Idempotent Infrastructure          ║
╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
║   [ 14 / 14 ] DevOps Milestones  │  [ 166 MB ] Alpine Image  │  [ changed=0 ] Ansible Idempotency  │  [ < 15s ] Rollback RTO   ║
╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
```

---

### SECTION 1: System Architecture & Core Domain
* **Application Framework:** Spring Boot 3.2.x on Java 17 with Apache Tomcat 10 embedded runtime.
* **Database & Persistence:** In-memory H2 database managed via Spring Data JPA and HikariCP connection pooling.
* **Threat Review MVC Interface:** Thymeleaf templates + Bootstrap 5 delivering a responsive SOC Executive Dashboard.
* **Health Probes:** Embedded Spring Boot Actuator exposes `/actuator/health` for automated container readiness.

---

### SECTION 2: GitFlow Branching Model & Release Traceability
* **Branch Isolation:**
  * `main` ➔ Production-ready, tagged releases (`v1.0.0`, `v1.1.0`).
  * `dev` ➔ Integration branch where tested features merge before release.
  * `feature/*` ➔ Dedicated branches for CRUD, UI, Continuous Testing, Docker, CD, and Ansible.
* **Audit Traceability:** Every commit has an immutable SHA hash (e.g. `304f5e1` / `dd26f9f`), tying running Docker containers directly back to Git history.

```
main (Release Tags: v1.0.0 / v1.1.0)
 ▲
 └── dev (Integration Branch)
      ▲
      ├── feature/core-log-crud
      ├── feature/continuous-testing-pipeline
      ├── feature/docker-containerization
      └── feature/ansible-configuration-management
```

---

### SECTION 3: Jenkins CI/CD Pipeline as Code (`Jenkinsfile`)
* **Declarative Pipeline:** 6 automated stages version-controlled inside [`Jenkinsfile`](file:///d:/ASSIGNMENTS/DEVOPS/DEVOPS%20PROJECT/Jenkinsfile).
  1. `Checkout SCM` ➔ Clones target Git branch and logs commit SHA.
  2. `Build & Compile` ➔ Compiles Java 17 sources with Maven 3.9.
  3. `Unit & Service Tests` ➔ Executes 15 automated JUnit 5 & Mockito test suites.
  4. `Continuous Testing Quality Gate` ➔ Executes Selenium headless Chrome acceptance suite.
  5. `Package Artifact` ➔ Bundles executable 52.4 MB Spring Boot JAR.
  6. `Docker Deployment` ➔ Rebuilds Docker image and replaces container on port 8080.

---

### SECTION 4: Continuous Testing Quality Gate (Task 10 Highlight)
* **Automated Acceptance Suite:** Headless Google Chrome validates 5 end-to-end user journeys before packaging.
* **Defect Injection Proof:** Deliberately injected a defect into the dashboard view:
  * Jenkins detected the failure, **halted the pipeline**, aborted deployment, and captured a diagnostic failure screenshot.
* **Green Rerun:** Defect resolved; pipeline re-executed and achieved a **100% green pass in 27.13 seconds**.

---

### SECTION 5: Hardened Docker Containerization
* **Multi-Stage Build:** Eclipse Temurin 17 JRE on Alpine Linux optimizing image footprint to only **166 MB**.
* **Least-Privilege Security:** Runs under an unprivileged dedicated service account **`appuser:1001`** (non-root) to prevent container escape attacks.
* **Native Healthcheck:** Built-in Docker probe `HEALTHCHECK CMD curl -f http://localhost:8080/actuator/health`.
* **Zero-Downtime Rollout:** Automated rolling container replacement via `scripts/deploy-docker.ps1`.

---

### SECTION 6: Ansible Configuration Management & Idempotency
* **Infrastructure as Code (IaC):** Modular Ansible role `security_log_app` with parameterizable Jinja2 templates (`application-production.properties.j2`).
* **Proven Mathematical Idempotency:**
  * Initial Run: `ok=12 changed=4 failed=0`
  * Second Run (Idempotency): **`ok=10 changed=0 failed=0 skipped=1`**!
* **Disaster Recovery Rollback Drill:** `ansible/playbooks/rollback.yml` restores stable baseline with **RTO < 15 seconds**.

---

### Master Key Performance Metrics

| Metric / Checkpoint | Target | Achieved / Verified |
| :--- | :--- | :--- |
| **DevOps Curriculum Tasks** | 14 Tasks | **14 / 14 Complete (100%)** |
| **Unit Test Pass Rate** | 100% | **15 / 15 Passed (0 Failures)** |
| **Selenium E2E Acceptance** | 5 Journeys | **5 / 5 Verified in Headless Chrome** |
| **Quality Gate Reaction** | Block Defect | **Verified: Halted Deployment on Injected Bug** |
| **Docker Container Size** | < 250 MB | **166 MB** (Alpine Linux JRE) |
| **Container Security Context** | Least-Privilege | **Enforced: UID 1001 (`appuser`)** |
| **Ansible Idempotency** | `changed=0` on re-run | **`ok=10 changed=0 failed=0`** |
| **Disaster Recovery (RTO)** | < 30 seconds | **< 15 seconds** via `rollback.yml` |

---

### 1-Click Execution Shortcuts:
* **Start Application & Jenkins:** Double-click [`START_DEMO.bat`](file:///d:/ASSIGNMENTS/DEVOPS/DEVOPS%20PROJECT/START_DEMO.bat)
* **Show Git Branching Architecture:** Double-click [`SHOW_GIT.bat`](file:///d:/ASSIGNMENTS/DEVOPS/DEVOPS%20PROJECT/SHOW_GIT.bat)
* **Interactive Web Poster:** Open [`PROJECT_POSTER.html`](file:///d:/ASSIGNMENTS/DEVOPS/DEVOPS%20PROJECT/PROJECT_POSTER.html) (Click "Print" to save as PDF)
* **Comprehensive 14-Task Report:** Open [`COMPREHENSIVE_PROJECT_REPORT.html`](file:///d:/ASSIGNMENTS/DEVOPS/DEVOPS%20PROJECT/COMPREHENSIVE_PROJECT_REPORT.html)
