pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Setup Terraform Binary') {
            steps {
                sh '''
                    if [ ! -f terraform ]; then
                        echo "Downloading Terraform using curl..."
                        # تحميل الملف باستعمال curl عوض wget
                        curl -fsSL https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip -o terraform.zip
                        
                        echo "Extracting Terraform..."
                        # فك الضغط على الملف
                        unzip -o terraform.zip
                        rm terraform.zip
                        chmod +x terraform
                    fi
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh '../terraform init'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh '../terraform apply -auto-approve'
                }
            }
        }
    }
}
