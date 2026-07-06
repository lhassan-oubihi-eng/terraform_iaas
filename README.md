# Infrastructure & Monitoring Automation Project

Ce projet offre une solution complète pour le déploiement et la surveillance d'infrastructures informatiques. Il automatise la création des serveurs avec **Terraform** et la configuration logicielle avec **Ansible**, tout en assurant une visibilité constante via une pile de monitoring (**Prometheus & Grafana**).

## 📂 Structure du projet
```text
/
├── ansible/          # Playbooks et inventaires Ansible
├── monitoring/       # Configurations Docker et Monitoring
├── terraform/        # Fichiers de configuration Terraform (.tf)
└── README.md         # Documentation du projet
🛠 Guide d'utilisation
Pour déployer et configurer l'infrastructure, suivez ces étapes dans l'ordre :

1. Infrastructure (Terraform)
Initialisez et déployez les ressources nécessaires :

Bash
cd terraform
terraform init
terraform apply
2. Automatisation (Ansible)
Une fois l'infrastructure en place, configurez les services :

Bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
📈 Monitoring & Observabilité
Le système inclut un tableau de bord pour visualiser les métriques en temps réel.

Prometheus : Collecte les données.

Grafana : Visualisation des performances (CPU, RAM, Réseau).

📋 Prérequis
Ansible installé sur votre machine locale.

Terraform installé.

Accès SSH configuré pour les cibles.

Développé par : Lhassan Oubihi
