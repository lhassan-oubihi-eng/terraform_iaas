#!/bin/bash
sudo apt-get update -y

# تهيئة الـ Swap Memory ديال 2GB
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# تثبيت Docker
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# إنشاء الشبكة والفوليومات
sudo docker network create monitoring_network || true
sudo docker volume create portainer_data || true
sudo docker volume create grafana_data || true
sudo docker volume create wordpress_db_data || true
sudo docker volume create jenkins_data || true
sudo docker volume create alertmanager_data || true

# 1. Jenkins Server
sudo docker run -d --name jenkins_server --restart always \
  --network monitoring_network \
  -p 8081:8080 -p 50000:50000 \
  -v jenkins_data:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# 2. Google cAdvisor
sudo docker run -d --name cadvisor --restart always \
  --network monitoring_network \
  -p 8082:8080 \
  -v /:/rootfs:ro \
  -v /var/run:/var/run:ro \
  -v /sys:/sys:ro \
  -v /var/lib/docker/:/var/lib/docker:ro \
  -v /dev/disk/:/dev/disk:ro \
  gcr.io/cadvisor/cadvisor:v0.47.0

# 3. Node Exporter
sudo docker run -d --name node-exporter --restart always \
  --network monitoring_network \
  -p 9100:9100 \
  -v "/proc:/host/proc:ro" \
  -v "/sys:/host/sys:ro" \
  -v "/:/rootfs:ro" \
  prom/node-exporter:latest \
  --path.procfs=/host/proc \
  --path.sysfs=/host/sys \
  --collector.filesystem.mount-points-exclude="^/(sys|proc|dev|host|etc)($|/)"

# 4. Alertmanager Configuration
sudo mkdir -p /etc/alertmanager
sudo tee /etc/alertmanager/alertmanager.yml > /dev/null << 'EOT'
global:
  resolve_timeout: 5m
route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'discord'
receivers:
- name: 'discord'
  discord_configs:
  - webhook_url: 'https://discordapp.com/api/webhooks/1523633593908330700/uf-cQ4JS475uav9gYD4bDc8_mQunU4SDuu-UjHZqRoYz7m_6gM0B33MD1201BVXSCXs'
    send_resolved: true
inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
EOT

sudo docker run -d --name alertmanager --restart always \
  --network monitoring_network \
  -p 9093:9093 \
  -v /etc/alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
  prom/alertmanager:latest

# 5. Alerting Rules
sudo mkdir -p /etc/prometheus
sudo tee /etc/prometheus/alert.rules.yml > /dev/null << 'EOT'
groups:
  - name: host_alerts
    rules:
      - alert: InstanceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "السيرفر متوقف! (Instance {{ $labels.instance }} down)"
          description: "لم يتمكن Prometheus من جلب البيانات."

      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 10
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "الديسك ديالك كيعمر!"
          description: "المساحة المتبقية أقل من 10%."

      - alert: HighCPUUsage
        expr: (sum(rate(container_cpu_usage_seconds_total{container_label_com_docker_compose_project=""}[5m])) by (instance) / sum(machine_cpu_cores) by (instance)) * 100 > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected on container host"
          description: "CPU usage is above 80% for more than 2 minutes."

      - alert: HighMemoryUsage
        expr: (node_memory_Active_bytes / node_memory_MemTotal_bytes) * 100 > 85
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High Memory usage detected"
          description: "Container host memory utilization is above 85%."
EOT

# 6. Prometheus Configuration
sudo tee /etc/prometheus/prometheus.yml > /dev/null << 'EOT'
global:
  scrape_interval: 15s

rule_files:
  - "alert.rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'alertmanager'
    static_configs:
      - targets: ['alertmanager:9093']

  - job_name: 'jenkins'
    metrics_path: '/prometheus/'
    basic_auth:
      username: 'admin'
      password: '${jenkins_token}'
    static_configs:
      - targets: ['jenkins_server:8080']
EOT

sudo docker run -d --name prometheus --restart always \
  --network monitoring_network \
  -p 9090:9090 \
  -v /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v /etc/prometheus/alert.rules.yml:/etc/prometheus/alert.rules.yml \
  prom/prometheus:latest

# 7. Grafana
sudo docker run -d --name grafana --restart always \
  --network monitoring_network \
  -p 3000:3000 \
  -v grafana_data:/var/lib/grafana \
  grafana/grafana:latest

# 8. MySQL
sudo docker run -d --name db_voip_tf --restart always \
  --network monitoring_network \
  -e MYSQL_ROOT_PASSWORD=somewordpress \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wordpress \
  -e MYSQL_PASSWORD=wordpress \
  -v wordpress_db_data:/var/lib/mysql \
  mysql:8.0

# 9. WordPress
sudo docker run -d --name web_voip_tf --restart always \
  --network monitoring_network \
  -e WORDPRESS_DB_HOST=db_voip_tf:3306 \
  -e WORDPRESS_DB_USER=wordpress \
  -e WORDPRESS_DB_PASSWORD=wordpress \
  -e WORDPRESS_DB_NAME=wordpress \
  wordpress:latest

# 10. Nginx Reverse Proxy
sudo mkdir -p /etc/nginx
sudo tee /etc/nginx/nginx.conf > /dev/null << 'EOT'
events {}
http {
    server {
        listen 80;
        location / {
            proxy_pass http://web_voip_tf:80;
            proxy_set_header Host $host:8080;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host:8080;
            proxy_set_header X-Forwarded-Port 8080;
        }
    }
}
EOT

sudo docker run -d --name nginx_server --restart always \
  --network monitoring_network \
  -p 8080:80 \
  -v /etc/nginx/nginx.conf:/etc/nginx/nginx.conf \
  nginx:latest

sleep 15
sudo docker exec web_voip_tf sed -i "/<?php/a define('WP_HOME', 'http://' . \$_SERVER['HTTP_HOST']);\ndefine('WP_SITEURL', 'http://' . \$_SERVER['HTTP_HOST']);\n\$_SERVER['REQUEST_URI'] = str_replace(\"/wp-admin/\", \"/wp-admin/\", \$_SERVER['REQUEST_URI']);" wp-config.php || true
