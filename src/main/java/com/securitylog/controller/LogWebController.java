package com.securitylog.controller;

import com.securitylog.model.LogStatus;
import com.securitylog.model.SecurityLog;
import com.securitylog.model.Severity;
import com.securitylog.service.SecurityLogService;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
public class LogWebController {

    private final SecurityLogService logService;

    public LogWebController(SecurityLogService logService) {
        this.logService = logService;
    }

    @GetMapping("/")
    public String index() {
        return "redirect:/logs";
    }

    @GetMapping("/logs")
    public String listLogs(@RequestParam(required = false) String keyword,
                           @RequestParam(required = false) Severity severity,
                           @RequestParam(required = false) LogStatus status,
                           Model model) {
        List<SecurityLog> logs = logService.searchLogs(keyword, severity, status);
        model.addAttribute("logs", logs);
        model.addAttribute("keyword", keyword);
        model.addAttribute("severity", severity);
        model.addAttribute("status", status);
        model.addAttribute("allSeverities", Severity.values());
        model.addAttribute("allStatuses", LogStatus.values());
        return "logs";
    }

    @GetMapping("/logs/new")
    public String showCreateForm(Model model) {
        if (!model.containsAttribute("securityLog")) {
            model.addAttribute("securityLog", new SecurityLog());
        }
        model.addAttribute("allSeverities", Severity.values());
        return "log-create";
    }

    @PostMapping("/logs/new")
    public String createLog(@Valid @ModelAttribute("securityLog") SecurityLog securityLog,
                            BindingResult bindingResult,
                            RedirectAttributes redirectAttributes,
                            Model model) {
        if (bindingResult.hasErrors()) {
            model.addAttribute("allSeverities", Severity.values());
            return "log-create";
        }

        SecurityLog created = logService.createLog(securityLog);
        redirectAttributes.addFlashAttribute("successMessage", 
                "Security log #" + created.getId() + " ingested successfully!");
        return "redirect:/logs";
    }

    @GetMapping("/logs/{id}")
    public String viewLog(@PathVariable Long id, Model model) {
        SecurityLog log = logService.getLogById(id)
                .orElseThrow(() -> new IllegalArgumentException("Security log not found: " + id));
        model.addAttribute("log", log);
        model.addAttribute("allStatuses", LogStatus.values());
        return "log-detail";
    }

    @GetMapping("/logs/{id}/edit")
    public String showEditForm(@PathVariable Long id, Model model) {
        SecurityLog log = logService.getLogById(id)
                .orElseThrow(() -> new IllegalArgumentException("Security log not found: " + id));
        model.addAttribute("securityLog", log);
        model.addAttribute("allSeverities", Severity.values());
        return "log-edit";
    }

    @PostMapping("/logs/{id}/edit")
    public String updateLog(@PathVariable Long id,
                            @Valid @ModelAttribute("securityLog") SecurityLog securityLog,
                            BindingResult bindingResult,
                            RedirectAttributes redirectAttributes,
                            Model model) {
        if (bindingResult.hasErrors()) {
            model.addAttribute("allSeverities", Severity.values());
            return "log-edit";
        }

        logService.updateLog(id, securityLog);
        redirectAttributes.addFlashAttribute("successMessage", 
                "Security log #" + id + " updated successfully!");
        return "redirect:/logs/" + id;
    }

    @PostMapping("/logs/{id}/delete")
    public String deleteLog(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        logService.deleteLog(id);
        redirectAttributes.addFlashAttribute("successMessage", 
                "Security log #" + id + " deleted successfully!");
        return "redirect:/logs";
    }
}
