package com.securitylog.repository;

import com.securitylog.model.LogStatus;
import com.securitylog.model.SecurityLog;
import com.securitylog.model.Severity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SecurityLogRepository extends JpaRepository<SecurityLog, Long> {

    List<SecurityLog> findByStatus(LogStatus status);

    List<SecurityLog> findBySeverity(Severity severity);

    @Query("SELECT l FROM SecurityLog l WHERE " +
           "(:keyword IS NULL OR LOWER(l.eventType) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(l.sourceIp) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(l.destinationIp) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(l.message) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
           "AND (:severity IS NULL OR l.severity = :severity) " +
           "AND (:status IS NULL OR l.status = :status) " +
           "ORDER BY l.createdAt DESC")
    List<SecurityLog> searchLogs(@Param("keyword") String keyword,
                                 @Param("severity") Severity severity,
                                 @Param("status") LogStatus status);

    long countByStatus(LogStatus status);

    long countBySeverity(Severity severity);
}
