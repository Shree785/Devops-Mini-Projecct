package com.securitylog.e2e;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;

import java.io.File;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

public class SecurityLogE2ETest extends BaseSeleniumTest {

    @Test
    @DisplayName("Journey 1: SOC Executive Dashboard Metrics and Navigation")
    void testJourney1_DashboardMetricsAndNavigation() {
        try {
            driver.get(getBaseUrl() + "/dashboard");

            WebElement title = waitForVisible(By.id("dashboardTitle"));
            assertThat(title.getText()).contains("Security Operations Center (SOC) Posture");

            WebElement totalLogsCard = waitForVisible(By.id("cardTotalLogs"));
            assertThat(totalLogsCard.isDisplayed()).isTrue();

            WebElement critHighCard = waitForVisible(By.id("cardCriticalHigh"));
            assertThat(critHighCard.isDisplayed()).isTrue();

            WebElement inReviewCard = waitForVisible(By.id("cardInReview"));
            assertThat(inReviewCard.isDisplayed()).isTrue();

            WebElement resolvedCard = waitForVisible(By.id("cardResolved"));
            assertThat(resolvedCard.isDisplayed()).isTrue();

            // Navigate to Stream via Dashboard Button
            WebElement viewLogsBtn = waitForClickable(By.id("btnDashViewLogs"));
            viewLogsBtn.click();

            waitForVisible(By.id("pageTitle"));
            assertThat(driver.getCurrentUrl()).contains("/logs");

            captureScreenshot("Journey1_Dashboard_Success");
        } catch (Throwable t) {
            captureScreenshot("Journey1_Dashboard_FAILURE");
            throw t;
        }
    }

    @Test
    @DisplayName("Journey 2: Ingest New Security Event with Form Validation")
    void testJourney2_IngestNewSecurityEvent() {
        try {
            driver.get(getBaseUrl() + "/logs/new");

            waitForVisible(By.id("formHeader"));

            // Fill Form Data
            WebElement eventTypeInput = driver.findElement(By.id("eventTypeInput"));
            eventTypeInput.sendKeys("RANSOMWARE_OUTBREAK");

            Select severitySelect = new Select(driver.findElement(By.id("severitySelect")));
            severitySelect.selectByValue("CRITICAL");

            WebElement sourceIpInput = driver.findElement(By.id("sourceIpInput"));
            sourceIpInput.sendKeys("10.99.1.50");

            WebElement destinationIpInput = driver.findElement(By.id("destinationIpInput"));
            destinationIpInput.sendKeys("10.99.1.1");

            WebElement messageInput = driver.findElement(By.id("messageInput"));
            messageInput.sendKeys("Automated encryption activity observed on SMB share \\\\finance\\payroll.");

            // Submit
            WebElement submitBtn = waitForClickable(By.id("submitLogBtn"));
            clickWithJs(submitBtn);

            // Assert Redirection and Flash Success Alert
            WebElement successAlert = waitForVisible(By.id("alertSuccess"));
            assertThat(successAlert.getText()).contains("ingested successfully");

            // Verify Presence in Log Table
            WebElement table = waitForVisible(By.id("logTable"));
            assertThat(table.getText()).contains("RANSOMWARE_OUTBREAK");
            assertThat(table.getText()).contains("10.99.1.50");

            captureScreenshot("Journey2_Ingest_Success");
        } catch (Throwable t) {
            captureScreenshot("Journey2_Ingest_FAILURE");
            throw t;
        }
    }

    @Test
    @DisplayName("Journey 3: Multi-Parameter Search and Severity Filtering")
    void testJourney3_SearchAndFilterLogs() {
        try {
            driver.get(getBaseUrl() + "/logs");

            waitForVisible(By.id("logTable"));

            // Filter by keyword 'SSH'
            WebElement searchInput = driver.findElement(By.id("searchInput"));
            searchInput.clear();
            searchInput.sendKeys("SSH");

            WebElement filterBtn = waitForClickable(By.id("btnSearch"));
            clickWithJs(filterBtn);

            // Wait for URL to update with query and table body to reload
            wait.until(ExpectedConditions.urlContains("keyword=SSH"));
            WebElement tableBody = wait.until(ExpectedConditions.presenceOfElementLocated(By.id("logTableBody")));
            List<WebElement> rows = tableBody.findElements(By.tagName("tr"));
            assertThat(rows).isNotEmpty();

            for (WebElement row : rows) {
                assertThat(row.getText()).containsIgnoringCase("SSH");
            }

            captureScreenshot("Journey3_SearchFilter_Success");
        } catch (Throwable t) {
            captureScreenshot("Journey3_SearchFilter_FAILURE");
            throw t;
        }
    }

    @Test
    @DisplayName("Journey 4: Role-Based Incident Status Workflow Lifecycle")
    void testJourney4_RoleBasedStatusWorkflowLifecycle() {
        try {
            // Step 1: Ingest log
            driver.get(getBaseUrl() + "/logs/new");
            driver.findElement(By.id("eventTypeInput")).sendKeys("DATA_EXFILTRATION");
            new Select(driver.findElement(By.id("severitySelect"))).selectByValue("HIGH");
            driver.findElement(By.id("sourceIpInput")).sendKeys("172.16.0.40");
            driver.findElement(By.id("messageInput")).sendKeys("High volume outbound transfer on port 8080.");
            clickWithJs(driver.findElement(By.id("submitLogBtn")));

            waitForVisible(By.id("alertSuccess"));

            // Click view on the first row
            WebElement firstViewBtn = waitForClickable(By.xpath("//table[@id='logTable']/tbody/tr[1]//a[contains(@id,'viewBtn-')]"));
            clickWithJs(firstViewBtn);

            // Verify Log Details & Initial Status NEW
            waitForVisible(By.id("logDetailCard"));
            WebElement statusBadge = driver.findElement(By.id("logStatusBadge"));
            assertThat(statusBadge.getText()).isEqualTo("NEW");

            // Advance NEW -> IN_REVIEW
            Select targetSelect = new Select(waitForVisible(By.id("targetStatusSelect")));
            targetSelect.selectByValue("IN_REVIEW");

            WebElement reviewerInput = driver.findElement(By.id("workflowReviewerName"));
            reviewerInput.clear();
            reviewerInput.sendKeys("Lead Analyst Bob");

            WebElement notesInput = driver.findElement(By.id("workflowNotes"));
            notesInput.clear();
            notesInput.sendKeys("Initial triage underway. Packet capture extracted.");

            clickWithJs(driver.findElement(By.id("btnSubmitTransition")));

            // Verify Updated Status IN_REVIEW
            waitForVisible(By.id("alertSuccess"));
            statusBadge = driver.findElement(By.id("logStatusBadge"));
            assertThat(statusBadge.getText()).isEqualTo("IN_REVIEW");

            // Advance IN_REVIEW -> ESCALATED
            targetSelect = new Select(waitForVisible(By.id("targetStatusSelect")));
            targetSelect.selectByValue("ESCALATED");
            reviewerInput = driver.findElement(By.id("workflowReviewerName"));
            reviewerInput.clear();
            reviewerInput.sendKeys("Tier 2 Sarah");
            notesInput = driver.findElement(By.id("workflowNotes"));
            notesInput.clear();
            notesInput.sendKeys("Exfiltration volume exceeds 5GB. Alerting CIRT.");

            clickWithJs(driver.findElement(By.id("btnSubmitTransition")));

            // Verify Updated Status ESCALATED
            waitForVisible(By.id("alertSuccess"));
            statusBadge = driver.findElement(By.id("logStatusBadge"));
            assertThat(statusBadge.getText()).isEqualTo("ESCALATED");

            // Advance ESCALATED -> RESOLVED
            targetSelect = new Select(waitForVisible(By.id("targetStatusSelect")));
            targetSelect.selectByValue("RESOLVED");
            reviewerInput = driver.findElement(By.id("workflowReviewerName"));
            reviewerInput.clear();
            reviewerInput.sendKeys("CISO Office");
            notesInput = driver.findElement(By.id("workflowNotes"));
            notesInput.clear();
            notesInput.sendKeys("Traffic blocked at core firewall. Credentials revoked.");

            clickWithJs(driver.findElement(By.id("btnSubmitTransition")));

            // Verify Final Status RESOLVED and audit notice
            waitForVisible(By.id("alertSuccess"));
            statusBadge = driver.findElement(By.id("logStatusBadge"));
            assertThat(statusBadge.getText()).isEqualTo("RESOLVED");
            WebElement resolvedNotice = waitForVisible(By.id("resolvedNotice"));
            assertThat(resolvedNotice.isDisplayed()).isTrue();

            captureScreenshot("Journey4_Workflow_Success");
        } catch (Throwable t) {
            captureScreenshot("Journey4_Workflow_FAILURE");
            throw t;
        }
    }

    @Test
    @DisplayName("Journey 5: Failure Screenshot Capture Mechanism Validation")
    void testJourney5_ScreenshotCaptureMechanism() {
        driver.get(getBaseUrl() + "/dashboard");
        waitForVisible(By.id("dashboardTitle"));

        File screenshot = captureScreenshot("Journey5_Mechanism_Verification");

        assertThat(screenshot).isNotNull();
        assertThat(screenshot.exists()).isTrue();
        assertThat(screenshot.length()).isGreaterThan(1000L); // valid PNG image bytes
    }
}
