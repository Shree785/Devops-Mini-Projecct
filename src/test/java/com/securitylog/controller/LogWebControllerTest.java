package com.securitylog.controller;

import com.securitylog.model.LogStatus;
import com.securitylog.model.SecurityLog;
import com.securitylog.model.Severity;
import com.securitylog.service.SecurityLogService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class LogWebControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private SecurityLogService logService;

    @Test
    void testListLogs_ReturnsOkAndContainsTable() throws Exception {
        logService.createLog(new SecurityLog("DDoS_ALERT", "203.0.113.10", "10.0.0.1", Severity.CRITICAL, "High SYN packet volume"));

        mockMvc.perform(get("/logs"))
                .andExpect(status().isOk())
                .andExpect(view().name("logs"))
                .andExpect(model().attributeExists("logs"))
                .andExpect(content().string(containsString("DDoS_ALERT")));
    }

    @Test
    void testShowCreateForm_ReturnsOk() throws Exception {
        mockMvc.perform(get("/logs/new"))
                .andExpect(status().isOk())
                .andExpect(view().name("log-create"))
                .andExpect(model().attributeExists("securityLog"))
                .andExpect(model().attributeExists("allSeverities"));
    }

    @Test
    void testCreateLog_RedirectsOnSuccess() throws Exception {
        mockMvc.perform(post("/logs/new")
                        .param("eventType", "RANSOMWARE_SUSPICION")
                        .param("sourceIp", "10.0.0.99")
                        .param("destinationIp", "10.0.0.100")
                        .param("severity", "CRITICAL")
                        .param("message", "Mass file rename operations observed on share."))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/logs"))
                .andExpect(flash().attributeExists("successMessage"));
    }

    @Test
    void testViewLogDetail_ReturnsOk() throws Exception {
        SecurityLog log = logService.createLog(new SecurityLog("EXFIL_ATTEMPT", "10.0.0.22", "198.51.100.5", 
                Severity.HIGH, "Outbound DNS tunneling query"));

        mockMvc.perform(get("/logs/" + log.getId()))
                .andExpect(status().isOk())
                .andExpect(view().name("log-detail"))
                .andExpect(model().attributeExists("log"))
                .andExpect(content().string(containsString("EXFIL_ATTEMPT")));
    }
}
