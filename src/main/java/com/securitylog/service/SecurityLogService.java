package com.securitylog.service;

import com.securitylog.model.LogStatus;
import com.securitylog.model.SecurityLog;
import com.securitylog.model.Severity;
import com.securitylog.repository.SecurityLogRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
        return repository.findAll();
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

    @Transactional(readOnly = true)
    public List<SecurityLog> searchLogs(String keyword, Severity severity, LogStatus status) {
        String cleanKeyword = (keyword != null && !keyword.trim().isEmpty()) ? keyword.trim() : null;
        return repository.searchLogs(cleanKeyword, severity, status);
    }

    public void deleteLog(Long id) {
        if (!repository.existsById(id)) {
            throw new IllegalArgumentException("Security log not found with ID: " + id);
        }
        repository.deleteById(id);
    }
}
