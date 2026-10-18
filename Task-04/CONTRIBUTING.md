# Contributing to Security Log Review System

## 1. Branch Naming Conventions
Always create branches from `dev` using the following prefixes:
- `feature/<short-description>`: e.g., `feature/core-log-crud`, `feature/workflow-and-dashboard`
- `bugfix/<issue-id>-<description>`: e.g., `bugfix/issue-12-xss-filter`
- `hotfix/<description>`: Emergency production fixes branched from `main`

## 2. Commit Message Guidelines
Follow the Conventional Commits specification:
```
<type>(<scope>): <subject>
```
Examples:
- `feat(crud): implement security log creation and validation`
- `fix(workflow): prevent status transition from resolved to new`
- `test(selenium): add e2e browser test for incident escalation`
- `docs(readme): update deployment prerequisites`

## 3. Pull Request Requirements
1. The PR must target `dev` (only release merges target `main`).
2. All unit tests (`mvn test`) must pass with zero failures.
3. Include clear testing notes and screenshots if UI changes were made.
4. Obtain at least one code review approval before merging.
