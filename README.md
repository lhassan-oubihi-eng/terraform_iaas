# Monitoring & Automation Project

This project provides a complete solution for infrastructure monitoring and automation.

## 📂 Project Structure
- **/monitoring**: Contains Docker Compose configuration for Prometheus, Grafana, and Alertmanager.
- **/terraform**: Contains Terraform files for infrastructure provisioning.
- **/ansible**: Contains Ansible playbooks for automated server configuration.

## 🚀 Quick Start

### 1. Infrastructure Provisioning
```bash
cd terraform
terraform init
terraform apply
```

### 2. Configuration Management
```bash
cd ../ansible
ansible-playbook -i inventory.ini playbook.yml
```

### 3. Monitoring Deployment
```bash
cd ../monitoring
docker-compose up -d
```

## 🛠 Technologies Used
- **IaC**: Terraform
- **Automation**: Ansible
- **Monitoring**: Prometheus, Grafana, Alertmanager
- **Containerization**: Docker & Docker Compose

---
*Internship Project - Lhassan Oubihi*
