import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE

def create_presentation(output_path):
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)
    blank_layout = prs.slide_layouts[6]

    # Color Palette
    C_NAVY = RGBColor(15, 23, 42)
    C_DARK_BLUE = RGBColor(30, 41, 59)
    C_ACCENT_BLUE = RGBColor(2, 132, 199)
    C_EMERALD = RGBColor(16, 185, 129)
    C_AMBER = RGBColor(245, 158, 11)
    C_RED = RGBColor(239, 68, 68)
    C_WHITE = RGBColor(255, 255, 255)
    C_LIGHT_BG = RGBColor(248, 250, 252)
    C_MUTED = RGBColor(100, 116, 139)
    C_CARD_BORDER = RGBColor(226, 232, 240)

    def add_header(slide, title_text, category_text="DEVSECOPS PROJECT DEFENSE"):
        # Header banner
        header_shape = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0), Inches(0), Inches(13.333), Inches(1.15))
        header_shape.fill.solid()
        header_shape.fill.fore_color.rgb = C_NAVY
        header_shape.line.color.rgb = C_NAVY

        # Category Tag
        cat_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.12), Inches(8), Inches(0.3))
        cat_tf = cat_box.text_frame
        cat_tf.word_wrap = True
        p_cat = cat_tf.paragraphs[0]
        p_cat.text = category_text.upper()
        p_cat.font.size = Pt(11)
        p_cat.font.bold = True
        p_cat.font.color.rgb = C_ACCENT_BLUE

        # Title
        title_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.42), Inches(11.5), Inches(0.6))
        tf = title_box.text_frame
        tf.word_wrap = True
        p = tf.paragraphs[0]
        p.text = title_text
        p.font.size = Pt(22)
        p.font.bold = True
        p.font.color.rgb = C_WHITE

        # Footer line
        footer_line = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0), Inches(7.15), Inches(13.333), Inches(0.35))
        footer_line.fill.solid()
        footer_line.fill.fore_color.rgb = C_DARK_BLUE
        footer_line.line.color.rgb = C_DARK_BLUE

        foot_box = slide.shapes.add_textbox(Inches(0.8), Inches(7.15), Inches(11.733), Inches(0.35))
        foot_tf = foot_box.text_frame
        p_foot = foot_tf.paragraphs[0]
        p_foot.text = "Enterprise Security Log Review System  |  Amogh Kulkarni (23102C0003)  |  14 DevOps Tasks"
        p_foot.font.size = Pt(10)
        p_foot.font.color.rgb = C_MUTED

    # ==========================================
    # SLIDE 1: Title Slide
    # ==========================================
    s1 = prs.slides.add_slide(blank_layout)
    bg1 = s1.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0), Inches(0), Inches(13.333), Inches(7.5))
    bg1.fill.solid()
    bg1.fill.fore_color.rgb = C_NAVY
    bg1.line.color.rgb = C_NAVY

    # Decorative Accent Bar
    accent_bar = s1.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(1.2), Inches(1.2), Inches(0.15), Inches(4.8))
    accent_bar.fill.solid()
    accent_bar.fill.fore_color.rgb = C_ACCENT_BLUE
    accent_bar.line.color.rgb = C_ACCENT_BLUE

    # Pill badge
    pill = s1.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(1.6), Inches(1.4), Inches(4.5), Inches(0.45))
    pill.fill.solid()
    pill.fill.fore_color.rgb = RGBColor(30, 41, 59)
    pill.line.color.rgb = C_ACCENT_BLUE
    pill_tf = pill.text_frame
    p_pill = pill_tf.paragraphs[0]
    p_pill.text = "END-TO-END DEVSECOPS CAPSTONE PROJECT"
    p_pill.font.size = Pt(11)
    p_pill.font.bold = True
    p_pill.font.color.rgb = C_ACCENT_BLUE
    p_pill.alignment = PP_ALIGN.CENTER

    # Main Title
    t1_box = s1.shapes.add_textbox(Inches(1.6), Inches(2.1), Inches(10.5), Inches(1.8))
    t1_tf = t1_box.text_frame
    t1_tf.word_wrap = True
    p_t1 = t1_tf.paragraphs[0]
    p_t1.text = "Ansible-Provisioned Security\nLog Review System"
    p_t1.font.size = Pt(36)
    p_t1.font.bold = True
    p_t1.font.color.rgb = C_WHITE

    # Subtitle
    sub1_box = s1.shapes.add_textbox(Inches(1.6), Inches(4.1), Inches(10.5), Inches(0.8))
    sub1_tf = sub1_box.text_frame
    sub1_tf.word_wrap = True
    p_sub1 = sub1_tf.paragraphs[0]
    p_sub1.text = "Automated Continuous Testing Quality Gates, Hardened Containerization, and Idempotent Infrastructure"
    p_sub1.font.size = Pt(15)
    p_sub1.font.color.rgb = RGBColor(148, 163, 184)

    # Author Card
    author_card = s1.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(1.6), Inches(5.1), Inches(7.5), Inches(1.2))
    author_card.fill.solid()
    author_card.fill.fore_color.rgb = RGBColor(30, 41, 59)
    author_card.line.color.rgb = RGBColor(51, 65, 85)
    ac_tf = author_card.text_frame
    ac_tf.word_wrap = True
    p_ac1 = ac_tf.paragraphs[0]
    p_ac1.text = "Prepared by: Amogh Kulkarni"
    p_ac1.font.size = Pt(15)
    p_ac1.font.bold = True
    p_ac1.font.color.rgb = C_WHITE
    p_ac2 = ac_tf.add_paragraph()
    p_ac2.text = "Roll Number: 23102C0003  |  Curriculum: 14 Completed DevOps Milestones"
    p_ac2.font.size = Pt(12)
    p_ac2.font.color.rgb = C_ACCENT_BLUE

    # ==========================================
    # Helper to create content cards
    # ==========================================
    def add_card(slide, left, top, width, height, title, items, border_color=C_CARD_BORDER, bg_color=C_WHITE, title_color=C_NAVY):
        card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(left), Inches(top), Inches(width), Inches(height))
        card.fill.solid()
        card.fill.fore_color.rgb = bg_color
        card.line.color.rgb = border_color
        card.line.width = Pt(1.5)

        tf = card.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.25)
        tf.margin_right = Inches(0.25)
        tf.margin_top = Inches(0.2)

        p_t = tf.paragraphs[0]
        p_t.text = title
        p_t.font.size = Pt(15)
        p_t.font.bold = True
        p_t.font.color.rgb = title_color
        p_t.space_after = Pt(8)

        for item in items:
            p = tf.add_paragraph()
            p.text = f"•  {item}"
            p.font.size = Pt(12)
            p.font.color.rgb = RGBColor(51, 65, 85)
            p.space_after = Pt(6)

    # ==========================================
    # SLIDE 2: Executive Summary & Project Objectives
    # ==========================================
    s2 = prs.slides.add_slide(blank_layout)
    add_header(s2, "Executive Summary & Project Objectives")
    add_card(s2, 0.8, 1.4, 5.7, 5.4, "The Problem & Context", [
        "Modern Security Operations Centers (SOC) process massive streams of intrusion logs.",
        "Manual triage is slow, prone to human error, and lacks automated regression validation.",
        "Traditional IT environments suffer from severe environment drift between staging and production.",
        "Security vulnerabilities occur when applications run as root in bloated container images.",
        "Goal: Engineer a production-grade, fully automated DevSecOps delivery platform."
    ], C_CARD_BORDER, C_LIGHT_BG, C_ACCENT_BLUE)

    add_card(s2, 6.8, 1.4, 5.7, 5.4, "Key Project Objectives", [
        "Automate the full software lifecycle across 14 sequential DevOps milestones.",
        "Shift Testing Left by integrating Selenium acceptance Quality Gates in Jenkins.",
        "Package application into hardened, minimal Alpine Linux OCI containers (166 MB).",
        "Enforce least-privilege runtime security with non-root service account (UID 1001).",
        "Achieve strict mathematical idempotency (changed=0) via modular Ansible roles.",
        "Provide automated zero-downtime disaster recovery rollback (RTO < 15 seconds)."
    ], C_CARD_BORDER, C_LIGHT_BG, C_EMERALD)

    # ==========================================
    # SLIDE 3: System Architecture & Technology Stack
    # ==========================================
    s3 = prs.slides.add_slide(blank_layout)
    add_header(s3, "System Architecture & Technology Stack")
    add_card(s3, 0.8, 1.4, 3.7, 5.4, "Application Tier", [
        "Spring Boot 3.2.x (Java 17)",
        "Embedded Tomcat 10 Server",
        "Spring Data JPA & Hibernate",
        "In-Memory H2 Database",
        "HikariCP Connection Pool",
        "Thymeleaf MVC + Bootstrap 5",
        "Spring Boot Actuator Probes"
    ], C_ACCENT_BLUE, C_WHITE, C_ACCENT_BLUE)

    add_card(s3, 4.8, 1.4, 3.7, 5.4, "CI/CD & Testing Tier", [
        "Git & GitFlow Branching Model",
        "Apache Maven 3.9 Build Lifecycle",
        "15 JUnit 5 & Mockito Unit Tests",
        "Selenium WebDriver 4 Suite",
        "Headless Google Chrome v155",
        "Declarative Jenkins Pipeline",
        "Continuous Testing Quality Gate"
    ], C_EMERALD, C_WHITE, C_EMERALD)

    add_card(s3, 8.8, 1.4, 3.7, 5.4, "Deployment & IaC Tier", [
        "Docker Engine on Alpine Linux",
        "Eclipse Temurin 17 JRE Base",
        "Unprivileged appuser (UID 1001)",
        "Docker Compose Lifecycles",
        "Ansible Core 2.19.x Engine",
        "Modular security_log_app Role",
        "Dynamic Jinja2 Template Injection"
    ], C_AMBER, C_WHITE, C_AMBER)

    # ==========================================
    # SLIDE 4: GitFlow Branching & Release Traceability (Task 2 & 4)
    # ==========================================
    s4 = prs.slides.add_slide(blank_layout)
    add_header(s4, "GitFlow Branching Architecture & Audit Traceability")
    add_card(s4, 0.8, 1.4, 6.0, 5.4, "Branching Strategy (GitFlow)", [
        "main Branch: Strictly reserved for stable, production-ready releases.",
        "dev Branch: Primary integration branch for active development.",
        "feature/* Branches: Isolated branch for every milestone task.",
        "feature/core-log-crud (Task 5: Domain entities & JPA)",
        "feature/continuous-testing-pipeline (Task 10: Quality Gate)",
        "feature/docker-containerization (Task 11: Multi-stage build)",
        "feature/ansible-configuration-management (Task 13: IaC roles)",
        "feature/provisioning-idempotency-rollback (Task 14: Execution)"
    ], C_CARD_BORDER, C_LIGHT_BG, C_NAVY)

    add_card(s4, 7.1, 1.4, 5.4, 5.4, "Release Tags & Traceability", [
        "Semantic Release Tagging:",
        "• v1.0.0: Functional MVP Release (Task 6 Baseline).",
        "• v1.1.0: Full Production Release (Task 14 Ansible Baseline).",
        "End-to-End Audit Traceability:",
        "• Every commit has an immutable SHA hash (e.g. 304f5e1 / dd26f9f).",
        "• Jenkins Checkout stage logs the exact commit SHA.",
        "• Docker image tagged matching Git release tags.",
        "• Guarantees 100% audit link between source code and running container."
    ], C_CARD_BORDER, C_LIGHT_BG, C_ACCENT_BLUE)

    # ==========================================
    # SLIDE 5: Apache Maven Build Automation (Task 5)
    # ==========================================
    s5 = prs.slides.add_slide(blank_layout)
    add_header(s5, "Apache Maven Build Automation & Lifecycle Standards")
    add_card(s5, 0.8, 1.4, 5.7, 5.4, "Declarative Lifecycle in pom.xml", [
        "Standardized Build Phases:",
        "• clean: Purges previous target/ artifacts.",
        "• compile: Compiles 18 Java source files with javac [debug release 17].",
        "• test: Executes unit and integration test suites automatically.",
        "• package: Packages self-contained executable fat JAR (52.4 MB).",
        "Eliminates manual javac commands and complex classpath arguments.",
        "Guarantees reproducible build artifacts across developer machines and CI/CD."
    ], C_CARD_BORDER, C_LIGHT_BG, C_NAVY)

    add_card(s5, 6.8, 1.4, 5.7, 5.4, "Dependency Management & Reproducibility", [
        "Automated Transitive Dependency Resolution:",
        "• spring-boot-starter-web (Tomcat 10 embedded server)",
        "• spring-boot-starter-data-jpa (Hibernate ORM 6.4)",
        "• com.h2database:h2 (In-memory SQL database)",
        "• spring-boot-starter-actuator (Production health probes)",
        "• org.seleniumhq.selenium:selenium-java (Automated browser testing)",
        "Zero classpath collision across 30+ transitive enterprise libraries."
    ], C_CARD_BORDER, C_LIGHT_BG, C_EMERALD)

    # ==========================================
    # SLIDE 6: Automated Testing Pyramid (Task 6 & 9)
    # ==========================================
    s6 = prs.slides.add_slide(blank_layout)
    add_header(s6, "Automated Testing: Unit & Selenium E2E Acceptance")
    add_card(s6, 0.8, 1.4, 5.7, 5.4, "Tier 1: Unit & Service Integration (Task 6)", [
        "15 Comprehensive Automated Unit Tests using JUnit 5 & Mockito.",
        "SecurityLogServiceTest: Tests business logic & state transitions.",
        "LogWebControllerTest: MockMvc endpoint testing (HTTP 200/400).",
        "SecurityLogApplicationTests: Full Spring application context loading.",
        "Results: 15 / 15 Passed (0 Failures, 0 Errors, 0 Skipped).",
        "Automated Surefire XML report publishing for CI/CD archiving."
    ], C_CARD_BORDER, C_LIGHT_BG, C_NAVY)

    add_card(s6, 6.8, 1.4, 5.7, 5.4, "Tier 2: Selenium E2E Browser Testing (Task 9)", [
        "Automated Headless Chrome testing 5 real-world user journeys:",
        "• Journey 1: SOC Executive Dashboard & metric KPI cards verification.",
        "• Journey 2: Ingesting security events with client/server validation.",
        "• Journey 3: Severity and threat type real-time search filtering.",
        "• Journey 4: Analyst incident triage workflow (NEW ➔ IN_REVIEW ➔ RESOLVED).",
        "• Journey 5: Actuator /actuator/health mechanism and non-root checks.",
        "Automated screenshot capture at every critical journey checkpoint."
    ], C_CARD_BORDER, C_LIGHT_BG, C_ACCENT_BLUE)

    # ==========================================
    # SLIDE 7: Continuous Testing Quality Gate (Task 10 Highlight)
    # ==========================================
    s7 = prs.slides.add_slide(blank_layout)
    add_header(s7, "Continuous Testing Quality Gate in Jenkins (Task 10)")
    add_card(s7, 0.8, 1.4, 5.7, 5.4, "The Defect Injection Experiment", [
        "Shift-Left Quality Gate Concept:",
        "• Tests must act as an enforceable quality barrier before packaging.",
        "Deliberate Defect Injection Drill:",
        "• We injected a deliberate defect into the SOC dashboard heading.",
        "• Headless Chrome Selenium test immediately detected the mismatch.",
        "• Jenkins tripped the Quality Gate, HALTED the pipeline, and aborted deployment.",
        "• Automatically captured and archived diagnostic failure screenshot."
    ], C_RED, C_WHITE, C_RED)

    add_card(s7, 6.8, 1.4, 5.7, 5.4, "Defect Resolution & Green Verification", [
        "Resolution & Re-execution:",
        "• Defect resolved and code restored to specification.",
        "• Jenkins re-triggered acceptance suite in headless Chrome.",
        "• All 5 end-to-end user journeys PASSED.",
        "• Green pipeline execution completed in 27.13 seconds.",
        "• Authorized artifact packaging and triggered automated Docker deployment.",
        "Proves that defective code NEVER reaches production."
    ], C_EMERALD, C_WHITE, C_EMERALD)

    # ==========================================
    # SLIDE 8: Declarative Jenkins Pipeline as Code (Task 8 & 12)
    # ==========================================
    s8 = prs.slides.add_slide(blank_layout)
    add_header(s8, "Jenkins CI/CD Pipeline as Code (Jenkinsfile)")
    add_card(s8, 0.8, 1.4, 11.7, 5.4, "6 Automated Declarative Pipeline Stages", [
        "Stage 1: Checkout SCM ➔ Pulls target Git branch (dev/main) and logs latest commit hash.",
        "Stage 2: Build & Compile ➔ Compiles Java 17 Spring Boot sources using Maven 3.9.",
        "Stage 3: Unit & Service Tests ➔ Executes 15 JUnit tests and publishes JUnit Surefire XML test reports.",
        "Stage 4: Continuous Testing Quality Gate ➔ Executes headless Chrome Selenium suite; halts on failure.",
        "Stage 5: Package Artifact ➔ Bundles executable 52.4 MB Spring Boot JAR with embedded Tomcat 10.",
        "Stage 6: Docker Deployment ➔ Builds multi-stage Alpine container and executes zero-downtime replacement.",
        "Verified Live Execution: Build #1, #2, #3 ALL passed 100% Green on http://localhost:8081."
    ], C_ACCENT_BLUE, C_LIGHT_BG, C_NAVY)

    # ==========================================
    # SLIDE 9: Production Docker Containerization (Task 11)
    # ==========================================
    s9 = prs.slides.add_slide(blank_layout)
    add_header(s9, "Production Hardened Docker Containerization (Task 11)")
    add_card(s9, 0.8, 1.4, 5.7, 5.4, "Container Optimization & Footprint", [
        "Multi-Stage Dockerfile Architecture:",
        "• Base: eclipse-temurin:17-jre-alpine (Alpine Linux 3.19).",
        "• Eliminates build tools and package managers from runtime.",
        "• Total Container Image Size: Only 166 MB (vs 600+ MB standard).",
        "• Low Memory Consumption: Under 180 MB RAM in steady state.",
        "• JVM CGroup Container Support: -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0.",
        "Port Mapping: Host 0.0.0.0:8080 ➔ Container port 8080/tcp."
    ], C_CARD_BORDER, C_LIGHT_BG, C_ACCENT_BLUE)

    add_card(s9, 6.8, 1.4, 5.7, 5.4, "Security Hardening & Health Monitoring", [
        "Least-Privilege Security Context:",
        "• Container explicitly creates dedicated user appuser (UID 1001).",
        "• Does NOT run as root (prevents host privilege escalation).",
        "• Read-only execution permissions: chmod 500 /app/app.jar.",
        "Native Docker Healthcheck Probe:",
        "• HEALTHCHECK --interval=30s --timeout=5s --start-period=40s",
        "• Probes curl -f http://localhost:8080/actuator/health.",
        "• Docker automatically marks container healthy once Spring Boot is UP."
    ], C_CARD_BORDER, C_LIGHT_BG, C_EMERALD)

    # ==========================================
    # SLIDE 10: Ansible Configuration Management (Task 13)
    # ==========================================
    s10 = prs.slides.add_slide(blank_layout)
    add_header(s10, "Ansible Configuration Management & Roles (Task 13)")
    add_card(s10, 0.8, 1.4, 5.7, 5.4, "Modular Role Architecture (security_log_app)", [
        "Structured Ansible Role Hierarchy:",
        "• tasks/main.yml: Orchestrates directories, config, and container.",
        "• handlers/main.yml: Triggered service restart on config change.",
        "• templates/: Jinja2 dynamic configuration templates.",
        "• defaults/ & vars/: Environment variables and port bindings.",
        "Externalizes Configuration from Application Code:",
        "• Injects dynamic ports, profiles, and database properties at deploy time.",
        "Multi-tier inventory file: ansible/inventory/hosts.ini."
    ], C_CARD_BORDER, C_LIGHT_BG, C_NAVY)

    add_card(s10, 6.8, 1.4, 5.7, 5.4, "Dynamic Jinja2 Template Injection", [
        "Jinja2 Template: application-production.properties.j2:",
        "• Injects {{ server_port }} (default: 8080)",
        "• Injects {{ app_profile }} (production)",
        "• Injects {{ db_name }} and logging severity levels",
        "Systemd Service Template: security-log-review.service.j2:",
        "• Codifies daemon lifecycle, restart policies, and resource limits.",
        "Achieves 100% Infrastructure as Code (IaC) governance."
    ], C_CARD_BORDER, C_LIGHT_BG, C_AMBER)

    # ==========================================
    # SLIDE 11: Idempotency & Disaster Rollback (Task 14 Highlight)
    # ==========================================
    s11 = prs.slides.add_slide(blank_layout)
    add_header(s11, "Proven Mathematical Idempotency & Disaster Rollback")
    add_card(s11, 0.8, 1.4, 5.7, 5.4, "Proven Mathematical Idempotency", [
        "Definition of Idempotency:",
        "• An operation is idempotent if running it multiple times leaves the system in the exact same state without unintended side effects.",
        "Verification Runs in Task 14:",
        "• Run 1 (Initial Provision): ok=12, changed=4, failed=0",
        "  (Created directories, deployed config, launched container).",
        "• Run 2 (Strict Idempotency Check):",
        "  ok=10, changed=0, failed=0, skipped=1!",
        "Zero unnecessary changes proved mathematical idempotency."
    ], C_EMERALD, C_WHITE, C_EMERALD)

    add_card(s11, 6.8, 1.4, 5.7, 5.4, "Disaster Recovery Rollback Drill (RTO < 15s)", [
        "Disaster Recovery Playbook: ansible/playbooks/rollback.yml:",
        "• Simulates immediate production incident remediation.",
        "• Stops flawed container version instantly.",
        "• Restores last-known-good configuration template from backup.",
        "• Launches previous stable container image tag (security-log-review:1.0.0).",
        "• Probes /actuator/health until HTTP 200 UP is verified.",
        "Recovery Time Objective (RTO): Under 15 seconds (RTO < 15s)."
    ], C_RED, C_WHITE, C_RED)

    # ==========================================
    # SLIDE 12: Master Performance Metrics & Conclusion
    # ==========================================
    s12 = prs.slides.add_slide(blank_layout)
    add_header(s12, "Key Performance Metrics & Project Conclusion")
    add_card(s12, 0.8, 1.4, 5.7, 5.4, "Audited Key Performance Metrics", [
        "Curriculum Completion: 14 / 14 Tasks Complete (100%).",
        "Unit Test Pass Rate: 15 / 15 Tests Passing (0 Failures).",
        "Selenium Acceptance: 5 / 5 User Journeys Verified in Chrome.",
        "Continuous Testing Gate: 27.13s Green Build Execution.",
        "Docker Image Size: 166 MB (Eclipse Temurin Alpine JRE).",
        "Container Security: Unprivileged appuser (UID 1001).",
        "Ansible Idempotency: changed=0, failed=0 on re-run.",
        "Disaster Recovery RTO: < 15 seconds via rollback.yml."
    ], C_CARD_BORDER, C_LIGHT_BG, C_NAVY)

    add_card(s12, 6.8, 1.4, 5.7, 5.4, "Conclusion & Defense Summary", [
        "The Security Log Review System successfully proves how modern DevSecOps practices transform manual IT delivery into a secure, automated, and resilient release pipeline.",
        "By enforcing Selenium-driven acceptance Quality Gates in Jenkins, hardened multi-stage Docker containers, and idempotent Ansible configuration, the system guarantees 100% environment parity and zero-downtime disaster recovery.",
        "Live Endpoints:",
        "• SOC Dashboard: http://localhost:8080/dashboard",
        "• Jenkins CI/CD: http://localhost:8081"
    ], C_CARD_BORDER, C_LIGHT_BG, C_EMERALD)

    # Save presentation
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    prs.save(output_path)
    print(f"Presentation saved successfully to {output_path}")

if __name__ == "__main__":
    out = r"D:\ASSIGNMENTS\DEVOPS\DEVOPS PROJECT\Poster\DevOps_Project_Presentation.pptx"
    create_presentation(out)
