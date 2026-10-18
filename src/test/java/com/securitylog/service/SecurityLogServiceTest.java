package com.securitylog.service;

import com.securitylog.model.DashboardMetricsDto;
import com.securitylog.model.LogStatus;
import com.securitylog.model.SecurityLog;
import com.securitylog.model.Severity;
import com.securitylog.repository.SecurityLogRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;

@SpringBootTest
@Transactional
class SecurityLogServiceTest {

    @Autowired
    private SecurityLogService logService;

    @Autowired
    private SecurityLogRepository repository;

    @BeforeEach
    void setUp() {
        repository.deleteAll();
    }

    @Test
    void testCreateLog_Success() {
        SecurityLog log = new SecurityLog("MALWARE_BEACON", "10.10.10.50", "198.51.100.1", 
                Severity.CRITICAL, "C2 beaconing detected over HTTPS port 443");

        SecurityLog created = logService.createLog(log);

        assertThat(created.getId()).isNotNull();
        assertThat(created.getEventType()).isEqualTo("MALWARE_BEACON");
        assertThat(created.getStatus()).isEqualTo(LogStatus.NEW);
        assertThat(created.getCreatedAt()).isNotNull();
    }

    @Test
    void testGetLogById_Found() {
        SecurityLog log = logService.createLog(new SecurityLog("PORT_SCAN", "192.168.1.1", "10.0.0.1", 
                Severity.LOW, "Port sweep observed"));

        Optional<SecurityLog> found = logService.getLogById(log.getId());

        assertThat(found).isPresent();
        assertThat(found.get().getEventType()).isEqualTo("PORT_SCAN");
    }

    @Test
    void testUpdateLog_Success() {
        SecurityLog log = logService.createLog(new SecurityLog("AUTH_FAILURE", "192.168.1.2", "10.0.0.1", 
                Severity.MEDIUM, "Invalid password attempt"));

        SecurityLog updateDetails = new SecurityLog("AUTH_FAILURE", "192.168.1.2", "10.0.0.1", 
                Severity.HIGH, "Multiple brute force attempts confirmed");
        updateDetails.setReviewerName("Auditor A");
        updateDetails.setReviewerNotes("Investigating user account lockout");

        SecurityLog updated = logService.updateLog(log.getId(), updateDetails);

        assertThat(updated.getSeverity()).isEqualTo(Severity.HIGH);
        assertThat(updated.getReviewerName()).isEqualTo("Auditor A");
        assertThat(updated.getReviewerNotes()).isEqualTo("Investigating user account lockout");
    }

    @Test
    void testSearchLogs_ByKeyword() {
        logService.createLog(new SecurityLog("SQL_INJECTION", "10.0.0.15", "10.0.0.1", Severity.HIGH, "SQL syntax error"));
        logService.createLog(new SecurityLog("PORT_SCAN", "10.0.0.20", "10.0.0.1", Severity.LOW, "TCP scan"));

        List<SecurityLog> results = logService.searchLogs("SQL", null, null);

        assertThat(results).hasSize(1);
        assertThat(results.get(0).getEventType()).isEqualTo("SQL_INJECTION");
    }

    @Test
    void testStatusWorkflow_ValidTransitions() {
        // Step 1: Create in NEW
        SecurityLog log = logService.createLog(new SecurityLog("RANSOMWARE", "10.0.0.5", "10.0.0.1", 
                Severity.CRITICAL, "Suspicious encrypt activity"));
        assertThat(log.getStatus()).isEqualTo(LogStatus.NEW);

        // Step 2: Transition NEW -> IN_REVIEW
        SecurityLog inReview = logService.transitionStatus(log.getId(), LogStatus.IN_REVIEW, "Analyst Dave", "Starting memory dump analysis");
        assertThat(inReview.getStatus()).isEqualTo(LogStatus.IN_REVIEW);
        assertThat(inReview.getReviewerName()).isEqualTo("Analyst Dave");

        // Step 3: Transition IN_REVIEW -> ESCALATED
        SecurityLog escalated = logService.transitionStatus(log.getId(), LogStatus.ESCALATED, "Lead Alice", "Escalating to Incident Command");
        assertThat(escalated.getStatus()).isEqualTo(LogStatus.ESCALATED);

        // Step 4: Transition ESCALATED -> RESOLVED
        SecurityLog resolved = logService.transitionStatus(log.getId(), LogStatus.RESOLVED, "Lead Alice", "Host isolated and re-imaged");
        assertThat(resolved.getStatus()).isEqualTo(LogStatus.RESOLVED);
    }

    @Test
    void testStatusWorkflow_IllegalTransition_ThrowsException() {
        SecurityLog log = logService.createLog(new SecurityLog("ANOMALY", "10.0.0.5", "10.0.0.1", 
                Severity.LOW, "Minor traffic deviation"));

        // Direct transition from NEW to RESOLVED without IN_REVIEW is prohibited
        assertThrows(IllegalStateException.class, () -> 
                logService.transitionStatus(log.getId(), LogStatus.RESOLVED, "Auditor", "Skipping review")
        );
    }

    @Test
    void testDashboardMetrics_Calculation() {
        logService.createLog(new SecurityLog("EVENT_1", "1.1.1.1", null, Severity.CRITICAL, "Crit event"));
        logService.createLog(new SecurityLog("EVENT_2", "1.1.1.2", null, Severity.HIGH, "High event"));
        logService.createLog(new SecurityLog("EVENT_3", "1.1.1.3", null, Severity.LOW, "Low event"));

        DashboardMetricsDto metrics = logService.getDashboardMetrics();

        assertThat(metrics.getTotalLogs()).isEqualTo(3);
        assertThat(metrics.getCriticalCount()).isEqualTo(1);
        assertThat(metrics.getHighCount()).isEqualTo(1);
        assertThat(metrics.getLowCount()).isEqualTo(1);
        assertThat(metrics.getNewCount()).isEqualTo(3);
    }

    @Test
    void testDeleteLog_Success() {
        SecurityLog log = logService.createLog(new SecurityLog("TEST_EVENT", "1.1.1.1", "2.2.2.2", 
                Severity.LOW, "Test log to delete"));

        logService.deleteLog(log.getId());

        assertThat(logService.getLogById(log.getId())).isEmpty();
    }
}
