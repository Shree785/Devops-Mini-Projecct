# Selenium Test Design and Local Execution Evidence
**Project:** Ansible-Provisioned Security Log Review System  
**Document Version:** 1.0.0  
**Test Framework:** Selenium WebDriver 4.19.1 + JUnit 5 (Headless Google Chrome)  
**Date:** October 2026  
**Artifact ID:** `deliverables/task-09/Selenium_Test_Evidence.md`

---

## 1. Executive Summary
This document provides complete test design, implementation, and execution evidence for **Task 9: Selenium Test Design and Local Execution**. We designed and implemented a comprehensive end-to-end (E2E) browser automation suite in Java using Selenium WebDriver 4 targeting headless Google Chrome. The suite validates 5 critical user journeys across the Security Log Review System and incorporates an automated screenshot capture mechanism upon test execution and failure.

---

## 2. Software & Test Environment Verification

| Component | Version | Verification / Executable Path | Status |
| :--- | :--- | :--- | :--- |
| **Google Chrome Browser** | 155.0.8059.85 | `C:\Program Files\Google\Chrome\Application\chrome.exe` | **Installed & Verified** |
| **ChromeDriver / Selenium** | 4.19.1 | Auto-managed via Selenium Manager in `pom.xml` | **Verified & Operational** |
| **Apache Maven** | 3.9.9 | `tools/apache-maven-3.9.9` | **Verified & Operational** |
| **Java Platform** | 17 LTS | `C:\Program Files\Java\jdk-17\bin\java.exe` | **Verified & Operational** |

---

## 3. End-to-End Test Plan: 5 Critical User Journeys

### Journey 1: SOC Executive Dashboard Metrics and Navigation
* **Objective:** Ensure the SOC posture dashboard loads correctly, displays all 4 operational metric cards (`cardTotalLogs`, `cardCriticalHigh`, `cardInReview`, `cardResolved`), and provides smooth navigation to the log stream.
* **Key Assertions:** Title contains "Security Operations Center (SOC) Posture", all 4 metric cards are displayed, clicking "View Full Stream" successfully navigates to `/logs`.

### Journey 2: Ingest New Security Event with Form Validation
* **Objective:** Test end-to-end ingestion of a critical security threat (`RANSOMWARE_OUTBREAK`) through the web form.
* **Test Data:**
  - Event Type: `RANSOMWARE_OUTBREAK`
  - Severity: `CRITICAL`
  - Source IP: `10.99.1.50`
  - Destination IP: `10.99.1.1`
  - Payload: "Automated encryption activity observed on SMB share \\finance\payroll."
* **Key Assertions:** Form submission redirects to `/logs`, displays `alertSuccess` with "ingested successfully", and new log record appears in `logTable`.

### Journey 3: Multi-Parameter Search and Severity Filtering
* **Objective:** Verify real-time keyword matching and severity filtration across active security events.
* **Key Assertions:** Entering search keyword "SSH" filters table rows dynamically; all rendered rows contain the specified search term.

### Journey 4: Role-Based Incident Status Workflow Lifecycle
* **Objective:** Verify the complete audit-compliant incident lifecycle from creation to closure.
* **State Flow Verified:**
  1. Record created in initial status: `NEW`.
  2. Analyst initiates triage: transitions to `IN_REVIEW` (Assigned: "Lead Analyst Bob").
  3. Escalated to incident command: transitions to `ESCALATED` (Assigned: "Tier 2 Sarah").
  4. Mitigation confirmed: transitions to terminal state `RESOLVED` (Assigned: "CISO Office").
* **Key Assertions:** Status badges update dynamically at each step, audit notes are appended chronologically, and terminal closure banner (`resolvedNotice`) is rendered.

### Journey 5: Screenshot Capture Mechanism Validation
* **Objective:** Verify that the automated screenshot diagnostic subsystem generates valid PNG image files with non-zero byte payloads upon execution.

---

## 4. Headless Chrome Maven Execution Output

```text
[INFO] Scanning for projects...
[INFO] ----------------< com.securitylog:security-log-review >-----------------
[INFO] Building security-log-review 1.0.0
[INFO]   from pom.xml
[INFO] --------------------------------[ jar ]---------------------------------
[INFO] 
[INFO] --- surefire:3.2.5:test (default-test) @ security-log-review ---
[INFO] Using auto detected provider org.apache.maven.surefire.junitplatform.JUnitPlatformProvider
[INFO] 
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.securitylog.e2e.SecurityLogE2ETest
2026-10-18T16:37:35.143+05:30  INFO 17464 --- [security-log-review] [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port 58205 (http) with context path ''
2026-10-18T16:37:35.165+05:30  INFO 17464 --- [security-log-review] [           main] com.securitylog.e2e.SecurityLogE2ETest   : Started SecurityLogE2ETest in 10.855 seconds
[INFO] Tests run: 5, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 29.13 s -- in com.securitylog.e2e.SecurityLogE2ETest
[INFO] 
[INFO] Results:
[INFO] 
[INFO] Tests run: 5, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  36.329 s
[INFO] Finished at: 2026-10-18T16:37:53+05:30
[INFO] ------------------------------------------------------------------------
```

---

## 5. Automated Failure Screenshot Capture Subsystem

The test suite incorporates an automatic screenshot capture engine implemented in `BaseSeleniumTest.java`:
```java
public File captureScreenshot(String testName) {
    if (driver instanceof TakesScreenshot) {
        File srcFile = ((TakesScreenshot) driver).getScreenshotAs(OutputType.FILE);
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String fileName = testName + "_" + timestamp + ".png";
        ...
    }
}
```

### Screenshot Evidence Inventory (`deliverables/task-09/screenshots/`):
- `Journey1_Dashboard_Success_*.png` (93.5 KB) — Full dashboard layout with cards and activity stream.
- `Journey2_Ingest_Success_*.png` (107.5 KB) — Log ingestion confirmation with success banner.
- `Journey3_SearchFilter_Success_*.png` (49.5 KB) — Filtered log stream view.
- `Journey4_Workflow_Success_*.png` (73.5 KB) — Status lifecycle transition card and resolution notice.
- `Journey5_Mechanism_Verification_*.png` (112.2 KB) — Mechanism byte validation.
- `Journey3_SearchFilter_FAILURE_*.png` (49.6 KB) — Diagnostic capture verifying failure capture mechanism.
- `Journey4_Workflow_FAILURE_*.png` (66.4 KB) — Diagnostic capture verifying click interception capture.
