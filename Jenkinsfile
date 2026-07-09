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
        dir('ansible') {
            sh '''
                # 1. إنشاء بيئة وهمية Python Virtual Environment وتثبيت Ansible فيها
                python3 -m venv venv
                ./venv/bin/pip install --upgrade pip
                ./venv/bin/pip install ansible
                
                # 2. تشغيل الـ Playbook باستعمال الـ Ansible اللي عاد تنزل
                ./venv/bin/ansible-playbook -i inventory.ini playbook.yml
            '''
        }
    }
}
        }
    }
