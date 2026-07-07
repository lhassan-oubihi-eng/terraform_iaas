terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
  }
}

provider "docker" {}

# ==============================================================================
# 0. NETWORKS, VOLUMES & IMAGES
# ==============================================================================
resource "docker_network" "monitoring_net" {
  name = "monitoring_network"
}

resource "docker_volume" "portainer_data" { name = "portainer_data" }
resource "docker_volume" "grafana_data"   { name = "grafana_data" }
resource "docker_volume" "db_data"        { name = "wordpress_db_data" }
resource "docker_volume" "jenkins_data"   { name = "jenkins_data" }

resource "docker_image" "mysql_img" {
  name         = "mysql:8.0"
  keep_locally = true
}

resource "docker_image" "wordpress_img" {
  name         = "wordpress:latest"
  keep_locally = true
}

# ==============================================================================
# 1. MONITORING LAYER
# ==============================================================================
resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = "prom/prometheus:latest"
  ports {
    internal = 9090
    external = 9090
  }
  
  # هـنـا غـانـعـطـيـوه الـ كـونـفـيـك نـيـشـان بـ تـمـريـر كـود مـبـاشـر بـاش يـتـهـنـى مـن الـ مـسـارات
  upload {
    content = <<EOT
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['node_exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
EOT
    file    = "/etc/prometheus/prometheus.yml"
  }
  
  networks_advanced { name = docker_network.monitoring_net.name }
  restart = "always"
}

resource "docker_container" "alertmanager" {
  name    = "alertmanager"
  image   = "prom/alertmanager:latest"
  command = ["--config.file=/etc/alertmanager/alertmanager.yml"]
  ports {
    internal = 9093
    external = 9093
  }
  
  upload {
    content = <<EOT
route:
  receiver: 'default-receiver'
receivers:
  - name: 'default-receiver'
EOT
    file    = "/etc/alertmanager/alertmanager.yml"
  }
  
  networks_advanced { name = docker_network.monitoring_net.name }
  restart = "always"
}

resource "docker_container" "grafana" {
  name  = "grafana"
  image = "grafana/grafana:latest"
  ports {
    internal = 3000
    external = 3000
  }
  volumes {
    volume_name    = docker_volume.grafana_data.name
    container_path = "/var/lib/grafana"
  }
  networks_advanced { name = docker_network.monitoring_net.name }
  restart = "always"
}

resource "docker_container" "cadvisor" {
  name  = "cadvisor"
  image = "gcr.io/cadvisor/cadvisor:v0.47.0"
  ports {
    internal = 8080
    external = 8085
  }
  volumes {
    host_path      = "/"
    container_path = "/rootfs"
    read_only      = true
  }
  volumes {
    host_path      = "/var/run"
    container_path = "/var/run"
    read_only      = false
  }
  volumes {
    host_path      = "/sys"
    container_path = "/sys"
    read_only      = true
  }
  volumes {
    host_path      = "/var/lib/docker"
    container_path = "/var/lib/docker"
    read_only      = true
  }
  networks_advanced { name = docker_network.monitoring_net.name }
  restart = "always"
}

resource "docker_container" "node_exporter" {
  name  = "node_exporter"
  image = "prom/node-exporter:latest"
  ports {
    internal = 9100
    external = 9100
  }
  volumes {
    host_path      = "/proc"
    container_path = "/host/proc"
    read_only      = true
  }
  volumes {
    host_path      = "/sys"
    container_path = "/host/sys"
    read_only      = true
  }
  volumes {
    host_path      = "/"
    container_path = "/rootfs"
    read_only      = true
  }
  command = [
    "--path.procfs=/host/proc",
    "--path.rootfs=/rootfs",
    "--path.sysfs=/host/sys"
  ]
  networks_advanced { name = docker_network.monitoring_net.name }
  restart = "always"
}

resource "docker_container" "portainer" {
  name  = "portainer_management"
  image = "portainer/portainer-ce:latest"
  ports {
    internal = 9443
    external = 9443
  }
  ports {
    internal = 9000
    external = 9002
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  volumes {
    volume_name    = docker_volume.portainer_data.name
    container_path = "/data"
  }
  networks_advanced { name = docker_network.monitoring_net.name }
  restart = "always"
}

# ==============================================================================
# 2. WEB & DATABASE LAYER
# ==============================================================================
resource "docker_container" "mysql" {
  name  = "db_voip_tf"
  image = docker_image.mysql_img.image_id
  env   = ["MYSQL_ROOT_PASSWORD=somewordpress", "MYSQL_DATABASE=wordpress", "MYSQL_USER=wordpress", "MYSQL_PASSWORD=wordpress"]
  networks_advanced { name = docker_network.monitoring_net.name }
  volumes {
    volume_name    = docker_volume.db_data.name
    container_path = "/var/lib/mysql"
  }
  restart = "always"
}

resource "docker_container" "wordpress" {
  name  = "web_voip_tf"
  image = docker_image.wordpress_img.image_id
  env   = ["WORDPRESS_DB_HOST=db_voip_tf:3306", "WORDPRESS_DB_USER=wordpress", "WORDPRESS_DB_PASSWORD=wordpress", "WORDPRESS_DB_NAME=wordpress"]
  networks_advanced { name = docker_network.monitoring_net.name }
  depends_on = [docker_container.mysql]
  restart = "always"
}

resource "docker_container" "nginx" {
  name  = "nginx_server"
  image = "nginx:latest"
  ports {
    internal = 80
    external = 8080
  }
  
  upload {
    content = <<EOT
events {}
http {
    server {
        listen 80;
        location / {
            proxy_pass http://web_voip_tf:80;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
EOT
    file    = "/etc/nginx/nginx.conf"
  }
  
  networks_advanced { name = docker_network.monitoring_net.name }
  depends_on = [docker_container.wordpress]
  restart = "always"
}

# ==============================================================================
# 3. CI/CD & CONFIGURATION MANAGEMENT LAYER
# ==============================================================================
resource "docker_container" "ansible_runner" {
  name  = "ansible_provisioner"
  image = "cytopia/ansible:latest"
  
  volumes {
    host_path      = abspath("${path.module}/../ansible")
    container_path = "/data"
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  working_dir = "/data"
  command     = ["ansible-playbook", "-i", "localhost,", "playbook.yml"]
  
  networks_advanced { name = docker_network.monitoring_net.name }
  depends_on = [docker_container.nginx]

  lifecycle {
    create_before_destroy = false
  }
}
