package com.securitylog;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Ansible-Provisioned Security Log Review System
 * Main Spring Boot Application Entry Point
 */
@SpringBootApplication
public class SecurityLogApplication {

    public static void main(String[] args) {
        SpringApplication.run(SecurityLogApplication.class, args);
    }
}
