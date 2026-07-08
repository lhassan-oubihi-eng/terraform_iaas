#!/bin/bash
sudo apt-get update -y

# تهيئة الـ Swap Memory ديال 2GB
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# نزول Docker
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# كربيي الشبكة والفوليومات
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

# 3. Alertmanager Configuration
sudo mkdir -p /etc/alertmanager
sudo tee /etc/alertmanager/alertmanager.yml > /dev/null << 'EOT'
global:
  resolve_timeout: 5m
route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'
receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://127.0.0.1:5001/'
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

# 4. Prometheus Configuration
sudo mkdir -p /etc/prometheus
sudo tee /etc/prometheus/prometheus.yml > /dev/null << 'EOT'
global:
  scrape_interval: 15s

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

  - job_name: 'alertmanager'
    static_configs:
      - targets: ['alertmanager:9093']

  - job_name: 'jenkins'
    metrics_path: '/prometheus/'
    static_configs:
      - targets: ['jenkins_server:8080']
EOT

sudo docker run -d --name prometheus --restart always \
  --network monitoring_network \
  -p 9090:9090 \
  -v /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus:latest

# 5. Grafana
sudo docker run -d --name grafana --restart always \
  --network monitoring_network \
  -p 3000:3000 \
  -v grafana_data:/var/lib/grafana \
  grafana/grafana:latest

# 6. MySQL
sudo docker run -d --name db_voip_tf --restart always \
  --network monitoring_network \
  -e MYSQL_ROOT_PASSWORD=somewordpress \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wordpress \
  -e MYSQL_PASSWORD=wordpress \
  -v wordpress_db_data:/var/lib/mysql \
  mysql:8.0

# 7. WordPress
sudo docker run -d --name web_voip_tf --restart always \
  --network monitoring_network \
  -e WORDPRESS_DB_HOST=db_voip_tf:3306 \
  -e WORDPRESS_DB_USER=wordpress \
  -e WORDPRESS_DB_PASSWORD=wordpress \
  -e WORDPRESS_DB_NAME=wordpress \
  wordpress:latest

# 8. Nginx Reverse Proxy (معدل بـ الـ Headers لتصحيح الـ Redirect والـ CSS)
sudo mkdir -p /etc/nginx
sudo tee /etc/nginx/nginx.conf > /dev/null << 'EOT'
events {}
http {
    server {
        listen 80;
        location / {
            proxy_pass http://web_voip_tf:80;
            proxy_set_header Host $host:8080; # إعلام الـ WordPress بالبورت الخارجي
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

# خطوة أوتوماتيكية لتعديل wp-config.php فور تشغيل الحاوية لضبط الـ URLs والـ CSS
sleep 15
sudo docker exec web_voip_tf sed -i "/<?php/a define('WP_HOME', 'http://' . \$_SERVER['HTTP_HOST']);\ndefine('WP_SITEURL', 'http://' . \$_SERVER['HTTP_HOST']);\n\$_SERVER['REQUEST_URI'] = str_replace(\"/wp-admin/\", \"/wp-admin/\", \$_SERVER['REQUEST_URI']);" wp-config.php || true
