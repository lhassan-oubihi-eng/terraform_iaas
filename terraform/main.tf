provider "aws" {
  region = "us-east-1" # بدّلها يلا كنتي خدام فـ شي ريجون أخرى
}

resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring_project_sg"
  description = "Security group for DevOps monitoring project"

  # Nginx (WordPress Proxy)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grafana
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Alertmanager
  ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # cAdvisor
  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "monitoring_server" {
  ami           = "ami-0e2c8caa4b6378d8c" # Ubuntu 24.04 LTS فـ us-east-1
  instance_type = "t3.medium"             # أحسن حيت الـ ستاك عامر بزاف
  key_name      = "my-aws-key"            # سميت الـ Key Pair ديارك فـ AWS

  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  user_data              = file("setup.sh")

  tags = {
    Name = "DevOps-Monitoring-Server"
  }
}

output "instance_public_ip" {
  value = aws_instance.monitoring_server.public_ip
}
