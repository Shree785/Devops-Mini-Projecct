package com.securitylog.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class StatusTransitionRequest {

    @NotNull(message = "New target status is required")
    private LogStatus targetStatus;

    @NotBlank(message = "Reviewer name is required for status transition")
    private String reviewerName;

    @NotBlank(message = "Triage / review notes are required for status transition")
    private String reviewerNotes;

    public StatusTransitionRequest() {
    }

    public StatusTransitionRequest(LogStatus targetStatus, String reviewerName, String reviewerNotes) {
        this.targetStatus = targetStatus;
        this.reviewerName = reviewerName;
        this.reviewerNotes = reviewerNotes;
    }

    public LogStatus getTargetStatus() {
        return targetStatus;
    }

    public void setTargetStatus(LogStatus targetStatus) {
        this.targetStatus = targetStatus;
    }

    public String getReviewerName() {
        return reviewerName;
    }

    public void setReviewerName(String reviewerName) {
        this.reviewerName = reviewerName;
    }

    public String getReviewerNotes() {
        return reviewerNotes;
    }

    public void setReviewerNotes(String reviewerNotes) {
        this.reviewerNotes = reviewerNotes;
    }
}
