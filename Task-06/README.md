# Ansible-Provisioned Security Log Review System

[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)]()
[![Java Version](https://img.shields.io/badge/Java-17%20LTS-blue.svg)](https://adoptium.net/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.5-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Maven](https://img.shields.io/badge/Apache%20Maven-3.9.9-red.svg)](https://maven.apache.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![Ansible](https://img.shields.io/badge/Ansible-Idempotent-black.svg)](https://www.ansible.com/)

---

## 1. Overview

> **System Status (Release v1.0.0 Baseline):** Full enterprise MVP operational featuring role-based triage workflow (`NEW` ➔ `IN_REVIEW` ➔ `ESCALATED` / `RESOLVED`), real-time SOC posture dashboard, and automated regression testing.

---



## 2. Tech Stack & Architecture
- **Backend:** Java 17 LTS, Spring Boot 3.2.5 (Spring MVC, Spring Data JPA, Hibernate, Actuator)
- **Frontend:** Thymeleaf 3, Bootstrap 5, FontAwesome (designed with deterministic DOM IDs for Selenium WebDriver)
- **Database:** Embedded H2 Database (zero-dependency portability)
- **Build Tool:** Apache Maven 3.9+
- **Test Automation:** JUnit 5, AssertJ, Selenium WebDriver 4 (Headless Chrome with failure screenshots)
- **CI/CD:** Jenkins Declarative Pipeline (`Jenkinsfile`)
- **Containers:** Docker, Dockerfile (multi-stage build)
- **Configuration Management:** Ansible Core (`inventory.ini`, `playbook.yml`)

---

## 3. Git Branching Strategy & Policies

We follow a structured Git Flow branching strategy:
* `main`: Protected production branch. Strictly receives pull requests from `dev` or release tags (`v1.0.0`).
* `dev`: Primary integration branch. All feature branches merge here via Pull Requests.
* `feature/<feature-name>`: Dedicated feature development branches (e.g. `feature/core-log-crud`, `feature/workflow-and-dashboard`).
* `hotfix/<fix-name>`: Immediate production bugfix branches branched off `main`.

### Commit Message Guidelines (Conventional Commits)
All commit messages must adhere to the format:
```text
<type>(<scope>): <short imperative summary>

[optional detailed body]
[optional issue reference]
```
Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`.

---

## 4. Local Quickstart

### Prerequisites
- OpenJDK 17 LTS
- Apache Maven 3.9+ (or use `./mvn.cmd` wrapper)

### Build & Run
```bash
# 1. Compile and run unit tests
./mvn.cmd clean test

# 2. Package the application
./mvn.cmd package

# 3. Launch application locally
./mvn.cmd spring-boot:run
```
The application will be accessible at `http://localhost:8080/`.  
The H2 Database Console is accessible at `http://localhost:8080/h2-console` (JDBC URL: `jdbc:h2:mem:securitydb`, Username: `sa`, Password: blank).
