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
        // هنا جينكينز غايجيب الملف الآمن ويحط المسار ديالو فـ متغير $SSH_KEY
        withCredentials([file(credentialsId: 'aws-ec2-ssh-key', variable: 'SSH_KEY')]) {
            sh '''
                echo "🔑 Using secure SSH key from Jenkins credentials..."
                
                # ضبط صلاحيات المفتاح السري المؤقت
                chmod 400 "$SSH_KEY"
                
                echo "🚀 Connecting to AWS EC2 instance ($instance_public_ip) via SSH..."
                
                # الاتصال وتشغيل Ansible بنجاح
                ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" ubuntu@52.72.248.55 '
                    sudo apt-get update
                    sudo apt-get install -y ansible git
                    sudo ansible-pull -U https://github.com/lhassan-oubihi-eng/terraform_iaas.git ansible/playbook.yml
                '
            '''
        }
    }
}
        }
    post {
        success {
            sh '''
                curl -H "Content-Type: application/json" \
                -X POST \
                -d "{\\"content\\": \\"✅ **Terraform-Pipeline #${BUILD_NUMBER} SUCCESS**\\\\n السيرفر طالع ناضي والـ Pipeline دازت خضرة كاملة! 🚀\\\\n🔗 الـ IP الجديد: 52.72.248.55\\"}" \
                "https://discordapp.com/api/webhooks/1524843805768028231/WQ4QMp_wxBmk1cAA0O-CWMfeipPLB0d3vUMwjM1R_iL1sI3dMfjOj5z6jAz2Vi2A9rRw"
            '''
        }
        failure {
            sh '''
                curl -H "Content-Type: application/json" \
                -X POST \
                -d "{\\"content\\": \\"❌ **Terraform-Pipeline #${BUILD_NUMBER} FAILED**\\\\nوقع مشكل فـ الـ Pipeline. تشيك الـ Console Output أستاذ لحسن! 🛠️\\"}" \
                "https://discordapp.com/api/webhooks/1524843805768028231/WQ4QMp_wxBmk1cAA0O-CWMfeipPLB0d3vUMwjM1R_iL1sI3dMfjOj5z6jAz2Vi2A9rRw"
            '''
        }
    }
    }
