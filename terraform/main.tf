terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1" # ◄── دير هادي دابا باش يـهـرب من 4.5.0 الـ عـريـضـة
    }
  }
}
provider "docker" {}

# --- NGINX CONFIGURATION ---
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "nginx_server"

  ports {
    internal = 80
    external = 8080
  }

  volumes {
    host_path      = "${path.cwd}/nginx.conf"
    container_path = "/etc/nginx/nginx.conf"
  }
}

# --- PORTAINER CONFIGURATION ---
# 1. كريو Volume خاص بـ Portainer باش الـ Data ديالو ما تمشيش يلا طفيناه
resource "docker_volume" "portainer_data" {
  name = "portainer_data"
}

# 2. جلب الـ Image ديال Portainer Community Edition
resource "docker_image" "portainer" {
  name         = "portainer/portainer-ce:latest"
  keep_locally = false
}

# 3. تشغيل الـ Container ديال Portainer
resource "docker_container" "portainer" {
  image = docker_image.portainer.image_id
  name  = "portainer_management"

  # Portainer كايخدم بـ 9443 للـ HTTPS و 9000 للـ HTTP العادي
# البورت 9443 للـ HTTPS
  ports {
    internal = 9443
    external = 9443
  }

  # البورت 9002 للـ HTTP العادي (بدلناه من 9000 باش نتفاداو التضارب)
  ports {
    internal = 9000
    external = 9002
  }
  # ربط الـ Volume والـ Docker Socket باش Portainer يتحكم ف الـ Docker د الماكينة
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  volumes {
    volume_name    = docker_volume.portainer_data.name
    container_path = "/data"
  }

  # إعادة التشغيل أوتوماتيكياً يلا طاح
  restart = "always"
}
