# 🚀 Multi-Container Application with Prometheus & Grafana Monitoring

Ce projet permet de déployer automatiquement une infrastructure complète sur AWS à l'aide de **Terraform** et **Docker**. Elle comprend un serveur WordPress (avec proxy inverse Nginx et base de données MySQL), un serveur Jenkins, ainsi qu'une stack de monitoring complète (Prometheus, Grafana, cAdvisor, Node Exporter, et Alertmanager connecté à Discord).

---

## 🛠️ Prérequis

Avant de commencer, assurez-vous d'avoir :
* **Terraform** installé sur votre machine locale.
* Un compte **AWS** (ou AWS Academy) avec des identifiants valides.
* Une paire de clés SSH AWS téléchargée (ex: `my-aws-key.pem`)

---

## 🚀 Configuration et Déploiement

### 1. Configuration des Identifiants AWS
Pour des raisons de sécurité, les clés d'accès AWS ne doivent **jamais** être écrites en dur dans le code Terraform. Vous devez les exporter temporairement dans l'environnement de votre terminal.

Ouvrez votre terminal et exécutez les commandes suivantes en remplaçant les valeurs par vos propres clés AWS :

```bash
# Configuration des variables d'environnement pour Terraform
export TF_VAR_access_key="VOTRE_AWS_ACCESS_KEY_ID"
export TF_VAR_secret_key="VOTRE_AWS_SECRET_ACCESS_KEY"

# Si vous utilisez AWS Academy, ajoutez également le token de session :
# export TF_VAR_token="VOTRE_AWS_SESSION_TOKEN"
```

> 💡 **Où trouver ces clés ?**
> * **AWS Classique :** Dans la console AWS ➡️ Security Credentials ➡️ Create Access Key.
> * **AWS Academy :** Cliquez sur "AWS Details" (à côté du bouton vert Start Lab) puis sur "Show" en face de *AWS CLI login credentials*.

---

### 2. Déploiement avec Terraform

Une fois les variables exportées, initialisez le projet et lancez le déploiement automatique :

```bash
# Initialiser le répertoire (téléchargement des providers)
terraform init

# Déployer l'infrastructure sur AWS
terraform apply -auto-approve
```

Le script va automatiquement :
1. Créer l'instance EC2 et le groupe de sécurité (Security Group) sur AWS.
2. Installer Docker et configurer une mémoire Swap de 2Go.
3. Télécharger et lancer l'ensemble des conteneurs via le script `setup.sh`.

---

## 📊 Accès aux Services

Une fois le déploiement terminé, Terraform affichera l'adresse IP publique de votre instance. Vous pourrez accéder aux différents services via les ports suivants :

* **WordPress :** `http://<IP_PUBLIQUE>:8080` (Proxy Nginx)
* **Jenkins :** `http://<IP_PUBLIQUE>:8081`
* **Prometheus :** `http://<IP_PUBLIQUE>:9090`
* **Grafana :** `http://<IP_PUBLIQUE>:3000` *(Dashboard Node Exporter : ID 1860)*
* **Alertmanager :** `http://<IP_PUBLIQUE>:9093`
