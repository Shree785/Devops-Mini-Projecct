package com.securitylog.config;

import com.securitylog.model.LogStatus;
import com.securitylog.model.SecurityLog;
import com.securitylog.model.Severity;
import com.securitylog.repository.SecurityLogRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DataLoader {

    @Bean
    CommandLineRunner initDatabase(SecurityLogRepository repository) {
        return args -> {
            if (repository.count() == 0) {
                SecurityLog log1 = new SecurityLog(
                        "SSH_BRUTE_FORCE",
                        "203.0.113.42",
                        "10.0.0.5",
                        Severity.CRITICAL,
                        "Repeated failed SSH logins detected for root user (15 attempts within 60s)."
                );
                log1.setStatus(LogStatus.IN_REVIEW);
                log1.setReviewerName("Alex Mercer");
                log1.setReviewerNotes("IP added to perimeter firewall blocklist. Analyzing potential lateral movement.");
                repository.save(log1);

                SecurityLog log2 = new SecurityLog(
                        "SQL_INJECTION_ATTEMPT",
                        "198.51.100.23",
                        "10.0.0.8",
                        Severity.HIGH,
                        "WAF blocked malicious payload 'OR 1=1; DROP TABLE users;' targeting /api/v1/auth."
                );
                log2.setStatus(LogStatus.NEW);
                repository.save(log2);

                SecurityLog log3 = new SecurityLog(
                        "PORT_SCAN",
                        "192.168.1.105",
                        "10.0.0.2",
                        Severity.MEDIUM,
                        "Synchronous TCP SYN packets observed across ports 1-1024 originating from internal segment."
                );
                log3.setStatus(LogStatus.NEW);
                repository.save(log3);

                SecurityLog log4 = new SecurityLog(
                        "PRIVILEGE_ESCALATION",
                        "10.0.0.45",
                        "10.0.0.1",
                        Severity.CRITICAL,
                        "Non-sudo user spawned root shell via vulnerable setuid helper script."
                );
                log4.setStatus(LogStatus.ESCALATED);
                log4.setReviewerName("Sarah Chen");
                log4.setReviewerNotes("Security patch applied to host. Revoked user token.");
                repository.save(log4);

                SecurityLog log5 = new SecurityLog(
                        "AUTH_FAILURE",
                        "192.168.1.200",
                        "10.0.0.10",
                        Severity.LOW,
                        "User entered incorrect password 2 times before successful MFA challenge."
                );
                log5.setStatus(LogStatus.RESOLVED);
                log5.setReviewerName("Jordan Taylor");
                log5.setReviewerNotes("False alarm - user mistyped credentials.");
                repository.save(log5);
            }
        };
    }
}
