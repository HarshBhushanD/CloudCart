# ☁️ CloudCart — Cloud-Native Microservices Platform

CloudCart is a production-style **cloud-native e-commerce platform** built using a microservices architecture and deployed through an automated **CI/CD pipeline**. The project demonstrates the complete DevOps lifecycle:

**Code → GitHub → Jenkins CI → Docker → Docker Hub → Kubernetes → Rolling Deployment → Health Checks → Self-Healing**

---

## 🚀 Project Overview

CloudCart is designed as a distributed e-commerce application consisting of multiple independently deployable services. The platform uses:

- Microservices architecture
- Docker containerization
- Jenkins CI/CD
- Docker Hub image registry
- Kubernetes orchestration
- PostgreSQL databases
- Kubernetes ConfigMaps & Secrets
- Health checks and readiness probes
- Rolling updates
- Kubernetes self-healing
- Infrastructure automation with Terraform
- Monitoring-ready architecture

The primary objective is to demonstrate how a modern application can be developed, containerized, tested, continuously integrated, and automatically deployed to Kubernetes.

---

## 🏗️ Architecture

```text
┌──────────────────────┐
│      Developer       │
│                      │
│      Git Push        │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│        GitHub        │
│  Source Repository   │
└──────────┬───────────┘
           │ Webhook / Trigger
           ▼
┌──────────────────────┐
│       Jenkins        │
│   CI/CD Pipeline     │
└──────────┬───────────┘
           │
 ┌─────────┴────────┬──────────────────┐
 │                  │                  │
 ▼                  ▼                  ▼
npm ci            Tests           Docker Build
                                       │
                                       ▼
                             ┌──────────────────┐
                             │    Docker Hub    │
                             │   Auth Image     │
                             │  Product Image   │
                             └────────┬─────────┘
                                      │
                                      ▼
                             ┌──────────────────┐
                             │    Kubernetes    │
                             │     Cluster      │
                             └────────┬─────────┘
                                      │
 ┌────────────────────────────────────┼───────────────────────────┐
 │                                    │                           │
 ▼                                    ▼                           ▼
┌──────────────┐             ┌────────────────┐          ┌──────────────┐
│ Auth Service │             │Product Service │          │Order Service │
│   2 Pods     │             │    2 Pods      │          │   2 Pods     │
└──────┬───────┘             └──────┬─────────┘          └──────┬───────┘
       │                            │                           │
       ▼                            ▼                           ▼
  PostgreSQL                   PostgreSQL                  PostgreSQL
```

---

## 🧩 Services

### 🔐 Auth Service
Responsible for authentication and user management.

**Responsibilities:**
- User registration
- User authentication
- Password handling
- JWT generation
- User data persistence
- Authentication APIs
- Health endpoint

**Technology:**
- Node.js
- Express.js
- PostgreSQL
- JWT
- Docker

**Port:** `5001`  
**Health endpoint:** `GET /health`

### 📦 Product Service
Responsible for product-related functionality.

**Responsibilities:**
- Product management
- Product APIs
- Product database operations
- Product health monitoring

**Technology:**
- Node.js
- Express.js
- PostgreSQL
- Docker

### 🛒 Order Service
Responsible for order-related functionality.

**Responsibilities:**
- Order management
- Order persistence
- Order APIs
- Database communication

**Technology:**
- Node.js
- Express.js
- PostgreSQL
- Docker

### 🖥️ Frontend
The frontend provides the user-facing application interface.

**Technology:**
- React
- JavaScript
- HTML/CSS
- Docker

---

## 🐳 Docker

Every backend service is containerized independently.

**Example Services:**
- `cloudcart-auth`
- `cloudcart-product`
- `cloudcart-order`

**Docker provides:**
- Consistent runtime environments
- Service isolation
- Reproducible builds
- Easy deployment
- Versioned images

### 📦 Docker Images
Images are published to Docker Hub:
- `harshbhushandixit/cloudcart-auth`
- `harshbhushandixit/cloudcart-product`

Images are versioned using the Jenkins build number.  
Example:
- `harshbhushandixit/cloudcart-auth:10`
- `harshbhushandixit/cloudcart-product:10`

This allows every deployment to be associated with a specific CI/CD build.

---

## 🔄 CI/CD Pipeline

Jenkins automates the complete deployment process.

### Pipeline Flow
```text
GitHub Push 
    │ 
    ▼ 
Checkout 
    │ 
    ▼ 
Install Dependencies 
    │ 
    ▼ 
Run Tests 
    │ 
    ▼ 
Build Docker Images 
    │ 
    ▼ 
Docker Login 
    │ 
    ▼ 
Push Images to Docker Hub 
    │ 
    ▼ 
Deploy to Kubernetes 
    │ 
    ▼ 
Wait for Rollout 
    │ 
    ▼ 
Verify Deployment
```

### 🔧 Jenkins Pipeline Stages
The Jenkins pipeline contains the following major stages:

1. **Checkout**  
   Jenkins retrieves the latest source code from GitHub: `GitHub → Jenkins Workspace`

2. **Dependency Installation**  
   Dependencies are installed using `npm ci` for each Node.js service.

3. **Testing**  
   The pipeline executes `npm test --if-present`. This allows services without configured tests to pass without breaking the pipeline.

4. **Docker Build**  
   Jenkins builds the service images:
   ```bash
   docker build -t $DOCKER_USER/cloudcart-auth:${BUILD_NUMBER} ./services/auth-service
   docker build -t $DOCKER_USER/cloudcart-product:${BUILD_NUMBER} ./services/product-service
   ```

5. **Docker Registry Login**  
   Jenkins securely authenticates with Docker Hub using Jenkins credentials. Credentials are injected through `dockerhub-creds`. Secrets are not hardcoded into the `Jenkinsfile`.

6. **Push Images**  
   Images are pushed to Docker Hub using the Jenkins build number (e.g., `cloudcart-auth:10`, `cloudcart-product:10`).

7. **Kubernetes Deployment**  
   Jenkins connects to the Kubernetes cluster and updates the deployments with the newly created image.  
   Example:
   - `auth-service` ↓ `harshbhushandixit/cloudcart-auth:10`
   - `product-service` ↓ `harshbhushandixit/cloudcart-product:10`

8. **Deployment Verification**  
   Jenkins verifies that Kubernetes successfully rolled out the new version. The deployment is only considered successful when the required replicas become available.

---

## ☸️ Kubernetes

CloudCart runs on a Kubernetes cluster. The local development cluster is created using `k3d`.

**Current cluster architecture:**  
1 Control Plane, 2 Worker Nodes  
Example: `k3d-cloudcart-server-0`, `k3d-cloudcart-agent-0`, `k3d-cloudcart-agent-1`

### 📊 Kubernetes Workloads
The `cloudcart` namespace contains:
- `auth-service`
- `product-service`
- `order-service`
- `frontend`
- `postgres-auth`
- `postgres-products`
- `postgres-order`

Backend services run with multiple replicas. Example:
- `auth-service`: 2 replicas
- `product-service`: 2 replicas
- `order-service`: 2 replicas

### 🔁 Rolling Updates
CloudCart uses Kubernetes `RollingUpdate` deployments. Example configuration:
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0
    maxSurge: 1
```
This allows Kubernetes to gradually replace old pods with new ones without taking down the application.

### ❤️ Health Checks
Services expose health endpoints that Kubernetes monitors (e.g., `GET /health`).

Kubernetes uses:
- **Liveness Probe**: Determines whether the application is still alive.
  ```yaml
  livenessProbe:
    httpGet:
      path: /health
      port: 5001
  ```
- **Readiness Probe**: Determines whether a pod is ready to receive traffic.
  ```yaml
  readinessProbe:
    httpGet:
      path: /health
      port: 5001
  ```

### 🛡️ Kubernetes Self-Healing
One of the key goals of CloudCart is demonstrating Kubernetes self-healing.  
If a running pod crashes, Kubernetes detects the missing replica and creates a replacement automatically.

```text
Desired replicas: 2
Pod A ─── Running
Pod B ─── Running
   │
   ▼ Pod B crashes
Pod A ─── Running
Pod B ─── Failed
   │
   ▼ Kubernetes reconciliation
Pod A ─── Running
Pod C ─── Running
```
The desired state is automatically restored.

### 🔐 Configuration Management
Application configuration is separated from application code using:
- **ConfigMaps**: For non-sensitive configuration (`PORT`, `DB_HOST`, `DB_NAME`, `DB_PORT`).
- **Secrets**: For sensitive values (`POSTGRES_PASSWORD`, `JWT_SECRET`).

This avoids hardcoding sensitive configuration into application manifests.

### 🗄️ PostgreSQL
Each major backend service has its own PostgreSQL database:
- `Auth Service` → `PostgreSQL Auth DB`
- `Product Service` → `PostgreSQL Product DB`
- `Order Service` → `PostgreSQL Order DB`

This follows the microservices principle of keeping service data isolated.

---

## 🏗️ Infrastructure as Code

Terraform is included in the project for infrastructure provisioning and configuration.

Example concepts used:
```text
Terraform
├── Kubernetes configuration
├── Infrastructure variables
├── Outputs
└── Kubeconfig integration
```

---

## 📁 Project Structure

```text
CloudCart/
├── services/
│   ├── auth-service/
│   │   ├── src/
│   │   │   ├── controllers/
│   │   │   ├── routes/
│   │   │   ├── config/
│   │   │   └── server.js
│   │   ├── package.json
│   │   ├── package-lock.json
│   │   └── Dockerfile
│   ├── product-service/
│   │   ├── src/
│   │   ├── package.json
│   │   ├── package-lock.json
│   │   └── Dockerfile
│   └── order-service/
│       ├── src/
│       ├── package.json
│       ├── package-lock.json
│       └── Dockerfile
├── frontend/
│   ├── src/
│   ├── package.json
│   └── Dockerfile
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secrets.yaml
│   ├── auth-service.yaml
│   ├── product-service.yaml
│   ├── order-service.yaml
│   ├── frontend.yaml
│   └── postgres/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── ...
├── jenkins/
│   └── Dockerfile
├── Jenkinsfile
├── docker-compose.yml
└── README.md
```

---

## 🛠️ Technology Stack

| Category | Technology |
|---|---|
| **Frontend** | React |
| **Backend** | Node.js + Express |
| **Database** | PostgreSQL |
| **Containerization** | Docker |
| **CI/CD** | Jenkins |
| **Container Registry** | Docker Hub |
| **Orchestration** | Kubernetes |
| **Local Kubernetes** | k3d |
| **Infrastructure as Code** | Terraform |
| **Version Control** | Git + GitHub |
| **Configuration** | Kubernetes ConfigMaps |
| **Secrets** | Kubernetes Secrets |
| **Health Monitoring** | Kubernetes Probes |

---

## ⚙️ Local Development

### Prerequisites
Install the following tools:
- Node.js & npm
- Docker
- kubectl
- k3d
- Git
- Terraform

### Clone Repository
```bash
git clone https://github.com/HarshBhushanD/CloudCart.git
cd CloudCart
```

### 🐳 Build Docker Images
**Auth Service:**
```bash
docker build -t cloudcart-auth:latest ./services/auth-service
```
**Product Service:**
```bash
docker build -t cloudcart-product:latest ./services/product-service
```

### ☸️ Kubernetes Deployment
Create the cluster:
```bash
k3d cluster create cloudcart
```
Verify:
```bash
kubectl get nodes
```
*Expected output: 1 server, 2 agents*

Deploy CloudCart:
```bash
kubectl apply -f k8s/
```

Check workloads:
```bash
kubectl get pods -n cloudcart
kubectl get deployments -n cloudcart
```

---

## 🔍 Useful Kubernetes Commands

```bash
# Check Pods
kubectl get pods -n cloudcart

# Check Services
kubectl get svc -n cloudcart

# Check Deployments
kubectl get deployment -n cloudcart

# Describe Deployment
kubectl describe deployment auth-service -n cloudcart

# View Logs
kubectl logs <pod-name> -n cloudcart

# Follow Logs
kubectl logs -f <pod-name> -n cloudcart

# Check Rollout Status
kubectl rollout status deployment/auth-service -n cloudcart

# Check Deployment Image
kubectl get deployment auth-service -n cloudcart -o jsonpath='{.spec.template.spec.containers[0].image}'
```

---

## 🔄 CI/CD Example

A developer pushes code:
```bash
git add .
git commit -m "update product service"
git push origin main
```

Jenkins automatically executes:
1. Checkout source
2. Install dependencies
3. Run tests
4. Build Docker images
5. Login to Docker Hub
6. Push images
7. Update Kubernetes
8. Wait for rollout
9. Verify deployment

**Example generated images:**
- `harshbhushandixit/cloudcart-auth:10`
- `harshbhushandixit/cloudcart-product:10`

---

## 📈 Deployment Verification

After deployment:
```bash
kubectl get deployment -n cloudcart
```

Example expected output:
```text
NAME              READY
auth-service      2/2
product-service   2/2
order-service     2/2
frontend          2/2
```

Check pods:
```bash
kubectl get pods -n cloudcart
```
All application pods should reach status `Running` with `READY 1/1`.

---

## 🔒 Security Considerations

CloudCart follows several security practices:
- Secrets are stored using Kubernetes Secrets.
- Docker Hub credentials are stored in Jenkins Credentials.
- Sensitive credentials are not hardcoded in the `Jenkinsfile`.
- Database passwords are injected through Kubernetes Secrets.
- JWT secrets are injected through Kubernetes Secrets.
- Docker login uses `--password-stdin`.

---

## 🎯 DevOps Concepts Demonstrated

This project demonstrates practical knowledge of:
- **Git**: Branching, commits, GitHub integration, webhook-triggered pipelines.
- **Docker**: Dockerfiles, image creation, image tagging, containerization, registry publishing, volume mounts, Docker daemon integration.
- **Jenkins**: Declarative pipelines, multi-stage pipelines, credentials management, environment variables, build numbers, failure handling.
- **Kubernetes**: Deployments, Pods, Services, ConfigMaps, Secrets, Rolling updates, ReplicaSets, Liveness probes, Readiness probes, Self-healing, Namespaces.
- **Terraform**: Infrastructure as Code, variables, outputs, Kubernetes provider integration.

---

## 🧪 Current Deployment Status

CloudCart has been validated with:
- [x] GitHub source integration
- [x] Jenkins CI pipeline
- [x] Dependency installation (`npm ci`)
- [x] Automated test stage
- [x] Docker image builds
- [x] Docker Hub authentication
- [x] Docker image publishing
- [x] Kubernetes deployment
- [x] Rolling updates
- [x] Kubernetes health probes
- [x] Multiple service replicas
- [x] Kubernetes self-healing
- [x] Jenkins → Kubernetes connectivity
- [x] Deployment verification
- [x] Kubernetes-based service configuration
- [x] PostgreSQL service databases
- [x] Terraform infrastructure configuration

---

## 🧠 Engineering Highlights

The project focuses on several real-world engineering principles:
- **Independent Deployment**: Each backend service can be built and deployed independently.
- **Immutable Artifacts**: Docker images are versioned using CI build numbers.
- **Declarative Infrastructure**: Kubernetes manifests describe the desired application state.
- **Automated Delivery**: Jenkins removes the need for manually building and deploying services.
- **Fault Recovery**: Kubernetes continuously reconciles actual state with desired state.
- **Configuration Separation**: Application configuration and secrets are separated from application code.
- **Zero-Downtime-Oriented Deployment**: Rolling updates with `maxUnavailable: 0` help maintain available replicas during deployments.

---

## 🚀 Future Improvements

Possible extensions include:
- Prometheus metrics & Grafana dashboards
- Alertmanager setup
- Centralized logging (ELK / EFK stack)
- API Gateway integration
- Redis caching layer
- Horizontal Pod Autoscaling (HPA)
- Ingress controller with TLS/HTTPS
- Trivy container security scanning
- SonarQube code quality analysis
- GitOps with Argo CD
- Production cloud deployment (AWS EKS)
- Automated rollback strategies

---

## 👨‍💻 Author

**Harsh Bhushan Dixit**  
Computer Science Undergraduate | Cloud Computing  
GitHub: [HarshBhushanD](https://github.com/HarshBhushanD)

---

## ⭐ Project Goal

CloudCart was built to demonstrate how a modern application can move from source code to a running Kubernetes deployment through an automated and repeatable DevOps workflow.

```text
┌──────────────┐
│  Developer   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   GitHub     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Jenkins    │
│  ├── Install │
│  ├── Test    │
│  ├── Build   │
│  └── Push    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Docker Hub  │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────┐
│          Kubernetes          │
│  ├── Auth Service            │
│  ├── Product Service         │
│  ├── Order Service           │
│  ├── Frontend                │
│  └── PostgreSQL              │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│   Health Checks & Healing    │
└──────────────────────────────┘
```

> **CloudCart — From Git Push to Kubernetes Deployment.**
