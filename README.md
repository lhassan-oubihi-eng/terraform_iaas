# 🚀 Infrastructure & Monitoring Automation Project

Ce projet propose une solution complète pour l'automatisation de l'infrastructure (IaC) et la mise en place d'un système de monitoring proactif. 🎯

---

## 📂 Structure du projet
```text
/
├── ansible/          # ⚙️ Playbooks et inventaires Ansible
├── monitoring/       # 📊 Configurations Docker, Prometheus & Grafana
├── terraform/        # 🏗️ Scripts de déploiement (IaC)
└── README.md         # 📝 Documentation

🛠 Guide d'utilisation
Pour déployer et configurer l'infrastructure, suivez ces étapes :

1. Infrastructure (Terraform) 🏗️
Initialisez et déployez les ressources nécessaires :

Bash
cd terraform
terraform init
terraform apply
2. Automatisation (Ansible) ⚙️
Configurez les services et les hôtes :

Bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
📈 Monitoring & Observabilité
Le système assure une surveillance continue :

✅ CPU & RAM usage : Suivi des performances en temps réel.

✅ Docker containers status : État de santé de vos conteneurs.

✅ Alerting systems : Notifications automatiques (Discord/Email) en cas d'anomalie 🔔.

📋 Prérequis
Ansible & Terraform installés.

Accès SSH configuré pour les serveurs cibles.

Développé avec passion par : Lhassan Oubihi 💻
