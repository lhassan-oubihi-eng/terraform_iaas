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
                        # تثبيت Ansible أوتوماتيكياً داخل الكونتينر إذا لم يكن موجوداً
                        if ! command -v ansible-playbook &> /dev/null; then
                        echo "Ansible not found. Installing..."
                            apt-get update && apt-get install -y ansible
                fi
                
                # تشغيل الـ Playbook
                ansible-playbook -i inventory.ini playbook.yml
            '''
                    }
                }
            }
        }
    }
