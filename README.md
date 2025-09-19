# AWS MySQL DevOps Solution — Step-by-step Guide

## 📌 Overview

This repository demonstrates a complete **Python + AWS** DevOps solution:

* FastAPI CRUD app backed by **MySQL**
* Docker + Docker Compose for local development
* Build & Push Docker images to Docker Hub
* Terraform for provisioning AWS (VPC, EKS, MySQL)
* Kubernetes deployment to AWS EKS

This README contains **explicit step-by-step commands**. Replace placeholders like `<DOCKERHUB_USERNAME>`, `<AWS_REGION>`, and `<DB_PASSWORD>` with your values.

---

## 🛠️ Prerequisites (install tools)

### Ubuntu / Debian

```bash
sudo apt-get update && sudo apt-get install -y \
  python3 python3-venv python3-pip \
  docker.io docker-compose unzip wget curl \
  apt-transport-https ca-certificates gnupg lsb-release software-properties-common

# Terraform
wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
unzip terraform_1.5.7_linux_amd64.zip && sudo mv terraform /usr/local/bin/

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### macOS (Homebrew)

```bash
brew update
brew install python docker docker-compose terraform awscli kubectl
```

### Docker (enable)

```bash
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER   # log out/in after this step
```

---

## 1️⃣ Clone repository

```bash
git clone <REPO_URL> devops-mysql-solution
cd devops-mysql-solution
```

---

## 2️⃣ Local development — Docker Compose

This runs **FastAPI app + MySQL DB** locally.

```bash
docker-compose up --build -d
```

Check logs:

```bash
docker-compose logs -f web
```

### MySQL connection details

* Host: `localhost`
* Port: `3306`
* User: `root`
* Password: `password` (default in `docker-compose.yml`)
* Database: `appdb`

### Verify DB

```bash
docker exec -it <mysql_container_id> mysql -u root -p
# Enter password: password
mysql> SHOW DATABASES;
```

### Verify API

* Swagger UI: [http://localhost:8000/docs](http://localhost:8000/docs)
* Example endpoints:

```bash
curl -s -X POST "http://localhost:8000/items" -H "Content-Type: application/json" -d '{"name": "Book", "description": "Novel"}'
curl -s http://localhost:8000/items
```

---

## 3️⃣ Build & Push Docker Image

Replace `<DOCKERHUB_USERNAME>`.

```bash
docker build -t <DOCKERHUB_USERNAME>/devops-app:latest .
docker login
docker push <DOCKERHUB_USERNAME>/devops-app:latest
```

---

## 4️⃣ Terraform — Provision AWS EKS

Ensure AWS CLI is configured:

```bash
aws configure
```

Run Terraform:

```bash
cd terraform
terraform init
terraform plan 
terraform apply -auto-approve
```

Outputs include:

* **EKS Cluster Name**


---

## 5️⃣ Configure kubectl for EKS

```bash
aws eks update-kubeconfig --region <AWS_REGION> --name <CLUSTER_NAME>
kubectl get nodes
```

---

## 6️⃣ Deploy App to Kubernetes

Update `k8s-deployment.yaml` with:

* `image: <DOCKERHUB_USERNAME>/devops-app:latest`
* `DB_HOST`, `DB_USER`, `DB_PASS`, `DB_NAME` (from Terraform outputs)

Apply manifests:

```bash
kubectl apply -f k8s-deployment.yaml
```

Verify:

```bash
kubectl get pods
kubectl get svc
```

Access the app via **LoadBalancer EXTERNAL-IP**.

---

## 7️⃣ Cleanup

### Local

```bash
docker-compose down -v
docker system prune -f
docker rmi <DOCKERHUB_USERNAME>/devops-app:latest || true
```

### Kubernetes

```bash
kubectl delete -f k8s-deployment.yaml
```

### Terraform (AWS infra)

```bash
cd terraform
terraform destroy -auto-approve
```

---

## 8️⃣ Troubleshooting Commands

```bash
kubectl describe pod <pod>
kubectl logs -f <pod>
terraform show
aws eks describe-cluster --name <CLUSTER_NAME> --region <AWS_REGION>
```

---

## ✅ Notes

* MySQL credentials are defined in **Docker Compose** and **Terraform**.
* For production, use **AWS Secrets Manager** for DB passwords.
* This repo is a starting point — expand with CI/CD pipelines as needed.

---

👩‍💻 Author: Tanushri Mujwar  – DevOps Engineer
