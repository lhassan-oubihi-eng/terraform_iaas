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
                dir('terraform') {
                    sh '''
                        if [ ! -f tf_bin ]; then
                            echo "Downloading Terraform inside project dir..."
                            curl -fsSL https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip -o terraform.zip
                            
                            echo "Extracting Terraform binary..."
                            unzip -o terraform.zip
                            
                            # Réglage du nom pour éviter le conflit avec le dossier 'terraform'
                            mv terraform tf_bin
                            rm terraform.zip
                            chmod +x tf_bin
                        fi
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    // Exécution via le binaire local ./tf_bin
                    sh './tf_bin init'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh './tf_bin apply -auto-approve'
                }
            }
        }
    }
}
