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
                // Téléchargement automatique du binaire officiel de Terraform pour Linux AMD64
                sh '''
                    if [ ! -f terraform ]; then
                        echo "Downloading Terraform..."
                        wget -q https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
                        unzip -o terraform_1.5.7_linux_amd64.zip
                        rm terraform_1.5.7_linux_amd64.zip
                        chmod +x terraform
                    fi
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    // Exécution en utilisant le binaire qu'on vient de télécharger (../terraform)
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
