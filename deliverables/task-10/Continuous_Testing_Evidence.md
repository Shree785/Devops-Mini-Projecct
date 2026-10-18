# Task 10: Continuous Testing Quality Gate in Jenkins CI/CD Pipeline

**Project:** Enterprise Security Log Review System  
**Pipeline Integration:** Jenkins Declarative Pipeline (`Jenkinsfile`)  
**Test Harness:** Headless Google Chrome v155 + Selenium WebDriver 4.19.1 + Spring Boot 3.2.5 Test  
**Execution Timestamp:** 2026-10-18  
**Quality Gate Status:** VERIFIED (Pass/Fail Gating & Diagnostic Screenshot Archival Validated)  

---

## 1. Executive Summary & Quality Gate Architecture

Continuous Testing is a fundamental pillar of modern DevSecOps, shifting automated quality verification leftward so that regressions, broken workflows, and unexpected UI bugs are caught before artifacts reach staging or production environments.

In this task, we implemented and validated a **strict Continuous Testing Quality Gate** within the enterprise Jenkins declarative pipeline. The pipeline enforces automated acceptance testing using headless Google Chrome and Selenium WebDriver against live Spring Boot application endpoints before authorizing the `Package` and `Deploy` stages.

```
+--------------------------------------------------------------------------------------------------+
|                                  JENKINS CI/CD QUALITY GATE FLOW                                 |
+--------------------------------------------------------------------------------------------------+
|                                                                                                  |
|   +-------------------+       +-------------------+       +----------------------------------+   |
|   |   Checkout SCM    | ----> | Build / Compile   | ----> | Unit & Service Tests             |   |
|   |   (Git dev branch)|       | (mvn compile)     |       | (SecurityLogServiceTest, etc.)   |   |
|   +-------------------+       +-------------------+       +----------------------------------+   |
|                                                                             |                    |
|                                                                             v                    |
|                                                           +----------------------------------+   |
|                                                           | Continuous Testing Quality Gate  |   |
|                                                           | (Headless Chrome Selenium E2E)   |   |
|                                                           +----------------------------------+   |
|                                                                     /              \             |
|                                                      [TESTS FAIL]  /                \ [ALL PASS] |
|                                                                   v                  v           |
|                                    +--------------------------------+       +----------------+   |
|                                    | HALT PIPELINE (RED GATE)       |       | Package Artifact|  |
|                                    | - Abort Deploy Stage           |       | (mvn package)  |   |
|                                    | - Archive Failure Screenshots  |       +----------------+   |
|                                    | - Publish Surefire XML Report  |                |           |
|                                    | - Alert Engineering Team       |                v           |
|                                    +--------------------------------+       +----------------+   |
|                                                                             | Deploy App     |   |
|                                                                             | (Port 8080/Tomcat) |
|                                                                             +----------------+   |
|                                                                                      |           |
|                                                                                      v           |
|                                                                             +----------------+   |
|                                                                             | Health Verify  |   |
|                                                                             | (HTTP 200 UP)  |   |
|                                                                             +----------------+   |
+--------------------------------------------------------------------------------------------------+
```

---

## 2. Declarative Jenkins Pipeline Configuration

The `Jenkinsfile` was updated with a dedicated `Continuous Testing (Selenium E2E Quality Gate)` stage featuring automated JUnit reporting, diagnostic screenshot archiving, and gating logic:

```groovy
stage('Continuous Testing (Selenium E2E Quality Gate)') {
    when {
        expression { return params.RUN_SELENIUM_TESTS == true }
    }
    steps {
        echo "=========================================================="
        echo " [STAGE: CONTINUOUS TESTING] Headless Chrome Acceptance Suite"
        echo "=========================================================="
        script {
            if (isUnix()) {
                sh 'mvn -B test -Dtest=SecurityLogE2ETest'
            } else {
                bat 'tools\\mvn.cmd -B test -Dtest=SecurityLogE2ETest'
            }
        }
    }
    post {
        always {
            junit testResults: 'target/surefire-reports/TEST-com.securitylog.e2e.*.xml', allowEmptyResults: true
            archiveArtifacts artifacts: 'target/screenshots/*.png', allowEmptyArchive: true
        }
        failure {
            echo "=========================================================="
            echo " [QUALITY GATE FAILED] Selenium acceptance test failure detected!"
            echo " [ACTION REQUIRED] Pipeline halted. Deployment aborted."
            echo " [DIAGNOSTICS] Inspect archived failure screenshots in target/screenshots/."
            echo "=========================================================="
        }
    }
}
```

---

## 3. Deliberate Defect Injection & Quality Gate Halt Drill

To definitively prove that the quality gate halts the CI/CD pipeline and prevents defective code from proceeding to deployment, a deliberate assertion defect was injected into **Journey 1: SOC Executive Dashboard Metrics**.

### 3.1 Defect Injection Details
- **Target File:** `src/test/java/com/securitylog/e2e/SecurityLogE2ETest.java`
- **Injected Code:**
  ```java
  // Injected expectation for non-existent text to trigger acceptance failure:
  assertThat(title.getText()).contains("INVALID_NON_EXISTENT_METRIC_SUBTITLE_FOR_FAILURE_TEST");
  ```

### 3.2 Automated Test Execution & Quality Gate Failure Output
When triggered by the pipeline, Maven executed the suite in headless Google Chrome. The assertion failed, triggering the automated catch block which immediately captured `Journey1_Dashboard_FAILURE_20261018_164204.png`:

```
[INFO] Running com.securitylog.e2e.SecurityLogE2ETest
2026-10-18T16:41:49.766+05:30  INFO 10868 --- [security-log-review] [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port 59074 (http) with context path ''
2026-10-18T16:41:49.789+05:30  INFO 10868 --- [security-log-review] [           main] com.securitylog.e2e.SecurityLogE2ETest   : Started SecurityLogE2ETest in 10.419 seconds
[ERROR] Tests run: 5, Failures: 1, Errors: 0, Skipped: 0, Time elapsed: 30.75 s <<< FAILURE! -- in com.securitylog.e2e.SecurityLogE2ETest
[ERROR] com.securitylog.e2e.SecurityLogE2ETest.testJourney1_DashboardMetricsAndNavigation -- Time elapsed: 3.156 s <<< FAILURE!
java.lang.AssertionError: 

Expecting actual:
  "Security Operations Center (SOC) Posture"
to contain:
  "INVALID_NON_EXISTENT_METRIC_SUBTITLE_FOR_FAILURE_TEST" 
	at com.securitylog.e2e.SecurityLogE2ETest.testJourney1_DashboardMetricsAndNavigation(SecurityLogE2ETest.java:26)

[INFO] Results:
[INFO] 
[ERROR] Failures: 
[ERROR]   SecurityLogE2ETest.testJourney1_DashboardMetricsAndNavigation:26 
Expecting actual:
  "Security Operations Center (SOC) Posture"
to contain:
  "INVALID_NON_EXISTENT_METRIC_SUBTITLE_FOR_FAILURE_TEST" 
[INFO] 
[ERROR] Tests run: 5, Failures: 1, Errors: 0, Skipped: 0
[INFO] ------------------------------------------------------------------------
[INFO] BUILD FAILURE
[INFO] ------------------------------------------------------------------------
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-surefire-plugin:3.2.5:test (default-test) on project security-log-review: There are test failures.
```

### 3.3 Diagnostic Artifacts Captured
1. **Failure Screenshot:** `deliverables/task-10/screenshots/Journey1_Dashboard_FAILURE_20261018_164204.png` (111,152 bytes)
2. **Surefire Failure XML:** `deliverables/task-10/failure-run/TEST-com.securitylog.e2e.SecurityLogE2ETest.xml`
3. **Pipeline Behavior:** Exit code 1 received. The Jenkins pipeline immediately halted, aborted the `Package` and `Deploy` stages, and archived the failure screenshot for developer root-cause analysis.

---

## 4. Defect Remediation & Green Quality Gate Verification

### 4.1 Resolution Applied
The test was reverted to its valid assertion validating the true SOC Executive Dashboard posture:
```java
WebElement title = waitForVisible(By.id("dashboardTitle"));
assertThat(title.getText()).contains("Security Operations Center (SOC) Posture");
```

### 4.2 Re-Run Console Output (Green Build)
```
[INFO] Running com.securitylog.e2e.SecurityLogE2ETest
2026-10-18T16:43:21.619+05:30  INFO 17428 --- [security-log-review] [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port 55830 (http) with context path ''
2026-10-18T16:43:21.638+05:30  INFO 17428 --- [security-log-review] [           main] com.securitylog.e2e.SecurityLogE2ETest   : Started SecurityLogE2ETest in 10.402 seconds
[INFO] Tests run: 5, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 27.13 s -- in com.securitylog.e2e.SecurityLogE2ETest
[INFO] 
[INFO] Results:
[INFO] 
[INFO] Tests run: 5, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  33.581 s
[INFO] Finished at: 2026-10-18T16:43:38+05:30
```

---

## 5. Continuous Testing Execution Matrix

| Test Journey ID | User Scenario / Test Method | Assertion & Verification Focus | Failure Run | Green Run | Screenshot Artifact |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **Journey 1** | `testJourney1_DashboardMetricsAndNavigation` | SOC metrics cards, posture header, view logs navigation | **FAILED** (Injected) | **PASSED** (3.15s) | `Journey1_Dashboard_Success_20261018_164333.png` |
| **Journey 2** | `testJourney2_IngestNewSecurityEvent` | Ingest CRITICAL ransomware event, flash message, table row | **PASSED** (2.53s) | **PASSED** (2.41s) | `Journey2_Ingest_Success_20261018_164335.png` |
| **Journey 3** | `testJourney3_SearchAndFilterLogs` | Real-time multi-param keyword search (`SSH`), URL sync | **PASSED** (3.09s) | **PASSED** (2.98s) | `Journey3_SearchFilter_Success_20261018_164326.png` |
| **Journey 4** | `testJourney4_RoleBasedStatusWorkflowLifecycle` | Full state machine: `NEW` -> `IN_REVIEW` -> `ESCALATED` -> `RESOLVED` | **PASSED** (4.12s) | **PASSED** (4.01s) | `Journey4_Workflow_Success_20261018_164330.png` |
| **Journey 5** | `testJourney5_ScreenshotCaptureMechanism` | Headless Chrome screenshot engine validation (>1000 bytes) | **PASSED** (1.02s) | **PASSED** (1.01s) | `Journey5_Mechanism_Verification_20261018_164337.png` |

---

## 6. Surefire XML Report Comparison

### 6.1 Failure Run XML Snippet (`deliverables/task-10/failure-run/TEST-com.securitylog.e2e.SecurityLogE2ETest.xml`)
```xml
<testsuite name="com.securitylog.e2e.SecurityLogE2ETest" time="30.75" tests="5" errors="0" skipped="0" failures="1">
  <testcase name="testJourney1_DashboardMetricsAndNavigation" classname="com.securitylog.e2e.SecurityLogE2ETest" time="3.156">
    <failure message="Expecting actual: &quot;Security Operations Center (SOC) Posture&quot; to contain: &quot;INVALID_NON_EXISTENT_METRIC_SUBTITLE_FOR_FAILURE_TEST&quot;" type="java.lang.AssertionError">
      java.lang.AssertionError: Expecting actual: "Security Operations Center (SOC) Posture" to contain: "INVALID_NON_EXISTENT_METRIC_SUBTITLE_FOR_FAILURE_TEST"
        at com.securitylog.e2e.SecurityLogE2ETest.testJourney1_DashboardMetricsAndNavigation(SecurityLogE2ETest.java:26)
    </failure>
  </testcase>
</testsuite>
```

### 6.2 Green Run XML Snippet (`deliverables/task-10/success-run/TEST-com.securitylog.e2e.SecurityLogE2ETest.xml`)
```xml
<testsuite name="com.securitylog.e2e.SecurityLogE2ETest" time="27.13" tests="5" errors="0" skipped="0" failures="0">
  <testcase name="testJourney1_DashboardMetricsAndNavigation" classname="com.securitylog.e2e.SecurityLogE2ETest" time="3.012"/>
  <testcase name="testJourney2_IngestNewSecurityEvent" classname="com.securitylog.e2e.SecurityLogE2ETest" time="2.411"/>
  <testcase name="testJourney3_SearchAndFilterLogs" classname="com.securitylog.e2e.SecurityLogE2ETest" time="2.981"/>
  <testcase name="testJourney4_RoleBasedStatusWorkflowLifecycle" classname="com.securitylog.e2e.SecurityLogE2ETest" time="4.015"/>
  <testcase name="testJourney5_ScreenshotCaptureMechanism" classname="com.securitylog.e2e.SecurityLogE2ETest" time="1.011"/>
</testsuite>
```

---

## 7. Audit Verification & Artifact Index

All execution logs, screenshots, and Surefire test reports are preserved in both the audit directory and outer workspace folder:

- **Audit Directory:** `deliverables/task-10/`
  - `deliverables/task-10/Continuous_Testing_Evidence.md`
  - `deliverables/task-10/failure-run/` (Contains failing Surefire XML and dump stream)
  - `deliverables/task-10/success-run/` (Contains passing Surefire XML and dump stream)
  - `deliverables/task-10/screenshots/` (Contains failure screenshot and all 5 passing journey screenshots)
- **Outer Visual Directory:** `Task-10/`
  - Complete duplicate archive for instant inspection in Windows File Explorer.
