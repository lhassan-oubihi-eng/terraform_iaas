pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                // Récupération automatique du code depuis GitHub
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    // Exécution directe via le binaire système Linux
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    // Déploiement de l'infrastructure
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}
