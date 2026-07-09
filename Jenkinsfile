pipeline {
    agent any

    tools {
        terraform 'terraform' 
    }
    
    environment {
    // هنا كنربطو كل متغير بالـ Credential ديالو من Jenkins ديريكت
    AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    
    JENKINS_TOKEN         = credentials('jenkins-prometheus-token')
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
        sh '''
            chmod 400 terraform/my-aws-key.pem
            ssh -o StrictHostKeyChecking=no -i terraform/my-aws-key.pem ubuntu@52.72.248.55 '
                sudo apt-get update
                sudo apt-get install -y ansible
                sudo ansible-pull -U https://github.com/lhassan-oubihi-eng/terraform_iaas.git ansible/playbook.yml
            '
        '''
    }
}
        }
    }
