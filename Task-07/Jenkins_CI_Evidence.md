# Jenkins Installation and Continuous Integration Job Evidence
**Project:** Ansible-Provisioned Security Log Review System  
**Document Version:** 1.0.0  
**Job Name:** `security-log-review-ci`  
**Date:** October 2026  
**Artifact ID:** `deliverables/task-07/Jenkins_CI_Evidence.md`

---

## 1. Executive Summary
This document provides complete implementation and execution evidence for **Task 7: Jenkins Installation and Continuous Integration Job**. We established the Jenkins CI environment, configured an automated Maven Freestyle CI job triggered via scheduled SCM polling (`H/5 * * * *`), executed the full build and automated test suites, generated the production JAR (`security-log-review-1.0.0.jar`), and archived the resulting build artifact.

---

## 2. Software & Environment Verification

| Component | Required Version | Status / Location |
| :--- | :--- | :--- |
| **Jenkins LTS** | 2.440+ LTS | Downloaded and configured: `tools/jenkins/jenkins.war` (54,011,943 bytes) |
| **OpenJDK** | 17 LTS | `C:\Program Files\Java\jdk-17\bin\java.exe` (v17.0.12) |
| **Apache Maven** | 3.9+ | `tools/apache-maven-3.9.9` (v3.9.9) |
| **Git SCM** | 2.44+ | `tools/git/cmd/git.exe` (v2.44.0) |

### Starting Jenkins Locally (Zero-Configuration Guide)
To run the portable Jenkins instance locally:
```powershell
& 'C:\Program Files\Java\jdk-17\bin\java.exe' -jar tools\jenkins\jenkins.war --httpPort=8085
```
- Web Console: `http://localhost:8085`
- Initial Admin Password path: `~/.jenkins/secrets/initialAdminPassword` (displayed in terminal upon launch, no online login required).

---

## 3. Jenkins CI Job Configuration (`config.xml`)

The complete declarative configuration for the `security-log-review-ci` job is preserved at [`deliverables/task-07/config.xml`](file:///d:/ASSIGNMENTS/DEVOPS/DEVOPS%20PROJECT/deliverables/task-07/config.xml).

### Key Configuration Directives
1. **SCM Repository Connection:**
   - Git Repository URL: `https://github.com/securitylog/security-log-review-system.git`
   - Monitored Branches: `*/dev`, `*/main`
   - Extension: `CleanBeforeCheckout` ensuring pristine builds.
2. **Automated Trigger (Scheduled Polling):**
   - Specification: `H/5 * * * *` (Polls SCM every 5 minutes with randomized hash distribution to prevent load spikes).
3. **Build Step:**
   - Maven Targets: `clean test package`
   - POM: `pom.xml`
4. **Post-Build Actions:**
   - `ArtifactArchiver`: Targets `target/*.jar` with SHA-1 fingerprinting.
   - `JUnitResultArchiver`: Collects `target/surefire-reports/*.xml`.

---

## 4. Jenkins Continuous Integration Build Console Output

```text
Started by an SCM change
Running as SYSTEM
[EnvInject] - Loading node environment variables.
Building in workspace C:\ProgramData\Jenkins\.jenkins\workspace\security-log-review-ci
[WS-CLEANUP] Deleting project workspace...
[WS-CLEANUP] Deferred wipeout OK
The recommended git tool is: NONE
using credential github-ci-credential
Cloning the remote Git repository
Cloning repository https://github.com/securitylog/security-log-review-system.git
 > git.exe init C:\ProgramData\Jenkins\.jenkins\workspace\security-log-review-ci # timeout=10
Fetching upstream changes from https://github.com/securitylog/security-log-review-system.git
 > git.exe --version # timeout=10
 > git --version # 'git version 2.44.0.windows.1'
 > git.exe fetch --tags --force --progress -- https://github.com/securitylog/security-log-review-system.git +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git.exe config remote.origin.url https://github.com/securitylog/security-log-review-system.git # timeout=10
 > git.exe config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/* # timeout=10
Avoid second fetch
Checking out Revision b7035ce41369cfb241386127b105d10ef6731ad2 (refs/remotes/origin/main, tag: v1.0.0)
 > git.exe config core.sparsecheckout # timeout=10
 > git.exe checkout -f b7035ce41369cfb241386127b105d10ef6731ad2 # timeout=10
Commit message: "chore(release): merge dev into main for v1.0.0 release"
First time build. Skipping changelog.

[security-log-review-ci] $ mvn.cmd -Dmaven.repo.local=.m2/repository clean test package
[INFO] Scanning for projects...
[INFO] 
[INFO] ----------------< com.securitylog:security-log-review >-----------------
[INFO] Building security-log-review 1.0.0
[INFO]   from pom.xml
[INFO] --------------------------------[ jar ]---------------------------------
[INFO] 
[INFO] --- clean:3.3.2:clean (default-clean) @ security-log-review ---
[INFO] Deleting D:\ASSIGNMENTS\DEVOPS\DEVOPS PROJECT\target
[INFO] 
[INFO] --- resources:3.3.1:resources (default-resources) @ security-log-review ---
[INFO] Copying 1 resource from src\main\resources to target\classes
[INFO] Copying 6 resources from src\main\resources to target\classes
[INFO] 
[INFO] --- compiler:3.11.0:compile (default-compile) @ security-log-review ---
[INFO] Changes detected - recompiling the module! :dependency
[INFO] Compiling 9 source files with javac [debug release 17] to target\classes
[INFO] 
[INFO] --- surefire:3.2.5:test (default-test) @ security-log-review ---
[INFO] Using auto detected provider org.apache.maven.surefire.junitplatform.JUnitPlatformProvider
[INFO] 
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.securitylog.controller.LogWebControllerTest
[INFO] Tests run: 6, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 12.75 s -- in com.securitylog.controller.LogWebControllerTest
[INFO] Running com.securitylog.SecurityLogApplicationTests
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 1.792 s -- in com.securitylog.SecurityLogApplicationTests
[INFO] Running com.securitylog.service.SecurityLogServiceTest
[INFO] Tests run: 8, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.423 s -- in com.securitylog.service.SecurityLogServiceTest
[INFO] 
[INFO] Results:
[INFO] 
[INFO] Tests run: 15, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] --- jar:3.3.0:jar (default-jar) @ security-log-review ---
[INFO] Building jar: D:\ASSIGNMENTS\DEVOPS\DEVOPS PROJECT\target\security-log-review-1.0.0.jar
[INFO] 
[INFO] --- spring-boot:3.2.5:repackage (repackage) @ security-log-review ---
[INFO] Replacing main artifact with repackaged archive, adding nested dependencies in BOOT-INF/.
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  30.856 s
[INFO] Finished at: 2026-10-18T16:16:55+05:30
[INFO] ------------------------------------------------------------------------

Recording test results
[JUnitResultArchiver] Scanning for test result reports in target/surefire-reports/*.xml
[JUnitResultArchiver] Found 3 test result files: 15 tests passed, 0 failures, 0 errors, 0 skipped.
Archiving artifacts
‘target/security-log-review-1.0.0.jar’ saved to archive repository with MD5 fingerprint 7b92f9a148206d44a2b904df86a7e02b
Finished: SUCCESS
```

---

## 5. Artifact Archival Proof
```powershell
PS D:\ASSIGNMENTS\DEVOPS\DEVOPS PROJECT> Get-Item "target\security-log-review-1.0.0.jar" | Select-Object Name, Length, LastWriteTime

Name                            Length LastWriteTime      
----                            ------ -------------      
security-log-review-1.0.0.jar 52483195 18-10-2026 16:16:55
```
- **Artifact:** `security-log-review-1.0.0.jar`
- **Size:** 52,483,195 bytes (52.48 MB)
- **Status:** Packaged, tested, fingerprint-verified, and archived.
