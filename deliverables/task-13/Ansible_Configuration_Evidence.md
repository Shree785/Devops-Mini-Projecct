# Task 13: Configuration Management with Ansible (Inventory, Playbooks, and Roles)

**Project:** Enterprise Security Log Review System  
**Tooling:** Ansible Core 2.19.14 (Python 3.11.17, Jinja2 3.1.6, PyYAML 6.0.3)  
**Configuration Pattern:** Enterprise Modular Role (`security_log_app`)  
**Execution Timestamp:** 2026-10-18  
**Task Status:** COMPLETE & FULLY VERIFIED  

---

## 1. Executive Summary & Architecture

Configuration Management is crucial for establishing reproducible, idempotent, and audit-compliant infrastructure. In Task 13, the Security Log Review System was codified into a complete **Ansible Configuration Management Suite** featuring:

1. **Multi-Tier Inventory (`ansible/inventory/hosts.ini`):** Defines production, staging, and development infrastructure targets with environment-specific variables.
2. **Modular Role Architecture (`ansible/roles/security_log_app`):** Encapsulates directory hierarchy provisioning, dynamic Jinja2 configuration templating, container deployment, service supervision, and event-driven handlers.
3. **Decoupled Playbooks:**
   - `ansible/playbooks/site.yml`: Master orchestration playbook.
   - `ansible/playbooks/provision.yml`: Infrastructure and application provisioning.
   - `ansible/playbooks/verify.yml`: Post-deployment compliance and security posture audit.

```
+--------------------------------------------------------------------------------------------------+
|                            ANSIBLE CONFIGURATION MANAGEMENT ARCHITECTURE                         |
+--------------------------------------------------------------------------------------------------+
|                                                                                                  |
|   +------------------------------------------------------------------------------------------+   |
|   | Ansible Controller (Ansible Core 2.19.14 / Python 3.11)                                  |   |
|   | Config: ansible/ansible.cfg (roles_path, inventory, default callbacks)                    |   |
|   +------------------------------------------------------------------------------------------+   |
|                                              |                                                   |
|                        +---------------------+---------------------+                             |
|                        |                                           |                             |
|                        v                                           v                             |
|   +-----------------------------------------+   +--------------------------------------------+   |
|   | Inventory (ansible/inventory/hosts.ini) |   | Playbooks (ansible/playbooks/)             |   |
|   | - [production] localhost (port 8080)    |   | - site.yml (Master Orchestration)          |   |
|   | - [staging] staging-soc-01 (port 8081)  |   | - provision.yml (Targeted Provisioning)    |   |
|   | - [dev] dev-soc-01 (port 8082)          |   | - verify.yml (Audit & Compliance)          |   |
|   +-----------------------------------------+   +--------------------------------------------+   |
|                                                                |                                 |
|                                                                v                                 |
|   +------------------------------------------------------------------------------------------+   |
|   | Ansible Role: security_log_app                                                           |   |
|   |   |-- defaults/main.yml    (Default ports, heap limits, container tags)                  |   |
|   |   |-- tasks/main.yml       (9 sequential idempotent provisioning tasks)                  |   |
|   |   |-- templates/           (Jinja2 config & systemd unit templates)                      |   |
|   |   `-- handlers/main.yml    (Event-driven restart & reload handlers)                      |   |
|   +------------------------------------------------------------------------------------------+   |
+--------------------------------------------------------------------------------------------------+
```

---

## 2. Inventory Specification (`ansible/inventory/hosts.ini`)

```ini
[local]
localhost ansible_connection=local ansible_python_interpreter=/usr/local/bin/python3

[soc_servers]
localhost ansible_connection=local

[production]
localhost ansible_connection=local app_env=production deploy_port=8080 jvm_max_ram=75.0

[staging]
staging-soc-01.internal ansible_host=10.0.1.15 ansible_connection=ssh ansible_user=deploy app_env=staging deploy_port=8081 jvm_max_ram=50.0

[dev]
dev-soc-01.internal ansible_host=10.0.2.20 ansible_connection=ssh ansible_user=deploy app_env=development deploy_port=8082 jvm_max_ram=50.0

[all:vars]
app_name=security-log-review
app_version=1.0.0
app_group=appgroup
app_user=appuser
app_uid=1001
app_gid=1001
app_install_dir=/opt/security-log-review
app_config_dir=/etc/security-log-review
app_log_dir=/var/log/security-log-review
docker_image=security-log-review:1.0.0
docker_container=security-log-review-app
healthcheck_retries=15
healthcheck_delay=3
```

---

## 3. Modular Ansible Role (`roles/security_log_app`)

### 3.1 Task Execution Sequence (`tasks/main.yml`)
1. **Context Output:** Displays target host, environment, port, and image.
2. **Prerequisite Check:** Verifies Docker daemon availability (`docker info`).
3. **Directory Provisioning:** Creates `/opt/security-log-review`, `/etc/security-log-review`, and `/var/log/security-log-review` with `0755` permissions.
4. **Configuration Templating:** Renders [`application-production.properties.j2`](file:///d:/ASSIGNMENTS/DEVOPS/DEVOPS%20PROJECT/ansible/roles/security_log_app/templates/application-production.properties.j2) and registers notify handler.
5. **Image Validation:** Inspects `security-log-review:1.0.0` container image.
6. **Drain & Clean:** Gracefully stops and removes stale container instances.
7. **Container Launch:** Starts container with cgroup CPU/RAM limits and port forwarding.
8. **Health Quality Gate:** Polls `http://localhost:8080/actuator/health` until `{"status":"UP"}`.
9. **Dashboard Probe:** Asserts HTTP 200 on SOC Executive Dashboard.

### 3.2 Dynamic Jinja2 Configuration Template (`templates/application-production.properties.j2`)
```properties
server.port={{ deploy_port }}
server.servlet.context-path=/

# Datasource Configuration
spring.datasource.url=jdbc:h2:mem:securitydb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=

# Actuator Operational Endpoints
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=always
management.info.env.enabled=true

# Logging Posture
logging.level.root=INFO
logging.level.com.securitylog=INFO
logging.file.name={{ app_log_dir }}/application.log
```

---

## 4. Execution & Verification Evidence

### 4.1 Playbook Syntax Check Validation
```text
PS> .\tools\ansible-playbook.cmd -i ansible/inventory/hosts.ini ansible/playbooks/site.yml --syntax-check
playbook: ansible/playbooks/site.yml

PS> .\tools\ansible-playbook.cmd -i ansible/inventory/hosts.ini ansible/playbooks/provision.yml --syntax-check
playbook: ansible/playbooks/provision.yml

PS> .\tools\ansible-playbook.cmd -i ansible/inventory/hosts.ini ansible/playbooks/verify.yml --syntax-check
playbook: ansible/playbooks/verify.yml
```
*Result: 100% syntax compliance across all playbooks.*

### 4.2 Inventory Parsing & Hierarchy Check (`ansible-inventory --list`)
```json
{
    "_meta": {
        "hostvars": {
            "localhost": {
                "ansible_connection": "local",
                "app_env": "production",
                "app_name": "security-log-review",
                "deploy_port": 8080,
                "docker_container": "security-log-review-app",
                "docker_image": "security-log-review:1.0.0",
                "jvm_max_ram": 75.0
            }
        }
    },
    "all": {
        "children": ["dev", "local", "production", "soc_servers", "staging"]
    }
}
```

### 4.3 Master Playbook Execution (`site.yml`)
```text
PLAY [Orchestrate Enterprise Security Log Review Infrastructure] ***************

TASK [Gathering Facts] *********************************************************
ok: [localhost]

TASK [security_log_app : [1/9] Display Provisioning Target & Environment Context] ***
ok: [localhost] => {
    "msg": [
        "Target Host     : localhost",
        "Application     : security-log-review:1.0.0",
        "Environment     : production",
        "Target Port     : 8080",
        "Container Image : security-log-review:1.0.0"
    ]
}

TASK [security_log_app : [2/9] Verify Docker Daemon Availability] **************
ok: [localhost]

TASK [security_log_app : [3/9] Ensure Application Directory Hierarchy Exists] ***
changed: [localhost] => (item=/opt/security-log-review)
changed: [localhost] => (item=/etc/security-log-review)
changed: [localhost] => (item=/var/log/security-log-review)

TASK [security_log_app : [4/9] Deploy Managed Application Configuration (Jinja2 Template)] ***
changed: [localhost]

TASK [security_log_app : [5/9] Verify Production Container Image Availability] ***
ok: [localhost]

TASK [security_log_app : [6/9] Drain & Terminate Existing Container Instance (Zero-Downtime Clean Up)] ***
ok: [localhost]

TASK [security_log_app : [7/9] Launch Provisioned Application Container] *******
changed: [localhost]

TASK [security_log_app : [8/9] Await Spring Boot Actuator Health Probe (Quality Gate)] ***
ok: [localhost]

TASK [security_log_app : [9/9] Verify SOC Posture Dashboard Endpoint] **********
ok: [localhost]

TASK [security_log_app : Display Ansible Provisioning Verification Summary] ****
ok: [localhost] => {
    "msg": [
        "==========================================================",
        " [ANSIBLE PROVISIONING SUCCESS] System Fully Operational!",
        " Application Container : security-log-review-app",
        " Instance ID           : 7b6753bffca0",
        " Health Endpoint        : http://localhost:8080/actuator/health (UP)",
        " SOC Dashboard          : http://localhost:8080/dashboard (HTTP 200)",
        " Configuration File     : /etc/security-log-review/application-production.properties",
        "=========================================================="
    ]
}

RUNNING HANDLER [security_log_app : Restart security-log-review container] *****
changed: [localhost]

PLAY RECAP *********************************************************************
localhost                  : ok=12   changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

### 4.4 Automated Compliance & Security Audit (`verify.yml`)
```text
PLAY [Validate Security Operations Posture & Operational Compliance] ***********

TASK [[VERIFY 1/5] Inspect Container Running State] ****************************
ok: [localhost]

TASK [[VERIFY 2/5] Await Container Health Status (healthy)] ********************
ok: [localhost]

TASK [[VERIFY 3/5] Query Spring Boot Actuator Health Metrics] ******************
ok: [localhost]

TASK [[VERIFY 4/5] Validate SOC Executive Dashboard HTTP 200 OK] ***************
ok: [localhost]

TASK [[VERIFY 5/5] Verify In-Container Least-Privilege User] *******************
ok: [localhost]

TASK [Audit Compliance Summary] ************************************************
ok: [localhost] => {
    "msg": [
        "==========================================================",
        " [POST-DEPLOYMENT AUDIT PASSED] 100% Compliant",
        " Container Status     : running (RUNNING)",
        " Docker Health        : healthy (HEALTHY)",
        " Actuator Health JSON : UP",
        " SOC Dashboard HTTP   : 200 (OK)",
        " Security UID         : 1001 (Least Privilege)",
        "=========================================================="
    ]
}

PLAY RECAP *********************************************************************
localhost                  : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

---

## 5. Artifact Archive & Directory Index

All playbooks, roles, inventory, and configuration files are mirrored in both the audit directory and outer workspace folder:

- **Audit Directory:** `deliverables/task-13/`
  - `deliverables/task-13/Ansible_Configuration_Evidence.md`
  - `deliverables/task-13/ansible/` (Full copy of inventory, roles, playbooks, templates)
- **Outer Visual Directory:** `Task-13/`
  - `Task-13/Ansible_Configuration_Evidence.md`
  - `Task-13/ansible/` (Complete duplicate archive for instant inspection in Windows File Explorer)
