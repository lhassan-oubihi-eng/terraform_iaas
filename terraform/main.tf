terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# هاد المتغير هو اللي غيستقبل الـ Token فـ الـ Terminal بلا ما يتكتب فـ الكود
variable "jenkins_prometheus_token" {
  type        = string
  sensitive   = true
  description = "The Jenkins API Token for Prometheus basic auth"
}

resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring_io_sg_prod_final_v5"
  description = "Allow Web, SSH, Jenkins and Monitoring traffic"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9443
    to_port     = 9443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
  ami             = "ami-04b70fa74e45c3917" 
  instance_type   = "t3.micro"              
  key_name        = "my-aws-key"            

  security_groups = [aws_security_group.monitoring_sg.name]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # هنا السحر: كيمرر الـ token لملف setup.sh أوتوماتيكياً
  user_data = templatefile("setup.sh", {
    jenkins_token = var.jenkins_prometheus_token
  })

  tags = { Name = "DevOps-Automation-Station" }
}

output "instance_public_ip" {
  value       = aws_instance.monitoring_server.public_ip
  description = "Public IP of the EC2 Instance"
}
