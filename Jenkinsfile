pipeline {
    agent any

    tools {
        terraform 'terraform' 
    }
    
    environment {
        AWS_CREDENTIALS = credentials('aws-access-key') 
        JENKINS_TOKEN   = credentials('jenkins-prometheus-token') 
    }    
    environment {
        AWS_CREDENTIALS = credentials('aws-access-key') 
        JENKINS_TOKEN   = credentials('jenkins-prometheus-token') 
    }
    
    stages {
        stage('Git Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    // تشغيل التيرالفورم أوتوماتيكياً بلا ما يسولك yes
                    sh "terraform apply -var='jenkins_prometheus_token=${JENKINS_TOKEN}' -auto-approve"
                }
            }
        }
        
        stage('Ansible Hardening') {
            steps {
                dir('ansible') {
                    // غنخليو أنسيبل يراني على السيرفر الجديد أوتوماتيكياً
                    sh "ansible-playbook -i inventory.ini playbook.yml"
                }
            }
        }
    }
}
