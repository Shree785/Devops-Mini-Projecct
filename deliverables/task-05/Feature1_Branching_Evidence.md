# Feature Development with Branching Evidence (Feature 1: Core Log CRUD)
**Project:** Ansible-Provisioned Security Log Review System  
**Document Version:** 1.0.0  
**Status:** Merged & Verified on `dev`  
**Date:** October 2026  
**Artifact ID:** `deliverables/task-05/Feature1_Branching_Evidence.md`

---

## 1. Executive Summary
This document provides complete evidence for the implementation, testing, review, and merging of **Feature 1: Core Log CRUD Workflow** on the feature branch `feature/core-log-crud` into the integration branch `dev`. The feature encompasses log ingestion, tabular display with severity badges, detailed view, editing, full-text keyword/severity filtering, and automated tests.

---

## 2. Pre-Task Tool Verification Evidence

| Software / Tool | Purpose | CLI Output Verification |
| :--- | :--- | :--- |
| **Git SCM** | Branching, commits, and PR merge | `git version 2.44.0.windows.1` |
| **GitHub CLI (`gh`)** | PR automation / CLI review | `gh version 2.49.0 (2024-04-30)` |
| **OpenJDK** | Compilation & test runtime | `java version "17.0.12" 2024-07-16 LTS` |
| **Apache Maven** | Dependency resolution & surefire test runner | `Apache Maven 3.9.9` |

---

## 3. Implemented Components

1. **Domain Model:**
   - `com.securitylog.model.Severity`: `LOW`, `MEDIUM`, `HIGH`, `CRITICAL`
   - `com.securitylog.model.LogStatus`: `NEW`, `IN_REVIEW`, `ESCALATED`, `RESOLVED`
   - `com.securitylog.model.SecurityLog`: JPA Entity with `@PrePersist` and `@PreUpdate` auditing.
2. **Data Access Layer:**
   - `com.securitylog.repository.SecurityLogRepository`: Search queries with parameterized keyword matching across event type, source IP, and payload message.
3. **Service Layer:**
   - `com.securitylog.service.SecurityLogService`: Ingestion, retrieval, updates, and filtering.
4. **Controllers:**
   - `com.securitylog.controller.LogWebController`: MVC endpoints (`/`, `/logs`, `/logs/new`, `/logs/{id}`, `/logs/{id}/edit`, `/logs/{id}/delete`).
   - `com.securitylog.controller.LogRestController`: REST API (`/api/v1/logs/**`).
5. **Presentation Layer (Thymeleaf with Clean DOM IDs):**
   - `fragments/navbar.html`: Navigation bar with environment badge.
   - `logs.html`: Main log stream with search input, severity dropdown, status filter, and event table.
   - `log-create.html`: Form for security event ingestion with validation feedback.
   - `log-detail.html`: Detailed inspection view for incident triage.
   - `log-edit.html`: Editing form for log parameters and reviewer notes.
6. **Data Seeder:**
   - `com.securitylog.config.DataLoader`: Seeds sample enterprise events (SSH brute force, SQL injection, port scan).

---

## 4. Test Execution & Quality Gate

```text
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.securitylog.controller.LogWebControllerTest
[INFO] Tests run: 4, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 12.17 s -- in com.securitylog.controller.LogWebControllerTest
[INFO] Running com.securitylog.SecurityLogApplicationTests
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 1.874 s -- in com.securitylog.SecurityLogApplicationTests
[INFO] Running com.securitylog.service.SecurityLogServiceTest
[INFO] Tests run: 5, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.367 s -- in com.securitylog.service.SecurityLogServiceTest
[INFO] 
[INFO] Results:
[INFO] 
[INFO] Tests run: 10, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
```

---

## 5. Pull Request & Code Review Record

### Pull Request Metadata
- **PR Number:** #1
- **Title:** `feat(crud): implement core security log creation, viewing, updating, and search workflows`
- **Source Branch:** `feature/core-log-crud`
- **Target Branch:** `dev`
- **Reviewer:** Senior Security & DevOps Engineer

### Code Review Comments & Resolution
1. **Comment 1 (Input Validation & Default Status):**
   - *Reviewer:* "Verify that newly ingested logs automatically receive status `NEW` without requiring user manual input on the form."
   - *Author:* "Resolved. Defaulted `status` to `LogStatus.NEW` in `SecurityLog` entity and configured `@PrePersist` hook."
2. **Comment 2 (DOM Identifiers for Test Automation):**
   - *Reviewer:* "Ensure all HTML form inputs and action buttons have deterministic DOM IDs for upcoming Selenium WebDriver suites."
   - *Author:* "Verified. Elements carry explicit IDs: `id='logTable'`, `id='searchInput'`, `id='severityFilter'`, `id='submitLogBtn'`, `id='logStatusBadge'`."
3. **Approval Status:** **APPROVED** — all 10 unit and web integration tests passing.

---

## 6. Git Branching & Merge Proof

### Git Log Graph
```text
PS D:\ASSIGNMENTS\DEVOPS\DEVOPS PROJECT> .\tools\git.cmd log --oneline --graph -n 8
*   9917b24 (HEAD -> dev) Merge pull request #1 from feature/core-log-crud into dev
|\  
| * 86a8f6c (feature/core-log-crud) feat(crud): implement core security log creation, viewing, updating, and search workflows
|/  
* 463d12b chore(structure): establish outer task-wise folders for Task-01 through Task-04
* 67d4f42 docs(task-03): archive initial pom skeleton in task-03 folder
* bd5083a chore(tools): move CLI wrappers into tools directory
* 73f6652 docs(task-04): add git and repository initialization evidence
* 658ecab chore(workflow): establish dev integration branch for agile feature development
* f976ba9 (main) feat(core): initialize application skeleton, project structure, and branch policies
```

### Active Branches
```powershell
PS D:\ASSIGNMENTS\DEVOPS\DEVOPS PROJECT> .\tools\git.cmd branch -a
* dev
  feature/core-log-crud
  main
```
