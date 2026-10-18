package com.securitylog.controller;

import com.securitylog.model.DashboardMetricsDto;
import com.securitylog.model.LogStatus;
import com.securitylog.model.SecurityLog;
import com.securitylog.model.Severity;
import com.securitylog.model.StatusTransitionRequest;
import com.securitylog.service.SecurityLogService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/logs")
public class LogRestController {

    private final SecurityLogService logService;

    public LogRestController(SecurityLogService logService) {
        this.logService = logService;
    }

    @GetMapping
    public ResponseEntity<List<SecurityLog>> getAllLogs(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Severity severity,
            @RequestParam(required = false) LogStatus status) {
        return ResponseEntity.ok(logService.searchLogs(keyword, severity, status));
    }

    @GetMapping("/{id}")
    public ResponseEntity<SecurityLog> getLogById(@PathVariable Long id) {
        return logService.getLogById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/metrics")
    public ResponseEntity<DashboardMetricsDto> getMetrics() {
        return ResponseEntity.ok(logService.getDashboardMetrics());
    }

    @PostMapping
    public ResponseEntity<SecurityLog> createLog(@Valid @RequestBody SecurityLog log) {
        SecurityLog created = logService.createLog(log);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<SecurityLog> updateLog(@PathVariable Long id, @Valid @RequestBody SecurityLog log) {
        try {
            SecurityLog updated = logService.updateLog(id, log);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<?> transitionStatus(@PathVariable Long id, 
                                              @Valid @RequestBody StatusTransitionRequest request) {
        try {
            SecurityLog updated = logService.transitionStatus(
                    id, 
                    request.getTargetStatus(), 
                    request.getReviewerName(), 
                    request.getReviewerNotes()
            );
            return ResponseEntity.ok(updated);
        } catch (IllegalStateException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteLog(@PathVariable Long id) {
        try {
            logService.deleteLog(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
