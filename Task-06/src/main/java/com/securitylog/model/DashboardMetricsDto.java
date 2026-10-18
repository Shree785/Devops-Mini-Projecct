package com.securitylog.model;

import java.util.List;

public class DashboardMetricsDto {

    private long totalLogs;
    private long criticalCount;
    private long highCount;
    private long mediumCount;
    private long lowCount;
    private long newCount;
    private long inReviewCount;
    private long escalatedCount;
    private long resolvedCount;
    private List<SecurityLog> recentLogs;

    public DashboardMetricsDto() {
    }

    public DashboardMetricsDto(long totalLogs, long criticalCount, long highCount, long mediumCount,
                               long lowCount, long newCount, long inReviewCount, long escalatedCount,
                               long resolvedCount, List<SecurityLog> recentLogs) {
        this.totalLogs = totalLogs;
        this.criticalCount = criticalCount;
        this.highCount = highCount;
        this.mediumCount = mediumCount;
        this.lowCount = lowCount;
        this.newCount = newCount;
        this.inReviewCount = inReviewCount;
        this.escalatedCount = escalatedCount;
        this.resolvedCount = resolvedCount;
        this.recentLogs = recentLogs;
    }

    public long getTotalLogs() {
        return totalLogs;
    }

    public void setTotalLogs(long totalLogs) {
        this.totalLogs = totalLogs;
    }

    public long getCriticalCount() {
        return criticalCount;
    }

    public void setCriticalCount(long criticalCount) {
        this.criticalCount = criticalCount;
    }

    public long getHighCount() {
        return highCount;
    }

    public void setHighCount(long highCount) {
        this.highCount = highCount;
    }

    public long getMediumCount() {
        return mediumCount;
    }

    public void setMediumCount(long mediumCount) {
        this.mediumCount = mediumCount;
    }

    public long getLowCount() {
        return lowCount;
    }

    public void setLowCount(long lowCount) {
        this.lowCount = lowCount;
    }

    public long getNewCount() {
        return newCount;
    }

    public void setNewCount(long newCount) {
        this.newCount = newCount;
    }

    public long getInReviewCount() {
        return inReviewCount;
    }

    public void setInReviewCount(long inReviewCount) {
        this.inReviewCount = inReviewCount;
    }

    public long getEscalatedCount() {
        return escalatedCount;
    }

    public void setEscalatedCount(long escalatedCount) {
        this.escalatedCount = escalatedCount;
    }

    public long getResolvedCount() {
        return resolvedCount;
    }

    public void setResolvedCount(long resolvedCount) {
        this.resolvedCount = resolvedCount;
    }

    public List<SecurityLog> getRecentLogs() {
        return recentLogs;
    }

    public void setRecentLogs(List<SecurityLog> recentLogs) {
        this.recentLogs = recentLogs;
    }

    public long getCriticalAndHighCount() {
        return criticalCount + highCount;
    }
}
