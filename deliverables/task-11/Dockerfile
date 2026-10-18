# ==============================================================================
# Enterprise Hardened Dockerfile: Security Log Review System
# Base: Eclipse Temurin 17 JRE on Alpine Linux (Ultra-lightweight & Minimal Attack Surface)
# ==============================================================================

FROM eclipse-temurin:17-jre-alpine AS runtime

LABEL maintainer="SecOps Team <secops@enterprise-soc.local>" \
      project="security-log-review" \
      version="1.0.0" \
      description="Production Container for Enterprise Security Log Review System"

# Install curl for container health checks and timezone support
RUN apk add --no-cache curl tzdata

# Security Hardening: Dedicated least-privilege non-root service account
RUN addgroup -S appgroup -g 1001 && \
    adduser -S appuser -u 1001 -G appgroup

WORKDIR /app

# Copy production Spring Boot executable JAR
COPY target/security-log-review-1.0.0.jar /app/app.jar

# Enforce strict file ownership and execution permissions
RUN chown -R appuser:appgroup /app && \
    chmod 500 /app/app.jar

# Switch to unprivileged runtime user (UID 1001)
USER appuser:appgroup

# Expose Spring Boot web port
EXPOSE 8080

# JVM container support & heap sizing
ENV SERVER_PORT=8080 \
    SPRING_PROFILES_ACTIVE=production \
    JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError -Djava.security.egd=file:/dev/./urandom"

# Native Docker container healthcheck against Spring Boot Actuator
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Container entrypoint
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/app.jar"]
