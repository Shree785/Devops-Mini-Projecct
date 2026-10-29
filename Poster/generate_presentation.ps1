# Script to generate a professional 6-slide PowerPoint presentation
param (
    [string]$OutputPath = "D:\ASSIGNMENTS\DEVOPS\DEVOPS PROJECT\Poster\DevOps_Project_Presentation.pptx"
)

function Get-RGB([int]$r, [int]$g, [int]$b) {
    return [int]($r + ($g * 256) + ($b * 65536))
}

$cDarkNavy    = Get-RGB 15 23 42
$cCardDark    = Get-RGB 30 41 59
$cWhite       = Get-RGB 255 255 255
$cCyan        = Get-RGB 14 165 233
$cBlue        = Get-RGB 37 99 235
$cGreen       = Get-RGB 16 185 129
$cAmber       = Get-RGB 245 158 11
$cPurple      = Get-RGB 139 92 246
$cTextMuted   = Get-RGB 148 163 184
$cLightBg     = Get-RGB 248 250 252
$cBorderLight = Get-RGB 226 232 240

$msoTrue = -1
$msoFalse = 0
$ppLayoutBlank = 12

Write-Host "Initializing PowerPoint Application..."
$ppt = New-Object -ComObject PowerPoint.Application
$ppt.Visible = $msoTrue

$pres = $ppt.Presentations.Add($msoTrue)
$pres.PageSetup.SlideWidth = 960
$pres.PageSetup.SlideHeight = 540

function Add-Header {
    param($slide, [string]$category, [string]$title, [int]$slideNum)

    $bg = $slide.Shapes.AddShape(1, 0, 0, 960, 540)
    $bg.Fill.Solid()
    $bg.Fill.ForeColor.RGB = $cLightBg
    $bg.Line.Visible = $msoFalse

    $bar = $slide.Shapes.AddShape(1, 0, 0, 960, 6)
    $bar.Fill.Solid()
    $bar.Fill.ForeColor.RGB = $cCyan
    $bar.Line.Visible = $msoFalse

    $badge = $slide.Shapes.AddShape(1, 40, 24, 160, 22)
    $badge.Fill.Solid()
    $badge.Fill.ForeColor.RGB = (Get-RGB 224 242 254)
    $badge.Line.Visible = $msoFalse
    $badge.TextFrame.TextRange.Text = $category.ToUpper()
    $badge.TextFrame.TextRange.Font.Name = "Segoe UI"
    $badge.TextFrame.TextRange.Font.Size = 10
    $badge.TextFrame.TextRange.Font.Bold = $msoTrue
    $badge.TextFrame.TextRange.Font.Color.RGB = $cBlue

    $tb = $slide.Shapes.AddTextbox(1, 38, 50, 750, 40)
    $tb.TextFrame.WordWrap = $msoTrue
    $tb.TextFrame.MarginLeft = 0
    $tb.TextFrame.MarginTop = 0
    $tr = $tb.TextFrame.TextRange
    $tr.Text = $title
    $tr.Font.Name = "Segoe UI"
    $tr.Font.Size = 22
    $tr.Font.Bold = $msoTrue
    $tr.Font.Color.RGB = $cDarkNavy

    $pill = $slide.Shapes.AddShape(1, 860, 24, 60, 24)
    $pill.Fill.Solid()
    $pill.Fill.ForeColor.RGB = (Get-RGB 241 245 249)
    $pill.Line.Visible = $msoFalse
    $pill.TextFrame.TextRange.Text = "$slideNum / 6"
    $pill.TextFrame.TextRange.Font.Name = "Segoe UI"
    $pill.TextFrame.TextRange.Font.Size = 10
    $pill.TextFrame.TextRange.Font.Bold = $msoTrue
    $pill.TextFrame.TextRange.Font.Color.RGB = $cTextMuted

    $ft = $slide.Shapes.AddTextbox(1, 40, 510, 880, 20)
    $ft.TextFrame.MarginLeft = 0
    $ft.TextFrame.MarginTop = 0
    $ftr = $ft.TextFrame.TextRange
    $ftr.Text = "DevSecOps Capstone Project | Amogh Kulkarni (23102C0003)"
    $ftr.Font.Name = "Segoe UI"
    $ftr.Font.Size = 9
    $ftr.Font.Color.RGB = $cTextMuted
}

function Add-Card {
    param($slide, [double]$x, [double]$y, [double]$w, [double]$h, [string]$title, [string[]]$points, [int]$accentColor)

    $card = $slide.Shapes.AddShape(1, $x, $y, $w, $h)
    $card.Fill.Solid()
    $card.Fill.ForeColor.RGB = $cWhite
    $card.Line.ForeColor.RGB = $cBorderLight
    $card.Line.Weight = 1

    $stripe = $slide.Shapes.AddShape(1, $x, $y, 5, $h)
    $stripe.Fill.Solid()
    $stripe.Fill.ForeColor.RGB = $accentColor
    $stripe.Line.Visible = $msoFalse

    $tbTitle = $slide.Shapes.AddTextbox(1, ($x + 20), ($y + 15), ($w - 35), 30)
    $tbTitle.TextFrame.MarginLeft = 0
    $tbTitle.TextFrame.MarginTop = 0
    $trT = $tbTitle.TextFrame.TextRange
    $trT.Text = $title
    $trT.Font.Name = "Segoe UI"
    $trT.Font.Size = 14
    $trT.Font.Bold = $msoTrue
    $trT.Font.Color.RGB = $cDarkNavy

    $tbContent = $slide.Shapes.AddTextbox(1, ($x + 20), ($y + 48), ($w - 35), ($h - 55))
    $tbContent.TextFrame.MarginLeft = 0
    $tbContent.TextFrame.MarginTop = 0
    $tbContent.TextFrame.WordWrap = $msoTrue
    $trC = $tbContent.TextFrame.TextRange

    $bulletSymbol = [char]0x2022
    $lines = @()
    foreach ($pt in $points) {
        $lines += "$bulletSymbol  $pt"
    }
    $trC.Text = ($lines -join "`n`n")
    $trC.Font.Name = "Segoe UI"
    $trC.Font.Size = 11
    $trC.Font.Color.RGB = (Get-RGB 51 65 85)
}

# SLIDE 1
Write-Host "Creating Slide 1: Title Slide..."
$s1 = $pres.Slides.Add(1, $ppLayoutBlank)

$s1Bg = $s1.Shapes.AddShape(1, 0, 0, 960, 540)
$s1Bg.Fill.Solid()
$s1Bg.Fill.ForeColor.RGB = $cDarkNavy
$s1Bg.Line.Visible = $msoFalse

$s1Bar = $s1.Shapes.AddShape(1, 0, 0, 960, 6)
$s1Bar.Fill.Solid()
$s1Bar.Fill.ForeColor.RGB = $cCyan
$s1Bar.Line.Visible = $msoFalse

$badge1 = $s1.Shapes.AddShape(1, 70, 75, 230, 26)
$badge1.Fill.Solid()
$badge1.Fill.ForeColor.RGB = (Get-RGB 30 41 59)
$badge1.Line.ForeColor.RGB = $cCyan
$badge1.Line.Weight = 1
$badge1.TextFrame.TextRange.Text = "DEVOPS ENGINEERING CAPSTONE"
$badge1.TextFrame.TextRange.Font.Name = "Segoe UI"
$badge1.TextFrame.TextRange.Font.Size = 10
$badge1.TextFrame.TextRange.Font.Bold = $msoTrue
$badge1.TextFrame.TextRange.Font.Color.RGB = $cCyan

$tbS1Title = $s1.Shapes.AddTextbox(1, 68, 115, 820, 110)
$tbS1Title.TextFrame.WordWrap = $msoTrue
$tbS1Title.TextFrame.MarginLeft = 0
$trS1Title = $tbS1Title.TextFrame.TextRange
$trS1Title.Text = "Ansible-Provisioned Security`nLog Review System"
$trS1Title.Font.Name = "Segoe UI"
$trS1Title.Font.Size = 36
$trS1Title.Font.Bold = $msoTrue
$trS1Title.Font.Color.RGB = $cWhite

$tbS1Sub = $s1.Shapes.AddTextbox(1, 70, 235, 820, 50)
$tbS1Sub.TextFrame.WordWrap = $msoTrue
$tbS1Sub.TextFrame.MarginLeft = 0
$trS1Sub = $tbS1Sub.TextFrame.TextRange
$trS1Sub.Text = "End-to-End DevSecOps Automation: Spring Boot 3, GitFlow, Automated CI/CD Testing, Docker Hardening and Idempotent Ansible Orchestration"
$trS1Sub.Font.Name = "Segoe UI"
$trS1Sub.Font.Size = 13
$trS1Sub.Font.Color.RGB = $cTextMuted

$authCard = $s1.Shapes.AddShape(1, 70, 315, 400, 145)
$authCard.Fill.Solid()
$authCard.Fill.ForeColor.RGB = $cCardDark
$authCard.Line.ForeColor.RGB = (Get-RGB 51 65 85)
$authCard.Line.Weight = 1

$tbAuth = $s1.Shapes.AddTextbox(1, 95, 330, 350, 120)
$tbAuth.TextFrame.WordWrap = $msoTrue
$tbAuth.TextFrame.MarginLeft = 0
$trAuth = $tbAuth.TextFrame.TextRange
$trAuth.Text = "STUDENT PRESENTER`nAmogh Kulkarni`nRoll No: 23102C0003`nDepartment of DevOps and Cloud Systems"
$trAuth.Font.Name = "Segoe UI"
$trAuth.Font.Size = 12
$trAuth.Font.Color.RGB = $cWhite

$techCard = $s1.Shapes.AddShape(1, 490, 315, 400, 145)
$techCard.Fill.Solid()
$techCard.Fill.ForeColor.RGB = $cCardDark
$techCard.Line.ForeColor.RGB = (Get-RGB 51 65 85)
$techCard.Line.Weight = 1

$tbTech = $s1.Shapes.AddTextbox(1, 515, 330, 350, 120)
$tbTech.TextFrame.WordWrap = $msoTrue
$tbTech.TextFrame.MarginLeft = 0
$trTech = $tbTech.TextFrame.TextRange
$trTech.Text = "KEY PROJECT HIGHLIGHTS`n* 14 Fully Realized DevOps Milestones`n* 100% Automated Quality Gate (15 JUnit + Selenium)`n* 166 MB Alpine Hardened Container`n* Verified Idempotent Ansible Deployment (changed=0)"
$trTech.Font.Name = "Segoe UI"
$trTech.Font.Size = 11
$trTech.Font.Color.RGB = $cTextMuted

# SLIDE 2
Write-Host "Creating Slide 2: Problem Statement..."
$s2 = $pres.Slides.Add(2, $ppLayoutBlank)
Add-Header -slide $s2 -category "Project Motivation" -title "Problem Statement and Project Objectives" -slideNum 2

$pts2A = @(
    "Alert Fatigue: SOC analysts are overwhelmed by millions of raw, heterogeneous log lines daily with no unified triage.",
    "Delayed Incident Response: High-severity intrusion attempts go unnoticed due to slow manual log parsing.",
    "Manual Deployment Risk: Traditional server provisioning results in configuration drift and high operational downtime.",
    "Lack of Automated Quality Gates: Vulnerable code frequently bypasses manual reviews into production environments."
)
Add-Card -slide $s2 -x 40 -y 105 -w 425 -h 385 -title "The Security Operations Problem" -points $pts2A -accentColor $cAmber

$pts2B = @(
    "Automated Log Ingestion: Real-time parsing, classification, and severity-tagging (CRITICAL, WARN, INFO).",
    "Continuous Quality Assurance: Full CI pipeline executing 15 unit tests and Selenium browser testing before build.",
    "Production-Ready Containerization: Multi-stage lightweight Alpine image running as non-root service account.",
    "Zero-Drift Orchestration: Complete Ansible automation with verified idempotency (changed=0) and 15s rollback."
)
Add-Card -slide $s2 -x 495 -y 105 -w 425 -h 385 -title "Core Engineering Objectives" -points $pts2B -accentColor $cBlue

# SLIDE 3
Write-Host "Creating Slide 3: Architecture..."
$s3 = $pres.Slides.Add(3, $ppLayoutBlank)
Add-Header -slide $s3 -category "System Design" -title "System Architecture and Core Technology Stack" -slideNum 3

$pts3A = @(
    "Spring Boot 3.2.x: Modern microservice framework with Java 17 LTS support.",
    "Embedded Tomcat 10: High-throughput HTTP container optimized for cloud deployments.",
    "Spring Security: Role-based access control protecting triage and admin routes.",
    "Actuator: Production telemetry exposing /health, /info, and /metrics endpoints."
)
Add-Card -slide $s3 -x 40 -y 105 -w 275 -h 385 -title "Backend and Core Engine" -points $pts3A -accentColor $cBlue

$pts3B = @(
    "In-Memory H2 DB: Zero external dependency, sub-millisecond query execution for forensic review.",
    "JPA / Hibernate: Efficient ORM data models mapping security event streams.",
    "Thymeleaf 3: Server-side rendering delivering fast, responsive views.",
    "Bootstrap 5: Dark/light interactive dashboards with instant filter controls."
)
Add-Card -slide $s3 -x 340 -y 105 -w 275 -h 385 -title "Data and Presentation" -points $pts3B -accentColor $cGreen

$pts3C = @(
    "Maven: Multi-phase build management with reproducible artifact packaging.",
    "GitFlow: Structured branching (feature to develop to main) with branch protection.",
    "Docker: Multi-stage Alpine containerization for minimal attack surface.",
    "Ansible: Declarative IaC automating deployment, config, and rollback."
)
Add-Card -slide $s3 -x 640 -y 105 -w 275 -h 385 -title "DevOps and Toolchain" -points $pts3C -accentColor $cPurple

# SLIDE 4
Write-Host "Creating Slide 4: CI/CD..."
$s4 = $pres.Slides.Add(4, $ppLayoutBlank)
Add-Header -slide $s4 -category "Quality Assurance" -title "CI/CD Pipeline and Automated Testing Quality Gates" -slideNum 4

$pts4A = @(
    "Jenkins Declarative Pipeline: Fully automated stages for Checkout, Build, Unit Test, UI Test, Package, and Deploy.",
    "Automated Triggers: Webhooks run quality validation on every pull request and commit.",
    "Artifact Lifecycle: Successful builds produce versioned, runnable Spring Boot JARs stored in the artifact repository.",
    "Quality Gate Enforcement: Pipeline automatically fails and aborts build if any single test fails or coverage drops."
)
Add-Card -slide $s4 -x 40 -y 105 -w 425 -h 385 -title "Continuous Integration Architecture" -points $pts4A -accentColor $cBlue

$pts4B = @(
    "15 JUnit Unit Tests: Validates log ingestion parsers, regex extractors, event categorization, and alert thresholds.",
    "Selenium UI Automation: Headless Chrome suite testing end-to-end user login, log search, filter toggling, and export.",
    "Defect Injection Validation: Intentionally injected assertions into log parsers to prove the pipeline blocks faulty code.",
    "Test Report Publishing: Jenkins automatically archives Surefire XML and Selenium screenshots for audit compliance."
)
Add-Card -slide $s4 -x 495 -y 105 -w 425 -h 385 -title "Multi-Tier Testing Verification" -points $pts4B -accentColor $cGreen

# SLIDE 5
Write-Host "Creating Slide 5: Containerization..."
$s5 = $pres.Slides.Add(5, $ppLayoutBlank)
Add-Header -slide $s5 -category "Container Security" -title "Docker Hardening and Cloud-Ready Packaging" -slideNum 5

$pts5A = @(
    "Multi-Stage Build: Separates Maven compile dependencies from final runtime, achieving an ultra-small 166 MB image.",
    "Alpine Linux 3.19 Base: Stripped-down base distribution containing only essential binaries, drastically cutting CVE risks.",
    "Layer Caching: Dockerfile structure orders dependencies before source code for rapid incremental rebuilds.",
    "Container Networking: Isolated bridge network exposing only port 8080 with strict ingress rules."
)
Add-Card -slide $s5 -x 40 -y 105 -w 425 -h 385 -title "Container Optimization and Design" -points $pts5A -accentColor $cPurple

$pts5B = @(
    "Non-Root User Execution: Enforces appuser:1001 ownership; prevents container escape vulnerabilities.",
    "Read-Only Protection: Container filesystem is locked to prevent unauthorized tampering or script injection.",
    "Built-in Health Checks: Native Docker HEALTHCHECK probes /actuator/health every 15s to detect hung instances.",
    "Zero-Downtime Deployment: Container lifecycle managed with graceful SIGTERM handling and instant container replacement."
)
Add-Card -slide $s5 -x 495 -y 105 -w 425 -h 385 -title "Production Security Hardening" -points $pts5B -accentColor $cAmber

# SLIDE 6
Write-Host "Creating Slide 6: Ansible..."
$s6 = $pres.Slides.Add(6, $ppLayoutBlank)
Add-Header -slide $s6 -category "Infrastructure as Code" -title "Ansible Provisioning, Idempotency and Rollback" -slideNum 6

$pts6A = @(
    "Modular Roles: Dedicated roles for common system packages, Docker runtime, security hardening, and app deployment.",
    "Dynamic Templating: Jinja2 templates configure systemd service units, environment files, and logging parameters.",
    "Strict Idempotency: Verified by running playbooks consecutively -- second run guarantees changed=0, failed=0.",
    "Inventory Abstraction: Staging and Production environments defined cleanly with separate inventory variables."
)
Add-Card -slide $s6 -x 40 -y 105 -w 425 -h 385 -title "Role-Based Declarative Provisioning" -points $pts6A -accentColor $cCyan

$pts6B = @(
    "Sub-15s Rollback (RTO under 15s): Automated rollback playbook instantly reverts symlinks to previous stable build.",
    "Complete Traceability: Every configuration change is committed to Git, enabling reproducible disaster recovery.",
    "Viva Takeaway 1: Demonstrated full DevSecOps loop from source code to tested, hardened, and orchestrated container.",
    "Viva Takeaway 2: Zero-drift infrastructure guaranteed through Ansible declarative state management."
)
Add-Card -slide $s6 -x 495 -y 105 -w 425 -h 385 -title "Disaster Recovery and Viva Takeaways" -points $pts6B -accentColor $cGreen

# SAVE
Write-Host "Saving presentation to $OutputPath..."
if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Force
}

$pres.SaveAs($OutputPath)
$pres.Close()
$ppt.Quit()

[System.Runtime.Interopservices.Marshal]::ReleaseComObject($pres) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($ppt) | Out-Null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

Write-Host "SUCCESS: PowerPoint presentation created at $OutputPath"
