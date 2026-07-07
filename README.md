# Automated Multi-Container Infrastructure with Terraform & Docker

This repository contains a fully automated, containerized infrastructure deploying a WordPress website backed by a MySQL database, route-managed via an Nginx Reverse Proxy, and completely monitored using the Prometheus & Grafana ecosystem.

---

## 🏗️ Architecture Overview

The system is split into three main architectural layers:

1. **Web & Database Layer:**
   * **WordPress (`web_voip_tf`):** The core content management system.
   * **MySQL (`db_voip_tf`):** Secured relational database management system initialized with persistent volumes.
   * **Nginx (`nginx_server`):** Acts as a Reverse Proxy directing external traffic, handling dynamic upstream routing, and managing custom timeouts.

2. **Monitoring & Alerting Layer:**
   * **Prometheus:** Scrapes system and operational metrics across the network dynamically.
   * **Alertmanager:** Formatted to capture Prometheus metrics and trigger system alerts based on preset operational thresholds.
   * **cAdvisor:** Analyzes and exposes resource usage (CPU, Memory, Network) from the running containers.
   * **Node Exporter:** Exposes hardware and OS-level metrics from the host machine.

3. **Management Layer:**
   * **Portainer (`portainer_management`):** GUI platform for granular Docker container management and live logging.

---

## 🚀 Quick Start (Deployment Guide)

Since the infrastructure relies on Terraform environment runtime detection wrappers (`abspath` and `path.module`), you don't need to manually change any filesystem paths.

### Prerequisites
Make sure you have Docker and Terraform installed on your system.

```bash
docker --version
terraform --version
```

### Deployment Steps

1. **Clone the repository and navigate to the Terraform workspace:**
```bash
cd full_project/terraform
```

2. **Initialize the project workspace to download the necessary Docker providers:**
```bash
terraform init
```

3. **Provision and spin up all containers automatically:**
```bash
terraform apply -auto-approve
```

---

## 🔍 Exposing Endpoints

Once deployed successfully, the following infrastructure ports will be mapped locally:

| Service | Port / Endpoint | Description |
| :--- | :--- | :--- |
| **WordPress / Web App** | `http://localhost:8080` | Main application website |
| **Prometheus UI** | `http://localhost:9090` | Check scrape targets and query metrics |
| **Grafana Dashboards** | `http://localhost:3000` | Data visualization dashboards |
| **Portainer Dashboard** | `http://localhost:9443` | Container management GUI |
| **Alertmanager UI** | `http://localhost:9093` | Alert threshold tracking dashboard |
| **cAdvisor Metrics** | `http://localhost:8085` | Direct structural raw container metrics |

---

## 🛠️ Infrastructure Cleanup

To safely tear down the entire infrastructure, remove active containers, and isolate the network setups, execute:

```bash
terraform destroy -auto-approve
```

> **Note:** Active persistent data volumes for MySQL, Portainer, and Grafana remain protected from unintended data loss.
