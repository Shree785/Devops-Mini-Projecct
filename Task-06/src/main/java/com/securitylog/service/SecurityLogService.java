package com.securitylog.service;

import com.securitylog.model.DashboardMetricsDto;
import com.securitylog.model.LogStatus;
import com.securitylog.model.SecurityLog;
import com.securitylog.model.Severity;
import com.securitylog.repository.SecurityLogRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class SecurityLogService {

    private final SecurityLogRepository repository;

    public SecurityLogService(SecurityLogRepository repository) {
        this.repository = repository;
    }

    public SecurityLog createLog(SecurityLog log) {
        if (log.getStatus() == null) {
            log.setStatus(LogStatus.NEW);
        }
        return repository.save(log);
    }

    @Transactional(readOnly = true)
    public List<SecurityLog> getAllLogs() {
        return repository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"));
    }

    @Transactional(readOnly = true)
    public Optional<SecurityLog> getLogById(Long id) {
        return repository.findById(id);
    }

    public SecurityLog updateLog(Long id, SecurityLog updatedLog) {
        SecurityLog existing = repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Security log not found with ID: " + id));

        existing.setEventType(updatedLog.getEventType());
        existing.setSourceIp(updatedLog.getSourceIp());
        existing.setDestinationIp(updatedLog.getDestinationIp());
        existing.setSeverity(updatedLog.getSeverity());
        existing.setMessage(updatedLog.getMessage());
        if (updatedLog.getReviewerName() != null) {
            existing.setReviewerName(updatedLog.getReviewerName());
        }
        if (updatedLog.getReviewerNotes() != null) {
            existing.setReviewerNotes(updatedLog.getReviewerNotes());
        }

        return repository.save(existing);
    }

    public SecurityLog transitionStatus(Long id, LogStatus targetStatus, String reviewerName, String notes) {
        SecurityLog log = repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Security log not found with ID: " + id));

        LogStatus current = log.getStatus();
        if (current == targetStatus) {
            return log; // no-op
        }

        // Validate state machine rules
        boolean isValid = false;
        switch (current) {
            case NEW:
                if (targetStatus == LogStatus.IN_REVIEW) {
                    isValid = true;
                }
                break;
            case IN_REVIEW:
                if (targetStatus == LogStatus.ESCALATED || targetStatus == LogStatus.RESOLVED) {
                    isValid = true;
                }
                break;
            case ESCALATED:
                if (targetStatus == LogStatus.RESOLVED) {
                    isValid = true;
                }
                break;
            case RESOLVED:
                // Terminal state in strict audit mode
                isValid = false;
                break;
        }

        if (!isValid) {
            throw new IllegalStateException("Illegal state transition from " + current + " to " + targetStatus);
        }

        log.setStatus(targetStatus);
        if (reviewerName != null && !reviewerName.trim().isEmpty()) {
            log.setReviewerName(reviewerName.trim());
        }
        if (notes != null && !notes.trim().isEmpty()) {
            String existingNotes = log.getReviewerNotes() != null ? log.getReviewerNotes() + "\n" : "";
            log.setReviewerNotes(existingNotes + "[" + LocalDateTime.now() + " - " + targetStatus + "] " + notes.trim());
        }

        return repository.save(log);
    }

    @Transactional(readOnly = true)
    public List<SecurityLog> searchLogs(String keyword, Severity severity, LogStatus status) {
        String cleanKeyword = (keyword != null && !keyword.trim().isEmpty()) ? keyword.trim() : null;
        return repository.searchLogs(cleanKeyword, severity, status);
    }

    @Transactional(readOnly = true)
    public DashboardMetricsDto getDashboardMetrics() {
        long totalLogs = repository.count();
        long criticalCount = repository.countBySeverity(Severity.CRITICAL);
        long highCount = repository.countBySeverity(Severity.HIGH);
        long mediumCount = repository.countBySeverity(Severity.MEDIUM);
        long lowCount = repository.countBySeverity(Severity.LOW);

        long newCount = repository.countByStatus(LogStatus.NEW);
        long inReviewCount = repository.countByStatus(LogStatus.IN_REVIEW);
        long escalatedCount = repository.countByStatus(LogStatus.ESCALATED);
        long resolvedCount = repository.countByStatus(LogStatus.RESOLVED);

        List<SecurityLog> recentLogs = repository.findAll(
                PageRequest.of(0, 5, Sort.by(Sort.Direction.DESC, "createdAt"))
        ).getContent();

        return new DashboardMetricsDto(
                totalLogs, criticalCount, highCount, mediumCount, lowCount,
                newCount, inReviewCount, escalatedCount, resolvedCount, recentLogs
        );
    }

    public void deleteLog(Long id) {
        if (!repository.existsById(id)) {
            throw new IllegalArgumentException("Security log not found with ID: " + id);
        }
        repository.deleteById(id);
    }
}
