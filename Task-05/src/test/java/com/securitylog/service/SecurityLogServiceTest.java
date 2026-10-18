package com.securitylog.service;

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
    void testDeleteLog_Success() {
        SecurityLog log = logService.createLog(new SecurityLog("TEST_EVENT", "1.1.1.1", "2.2.2.2", 
                Severity.LOW, "Test log to delete"));

        logService.deleteLog(log.getId());

        assertThat(logService.getLogById(log.getId())).isEmpty();
    }
}
