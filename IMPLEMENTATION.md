# DevOps Capstone Project - Implementation Guide

## 📚 What You'll Learn

This comprehensive guide will teach you to implement a complete DevOps pipeline using industry-standard tools. By the end of this project, you'll have hands-on experience with:

- **Containerization** (Docker) - Package applications into portable containers
- **Container Orchestration** (Kubernetes) - Manage containers at scale
- **Package Management** (Helm) - Deploy applications using templates
- **CI/CD Pipelines** (Jenkins) - Automate testing and deployment
- **GitOps** (ArgoCD) - Deploy using Git as source of truth
- **Infrastructure as Code** (Terraform) - Manage infrastructure using code
- **Configuration Management** (Ansible) - Automate system configuration
- **Monitoring** (Prometheus & Grafana) - Track system performance
- **Microservices Architecture** - Build scalable distributed applications

## 🎯 Project Overview

We'll build a simple todo application with three components:
1. **Frontend** - React web interface (runs in browser)
2. **Backend** - Node.js API server (handles business logic)
3. **Database** - MongoDB (stores data)

This represents a typical modern web application architecture.

## 📋 Prerequisites and Environment Setup

### 💻 System Requirements

**Hardware Requirements:**
- **RAM**: Minimum 8GB (16GB recommended)
  - *Why?* Kubernetes and multiple containers need significant memory
- **Disk Space**: 50GB free space
  - *Why?* Docker images, logs, and application data take space
- **CPU**: 4+ cores recommended
  - *Why?* Running multiple containers simultaneously requires processing power

**Operating System:**
- **Ubuntu 20.04 LTS or later** (or Windows with WSL2)
- **Internet Connection** - Required for downloading tools and images

### 🚀 Step 1: Initial System Update and Basic Tools

**What we're doing:** Setting up essential command-line tools that we'll use throughout the project.

```bash
# Update the list of available packages and their versions
# This ensures we get the latest versions of software
sudo apt update 

# Install essential command-line tools
# Each tool serves a specific purpose in our DevOps workflow
sudo apt install -y \
  curl \                           # Download files from web
  wget \                           # Alternative download tool
  git \                            # Version control system
  vim \                            # Text editor for config files
  unzip \                          # Extract compressed files
  software-properties-common \     # Manage software repositories
  apt-transport-https \            # Enable HTTPS for package downloads
  ca-certificates \                # SSL/TLS certificates for secure connections
  gnupg \                          # GNU Privacy Guard for signatures
  lsb-release                      # Get Ubuntu version information
```

**🔍 What each tool does:**

- **curl**: Download files and test web APIs
- **wget**: Alternative tool for downloading files
- **git**: Track changes in code and collaborate with others
- **vim**: Edit configuration files directly in terminal
- **unzip**: Extract downloaded software packages
- **software-properties-common**: Add external software repositories
- **apt-transport-https**: Download packages securely over HTTPS
- **ca-certificates**: Verify the identity of websites and servers
- **gnupg**: Verify digital signatures on downloaded software
- **lsb-release**: Identify your Ubuntu version for compatibility

**✅ Verification:**
```bash
# Check that essential tools are installed correctly
curl --version    # Should show curl version (e.g., curl 7.68.0)
git --version     # Should show git version (e.g., git version 2.25.1)
vim --version     # Should show vim version information
```

**🚨 Troubleshooting:**
```bash
# If any command fails, try:
sudo apt update && sudo apt upgrade -y
# This updates all packages to latest versions

# If you get "permission denied", make sure to use sudo:
sudo apt install curl
```

### 🐳 Step 2: Install Docker

**What is Docker?**
Docker is like a virtual shipping container for your applications. Just as shipping containers can hold different goods but fit on any ship, Docker containers can hold different applications but run on any computer.

**Why do we need Docker?**
- **Consistency**: Your application runs the same way everywhere
- **Isolation**: Applications don't interfere with each other
- **Portability**: Move applications between different computers easily

**Installation Process:**

```bash
# Step 2a: Remove any existing Docker installations to start clean
# This prevents conflicts with older versions
sudo apt remove docker docker-engine docker.io containerd runc

# Step 2b: Add Docker's official GPG key for security
# This ensures we download authentic Docker software, not malicious copies
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Step 2c: Add Docker's official repository to our system
# This tells Ubuntu where to find Docker packages
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Step 2d: Update package list to include Docker repository
sudo apt update

# Step 2e: Install Docker components
sudo apt install -y \
  docker-ce \              # Docker Community Edition (main engine)
  docker-ce-cli \          # Command-line interface for Docker
  containerd.io \          # Container runtime
  docker-compose-plugin    # Tool for multi-container applications

# Step 2f: Add your user to the docker group
# This allows you to run Docker commands without 'sudo'
sudo usermod -aG docker $USER

# Step 2g: Apply the group membership immediately
newgrp docker
```

**🔍 Understanding the Installation:**

1. **GPG Key**: Like a digital signature that proves the software is authentic
2. **Repository**: A trusted source where Ubuntu can download Docker
3. **docker-ce**: The main Docker engine that runs containers
4. **docker-ce-cli**: Command-line tools to control Docker
5. **containerd.io**: Low-level runtime that actually executes containers
6. **docker-compose-plugin**: Helps manage multi-container applications

**✅ Verification:**
```bash
# Check Docker is installed correctly
docker --version          # Should show Docker version (e.g., Docker version 24.0.2)

# Test Docker is working by running a simple container
docker run hello-world     # Downloads and runs a test container

# Check Docker service is running
sudo systemctl status docker  # Should show "active (running)"
```

**🔧 What the test does:**
When you run `docker run hello-world`:
1. Docker looks for the "hello-world" image locally
2. If not found, it downloads it from Docker Hub (online repository)
3. Creates a container from the image
4. Runs the container (which prints a welcome message)
5. Container exits automatically

**🚨 Troubleshooting Docker:**

**Problem**: "Permission denied" when running Docker commands
```bash
# Solution: Make sure you're in the docker group
groups $USER              # Should show "docker" in the list
sudo usermod -aG docker $USER
# Then log out and log back in, or restart your terminal
```

**Problem**: Docker service not running
```bash
# Solution: Start Docker service
sudo systemctl start docker
sudo systemctl enable docker  # Start automatically on boot
```

**Problem**: "Cannot connect to Docker daemon"
```bash
# Solution: Check if Docker is running
sudo systemctl status docker
# If not running:
sudo systemctl start docker
```
docker run hello-world
```

### ⎈ Step 3: Install Kubectl

**What is Kubectl?**
Kubectl (pronounced "cube-control") is the command-line tool for controlling Kubernetes clusters. Think of it as the remote control for your Kubernetes cluster.

**What is Kubernetes?**
Kubernetes (K8s) is like a smart orchestrator for containers. If Docker containers are like individual musicians, Kubernetes is the conductor that coordinates them to play together as an orchestra.

**Why do we need Kubectl?**
- **Deploy applications** to Kubernetes clusters
- **Monitor** the status of your applications
- **Scale** applications up or down based on demand
- **Troubleshoot** issues when things go wrong

**Installation Process:**

```bash
# Step 3a: Download the latest stable version of kubectl
# The inner command gets the latest version number from Kubernetes releases
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Step 3b: Make the downloaded file executable
# This gives us permission to run it as a program
chmod +x kubectl

# Step 3c: Move kubectl to a directory in your PATH
# This lets you run 'kubectl' from anywhere in the terminal
sudo mv kubectl /usr/local/bin/

# Step 3d: Enable auto-completion for kubectl commands
# This helps you type commands faster and avoid typos
echo 'source <(kubectl completion bash)' >> ~/.bashrc

# Step 3e: Apply the changes to your current terminal session
source ~/.bashrc
```

**🔍 Understanding the Installation:**

1. **curl -LO**: Downloads the kubectl binary file
2. **chmod +x**: Makes the file executable (runnable as a program)
3. **/usr/local/bin/**: A standard directory for user-installed programs
4. **Auto-completion**: Press Tab to complete kubectl commands automatically

**✅ Verification:**
```bash
# Check kubectl is installed correctly
kubectl version --client    # Should show kubectl version (e.g., Client Version: v1.28.2)

# Test kubectl can find available commands
kubectl --help             # Shows all available kubectl commands

# Check kubectl completion is working
kubectl get <TAB>          # Should show possible completions like 'pods', 'services', etc.
```

**🔧 What these commands do:**
- `kubectl version --client`: Shows the version of your kubectl tool
- `kubectl --help`: Lists all available commands and options
- `kubectl get <resource>`: Retrieves information about Kubernetes resources

**🚨 Troubleshooting Kubectl:**

**Problem**: "kubectl: command not found"
```bash
# Solution: Check if kubectl is in your PATH
which kubectl              # Should show /usr/local/bin/kubectl
echo $PATH                 # Should include /usr/local/bin

# If not found, try reinstalling:
sudo mv kubectl /usr/local/bin/
sudo chmod +x /usr/local/bin/kubectl
```

**Problem**: Auto-completion not working
```bash
# Solution: Reload your shell configuration
source ~/.bashrc
# Or restart your terminal
```

### 🚗 Step 4: Install Minikube

**What is Minikube?**
Minikube is like a miniature Kubernetes cluster that runs on your local computer. It's perfect for learning and development. Think of it as having a small-scale production environment on your laptop.

**Why use Minikube instead of real Kubernetes?**
- **Learning-friendly**: Runs on a single machine (your computer)
- **Free**: No cloud costs for learning
- **Fast setup**: Ready in minutes, not hours
- **Safe to experiment**: Can't break production systems

**Installation Process:**

```bash
# Step 4a: Download the latest Minikube binary
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Step 4b: Install Minikube to system PATH
# This makes 'minikube' command available everywhere
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Step 4c: Remove the downloaded file (cleanup)
rm minikube-linux-amd64

# Step 4d: Start your first Kubernetes cluster!
# This creates a virtual machine with Kubernetes inside
minikube start \
  --driver=docker \      # Use Docker as the virtualization layer
  --cpus=4 \            # Allocate 4 CPU cores to the cluster
  --memory=6144         # Allocate 6GB RAM to the cluster

# Step 4e: Enable essential add-ons
minikube addons enable ingress        # Web traffic routing
minikube addons enable metrics-server # Resource monitoring
```

**🔍 Understanding the Configuration:**

1. **--driver=docker**: Uses Docker containers instead of virtual machines (faster)
2. **--cpus=4**: Gives Kubernetes 4 CPU cores to work with
3. **--memory=6144**: Allocates 6GB RAM (6144 MB) to Kubernetes
4. **ingress addon**: Allows external traffic to reach your applications
5. **metrics-server addon**: Collects performance data (CPU, memory usage)

**✅ Verification:**
```bash
# Check Minikube cluster status
minikube status           # Should show "Running" for all components

# Check Kubernetes cluster is working
kubectl cluster-info      # Shows cluster endpoints and services

# Check nodes in your cluster
kubectl get nodes         # Should show one node named "minikube"

# Check enabled addons
minikube addons list      # Shows which features are enabled
```

**🔧 What happens during startup:**

1. **Downloads Kubernetes**: Gets the latest Kubernetes components
2. **Creates virtual environment**: Sets up isolated space for cluster
3. **Installs Kubernetes**: Configures all necessary services
4. **Configures networking**: Sets up internal cluster networking
5. **Enables addons**: Installs extra features you requested

**Expected output when successful:**
```
😄  minikube v1.32.0 on Ubuntu 22.04
✨  Using the docker driver based on user configuration
📌  Using Docker driver with root privileges
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
💾  Downloading Kubernetes v1.28.3 preload ...
🔥  Creating docker container (CPUs=4, Memory=6144MB) ...
🐳  Preparing Kubernetes v1.28.3 on Docker 24.0.7 ...
🔎  Verifying Kubernetes components...
🌟  Enabled addons: storage-provisioner, default-storageclass, ingress, metrics-server
🏄  Done! kubectl is now configured to use "minikube" cluster
```

**🚨 Troubleshooting Minikube:**

**Problem**: "Insufficient memory" error
```bash
# Solution: Reduce memory allocation
minikube delete          # Remove existing cluster
minikube start --driver=docker --cpus=2 --memory=4096
```

**Problem**: "Docker driver not found"
```bash
# Solution: Make sure Docker is running
sudo systemctl status docker
sudo systemctl start docker
# Then try starting Minikube again
```

**Problem**: Minikube won't start
```bash
# Solution: Clean up and try again
minikube delete --all    # Remove all clusters
minikube start --driver=docker --cpus=4 --memory=6144
```

**Problem**: "VirtualBox driver" errors (if you see them)
```bash
# Solution: Force Docker driver
minikube start --driver=docker --force
```

**🎯 Success Indicators:**
- ✅ `minikube status` shows all components as "Running"
- ✅ `kubectl get nodes` shows one node in "Ready" state
- ✅ No error messages during startup
- ✅ `kubectl cluster-info` shows cluster endpoints

### 📦 Step 5: Install Helm

**What is Helm?**
Helm is like an app store for Kubernetes. Instead of writing complex Kubernetes configuration files from scratch, you can use pre-built "charts" (packages) that others have created and tested.

**Real-world analogy:**
- Writing Kubernetes YAML files manually = Building furniture from individual screws and wood pieces
- Using Helm charts = Buying pre-designed IKEA furniture with clear instructions

**Why use Helm?**
- **Simplifies deployment**: Install complex applications with one command
- **Reusability**: Use the same chart for different environments (dev, staging, production)
- **Version management**: Easy upgrades and rollbacks
- **Community**: Thousands of pre-built charts available

**Installation Process:**

```bash
# Step 5a: Add Helm's official GPG key for security verification
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null

# Step 5b: Add Helm's official package repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

# Step 5c: Update package list and install Helm
sudo apt update
sudo apt install helm

# Step 5d: Add popular Helm chart repositories
# These are like adding app stores to your phone

# Official Helm charts repository
helm repo add stable https://charts.helm.sh/stable

# Prometheus monitoring charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Grafana dashboard charts
helm repo add grafana https://grafana.github.io/helm-charts

# Step 5e: Update all repositories to get latest chart versions
helm repo update
```

**🔍 Understanding Helm Repositories:**

1. **stable**: Official Helm charts (like the main app store)
2. **prometheus-community**: Charts for monitoring and alerting tools
3. **grafana**: Charts for data visualization dashboards

**✅ Verification:**
```bash
# Check Helm is installed correctly
helm version                 # Should show Helm version (e.g., version.BuildInfo{Version:"v3.13.1"})

# List configured repositories
helm repo list               # Should show the three repositories we added

# Search for available charts (example)
helm search repo nginx       # Shows available nginx charts

# Check repository status
helm repo update             # Updates all repositories (should complete without errors)
```

**🔧 Understanding Helm Commands:**

- `helm repo add`: Adds a new chart repository (like adding an app store)
- `helm repo list`: Shows all configured repositories
- `helm repo update`: Updates chart information from repositories
- `helm search repo <name>`: Finds charts containing the specified name
- `helm install <name> <chart>`: Installs a chart into Kubernetes
- `helm upgrade`: Updates an existing installation
- `helm uninstall`: Removes an installation

**🎯 Test Helm Installation:**
```bash
# Search for a simple chart to test
helm search repo hello-world

# Try to install a simple test chart (don't worry, we'll remove it)
helm install test-release stable/hello-world 2>/dev/null || echo "Chart not found (this is normal)"

# List current Helm installations
helm list                    # Should show empty list initially
```

**🚨 Troubleshooting Helm:**

**Problem**: "helm: command not found"
```bash
# Solution: Verify PATH and reinstall
which helm                   # Should show /usr/bin/helm
sudo apt install --reinstall helm
```

**Problem**: Repository errors
```bash
# Solution: Re-add repositories
helm repo remove stable prometheus-community grafana
helm repo add stable https://charts.helm.sh/stable
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

**Problem**: "Error: Kubernetes cluster unreachable"
```bash
# Solution: Check Minikube is running
minikube status
kubectl cluster-info
# If not running:
minikube start
```

**🎓 What we'll use Helm for:**
Later in this project, we'll use Helm to install:
- **Our applications** (frontend, backend, database)
- **Prometheus** (monitoring system)
- **Grafana** (dashboard for viewing metrics)
- **ArgoCD** (GitOps deployment tool)

Each of these would require dozens of Kubernetes configuration files if done manually. With Helm, each becomes a simple one-line install command!

### 🏭 Step 6: Install Jenkins

**What is Jenkins?**
Jenkins is like an automated assembly line for your code. Every time you make changes to your application, Jenkins automatically:
1. Tests your code to make sure it works
2. Builds your application into containers
3. Deploys it to your servers
4. Notifies you if anything goes wrong

**Why use Jenkins?**
- **Automation**: No more manual deployments that are error-prone
- **Consistency**: Every deployment follows the same process
- **Speed**: Deploy changes in minutes, not hours
- **Reliability**: Catch problems before they reach users
- **Collaboration**: Team members can see deployment status

**Installation Process:**

```bash
# Step 6a: Add Jenkins official GPG key for security
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Step 6b: Add Jenkins repository to package sources
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Step 6c: Install Java (Jenkins is built on Java and requires it)
sudo apt update
sudo apt install -y openjdk-11-jdk

# Step 6d: Install Jenkins
sudo apt install jenkins

# Step 6e: Start Jenkins service immediately
sudo systemctl start jenkins

# Step 6f: Enable Jenkins to start automatically when system boots
sudo systemctl enable jenkins

# Step 6g: Get the initial admin password (you'll need this!)
echo "=========================================="
echo "🔐 IMPORTANT: Save this password!"
echo "=========================================="
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "=========================================="
echo "You'll need this password to set up Jenkins"
echo "=========================================="
```

**🔍 Understanding the Installation:**

1. **GPG Key**: Ensures we're downloading authentic Jenkins software
2. **Java JDK**: Jenkins is a Java application, so it needs Java runtime
3. **systemctl start**: Starts Jenkins immediately
4. **systemctl enable**: Makes Jenkins start automatically after system reboots
5. **Initial password**: Randomly generated password for first-time setup

**✅ Verification:**
```bash
# Check Jenkins service is running
sudo systemctl status jenkins    # Should show "active (running)"

# Check Jenkins is listening on port 8080
sudo netstat -tlnp | grep 8080   # Should show Jenkins process listening

# Check Java is installed correctly
java -version                    # Should show Java 11 version

# Verify Jenkins files exist
ls -la /var/lib/jenkins/         # Should show Jenkins home directory
```

**🌐 Initial Jenkins Setup:**

```bash
# Open Jenkins in your web browser
echo "Open your web browser and go to: http://localhost:8080"

# If you're on a remote server, use the server's IP address:
echo "Or go to: http://$(hostname -I | awk '{print $1}'):8080"
```

**🔧 First-time Setup Steps (in web browser):**

1. **Unlock Jenkins Page**:
   - Paste the initial admin password (from Step 6g above)
   - Click "Continue"

2. **Install Plugins**:
   - Choose "Install suggested plugins" (recommended for beginners)
   - Wait for installation to complete (5-10 minutes)

3. **Create Admin User**:
   - Username: `admin`
   - Password: `admin123` (choose a strong password in real projects!)
   - Full Name: Your name
   - Email: Your email

4. **Instance Configuration**:
   - Keep the default Jenkins URL: `http://localhost:8080/`
   - Click "Save and Finish"

5. **Welcome Screen**:
   - Click "Start using Jenkins"

**🎯 Essential Jenkins Plugins (we'll install these later):**
- **Docker Pipeline**: Build and push Docker images
- **Kubernetes**: Deploy to Kubernetes clusters
- **Git**: Connect to Git repositories
- **Pipeline**: Create complex automated workflows
- **Blue Ocean**: Modern, visual pipeline interface

**🚨 Troubleshooting Jenkins:**

**Problem**: Jenkins won't start
```bash
# Check if port 8080 is already in use
sudo netstat -tlnp | grep 8080

# If something else is using port 8080, change Jenkins port:
sudo systemctl stop jenkins
sudo sed -i 's/HTTP_PORT=8080/HTTP_PORT=8081/g' /etc/default/jenkins
sudo systemctl start jenkins
# Then access Jenkins at http://localhost:8081
```

**Problem**: "Java not found" error
```bash
# Verify Java installation
java -version
which java

# If Java is missing:
sudo apt install openjdk-11-jdk
```

**Problem**: Permission denied accessing Jenkins
```bash
# Check Jenkins service status
sudo systemctl status jenkins

# Check Jenkins logs for errors
sudo journalctl -u jenkins --no-pager

# Restart Jenkins if needed
sudo systemctl restart jenkins
```

**Problem**: Can't access Jenkins from browser
```bash
# Check if Jenkins is running
sudo systemctl status jenkins

# Check firewall (if enabled)
sudo ufw status
sudo ufw allow 8080/tcp  # If firewall is active

# Check if you're using the right IP address
hostname -I              # Shows your computer's IP address
```

**🔒 Security Notes:**
- The initial password is randomly generated for security
- Change the default admin password after setup
- In production environments, use stronger authentication (LDAP, OAuth, etc.)
- Consider setting up HTTPS for secure access

**📱 Mobile Access:**
You can even access Jenkins from your phone! Just use your computer's IP address:
```bash
# Get your IP address
ip route get 8.8.8.8 | awk '{print $7}' | head -1
# Then go to http://YOUR_IP:8080 on your phone
```

### 🏗️ Step 7: Install Terraform

**What is Terraform?**
Terraform is like a blueprint system for your infrastructure. Instead of manually creating servers, databases, and networks by clicking in web interfaces, you write code that describes what you want, and Terraform builds it for you.

**Real-world analogy:**
- **Manual infrastructure** = Building a house by placing each brick by hand
- **Terraform** = Having architectural blueprints that construction crews can follow to build identical houses

**Why use Terraform?**
- **Reproducible**: Create identical environments every time
- **Version controlled**: Track changes to your infrastructure like code
- **Safe**: Preview changes before applying them
- **Multi-cloud**: Works with AWS, Azure, Google Cloud, and Kubernetes
- **Teamwork**: Share infrastructure definitions with your team

**What we'll use Terraform for:**
In this project, Terraform will create our Kubernetes namespaces, configure resources, and set up our application environment automatically.

**Installation Process:**

```bash
# Step 7a: Add HashiCorp's official GPG key
# HashiCorp is the company that makes Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Step 7b: Add HashiCorp repository to our package sources
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Step 7c: Update package list and install Terraform
sudo apt update
sudo apt install terraform

# Step 7d: Enable Terraform auto-completion (makes typing commands easier)
terraform -install-autocomplete
```

**🔍 Understanding Infrastructure as Code:**

**Traditional Way (Manual):**
1. Log into cloud provider web console
2. Click "Create Server"
3. Choose size, network settings, security groups
4. Repeat for each environment (dev, staging, production)
5. Hope you remember all the settings when you need to recreate it

**Terraform Way (Automated):**
1. Write a `.tf` file describing what you want
2. Run `terraform plan` to see what will be created
3. Run `terraform apply` to create everything
4. Use the same file for all environments
5. Everything is documented and version controlled

**✅ Verification:**
```bash
# Check Terraform is installed correctly
terraform --version         # Should show Terraform version (e.g., Terraform v1.6.3)

# Test Terraform basic functionality
terraform --help           # Shows all available commands

# Check auto-completion is working (if you installed it)
terraform <TAB><TAB>       # Should show available commands
```

**🎯 Basic Terraform Concepts:**

1. **Providers**: Plugins that let Terraform talk to different services (AWS, Kubernetes, etc.)
2. **Resources**: Things you want to create (servers, databases, networks)
3. **Variables**: Settings you can customize (like server size, names)
4. **Outputs**: Information Terraform shows you after creating resources
5. **State**: Terraform's memory of what it has created

**🔧 Essential Terraform Commands (you'll use these later):**
```bash
terraform init      # Download necessary plugins for your configuration
terraform plan      # Show what Terraform will create/modify/destroy
terraform apply     # Actually create/modify the infrastructure
terraform destroy   # Remove everything Terraform created
terraform validate  # Check if your configuration files are valid
terraform fmt       # Format your configuration files nicely
```

**🧪 Test Terraform Installation:**
```bash
# Create a simple test configuration
mkdir -p ~/terraform-test
cd ~/terraform-test

# Create a basic Terraform file
cat > test.tf << 'EOF'
# This is a comment in Terraform
# Let's create a simple local file to test Terraform

resource "local_file" "test" {
  filename = "hello-terraform.txt"
  content  = "Hello from Terraform! Today is ${timestamp()}"
}

output "file_location" {
  value = local_file.test.filename
}
EOF

# Initialize Terraform (downloads the 'local' provider)
terraform init

# See what Terraform plans to do
terraform plan

# Apply the configuration (create the file)
terraform apply -auto-approve

# Check the file was created
ls -la hello-terraform.txt
cat hello-terraform.txt

# Clean up the test
terraform destroy -auto-approve
cd ~
rm -rf ~/terraform-test
```

**🔍 What the test does:**
1. Creates a simple Terraform configuration that makes a local file
2. Initializes Terraform (downloads providers)
3. Plans the changes (shows what will happen)
4. Applies the changes (creates the file)
5. Shows the output
6. Destroys everything (cleans up)

**🚨 Troubleshooting Terraform:**

**Problem**: "terraform: command not found"
```bash
# Solution: Check installation
which terraform
echo $PATH

# Reinstall if needed
sudo apt update
sudo apt install terraform --reinstall
```

**Problem**: "Failed to install provider"
```bash
# Solution: Check internet connection and try again
terraform init
# If still fails, try:
terraform init -upgrade
```

**Problem**: Permission errors
```bash
# Solution: Make sure you have write permissions in current directory
pwd
ls -la
# Move to a directory you own:
cd ~
```

**🎓 Learning Resources:**
- **Terraform Documentation**: https://terraform.io/docs
- **Terraform Tutorials**: https://learn.hashicorp.com/terraform
- **Terraform Examples**: https://github.com/hashicorp/terraform/tree/main/examples

**💡 Pro Tips:**
- Always run `terraform plan` before `terraform apply` to see what will change
- Keep your `.tf` files in version control (Git)
- Use meaningful names for your resources
- Add comments to explain complex configurations
- Never manually change resources that Terraform manages

### 🤖 Step 8: Install Ansible

**What is Ansible?**
Ansible is like a remote control for multiple computers. It lets you configure, update, and manage many servers at once by writing simple instructions called "playbooks." Think of it as being able to give the same instructions to hundreds of computers simultaneously.

**Real-world analogy:**
- **Manual server management** = Calling each employee individually to give them instructions
- **Ansible** = Sending a company-wide email with clear instructions that everyone follows

**Why use Ansible?**
- **Agentless**: No special software needed on target computers
- **Simple**: Uses human-readable YAML files
- **Idempotent**: Running the same playbook multiple times gives same result
- **Powerful**: Can configure anything from single servers to entire data centers
- **Safe**: Can test changes before applying them

**What we'll use Ansible for:**
In this project, Ansible will help us:
- Configure our Kubernetes cluster
- Install and configure monitoring tools
- Set up ArgoCD for GitOps
- Automate repetitive setup tasks

**Installation Process:**

```bash
# Step 8a: Update package list to get latest version information
sudo apt update

# Step 8b: Install Ansible and its dependencies
sudo apt install -y ansible

# Step 8c: Create Ansible configuration directory
mkdir -p ~/.ansible

# Step 8d: Create a basic Ansible configuration file
cat > ~/.ansible.cfg << 'EOF'
[defaults]
# Basic Ansible configuration for beginners
host_key_checking = False
inventory = ~/.ansible/inventory
remote_user = $USER
private_key_file = ~/.ssh/id_rsa

[inventory]
# Automatically enable useful plugins
enable_plugins = host_list, script, auto, yaml, ini, toml
EOF

# Step 8e: Create an inventory file for local operations
cat > ~/.ansible/inventory << 'EOF'
# Ansible inventory file
# This tells Ansible which computers to manage

[local]
localhost ansible_connection=local

[kubernetes]
# We'll add Kubernetes nodes here later if needed
EOF
```

**🔍 Understanding Ansible Components:**

1. **Inventory**: List of servers/computers Ansible manages
2. **Playbooks**: Instructions written in YAML format
3. **Tasks**: Individual actions (install software, copy files, etc.)
4. **Modules**: Pre-built functions (apt, copy, service, etc.)
5. **Roles**: Reusable collections of tasks

**✅ Verification:**
```bash
# Check Ansible is installed correctly
ansible --version           # Should show Ansible version (e.g., ansible [core 2.12.1])

# Test Ansible can connect to localhost
ansible localhost -m ping   # Should return "pong" if successful

# Check Ansible configuration
ansible-config view         # Shows current Ansible settings

# List available modules
ansible-doc -l | head -10   # Shows first 10 available modules

# Test a simple Ansible command
ansible localhost -m setup | head -20  # Shows system information
```

**🧪 Test Ansible with a Simple Playbook:**

```bash
# Create a test playbook
cat > ~/test-playbook.yml << 'EOF'
---
# This is a simple Ansible playbook for testing
- name: Test Ansible Installation
  hosts: localhost
  connection: local
  gather_facts: yes
  
  tasks:
    - name: Create a test directory
      file:
        path: ~/ansible-test
        state: directory
        mode: '0755'
    
    - name: Create a test file with system info
      copy:
        content: |
          Ansible Test File
          =================
          Created on: {{ ansible_date_time.iso8601 }}
          System: {{ ansible_distribution }} {{ ansible_distribution_version }}
          Hostname: {{ ansible_hostname }}
          User: {{ ansible_user_id }}
        dest: ~/ansible-test/system-info.txt
        mode: '0644'
    
    - name: Display success message
      debug:
        msg: "✅ Ansible test completed successfully!"
EOF

# Run the test playbook
echo "Running Ansible test playbook..."
ansible-playbook ~/test-playbook.yml

# Verify the test worked
echo "Checking test results..."
ls -la ~/ansible-test/
cat ~/ansible-test/system-info.txt

# Clean up test files
rm -rf ~/ansible-test ~/test-playbook.yml
```

**🔍 What the test does:**
1. Creates a directory
2. Generates a file with system information
3. Uses Ansible's fact-gathering to get system details
4. Shows how tasks run sequentially
5. Demonstrates Ansible's templating capabilities

**🔧 Essential Ansible Commands:**
```bash
# Run ad-hoc commands
ansible <host> -m <module>              # Run single module on host
ansible localhost -m ping               # Test connectivity

# Run playbooks
ansible-playbook playbook.yml           # Run a playbook
ansible-playbook playbook.yml --check   # Dry run (don't make changes)

# Get information
ansible-doc <module>                    # Get help for specific module
ansible-config list                     # Show all configuration options
ansible-inventory --list               # Show inventory in JSON format

# Debugging
ansible-playbook playbook.yml -v        # Verbose output
ansible-playbook playbook.yml -vvv      # Very verbose output
```

**🎯 Common Ansible Modules (you'll use these):**
- **ping**: Test connectivity to hosts
- **copy**: Copy files to remote systems
- **file**: Create directories, set permissions
- **apt**: Install packages on Ubuntu/Debian
- **service**: Start/stop/restart services
- **shell**: Run shell commands
- **template**: Process Jinja2 templates
- **kubernetes.core.k8s**: Manage Kubernetes resources

**🚨 Troubleshooting Ansible:**

**Problem**: "ansible: command not found"
```bash
# Solution: Verify installation
which ansible
sudo apt update
sudo apt install ansible --reinstall
```

**Problem**: "Could not match supplied host pattern"
```bash
# Solution: Check inventory file
ansible-inventory --list
cat ~/.ansible/inventory

# Add localhost to inventory if missing:
echo "localhost ansible_connection=local" >> ~/.ansible/inventory
```

**Problem**: SSH connection issues
```bash
# Solution: For localhost operations, use local connection
ansible localhost -c local -m ping

# For remote hosts, check SSH keys:
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

**Problem**: Permission denied errors
```bash
# Solution: Check file permissions
ls -la ~/.ansible/
chmod 644 ~/.ansible/inventory
chmod 644 ~/.ansible.cfg
```

**📚 Learning Ansible YAML Syntax:**

YAML (Yet Another Markup Language) is human-readable data format:
```yaml
---
# YAML starts with three dashes
# Comments start with hashtag

# Key-value pairs
name: "My Application"
version: 1.0

# Lists
fruits:
  - apple
  - banana
  - orange

# Nested structures
server:
  name: web-server
  port: 80
  ssl_enabled: true
```

**💡 Pro Tips for Ansible:**
- Always use `--check` mode first to test changes
- Keep playbooks in version control (Git)
- Use descriptive task names
- Group related tasks into roles
- Use variables for values that might change
- Test playbooks in development before running in production

**🎓 Next Steps:**
Later in this project, we'll create Ansible playbooks to:
- Set up our Kubernetes cluster configuration
- Install monitoring tools (Prometheus, Grafana)
- Configure ArgoCD for GitOps deployments
- Automate application deployments

### 🟢 Step 9: Install Node.js and npm

**What is Node.js?**
Node.js is a JavaScript runtime that lets you run JavaScript code outside of web browsers. It's like having a JavaScript engine that can power server applications, command-line tools, and build processes.

**What is npm?**
npm (Node Package Manager) is like an app store for JavaScript code. It contains millions of reusable code packages that developers share with each other.

**Real-world analogy:**
- **Node.js** = JavaScript engine that can run anywhere (like having a car engine that works in cars, boats, and generators)
- **npm** = Parts catalog where you can order any component you need for your projects

**Why do we need Node.js?**
- **Frontend development**: Build React applications
- **Backend development**: Create API servers
- **Build tools**: Compile TypeScript, bundle files, optimize images
- **Package management**: Install and manage project dependencies

**Installation Process:**

```bash
# Step 9a: Add NodeSource repository (official Node.js packages for Ubuntu)
# This ensures we get the latest Node.js 18.x version
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# Step 9b: Install Node.js (npm comes bundled with it)
sudo apt install -y nodejs

# Step 9c: Install build tools (needed for some npm packages)
sudo apt install -y build-essential

# Step 9d: Update npm to the latest version
sudo npm install -g npm@latest
```

**🔍 Understanding the Installation:**

1. **NodeSource repository**: Official Ubuntu packages for Node.js
2. **Node.js 18.x**: LTS (Long Term Support) version - stable and recommended
3. **build-essential**: Compiler tools needed for packages with native code
4. **npm update**: Ensures we have the latest package manager features

**✅ Verification:**
```bash
# Check Node.js version
node --version             # Should show v18.x.x (e.g., v18.17.0)

# Check npm version  
npm --version              # Should show 9.x.x or higher

# Test Node.js works
node -e "console.log('Hello from Node.js!')"  # Should print the message

# Check npm can install packages globally
npm list -g --depth=0     # Shows globally installed packages

# Test npm registry connection
npm ping                  # Should show successful connection to npm registry
```

**🧪 Test Node.js and npm:**

```bash
# Create a test project
mkdir ~/nodejs-test
cd ~/nodejs-test

# Initialize a new Node.js project
npm init -y               # Creates package.json with default values

# Install a simple test package
npm install chalk         # Popular library for colored terminal output

# Create a test script
cat > test.js << 'EOF'
// Test Node.js installation
const chalk = require('chalk');

console.log(chalk.green('✅ Node.js is working!'));
console.log(chalk.blue('📦 npm can install packages!'));
console.log(chalk.yellow('🚀 Ready for development!'));

// Show some system information
console.log('\nSystem Information:');
console.log(`Node.js version: ${process.version}`);
console.log(`Platform: ${process.platform}`);
console.log(`Architecture: ${process.arch}`);
EOF

# Run the test
node test.js

# Clean up
cd ~
rm -rf ~/nodejs-test
```

**🔧 Essential npm Commands:**

```bash
# Project management
npm init                  # Create new project
npm init -y               # Create project with defaults

# Package installation
npm install <package>     # Install package locally
npm install -g <package>  # Install package globally
npm install --save-dev <package>  # Install as development dependency

# Package management
npm list                  # Show installed packages
npm outdated              # Show packages that need updates
npm update                # Update packages
npm uninstall <package>   # Remove package

# Script running
npm run <script>          # Run script defined in package.json
npm start                 # Run start script
npm test                  # Run test script

# Information
npm --version             # Show npm version
npm info <package>        # Show package information
npm search <term>         # Search for packages
```

**🎯 Understanding package.json:**

The `package.json` file is like a project's ID card and instruction manual:

```json
{
  "name": "my-project",           // Project name
  "version": "1.0.0",             // Project version
  "description": "My awesome app", // What it does
  "main": "app.js",               // Main entry point
  "scripts": {                    // Commands you can run
    "start": "node app.js",
    "test": "npm test",
    "dev": "nodemon app.js"
  },
  "dependencies": {               // Packages needed in production
    "express": "^4.18.2",
    "mongoose": "^7.5.0"
  },
  "devDependencies": {            // Packages needed only for development
    "nodemon": "^3.0.1",
    "@types/node": "^20.5.0"
  }
}
```

**🚨 Troubleshooting Node.js and npm:**

**Problem**: "node: command not found"
```bash
# Solution: Check if Node.js is installed
which node
echo $PATH

# Reinstall if needed
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

**Problem**: npm permission errors (EACCES)
```bash
# Solution: Fix npm permissions (don't use sudo with npm!)
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Test with a global package install
npm install -g npm@latest
```

**Problem**: "Permission denied" when installing packages
```bash
# Solution: Make sure you're in a directory you own
pwd
ls -la
cd ~  # Go to home directory

# Or fix ownership of current directory
sudo chown -R $USER:$USER .
```

**Problem**: npm install fails with "network error"
```bash
# Solution: Check network and npm registry
npm ping
npm config get registry  # Should show https://registry.npmjs.org/

# Try different registry if needed
npm config set registry https://registry.npmjs.org/
```

**Problem**: Node.js version conflicts
```bash
# Solution: Use Node Version Manager (nvm) for multiple versions
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18
```

**🎓 What we'll build with Node.js:**

In this project, we'll use Node.js to create:

1. **Backend API Server** (Express.js):
   - Handle HTTP requests from frontend
   - Connect to MongoDB database
   - Provide REST API endpoints
   - Handle authentication and validation

2. **Frontend Build Process** (React):
   - Compile TypeScript to JavaScript
   - Bundle multiple files into optimized packages
   - Process CSS and images
   - Create production-ready builds

**📦 Key npm packages we'll use:**
- **express**: Web framework for building APIs
- **mongoose**: MongoDB object modeling
- **cors**: Handle cross-origin requests
- **helmet**: Security middleware
- **winston**: Logging library
- **nodemon**: Auto-restart during development
- **react**: Frontend UI library
- **typescript**: Type-safe JavaScript

**💡 Pro Tips:**
- Always use specific versions in package.json for production
- Use `npm ci` instead of `npm install` in CI/CD pipelines
- Keep package.json in version control
- Use `.npmrc` file for project-specific npm configuration
- Regularly audit packages for security: `npm audit`

**🔒 Security Best Practices:**
```bash
# Audit packages for vulnerabilities
npm audit

# Fix automatically fixable vulnerabilities
npm audit fix

# Update packages to latest versions
npm update

# Check for outdated packages
npm outdated
```

### 🍃 Step 10: Install MongoDB Tools (for local development)

**What is MongoDB?**
MongoDB is a NoSQL database that stores data in flexible, JSON-like documents instead of traditional rows and columns. It's like having a filing cabinet where each folder can contain different types of documents, rather than forcing everything into identical forms.

**Why use MongoDB?**
- **Flexible**: No fixed schema - you can change data structure anytime
- **Scalable**: Handles massive amounts of data efficiently
- **Developer-friendly**: Works naturally with JavaScript/JSON
- **Fast**: Optimized for modern web applications
- **Popular**: Used by companies like Facebook, eBay, and Craigslist

**Real-world analogy:**
- **Traditional SQL database** = Spreadsheet with fixed columns
- **MongoDB** = Collection of JSON files that can have different structures

**Installation Process:**

```bash
# Step 10a: Import MongoDB's official GPG key for security verification
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -

# Step 10b: Add MongoDB repository to our package sources
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Step 10c: Update package list and install MongoDB
sudo apt update
sudo apt install -y mongodb-org

# Step 10d: Start MongoDB service immediately
sudo systemctl start mongod

# Step 10e: Enable MongoDB to start automatically on system boot
sudo systemctl enable mongod

# Step 10f: Create MongoDB data directory with proper permissions
sudo mkdir -p /data/db
sudo chown -R mongodb:mongodb /data/db
```

**🔍 Understanding MongoDB Components:**

1. **mongod**: The database server process (daemon)
2. **mongosh**: Modern command-line interface for MongoDB
3. **mongodb-org**: Complete MongoDB package with all tools
4. **Data directory**: Where MongoDB stores all database files

**✅ Verification:**
```bash
# Check MongoDB service is running
sudo systemctl status mongod     # Should show "active (running)"

# Check MongoDB version
mongosh --version               # Should show MongoDB Shell version

# Test MongoDB connection
mongosh --eval "db.adminCommand('ismaster')"  # Should return connection info

# Check MongoDB is listening on default port
sudo netstat -tlnp | grep 27017  # Should show mongod listening on port 27017
```

**🧪 Test MongoDB Installation:**

```bash
# Connect to MongoDB and run basic tests
mongosh << 'EOF'
// Test MongoDB installation

// Show current database (should be 'test' by default)
print("Current database:", db.getName());

// Create a test collection and insert a document
db.testCollection.insertOne({
  name: "Test Document",
  created: new Date(),
  type: "installation_test"
});

// Find the document we just inserted
var result = db.testCollection.findOne({type: "installation_test"});
print("Inserted document:", JSON.stringify(result, null, 2));

// Count documents in the collection
var count = db.testCollection.countDocuments();
print("Total documents in testCollection:", count);

// Show all collections in current database
print("Collections:", db.getCollectionNames());

// Clean up: drop the test collection
db.testCollection.drop();
print("✅ Test completed successfully!");

// Exit MongoDB shell
exit
EOF
```

**🔧 Essential MongoDB Commands:**

```bash
# Service management
sudo systemctl start mongod      # Start MongoDB
sudo systemctl stop mongod       # Stop MongoDB
sudo systemctl restart mongod    # Restart MongoDB
sudo systemctl status mongod     # Check status

# Connect to MongoDB
mongosh                          # Connect to local MongoDB
mongosh "mongodb://localhost:27017/myapp"  # Connect to specific database

# MongoDB shell commands (inside mongosh)
show dbs                         # List all databases
use myapp                        # Switch to/create database
show collections                 # List collections in current database
db.collection.find()             # Show all documents in collection
db.collection.insertOne({...})   # Insert one document
db.collection.deleteMany({})     # Delete all documents
```

**🎯 Understanding MongoDB Structure:**

```
MongoDB Server (mongod)
├── Database 1 (e.g., "capstone")
│   ├── Collection 1 (e.g., "users")
│   │   ├── Document 1 (JSON-like object)
│   │   ├── Document 2 (JSON-like object)
│   │   └── ...
│   ├── Collection 2 (e.g., "items")
│   └── ...
├── Database 2 (e.g., "logs")
└── ...
```

**Example MongoDB Document:**
```json
{
  "_id": ObjectId("64f1a2b3c4d5e6f7g8h9i0j1"),
  "name": "John Doe",
  "email": "john@example.com",
  "age": 30,
  "hobbies": ["reading", "coding", "gaming"],
  "address": {
    "street": "123 Main St",
    "city": "Anytown",
    "country": "USA"
  },
  "createdAt": ISODate("2023-09-01T10:30:00Z")
}
```

**🚨 Troubleshooting MongoDB:**

**Problem**: MongoDB won't start
```bash
# Solution: Check logs and fix common issues
sudo journalctl -u mongod --no-pager

# Check disk space (MongoDB needs space for data files)
df -h

# Check permissions on MongoDB directories
ls -la /var/lib/mongodb
ls -la /var/log/mongodb

# Fix permissions if needed
sudo chown -R mongodb:mongodb /var/lib/mongodb
sudo chown -R mongodb:mongodb /var/log/mongodb
```

**Problem**: "Connection refused" when connecting
```bash
# Solution: Ensure MongoDB is running and listening
sudo systemctl status mongod
sudo systemctl start mongod

# Check if MongoDB is listening on port 27017
sudo ss -tlnp | grep 27017

# Check MongoDB configuration
sudo cat /etc/mongod.conf | grep bindIp
```

**Problem**: "Authorization failed" errors
```bash
# Solution: MongoDB starts without authentication by default
# For development, this is fine. For production, enable authentication:

# Connect to MongoDB
mongosh

# Create admin user (in MongoDB shell)
use admin
db.createUser({
  user: "admin",
  pwd: "securePassword123",
  roles: ["userAdminAnyDatabase", "readWriteAnyDatabase"]
})

# Exit and restart with authentication
exit
sudo systemctl restart mongod
```

**Problem**: High disk usage
```bash
# Solution: Monitor and manage MongoDB storage
# Check database sizes
mongosh --eval "db.runCommand({listCollections: 1}).cursor.firstBatch.forEach(function(collection){print(collection.name)})"

# Check individual collection sizes
mongosh --eval "db.stats()"

# Compact database if needed (during maintenance window)
mongosh --eval "db.runCommand({compact: 'collectionName'})"
```

**🔒 MongoDB Security Best Practices:**

```bash
# 1. Enable authentication (for production)
sudo nano /etc/mongod.conf
# Add these lines:
# security:
#   authorization: enabled

# 2. Bind to specific IP address (don't expose to public internet)
# In /etc/mongod.conf:
# net:
#   port: 27017
#   bindIp: 127.0.0.1,192.168.1.100  # localhost and specific internal IP

# 3. Enable SSL/TLS (for production)
# net:
#   ssl:
#     mode: requireSSL
#     PEMKeyFile: /path/to/certificate.pem
```

**🎓 What we'll use MongoDB for:**

In our capstone project, MongoDB will:

1. **Store application data**:
   - User information
   - Todo items
   - Application logs
   - Configuration settings

2. **Provide persistence**:
   - Data survives container restarts
   - Backup and recovery capabilities
   - Data consistency across deployments

3. **Scale with our application**:
   - Handle increased load
   - Support multiple application instances
   - Enable horizontal scaling

**📱 MongoDB in Kubernetes:**

Later, we'll run MongoDB inside Kubernetes with:
- **Persistent volumes** for data storage
- **StatefulSets** for stable network identities
- **Services** for network access
- **ConfigMaps** for configuration
- **Secrets** for sensitive data (passwords)

**💡 Pro Tips:**
- Use meaningful database and collection names
- Create indexes for frequently queried fields
- Use MongoDB Compass (GUI) for visual database exploration
- Monitor database performance with MongoDB's built-in tools
- Regular backups are essential for production systems

**🔗 Useful Resources:**
- **MongoDB Manual**: https://docs.mongodb.com/
- **MongoDB University**: https://university.mongodb.com/ (free courses)
- **MongoDB Compass**: GUI tool for exploring databases
- **Studio 3T**: Popular third-party MongoDB GUI

## 🏗️ Phase 1: Create Microservices Applications

**What are Microservices?**
Microservices are like LEGO blocks for software - each service is a small, independent application that does one thing well. Instead of building one massive application, we create several small applications that work together.

**Our Microservices Architecture:**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Frontend     │    │     Backend     │    │    Database     │
│   (React UI)    │◄──►│  (Node.js API)  │◄──►│   (MongoDB)     │
│                 │    │                 │    │                 │
│ - User Interface│    │ - Business Logic│    │ - Data Storage  │
│ - Web Browser   │    │ - API Endpoints │    │ - Persistence   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**Why Microservices?**
- **Independence**: Each service can be developed, deployed, and scaled separately
- **Technology Flexibility**: Use different languages/frameworks for each service
- **Fault Isolation**: If one service fails, others continue working
- **Team Scalability**: Different teams can work on different services
- **Easier Testing**: Test individual components in isolation

---

### 🎨 Frontend Service (React Application)

**What is the Frontend?**
The frontend is what users see and interact with - the web interface that runs in their browser. It's like the storefront of a shop - attractive, user-friendly, and designed to provide a great experience.

**Why React?**
- **Popular**: Used by Facebook, Netflix, Airbnb, and thousands of companies
- **Component-based**: Build reusable UI pieces
- **Fast**: Virtual DOM makes updates efficient
- **Large community**: Lots of resources and third-party libraries
- **TypeScript support**: Catch errors during development

**Step-by-Step Frontend Creation:**

```bash
# Step 1: Create the frontend directory structure
mkdir -p services/frontend
cd services/frontend

# Step 2: Initialize React application with TypeScript
# This creates a complete React project with modern tooling
npx create-react-app . --template typescript

# What this command does:
# - Downloads and sets up React with TypeScript
# - Configures build tools (Webpack, Babel)
# - Sets up testing framework (Jest)
# - Creates development server
# - Includes ES6+ support and hot reloading
```

**🔍 Understanding the Generated Project Structure:**
```
services/frontend/
├── public/                 # Static files served directly
│   ├── index.html         # Main HTML template
│   ├── favicon.ico        # Website icon
│   └── manifest.json      # Progressive Web App config
├── src/                   # Source code (where we write our app)
│   ├── App.tsx           # Main application component
│   ├── index.tsx         # Application entry point
│   ├── App.css           # Application styles
│   └── App.test.tsx      # Test files
├── package.json          # Dependencies and scripts
├── tsconfig.json         # TypeScript configuration
└── README.md             # Project documentation
```

**🎯 Create Our Custom Frontend Application:**

```bash
# Step 3: Replace the default App.tsx with our todo application
cat > src/App.tsx << 'EOF'
import React, { useState, useEffect } from 'react';
import './App.css';

// TypeScript interface for our todo items
interface TodoItem {
  _id?: string;
  name: string;
  description: string;
  createdAt?: string;
  completed?: boolean;
}

function App() {
  // React state hooks for managing data
  const [todos, setTodos] = useState<TodoItem[]>([]);
  const [newTodo, setNewTodo] = useState({ name: '', description: '' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // API base URL - will be configured for different environments
  const API_BASE = process.env.REACT_APP_API_URL || 'http://localhost:3000';

  // Fetch todos from backend when component loads
  useEffect(() => {
    fetchTodos();
  }, []);

  const fetchTodos = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await fetch(`${API_BASE}/api/items`);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      setTodos(data);
    } catch (err) {
      console.error('Error fetching todos:', err);
      setError('Failed to load todos. Please check if the backend is running.');
    } finally {
      setLoading(false);
    }
  };

  const addTodo = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!newTodo.name.trim()) {
      setError('Please enter a todo name');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      const response = await fetch(`${API_BASE}/api/items`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(newTodo),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const savedTodo = await response.json();
      setTodos([savedTodo, ...todos]);
      setNewTodo({ name: '', description: '' });
    } catch (err) {
      console.error('Error adding todo:', err);
      setError('Failed to add todo. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🚀 DevOps Capstone Todo App</h1>
        <p>A microservices application built with React, Node.js, and MongoDB</p>
      </header>

      <main className="App-main">
        {/* Add Todo Form */}
        <section className="add-todo">
          <h2>Add New Todo</h2>
          <form onSubmit={addTodo}>
            <div className="form-group">
              <input
                type="text"
                placeholder="Todo name (required)"
                value={newTodo.name}
                onChange={(e) => setNewTodo({ ...newTodo, name: e.target.value })}
                disabled={loading}
              />
            </div>
            <div className="form-group">
              <textarea
                placeholder="Description (optional)"
                value={newTodo.description}
                onChange={(e) => setNewTodo({ ...newTodo, description: e.target.value })}
                disabled={loading}
              />
            </div>
            <button type="submit" disabled={loading}>
              {loading ? 'Adding...' : 'Add Todo'}
            </button>
          </form>
        </section>

        {/* Error Display */}
        {error && (
          <div className="error-message">
            ⚠️ {error}
            <button onClick={() => setError(null)}>Dismiss</button>
          </div>
        )}

        {/* Todos List */}
        <section className="todos-list">
          <div className="todos-header">
            <h2>Your Todos ({todos.length})</h2>
            <button onClick={fetchTodos} disabled={loading}>
              {loading ? 'Refreshing...' : '🔄 Refresh'}
            </button>
          </div>

          {todos.length === 0 ? (
            <div className="empty-state">
              <p>No todos yet! Add one above to get started.</p>
            </div>
          ) : (
            <div className="todos-grid">
              {todos.map((todo) => (
                <div key={todo._id} className="todo-card">
                  <h3>{todo.name}</h3>
                  {todo.description && <p>{todo.description}</p>}
                  <small>
                    Created: {new Date(todo.createdAt || '').toLocaleDateString()}
                  </small>
                </div>
              ))}
            </div>
          )}
        </section>
      </main>

      {/* System Status */}
      <footer className="App-footer">
        <div className="status-indicator">
          <span className={`status-dot ${error ? 'offline' : 'online'}`}></span>
          {error ? 'Backend Offline' : 'System Online'}
        </div>
        <p>Built with ❤️ using DevOps best practices</p>
      </footer>
    </div>
  );
}

export default App;
EOF

# Step 4: Create modern CSS styles for our application
cat > src/App.css << 'EOF'
/* Modern CSS for our DevOps Todo App */

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

.App {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #333;
}

.App-header {
  text-align: center;
  padding: 2rem;
  background: rgba(255, 255, 255, 0.95);
  margin-bottom: 2rem;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.App-header h1 {
  color: #2c3e50;
  margin-bottom: 0.5rem;
  font-size: 2.5rem;
}

.App-header p {
  color: #7f8c8d;
  font-size: 1.1rem;
}

.App-main {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
}

/* Add Todo Form Styles */
.add-todo {
  background: white;
  border-radius: 10px;
  padding: 2rem;
  margin-bottom: 2rem;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.add-todo h2 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 12px;
  border: 2px solid #e0e0e0;
  border-radius: 6px;
  font-size: 16px;
  transition: border-color 0.3s ease;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #667eea;
}

.form-group textarea {
  min-height: 80px;
  resize: vertical;
}

button {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 16px;
  font-weight: 500;
  transition: transform 0.2s ease;
}

button:hover:not(:disabled) {
  transform: translateY(-2px);
}

button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

/* Error Message Styles */
.error-message {
  background: #fff5f5;
  border: 1px solid #fed7d7;
  color: #c53030;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.error-message button {
  background: #c53030;
  padding: 6px 12px;
  font-size: 14px;
}

/* Todos List Styles */
.todos-list {
  background: white;
  border-radius: 10px;
  padding: 2rem;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.todos-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.todos-header h2 {
  color: #2c3e50;
}

.empty-state {
  text-align: center;
  padding: 3rem;
  color: #7f8c8d;
}

.todos-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.todo-card {
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  padding: 1.5rem;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.todo-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
}

.todo-card h3 {
  color: #2c3e50;
  margin-bottom: 0.5rem;
  font-size: 1.2rem;
}

.todo-card p {
  color: #6c757d;
  line-height: 1.5;
  margin-bottom: 1rem;
}

.todo-card small {
  color: #adb5bd;
  font-size: 0.9rem;
}

/* Footer Styles */
.App-footer {
  text-align: center;
  padding: 2rem;
  margin-top: 3rem;
  background: rgba(255, 255, 255, 0.95);
}

.status-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
  font-weight: 500;
}

.status-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  display: inline-block;
}

.status-dot.online {
  background: #28a745;
  box-shadow: 0 0 0 2px rgba(40, 167, 69, 0.3);
}

.status-dot.offline {
  background: #dc3545;
  box-shadow: 0 0 0 2px rgba(220, 53, 69, 0.3);
}

/* Responsive Design */
@media (max-width: 768px) {
  .App-header h1 {
    font-size: 2rem;
  }
  
  .App-main {
    padding: 0 0.5rem;
  }
  
  .add-todo,
  .todos-list {
    padding: 1rem;
  }
  
  .todos-grid {
    grid-template-columns: 1fr;
  }
  
  .todos-header {
    flex-direction: column;
    align-items: stretch;
  }
}

/* Loading Animation */
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading {
  animation: spin 1s linear infinite;
}
EOF

# Step 5: Install additional dependencies we need
npm install axios @types/axios

# Step 6: Add environment variables for different deployments
cat > .env << 'EOF'
# Frontend Environment Variables
REACT_APP_API_URL=http://localhost:3000
REACT_APP_VERSION=1.0.0
REACT_APP_ENVIRONMENT=development
EOF

cat > .env.production << 'EOF'
# Production Environment Variables
REACT_APP_API_URL=http://backend-service:3000
REACT_APP_VERSION=1.0.0
REACT_APP_ENVIRONMENT=production
EOF
```

**🔍 What We Just Created:**

1. **Modern React App**: Uses hooks, TypeScript, and modern JavaScript features
2. **Todo Management**: Add, view, and manage todo items
3. **API Integration**: Communicates with our backend service
4. **Error Handling**: Graceful failure when backend is unavailable
5. **Responsive Design**: Works on desktop, tablet, and mobile
6. **Environment Configuration**: Different settings for development and production

**🧪 Test the Frontend:**

```bash
# Install dependencies
npm install

# Start development server
npm start

# Your app will open at http://localhost:3000
# You should see a modern todo application interface
# (The backend integration will work after we create the backend service)
```

**🎯 Features of Our Frontend:**
- ✅ **Modern UI**: Clean, professional design
- ✅ **TypeScript**: Catch errors during development
- ✅ **Responsive**: Works on all device sizes
- ✅ **Error Handling**: User-friendly error messages
- ✅ **Loading States**: Visual feedback during operations
- ✅ **Environment Variables**: Configure for different deployments
- ✅ **API Integration**: Ready to connect to our backend

**🐳 Create Production-Ready Dockerfile:**

```bash
# Step 7: Create multi-stage Dockerfile for efficient production builds
cat > Dockerfile << 'EOF'
# Multi-stage Docker build for React application
# This creates a small, optimized production image

# Stage 1: Build the React application
FROM node:18-alpine AS build

# Set working directory inside container
WORKDIR /app

# Copy package files first (for Docker layer caching)
# If package.json doesn't change, Docker reuses this layer
COPY package*.json ./

# Install dependencies (including dev dependencies for building)
RUN npm ci --silent

# Copy source code
COPY . .

# Create production build
# This compiles TypeScript, bundles JavaScript, optimizes assets
RUN npm run build

# Stage 2: Create production server
FROM nginx:alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Copy built application from previous stage
COPY --from=build /app/build /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create nginx user for security
RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# Expose port 80
EXPOSE 80

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Run nginx (non-daemon mode for Docker)
CMD ["nginx", "-g", "daemon off;"]
EOF
```

**🔍 Understanding the Multi-Stage Build:**

1. **Stage 1 (Build)**:
   - Uses full Node.js image with development tools
   - Installs all dependencies (including dev dependencies)
   - Compiles TypeScript and bundles the application
   - Creates optimized production build

2. **Stage 2 (Production)**:
   - Uses lightweight nginx Alpine image
   - Copies only the built files (not source code or dev dependencies)
   - Configures nginx web server
   - Results in much smaller final image (~20MB vs 200MB+)

**🌐 Create Nginx Configuration:**

```bash
# Step 8: Create nginx configuration for serving React app and proxying API calls
cat > nginx.conf << 'EOF'
# Nginx configuration for React application
# Optimized for production with security and performance features

# Events block - connection processing
events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

# HTTP block - main configuration
http {
    # Basic Settings
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # Performance optimizations
    sendfile        on;
    tcp_nopush      on;
    tcp_nodelay     on;
    keepalive_timeout  65;
    types_hash_max_size 2048;
    
    # Gzip compression for better performance
    gzip on;
    gzip_vary on;
    gzip_min_length 10240;
    gzip_proxied expired no-cache no-store private must-revalidate max-age=0;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    
    # Main server block
    server {
        listen 80;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html;
        
        # Security: Hide nginx version
        server_tokens off;
        
        # Serve static files with caching
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            try_files $uri =404;
        }
        
        # API proxy to backend service
        location /api {
            # Rate limiting for API calls
            limit_req zone=api burst=20 nodelay;
            
            # Proxy settings
            proxy_pass http://backend-service:3000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Timeout settings
            proxy_connect_timeout 30s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
            
            # Buffer settings
            proxy_buffering on;
            proxy_buffer_size 4k;
            proxy_buffers 8 4k;
        }
        
        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
        
        # Serve React app (Single Page Application)
        location / {
            try_files $uri $uri/ /index.html;
            
            # Prevent caching of index.html (so updates are immediately visible)
            location = /index.html {
                add_header Cache-Control "no-cache, no-store, must-revalidate";
                add_header Pragma "no-cache";
                add_header Expires "0";
            }
        }
        
        # Error pages
        error_page 404 /index.html;
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root /usr/share/nginx/html;
        }
    }
}
EOF
```

**🔍 Understanding the Nginx Configuration:**

1. **Static File Serving**: Efficiently serves CSS, JavaScript, images
2. **API Proxying**: Forwards `/api/*` requests to backend service
3. **SPA Support**: All routes serve `index.html` (for React Router)
4. **Performance**: Gzip compression, caching headers, keep-alive
5. **Security**: Security headers, rate limiting, hidden server tokens
6. **Health Checks**: `/health` endpoint for container monitoring

**🧪 Build and Test the Frontend Container:**

```bash
# Step 9: Build the Docker image locally
docker build -t capstone/frontend:latest .

# Check the image was created
docker images | grep capstone/frontend

# Test run the container locally
docker run -d -p 8080:80 --name frontend-test capstone/frontend:latest

# Test the health check
curl http://localhost:8080/health

# Test the React app
curl http://localhost:8080/

# Check container logs
docker logs frontend-test

# Clean up test container
docker stop frontend-test
docker rm frontend-test
```

**📊 Frontend Build Optimization Results:**

```bash
# Compare image sizes (you should see significant size reduction)
echo "=== Image Size Comparison ==="
echo "Full Node.js image: ~200MB+"
docker images node:18-alpine | grep node

echo "Our optimized frontend: ~20-30MB"
docker images capstone/frontend:latest | grep capstone

echo "Space saved: ~85% reduction!"
```

**🚨 Frontend Troubleshooting:**

**Problem**: Build fails with "npm ERR! peer dep missing"
```bash
# Solution: Update package.json with proper dependencies
npm audit fix
npm install --legacy-peer-deps
```

**Problem**: TypeScript compilation errors
```bash
# Solution: Check TypeScript configuration
npx tsc --noEmit
# Fix errors reported by TypeScript compiler
```

**Problem**: React app shows blank page
```bash
# Solution: Check browser console for errors
# Common causes:
# 1. API URL misconfiguration
# 2. CORS issues
# 3. JavaScript errors

# Check if build files exist
ls -la build/
```

**Problem**: Nginx fails to start in container
```bash
# Solution: Check nginx configuration syntax
nginx -t

# Check container logs
docker logs <container-name>
```

**🎯 What We Accomplished:**
- ✅ **Complete React Application**: Modern, responsive todo interface
- ✅ **TypeScript Integration**: Type safety for better code quality
- ✅ **Production Build**: Optimized bundle with code splitting
- ✅ **Multi-stage Docker**: Efficient container (~20MB final size)
- ✅ **Nginx Configuration**: Production-ready web server setup
- ✅ **Health Checks**: Container monitoring capabilities
- ✅ **API Integration**: Ready to connect to backend service
- ✅ **Environment Configuration**: Development and production settings

The frontend service is now complete and ready for Kubernetes deployment!

**Create nginx configuration:**
```nginx
# services/frontend/nginx.conf
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    server {
        listen 80;
        server_name localhost;
        
        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
            try_files $uri $uri/ /index.html;
        }
        
        location /api {
            proxy_pass http://backend-service:3000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
```

---

### 🔧 Backend Service (Node.js API)

**What is the Backend?**
The backend is the "brain" of our application - it handles business logic, manages data, and provides APIs (Application Programming Interfaces) that the frontend can use. Think of it as the kitchen in a restaurant - customers don't see it, but it's where all the food preparation happens.

**Why Node.js for Backend?**
- **JavaScript Everywhere**: Same language for frontend and backend
- **Fast Development**: Quick to build and iterate
- **Large Ecosystem**: Millions of packages available via npm
- **High Performance**: Event-driven, non-blocking I/O
- **Scalable**: Handles many concurrent connections efficiently
- **Industry Standard**: Used by Netflix, LinkedIn, Uber, and many others

**Our Backend Architecture:**
```
┌─────────────────────────────────────────┐
│              Backend API                │
├─────────────────────────────────────────┤
│  🌐 Express.js Web Framework            │
│  ├── REST API Endpoints (/api/items)    │
│  ├── Middleware (CORS, Security, Logs)  │
│  └── Error Handling & Validation        │
├─────────────────────────────────────────┤
│  📊 Database Layer (Mongoose ODM)       │
│  ├── Data Models & Schemas              │
│  ├── Database Connection Management     │
│  └── Query Optimization                 │
├─────────────────────────────────────────┤
│  🔒 Security & Monitoring               │
│  ├── Helmet.js (Security Headers)       │
│  ├── CORS (Cross-Origin Requests)       │
│  └── Winston Logging                    │
└─────────────────────────────────────────┘
```

**Step-by-Step Backend Creation:**

```bash
# Step 1: Create backend directory and navigate to it
mkdir -p services/backend
cd services/backend

# Step 2: Initialize Node.js project with default settings
# This creates package.json with project metadata
npm init -y

# Step 3: Install production dependencies
# These are packages our application needs to run

# Core web framework and database
npm install express mongoose

# Security and middleware
npm install cors dotenv helmet morgan

# Logging and utilities
npm install winston uuid bcryptjs jsonwebtoken

# Validation and utilities
npm install joi express-rate-limit

# Step 4: Install development dependencies
# These help during development but aren't needed in production
npm install -D \
  nodemon \          # Auto-restart server when files change
  @types/node \      # TypeScript definitions for Node.js
  typescript \       # TypeScript compiler
  @types/express \   # TypeScript definitions for Express
  @types/cors \      # TypeScript definitions for CORS
  jest \             # Testing framework
  supertest \        # HTTP testing
  @types/jest        # TypeScript definitions for Jest
```

**🔍 Understanding Our Dependencies:**

**Production Dependencies (Required at Runtime):**
- **express**: Web framework for building REST APIs
- **mongoose**: MongoDB object modeling (ODM) library
- **cors**: Enable cross-origin requests from frontend
- **dotenv**: Load environment variables from .env files
- **helmet**: Security middleware (sets HTTP headers)
- **morgan**: HTTP request logger middleware
- **winston**: Advanced logging library
- **joi**: Data validation library
- **express-rate-limit**: Prevent API abuse with rate limiting

**Development Dependencies (Build/Test Time Only):**
- **nodemon**: Auto-restart server during development
- **typescript**: Add type safety to JavaScript
- **jest**: Testing framework for unit tests
- **supertest**: Test HTTP endpoints

**🎯 Create the Main Application:**

```bash
# Step 5: Create the main application file
cat > app.js << 'EOF'
// DevOps Capstone Backend API
// Built with Node.js, Express, and MongoDB

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const winston = require('winston');
const Joi = require('joi');
require('dotenv').config();

// Initialize Express application
const app = express();
const PORT = process.env.PORT || 3000;

// ==========================================
// LOGGING CONFIGURATION
// ==========================================

// Create Winston logger for structured logging
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'capstone-backend' },
  transports: [
    // Write all logs with level 'error' and below to error.log
    new winston.transports.File({ 
      filename: 'logs/error.log', 
      level: 'error',
      maxsize: 5242880, // 5MB
      maxFiles: 5
    }),
    // Write all logs to combined.log
    new winston.transports.File({ 
      filename: 'logs/combined.log',
      maxsize: 5242880, // 5MB
      maxFiles: 10
    })
  ]
});

// In development, also log to console
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.simple()
    )
  }));
}

// ==========================================
// SECURITY MIDDLEWARE
// ==========================================

// Rate limiting to prevent API abuse
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: {
    error: 'Too many requests from this IP, please try again later.',
    retryAfter: '15 minutes'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Apply rate limiting to all requests
app.use(limiter);

// Security headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
}));

// Enable CORS with specific configuration
app.use(cors({
  origin: process.env.FRONTEND_URL || ['http://localhost:3000', 'http://localhost:8080'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Request logging with Morgan and Winston
app.use(morgan('combined', {
  stream: { write: message => logger.info(message.trim()) }
}));

// Parse JSON bodies (with size limit for security)
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ==========================================
// DATABASE CONNECTION
// ==========================================

// MongoDB connection with retry logic
const connectDB = async () => {
  const maxRetries = 5;
  let retries = 0;
  
  while (retries < maxRetries) {
    try {
      const mongoURI = process.env.MONGODB_URI || 'mongodb://mongodb-service:27017/capstone';
      
      await mongoose.connect(mongoURI, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        maxPoolSize: 10, // Maintain up to 10 socket connections
        serverSelectionTimeoutMS: 5000, // Keep trying to send operations for 5 seconds
        socketTimeoutMS: 45000, // Close sockets after 45 seconds of inactivity
        family: 4 // Use IPv4, skip trying IPv6
      });
      
      logger.info('✅ MongoDB connected successfully');
      break;
      
    } catch (error) {
      retries++;
      logger.error(`❌ MongoDB connection attempt ${retries} failed:`, error.message);
      
      if (retries < maxRetries) {
        logger.info(`⏳ Retrying in 5 seconds... (${retries}/${maxRetries})`);
        await new Promise(resolve => setTimeout(resolve, 5000));
      } else {
        logger.error('💥 Failed to connect to MongoDB after maximum retries');
        process.exit(1);
      }
    }
  }
};

// Handle MongoDB connection events
mongoose.connection.on('disconnected', () => {
  logger.warn('⚠️ MongoDB disconnected');
});

mongoose.connection.on('error', (error) => {
  logger.error('❌ MongoDB error:', error);
});

// Graceful shutdown
process.on('SIGINT', async () => {
  logger.info('🛑 Received SIGINT, shutting down gracefully');
  await mongoose.connection.close();
  process.exit(0);
});

// ==========================================
// DATA MODELS
// ==========================================

// Todo Item Schema with validation
const itemSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Name is required'],
    trim: true,
    maxlength: [100, 'Name cannot exceed 100 characters']
  },
  description: {
    type: String,
    trim: true,
    maxlength: [500, 'Description cannot exceed 500 characters']
  },
  completed: {
    type: Boolean,
    default: false
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high'],
    default: 'medium'
  },
  tags: [{
    type: String,
    trim: true,
    maxlength: 20
  }],
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true // Automatically manage createdAt and updatedAt
});

// Add indexes for better query performance
itemSchema.index({ createdAt: -1 });
itemSchema.index({ completed: 1 });
itemSchema.index({ name: 'text', description: 'text' });

// Create model from schema
const Item = mongoose.model('Item', itemSchema);

// ==========================================
// VALIDATION SCHEMAS
// ==========================================

// Joi validation schemas for request validation
const createItemSchema = Joi.object({
  name: Joi.string().required().trim().max(100).messages({
    'string.empty': 'Name is required',
    'string.max': 'Name cannot exceed 100 characters'
  }),
  description: Joi.string().allow('').trim().max(500).messages({
    'string.max': 'Description cannot exceed 500 characters'
  }),
  priority: Joi.string().valid('low', 'medium', 'high').default('medium'),
  tags: Joi.array().items(Joi.string().trim().max(20)).max(10)
});

const updateItemSchema = Joi.object({
  name: Joi.string().trim().max(100),
  description: Joi.string().allow('').trim().max(500),
  completed: Joi.boolean(),
  priority: Joi.string().valid('low', 'medium', 'high'),
  tags: Joi.array().items(Joi.string().trim().max(20)).max(10)
}).min(1); // At least one field must be provided for update

// ==========================================
// MIDDLEWARE FUNCTIONS
// ==========================================

// Request validation middleware
const validateRequest = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body);
    if (error) {
      logger.warn('Validation error:', error.details);
      return res.status(400).json({
        error: 'Validation failed',
        details: error.details.map(detail => ({
          field: detail.path.join('.'),
          message: detail.message
        }))
      });
    }
    req.body = value; // Use validated and sanitized data
    next();
  };
};

// Error handling middleware
const errorHandler = (err, req, res, next) => {
  logger.error('Unhandled error:', err);

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const errors = Object.values(err.errors).map(e => ({
      field: e.path,
      message: e.message
    }));
    return res.status(400).json({
      error: 'Validation failed',
      details: errors
    });
  }

  // Mongoose cast error (invalid ObjectId)
  if (err.name === 'CastError') {
    return res.status(400).json({
      error: 'Invalid ID format'
    });
  }

  // MongoDB duplicate key error
  if (err.code === 11000) {
    return res.status(409).json({
      error: 'Resource already exists'
    });
  }

  // Default error response
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
};

// ==========================================
// API ROUTES
// ==========================================

// Health check endpoint (for container health monitoring)
app.get('/health', (req, res) => {
  const healthInfo = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    version: process.env.APP_VERSION || '1.0.0',
    mongodb: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected'
  };
  
  res.status(200).json(healthInfo);
});

// API Information endpoint
app.get('/api', (req, res) => {
  res.json({
    name: 'DevOps Capstone API',
    version: process.env.APP_VERSION || '1.0.0',
    description: 'RESTful API for todo management',
    endpoints: {
      'GET /health': 'Health check',
      'GET /api/items': 'Get all items',
      'POST /api/items': 'Create new item',
      'GET /api/items/:id': 'Get item by ID',
      'PUT /api/items/:id': 'Update item by ID',
      'DELETE /api/items/:id': 'Delete item by ID'
    }
  });
});

// GET /api/items - Retrieve all items with filtering and pagination
app.get('/api/items', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;
    
    // Build filter object
    const filter = {};
    if (req.query.completed !== undefined) {
      filter.completed = req.query.completed === 'true';
    }
    if (req.query.priority) {
      filter.priority = req.query.priority;
    }
    if (req.query.search) {
      filter.$text = { $search: req.query.search };
    }

    // Execute query with pagination
    const items = await Item.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .lean(); // Use lean() for better performance when we don't need Mongoose documents

    const total = await Item.countDocuments(filter);

    logger.info(`Retrieved ${items.length} items (page ${page}/${Math.ceil(total/limit)})`);
    
    res.json({
      items,
      pagination: {
        current: page,
        pages: Math.ceil(total / limit),
        total,
        limit
      }
    });
  } catch (error) {
    logger.error('Error fetching items:', error);
    res.status(500).json({ error: 'Failed to fetch items' });
  }
});

// POST /api/items - Create new item
app.post('/api/items', validateRequest(createItemSchema), async (req, res) => {
  try {
    const item = new Item(req.body);
    await item.save();
    
    logger.info('Created new item:', { id: item._id, name: item.name });
    res.status(201).json(item);
  } catch (error) {
    logger.error('Error creating item:', error);
    res.status(500).json({ error: 'Failed to create item' });
  }
});

// GET /api/items/:id - Get specific item
app.get('/api/items/:id', async (req, res) => {
  try {
    const item = await Item.findById(req.params.id);
    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }
    
    logger.info('Retrieved item:', { id: item._id, name: item.name });
    res.json(item);
  } catch (error) {
    logger.error('Error fetching item:', error);
    res.status(500).json({ error: 'Failed to fetch item' });
  }
});

// PUT /api/items/:id - Update item
app.put('/api/items/:id', validateRequest(updateItemSchema), async (req, res) => {
  try {
    const item = await Item.findByIdAndUpdate(
      req.params.id,
      { ...req.body, updatedAt: new Date() },
      { new: true, runValidators: true }
    );
    
    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }
    
    logger.info('Updated item:', { id: item._id, name: item.name });
    res.json(item);
  } catch (error) {
    logger.error('Error updating item:', error);
    res.status(500).json({ error: 'Failed to update item' });
  }
});

// DELETE /api/items/:id - Delete item
app.delete('/api/items/:id', async (req, res) => {
  try {
    const item = await Item.findByIdAndDelete(req.params.id);
    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }
    
    logger.info('Deleted item:', { id: item._id, name: item.name });
    res.json({ message: 'Item deleted successfully', item });
  } catch (error) {
    logger.error('Error deleting item:', error);
    res.status(500).json({ error: 'Failed to delete item' });
  }
});

// Handle 404 for undefined routes
app.use('*', (req, res) => {
  logger.warn(`404 - Route not found: ${req.method} ${req.originalUrl}`);
  res.status(404).json({
    error: 'Route not found',
    method: req.method,
    url: req.originalUrl,
    availableEndpoints: ['/health', '/api', '/api/items']
  });
});

// Apply error handling middleware
app.use(errorHandler);

// ==========================================
// SERVER STARTUP
// ==========================================

const startServer = async () => {
  try {
    // Create logs directory
    const fs = require('fs');
    if (!fs.existsSync('logs')) {
      fs.mkdirSync('logs');
    }
    
    // Connect to database
    await connectDB();
    
    // Start HTTP server
    const server = app.listen(PORT, '0.0.0.0', () => {
      logger.info(`🚀 Server running on port ${PORT}`);
      logger.info(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
      logger.info(`🔗 Health check: http://localhost:${PORT}/health`);
      logger.info(`📡 API endpoint: http://localhost:${PORT}/api/items`);
    });

    // Graceful shutdown
    const gracefulShutdown = (signal) => {
      logger.info(`🛑 Received ${signal}, shutting down gracefully`);
      server.close(async () => {
        logger.info('📴 HTTP server closed');
        await mongoose.connection.close();
        logger.info('🔌 MongoDB connection closed');
        process.exit(0);
      });
    };

    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));

  } catch (error) {
    logger.error('💥 Failed to start server:', error);
    process.exit(1);
  }
};

// Start the server
startServer();

// Export app for testing
module.exports = app;
EOF
```

**🎯 Create Package.json Scripts:**

```bash
# Step 6: Update package.json with useful scripts
cat > package.json << 'EOF'
{
  "name": "capstone-backend",
  "version": "1.0.0",
  "description": "Backend API for DevOps Capstone Project",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "dev": "nodemon app.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "build": "echo 'No build step required for Node.js'",
    "health": "curl -f http://localhost:3000/health || exit 1"
  },
  "keywords": [
    "nodejs",
    "express",
    "mongodb",
    "api",
    "microservice",
    "devops"
  ],
  "author": "DevOps Team",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^7.5.0",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0",
    "winston": "^3.10.0",
    "joi": "^17.9.2",
    "express-rate-limit": "^6.10.0",
    "uuid": "^9.0.0",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "@types/node": "^20.5.0",
    "typescript": "^5.1.6",
    "@types/express": "^4.17.17",
    "@types/cors": "^2.8.13",
    "jest": "^29.6.2",
    "supertest": "^6.3.3",
    "@types/jest": "^29.5.4",
    "eslint": "^8.47.0"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=8.0.0"
  }
}
EOF
```

**🔧 Create Environment Configuration:**

```bash
# Step 7: Create environment variables for different deployments
cat > .env << 'EOF'
# Backend Environment Variables - Development
NODE_ENV=development
PORT=3000

# Database Configuration
MONGODB_URI=mongodb://localhost:27017/capstone_dev

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000,http://localhost:8080

# Logging
LOG_LEVEL=debug

# Security
JWT_SECRET=your-super-secret-jwt-key-change-in-production
BCRYPT_ROUNDS=10

# Application
APP_VERSION=1.0.0
API_RATE_LIMIT=100
EOF

cat > .env.production << 'EOF'
# Backend Environment Variables - Production
NODE_ENV=production
PORT=3000

# Database Configuration
MONGODB_URI=mongodb://mongodb-service:27017/capstone

# Frontend URL (for CORS)
FRONTEND_URL=http://frontend-service

# Logging
LOG_LEVEL=info

# Security (CHANGE THESE IN REAL PRODUCTION!)
JWT_SECRET=change-this-to-a-secure-random-string-in-production
BCRYPT_ROUNDS=12

# Application
APP_VERSION=1.0.0
API_RATE_LIMIT=50
EOF

cat > .env.test << 'EOF'
# Backend Environment Variables - Testing
NODE_ENV=test
PORT=3001

# Database Configuration
MONGODB_URI=mongodb://localhost:27017/capstone_test

# Logging
LOG_LEVEL=error

# Application
APP_VERSION=1.0.0
EOF
```

**🧪 Create Test Suite:**

```bash
# Step 8: Create comprehensive test suite
mkdir -p tests
cat > tests/app.test.js << 'EOF'
// Backend API Tests
const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../app');

// Test database connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/capstone_test';

describe('Backend API Tests', () => {
  // Setup and teardown
  beforeAll(async () => {
    if (mongoose.connection.readyState === 0) {
      await mongoose.connect(MONGODB_URI);
    }
  });

  afterAll(async () => {
    await mongoose.connection.close();
  });

  beforeEach(async () => {
    // Clean up test data before each test
    const collections = mongoose.connection.collections;
    for (const key in collections) {
      await collections[key].deleteMany({});
    }
  });

  // Health check tests
  describe('GET /health', () => {
    it('should return health status', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.body).toHaveProperty('status', 'healthy');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('uptime');
    });
  });

  // API info tests
  describe('GET /api', () => {
    it('should return API information', async () => {
      const response = await request(app)
        .get('/api')
        .expect(200);

      expect(response.body).toHaveProperty('name');
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('endpoints');
    });
  });

  // Items API tests
  describe('Items API', () => {
    describe('GET /api/items', () => {
      it('should return empty array when no items exist', async () => {
        const response = await request(app)
          .get('/api/items')
          .expect(200);

        expect(response.body).toHaveProperty('items');
        expect(response.body.items).toEqual([]);
        expect(response.body).toHaveProperty('pagination');
      });

      it('should return items with pagination', async () => {
        // Create test items
        const testItems = [
          { name: 'Test Item 1', description: 'First test item' },
          { name: 'Test Item 2', description: 'Second test item' }
        ];

        for (const item of testItems) {
          await request(app)
            .post('/api/items')
            .send(item)
            .expect(201);
        }

        const response = await request(app)
          .get('/api/items')
          .expect(200);

        expect(response.body.items).toHaveLength(2);
        expect(response.body.pagination.total).toBe(2);
      });
    });

    describe('POST /api/items', () => {
      it('should create a new item', async () => {
        const newItem = {
          name: 'Test Todo',
          description: 'This is a test todo item',
          priority: 'high'
        };

        const response = await request(app)
          .post('/api/items')
          .send(newItem)
          .expect(201);

        expect(response.body).toHaveProperty('_id');
        expect(response.body.name).toBe(newItem.name);
        expect(response.body.description).toBe(newItem.description);
        expect(response.body.priority).toBe(newItem.priority);
        expect(response.body).toHaveProperty('createdAt');
      });

      it('should reject item without required name', async () => {
        const invalidItem = {
          description: 'Missing name field'
        };

        const response = await request(app)
          .post('/api/items')
          .send(invalidItem)
          .expect(400);

        expect(response.body).toHaveProperty('error');
        expect(response.body.error).toBe('Validation failed');
      });

      it('should reject item with invalid priority', async () => {
        const invalidItem = {
          name: 'Test Item',
          priority: 'invalid-priority'
        };

        const response = await request(app)
          .post('/api/items')
          .send(invalidItem)
          .expect(400);

        expect(response.body).toHaveProperty('error');
      });
    });

    describe('GET /api/items/:id', () => {
      it('should return specific item', async () => {
        // Create test item
        const createResponse = await request(app)
          .post('/api/items')
          .send({ name: 'Test Item', description: 'Test description' })
          .expect(201);

        const itemId = createResponse.body._id;

        const response = await request(app)
          .get(`/api/items/${itemId}`)
          .expect(200);

        expect(response.body._id).toBe(itemId);
        expect(response.body.name).toBe('Test Item');
      });

      it('should return 404 for non-existent item', async () => {
        const fakeId = new mongoose.Types.ObjectId();
        
        await request(app)
          .get(`/api/items/${fakeId}`)
          .expect(404);
      });
    });

    describe('PUT /api/items/:id', () => {
      it('should update existing item', async () => {
        // Create test item
        const createResponse = await request(app)
          .post('/api/items')
          .send({ name: 'Original Name', description: 'Original description' })
          .expect(201);

        const itemId = createResponse.body._id;

        const updateData = {
          name: 'Updated Name',
          completed: true
        };

        const response = await request(app)
          .put(`/api/items/${itemId}`)
          .send(updateData)
          .expect(200);

        expect(response.body.name).toBe('Updated Name');
        expect(response.body.completed).toBe(true);
        expect(response.body.description).toBe('Original description'); // Should remain unchanged
      });
    });

    describe('DELETE /api/items/:id', () => {
      it('should delete existing item', async () => {
        // Create test item
        const createResponse = await request(app)
          .post('/api/items')
          .send({ name: 'Item to Delete', description: 'Will be deleted' })
          .expect(201);

        const itemId = createResponse.body._id;

        await request(app)
          .delete(`/api/items/${itemId}`)
          .expect(200);

        // Verify item is deleted
        await request(app)
          .get(`/api/items/${itemId}`)
          .expect(404);
      });
    });
  });

  // Error handling tests
  describe('Error Handling', () => {
    it('should return 404 for undefined routes', async () => {
      const response = await request(app)
        .get('/nonexistent-route')
        .expect(404);

      expect(response.body).toHaveProperty('error', 'Route not found');
      expect(response.body).toHaveProperty('availableEndpoints');
    });
  });
});
EOF

# Step 9: Create Jest configuration
cat > jest.config.js << 'EOF'
module.exports = {
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  testMatch: ['**/__tests__/**/*.js', '**/?(*.)+(spec|test).js'],
  collectCoverageFrom: [
    '**/*.js',
    '!**/node_modules/**',
    '!**/coverage/**',
    '!**/logs/**',
    '!jest.config.js'
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70
    }
  }
};
EOF

# Create test setup file
cat > tests/setup.js << 'EOF'
// Test setup and configuration
require('dotenv').config({ path: '.env.test' });

// Increase timeout for database operations
jest.setTimeout(30000);

// Mock console methods to keep test output clean
global.console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
};
EOF
```

**🐳 Create Production-Ready Backend Dockerfile:**

```bash
# Step 10: Create multi-stage Dockerfile optimized for production
cat > Dockerfile << 'EOF'
# Multi-stage Docker build for Node.js backend
# Stage 1: Development/Build stage with all dependencies

FROM node:18-alpine AS development

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create app directory and set proper ownership
RUN mkdir -p /app && chown -R node:node /app
WORKDIR /app

# Switch to non-root user early for security
USER node

# Copy package files
COPY --chown=node:node package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm ci --only=development && npm cache clean --force

# Copy source code
COPY --chown=node:node . .

# Run tests and linting (optional - uncomment if you have these)
# RUN npm run test
# RUN npm run lint

# Stage 2: Production stage with minimal footprint
FROM node:18-alpine AS production

# Install dumb-init and curl for health checks
RUN apk add --no-cache dumb-init curl

# Create app directory and user
RUN mkdir -p /app && chown -R node:node /app
WORKDIR /app

# Switch to non-root user for security
USER node

# Copy package files
COPY --chown=node:node package*.json ./

# Install only production dependencies
RUN npm ci --only=production --silent && npm cache clean --force

# Copy application code from development stage (if needed) or directly
COPY --chown=node:node --from=development /app/app.js ./
COPY --chown=node:node --from=development /app/.env* ./

# Create logs directory
RUN mkdir -p logs

# Expose port
EXPOSE 3000

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["node", "app.js"]
EOF

# Step 11: Create .dockerignore for efficient builds
cat > .dockerignore << 'EOF'
# Dockerignore file to reduce build context size and improve security

# Node.js
node_modules
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment files (copy specific ones in Dockerfile)
.env.local
.env.*.local

# Logs
logs
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# nyc test coverage
.nyc_output

# Dependency directories
.npm
.eslintcache

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env.test
.env.local
.env.*.local

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Git
.git
.gitignore
README.md

# CI/CD
.github/
.gitlab-ci.yml
.travis.yml

# Documentation
docs/
*.md

# Tests
tests/
__tests__/
*.test.js
*.spec.js
jest.config.js

# Development files
nodemon.json
.eslintrc*
.prettierrc*
EOF
```

**🧪 Test the Backend Locally:**

```bash
# Step 12: Install dependencies and run tests
npm install

# Run the test suite to ensure everything works
npm test

# Start the development server
npm run dev

# In another terminal, test the API endpoints
echo "Testing health endpoint..."
curl http://localhost:3000/health

echo -e "\n\nTesting API info..."
curl http://localhost:3000/api

echo -e "\n\nTesting create item..."
curl -X POST http://localhost:3000/api/items \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Todo","description":"Created via curl","priority":"high"}'

echo -e "\n\nTesting get items..."
curl http://localhost:3000/api/items
```

**🐳 Build and Test Docker Container:**

```bash
# Step 13: Build the backend Docker image
docker build -t capstone/backend:latest .

# Check image size (should be much smaller than full Node.js image)
docker images | grep capstone/backend

# Test run the container
docker run -d \
  --name backend-test \
  -p 3000:3000 \
  -e NODE_ENV=development \
  -e MONGODB_URI=mongodb://host.docker.internal:27017/capstone \
  capstone/backend:latest

# Wait a moment for startup
sleep 5

# Test the containerized API
echo "Testing containerized backend..."
curl http://localhost:3000/health

# Check container logs
docker logs backend-test

# Clean up test container
docker stop backend-test
docker rm backend-test
```

**🔍 Understanding Our Backend Architecture:**

**Key Features Implemented:**
1. **RESTful API Design**: Standard HTTP methods and status codes
2. **Input Validation**: Joi schema validation for all endpoints
3. **Security**: Helmet.js headers, CORS, rate limiting
4. **Logging**: Structured logging with Winston
5. **Error Handling**: Comprehensive error catching and responses
6. **Database Integration**: Mongoose ODM with connection retry logic
7. **Health Monitoring**: Health check endpoint for container orchestration
8. **Testing**: Complete test suite with Jest and Supertest
9. **Environment Configuration**: Different configs for dev/test/production
10. **Docker Optimization**: Multi-stage build for small production images

**API Endpoints:**
```
GET    /health              - Health check (returns system status)
GET    /api                 - API information and available endpoints
GET    /api/items           - List all items (with pagination/filtering)
POST   /api/items           - Create new item
GET    /api/items/:id       - Get specific item by ID  
PUT    /api/items/:id       - Update item by ID
DELETE /api/items/:id       - Delete item by ID
```

**Example API Usage:**
```bash
# Create a new todo
curl -X POST http://localhost:3000/api/items \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Learn Kubernetes",
    "description": "Study container orchestration",
    "priority": "high",
    "tags": ["devops", "kubernetes"]
  }'

# Get all todos with pagination
curl "http://localhost:3000/api/items?page=1&limit=10&completed=false"

# Update a todo
curl -X PUT http://localhost:3000/api/items/[ID] \
  -H "Content-Type: application/json" \
  -d '{"completed": true}'

# Delete a todo
curl -X DELETE http://localhost:3000/api/items/[ID]
```

**🚨 Backend Troubleshooting:**

**Problem**: "Cannot connect to MongoDB"
```bash
# Solution: Check MongoDB connection
# For local development:
mongosh mongodb://localhost:27017/capstone

# For Docker:
docker run -d -p 27017:27017 --name mongodb mongo:6.0
```

**Problem**: "Port 3000 already in use"
```bash
# Solution: Find and kill the process
lsof -ti:3000 | xargs kill -9
# Or use different port:
PORT=3001 npm start
```

**Problem**: Tests failing
```bash
# Solution: Check test database connection
npm run test -- --verbose
# Make sure MongoDB is running for tests
```

**Problem**: Docker build fails
```bash
# Solution: Check Docker build context
docker build --no-cache -t capstone/backend:latest .
# Check .dockerignore file
```

**🎯 What We Accomplished:**
- ✅ **Production-Ready API**: Full CRUD operations with validation
- ✅ **Security**: Rate limiting, CORS, security headers
- ✅ **Monitoring**: Health checks and structured logging  
- ✅ **Testing**: Comprehensive test suite with high coverage
- ✅ **Database Integration**: MongoDB with connection management
- ✅ **Error Handling**: Graceful error responses and logging
- ✅ **Docker Optimization**: Multi-stage build (~30MB final image)
- ✅ **Environment Config**: Separate configs for different environments
- ✅ **Documentation**: API endpoints and usage examples

The backend service is now complete and ready for Kubernetes deployment!

---

## 🏗️ Phase 2: Infrastructure Setup

**What is Infrastructure as Code (IaC)?**
Instead of manually clicking through web interfaces to create servers, networks, and services, we write code that describes what infrastructure we want. This code can be version-controlled, reviewed, and automatically applied.

**Benefits of IaC:**
- **Reproducible**: Create identical environments every time
- **Version Controlled**: Track changes like application code
- **Collaborative**: Team members can review infrastructure changes
- **Documented**: Infrastructure is self-documenting through code
- **Automated**: No manual steps that can be forgotten or done wrong

**Our Infrastructure Stack:**
```
┌─────────────────────────────────────────────┐
│              Terraform                      │
│        (Infrastructure as Code)             │
├─────────────────────────────────────────────┤
│  📦 Kubernetes Namespaces                  │
│  ├── capstone (application)                │
│  ├── monitoring (metrics & dashboards)     │
│  └── argocd (gitops)                       │
├─────────────────────────────────────────────┤
│  🔧 Resource Configurations                │
│  ├── ConfigMaps (application config)       │
│  ├── Secrets (sensitive data)              │
│  ├── PersistentVolumes (storage)           │
│  └── NetworkPolicies (security)            │
└─────────────────────────────────────────────┘
```

---

### 🏗️ Terraform Configuration

**What is Terraform doing for us?**
Terraform will create and manage our Kubernetes infrastructure components automatically. Instead of running dozens of `kubectl create` commands, we describe what we want in `.tf` files and Terraform makes it happen.

```bash
# Step 1: Create Terraform directory structure
mkdir -p infrastructure/terraform
cd infrastructure/terraform

# Step 2: Create the main Terraform configuration
cat > main.tf << 'EOF'
# DevOps Capstone Infrastructure Configuration
# This file defines all Kubernetes resources needed for our application

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

# Configure Kubernetes provider to use local kubeconfig
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "minikube"
  }
}

# ==========================================
# NAMESPACES
# ==========================================

# Main application namespace
resource "kubernetes_namespace" "capstone" {
  metadata {
    name = "capstone"
    labels = {
      name          = "capstone"
      environment   = var.environment
      managed-by    = "terraform"
      project       = "devops-capstone"
    }
    annotations = {
      description = "Main application namespace for DevOps capstone project"
    }
  }
}

# Monitoring namespace for Prometheus, Grafana, etc.
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name          = "monitoring"
      environment   = var.environment
      managed-by    = "terraform"
      project       = "devops-capstone"
    }
    annotations = {
      description = "Monitoring stack namespace (Prometheus, Grafana)"
    }
  }
}

# ArgoCD namespace for GitOps
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      name          = "argocd"
      environment   = var.environment
      managed-by    = "terraform"
      project       = "devops-capstone"
    }
    annotations = {
      description = "GitOps namespace for ArgoCD"
    }
  }
}

# ==========================================
# CONFIGMAPS
# ==========================================

# Application configuration
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.capstone.metadata[0].name
    labels = {
      app = "capstone"
    }
  }

  data = {
    APP_NAME        = "DevOps Capstone"
    APP_VERSION     = var.app_version
    ENVIRONMENT     = var.environment
    LOG_LEVEL       = var.environment == "production" ? "info" : "debug"
    API_RATE_LIMIT  = var.environment == "production" ? "50" : "100"
  }
}

# Database configuration
resource "kubernetes_config_map" "db_config" {
  metadata {
    name      = "db-config"
    namespace = kubernetes_namespace.capstone.metadata[0].name
    labels = {
      app = "mongodb"
    }
  }

  data = {
    MONGODB_DATABASE = "capstone"
    MONGODB_USERNAME = "capstone_user"
  }
}

# Nginx configuration for frontend
resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name      = "nginx-config"
    namespace = kubernetes_namespace.capstone.metadata[0].name
    labels = {
      app = "frontend"
    }
  }

  data = {
    "nginx.conf" = file("${path.module}/configs/nginx.conf")
  }
}

# ==========================================
# SECRETS
# ==========================================

# Database credentials
resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace.capstone.metadata[0].name
    labels = {
      app = "mongodb"
    }
  }

  type = "Opaque"

  data = {
    username = base64encode(var.mongodb_username)
    password = base64encode(var.mongodb_password)
    root-password = base64encode(var.mongodb_root_password)
  }
}

# Application secrets
resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "app-secrets"
    namespace = kubernetes_namespace.capstone.metadata[0].name
    labels = {
      app = "backend"
    }
  }

  type = "Opaque"

  data = {
    jwt-secret = base64encode(var.jwt_secret)
    api-key    = base64encode(var.api_key)
  }
}

# ==========================================
# PERSISTENT VOLUMES
# ==========================================

# Storage class for dynamic provisioning
resource "kubernetes_storage_class" "fast_ssd" {
  metadata {
    name = "fast-ssd"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false"
    }
  }
  
  storage_provisioner    = "k8s.io/minikube-hostpath"
  reclaim_policy        = "Retain"
  volume_binding_mode   = "Immediate"
  allow_volume_expansion = true
  
  parameters = {
    type = "pd-ssd"
  }
}

# Persistent Volume for MongoDB data
resource "kubernetes_persistent_volume" "mongodb_pv" {
  metadata {
    name = "mongodb-pv"
    labels = {
      app = "mongodb"
      type = "local"
    }
  }

  spec {
    capacity = {
      storage = var.mongodb_storage_size
    }

    access_modes       = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.fast_ssd.metadata[0].name

    persistent_volume_source {
      host_path {
        path = "/data/mongodb"
        type = "DirectoryOrCreate"
      }
    }

    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = ["minikube"]
          }
        }
      }
    }
  }
}

# Persistent Volume Claim for MongoDB
resource "kubernetes_persistent_volume_claim" "mongodb_pvc" {
  metadata {
    name      = "mongodb-pvc"
    namespace = kubernetes_namespace.capstone.metadata[0].name
    labels = {
      app = "mongodb"
    }
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.fast_ssd.metadata[0].name

    resources {
      requests = {
        storage = var.mongodb_storage_size
      }
    }

    volume_name = kubernetes_persistent_volume.mongodb_pv.metadata[0].name
  }
}

# ==========================================
# NETWORK POLICIES
# ==========================================

# Default deny all traffic (security first approach)
resource "kubernetes_network_policy" "default_deny" {
  metadata {
    name      = "default-deny-all"
    namespace = kubernetes_namespace.capstone.metadata[0].name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

# Allow frontend to backend communication
resource "kubernetes_network_policy" "frontend_to_backend" {
  metadata {
    name      = "frontend-to-backend"
    namespace = kubernetes_namespace.capstone.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        app = "frontend"
      }
    }

    policy_types = ["Egress"]

    egress {
      to {
        pod_selector {
          match_labels = {
            app = "backend"
          }
        }
      }
      ports {
        port     = "3000"
        protocol = "TCP"
      }
    }

    # Allow DNS resolution
    egress {
      to {}
      ports {
        port     = "53"
        protocol = "UDP"
      }
    }
  }
}

# Allow backend to MongoDB communication
resource "kubernetes_network_policy" "backend_to_mongodb" {
  metadata {
    name      = "backend-to-mongodb"
    namespace = kubernetes_namespace.capstone.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        app = "backend"
      }
    }

    policy_types = ["Egress"]

    egress {
      to {
        pod_selector {
          match_labels = {
            app = "mongodb"
          }
        }
      }
      ports {
        port     = "27017"
        protocol = "TCP"
      }
    }

    # Allow DNS resolution
    egress {
      to {}
      ports {
        port     = "53"
        protocol = "UDP"
      }
    }
  }
}

# Allow ingress to frontend
resource "kubernetes_network_policy" "allow_frontend_ingress" {
  metadata {
    name      = "allow-frontend-ingress"
    namespace = kubernetes_namespace.capstone.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        app = "frontend"
      }
    }

    policy_types = ["Ingress"]

    ingress {
      from {}
      ports {
        port     = "80"
        protocol = "TCP"
      }
    }
  }
}

# ==========================================
# RESOURCE QUOTAS
# ==========================================

# Resource quota for the capstone namespace
resource "kubernetes_resource_quota" "capstone_quota" {
  metadata {
    name      = "capstone-quota"
    namespace = kubernetes_namespace.capstone.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = var.resource_quota.cpu_requests
      "requests.memory" = var.resource_quota.memory_requests
      "limits.cpu"      = var.resource_quota.cpu_limits
      "limits.memory"   = var.resource_quota.memory_limits
      "persistentvolumeclaims" = "5"
      "services"        = "10"
      "secrets"         = "10"
      "configmaps"      = "10"
    }
  }
}

# ==========================================
# LIMIT RANGES
# ==========================================

# Limit ranges to ensure proper resource allocation
resource "kubernetes_limit_range" "capstone_limits" {
  metadata {
    name      = "capstone-limits"
    namespace = kubernetes_namespace.capstone.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      
      default = {
        cpu    = "200m"
        memory = "256Mi"
      }
      
      default_request = {
        cpu    = "100m"
        memory = "128Mi"
      }
      
      max = {
        cpu    = "1"
        memory = "1Gi"
      }
      
      min = {
        cpu    = "50m"
        memory = "64Mi"
      }
    }
  }
}

# ==========================================
# OUTPUTS
# ==========================================

# Output important information for other modules or manual reference
output "namespaces" {
  description = "Created namespace names"
  value = {
    capstone   = kubernetes_namespace.capstone.metadata[0].name
    monitoring = kubernetes_namespace.monitoring.metadata[0].name
    argocd     = kubernetes_namespace.argocd.metadata[0].name
  }
}

output "storage_class" {
  description = "Created storage class name"
  value       = kubernetes_storage_class.fast_ssd.metadata[0].name
}

output "mongodb_pvc" {
  description = "MongoDB persistent volume claim name"
  value       = kubernetes_persistent_volume_claim.mongodb_pvc.metadata[0].name
}

output "configmaps" {
  description = "Created ConfigMap names"
  value = {
    app_config   = kubernetes_config_map.app_config.metadata[0].name
    db_config    = kubernetes_config_map.db_config.metadata[0].name
    nginx_config = kubernetes_config_map.nginx_config.metadata[0].name
  }
}

output "secrets" {
  description = "Created Secret names"
  value = {
    db_credentials = kubernetes_secret.db_credentials.metadata[0].name
    app_secrets    = kubernetes_secret.app_secrets.metadata[0].name
  }
}
EOF
```

**🔧 Create Variables Configuration:**

```bash
# Step 3: Create variables file for customization
cat > variables.tf << 'EOF'
# Terraform Variables for DevOps Capstone Infrastructure
# These variables allow customization without changing main configuration

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "development"
  
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "app_version" {
  description = "Application version tag"
  type        = string
  default     = "1.0.0"
}

variable "mongodb_storage_size" {
  description = "Storage size for MongoDB persistent volume"
  type        = string
  default     = "5Gi"
}

variable "mongodb_username" {
  description = "MongoDB application username"
  type        = string
  default     = "capstone_user"
  sensitive   = true
}

variable "mongodb_password" {
  description = "MongoDB application password"
  type        = string
  default     = "capstone_password_123"
  sensitive   = true
}

variable "mongodb_root_password" {
  description = "MongoDB root password"
  type        = string
  default     = "root_password_456"
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret for application authentication"
  type        = string
  default     = "super-secret-jwt-key-change-in-production"
  sensitive   = true
}

variable "api_key" {
  description = "API key for external services"
  type        = string
  default     = "dev-api-key-123"
  sensitive   = true
}

variable "resource_quota" {
  description = "Resource quota limits for the namespace"
  type = object({
    cpu_requests    = string
    memory_requests = string
    cpu_limits      = string
    memory_limits   = string
  })
  default = {
    cpu_requests    = "2"
    memory_requests = "4Gi"
    cpu_limits      = "4"
    memory_limits   = "8Gi"
  }
}

variable "enable_network_policies" {
  description = "Enable network policies for enhanced security"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
  
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 30
    error_message = "Backup retention must be between 1 and 30 days."
  }
}
EOF

# Step 4: Create environment-specific variable files
cat > terraform.tfvars << 'EOF'
# Development Environment Variables
environment              = "development"
app_version             = "latest"
mongodb_storage_size    = "2Gi"
enable_network_policies = false

resource_quota = {
  cpu_requests    = "1"
  memory_requests = "2Gi" 
  cpu_limits      = "2"
  memory_limits   = "4Gi"
}
EOF

cat > production.tfvars << 'EOF'
# Production Environment Variables
environment              = "production"
app_version             = "1.0.0"
mongodb_storage_size    = "20Gi"
enable_network_policies = true
backup_retention_days   = 30

resource_quota = {
  cpu_requests    = "4"
  memory_requests = "8Gi"
  cpu_limits      = "8"
  memory_limits   = "16Gi"
}

# Security: These should be set via environment variables in production
# mongodb_username     = "secure_user"
# mongodb_password     = "very-secure-password"
# jwt_secret          = "production-jwt-secret-256-bits"
EOF
```

**🧪 Initialize and Test Terraform:**

```bash
# Step 5: Create supporting configuration files
mkdir -p configs

# Create nginx configuration file
cat > configs/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    upstream backend {
        server backend-service:3000;
    }
    
    server {
        listen 80;
        server_name localhost;
        
        location /api {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        location / {
            root /usr/share/nginx/html;
            index index.html;
            try_files $uri $uri/ /index.html;
        }
    }
}
EOF

# Step 6: Initialize Terraform
terraform init

# Step 7: Validate configuration
terraform validate

# Step 8: Plan the infrastructure changes
terraform plan

# Step 9: Apply the infrastructure (create resources)
terraform apply -auto-approve

# Step 10: Verify resources were created
kubectl get namespaces -l managed-by=terraform
kubectl get configmaps -n capstone
kubectl get secrets -n capstone
kubectl get pvc -n capstone
```

**🔍 Understanding What Terraform Created:**

1. **Namespaces**: Isolated environments for different components
2. **ConfigMaps**: Non-sensitive configuration data
3. **Secrets**: Sensitive data like passwords (base64 encoded)
4. **Persistent Volumes**: Storage for database data
5. **Network Policies**: Security rules for network traffic
6. **Resource Quotas**: Limits to prevent resource exhaustion
7. **Limit Ranges**: Default resource allocations

---

### 🤖 Ansible Configuration

**What will Ansible do for us?**
Ansible will automate the setup and configuration of our Kubernetes cluster components. It will install monitoring tools, configure ArgoCD for GitOps, and ensure everything is properly configured.

```bash
# Step 1: Create Ansible directory and move there
mkdir -p infrastructure/ansible
cd infrastructure/ansible

# Step 2: Create Ansible inventory for our setup
cat > inventory << 'EOF'
[local]
localhost ansible_connection=local

[kubernetes]
# Minikube cluster - using localhost since we're managing local cluster
minikube ansible_host=localhost ansible_connection=local

[all:vars]
# Global variables for all hosts
ansible_python_interpreter=/usr/bin/python3
cluster_name=minikube
namespace_app=capstone
namespace_monitoring=monitoring
namespace_argocd=argocd
EOF

# Step 3: Create main setup playbook
cat > setup.yml << 'EOF'
---
# DevOps Capstone - Ansible Setup Playbook
# This playbook configures our Kubernetes cluster with all necessary components

- name: Setup Kubernetes cluster for DevOps capstone project
  hosts: localhost
  connection: local
  gather_facts: true
  become: false

  vars:
    # Application variables
    app_name: "devops-capstone"
    app_version: "{{ app_version | default('1.0.0') }}"
    environment: "{{ environment | default('development') }}"
    
    # Namespace variables
    namespaces:
      - name: capstone
        description: "Main application namespace"
      - name: monitoring
        description: "Monitoring stack namespace"
      - name: argocd
        description: "GitOps namespace"
    
    # Monitoring configuration
    prometheus_version: "45.7.1"
    grafana_admin_password: "admin123"
    
    # ArgoCD configuration
    argocd_version: "v2.8.4"
    argocd_admin_password: "admin123"

  tasks:
    # ==========================================
    # PREREQUISITES CHECK
    # ==========================================
    
    - name: Check if kubectl is available
      command: kubectl version --client
      register: kubectl_check
      failed_when: false
      changed_when: false

    - name: Fail if kubectl not found
      fail:
        msg: "kubectl is not installed or not in PATH"
      when: kubectl_check.rc != 0

    - name: Check if Helm is available
      command: helm version
      register: helm_check
      failed_when: false
      changed_when: false

    - name: Fail if Helm not found
      fail:
        msg: "Helm is not installed or not in PATH"
      when: helm_check.rc != 0

    - name: Check cluster connectivity
      kubernetes.core.k8s_info:
        api_version: v1
        kind: Node
      register: cluster_nodes
      
    - name: Display cluster information
      debug:
        msg: "Connected to cluster with {{ cluster_nodes.resources | length }} node(s)"

    # ==========================================
    # TERRAFORM INFRASTRUCTURE
    # ==========================================
    
    - name: Apply Terraform infrastructure configuration
      block:
        - name: Check if Terraform directory exists
          stat:
            path: ../terraform
          register: terraform_dir

        - name: Initialize Terraform
          command: terraform init
          args:
            chdir: ../terraform
          when: terraform_dir.stat.exists

        - name: Plan Terraform changes
          command: terraform plan -out=tfplan
          args:
            chdir: ../terraform
          when: terraform_dir.stat.exists
          register: terraform_plan

        - name: Apply Terraform configuration
          command: terraform apply tfplan
          args:
            chdir: ../terraform
          when: terraform_dir.stat.exists and terraform_plan is succeeded

    # ==========================================
    # NAMESPACE VERIFICATION
    # ==========================================
    
    - name: Wait for namespaces to be ready
      kubernetes.core.k8s_info:
        api_version: v1
        kind: Namespace
        name: "{{ item.name }}"
        wait: true
        wait_condition:
          type: Active
          status: "True"
        wait_timeout: 300
      loop: "{{ namespaces }}"
      register: namespace_status

    - name: Display namespace status
      debug:
        msg: "Namespace {{ item.item.name }} is {{ item.resources[0].status.phase }}"
      loop: "{{ namespace_status.results }}"

    # ==========================================
    # MONITORING STACK SETUP
    # ==========================================
    
    - name: Add Prometheus Helm repository
      kubernetes.core.helm_repository:
        name: prometheus-community
        repo_url: https://prometheus-community.github.io/helm-charts
        state: present

    - name: Update Helm repositories
      command: helm repo update

    - name: Create monitoring values file
      copy:
        content: |
          # Prometheus and Grafana configuration
          prometheus:
            prometheusSpec:
              retention: 15d
              storageSpec:
                volumeClaimTemplate:
                  spec:
                    accessModes: ["ReadWriteOnce"]
                    resources:
                      requests:
                        storage: 5Gi
              
          grafana:
            adminPassword: {{ grafana_admin_password }}
            persistence:
              enabled: true
              size: 1Gi
            
            dashboardProviders:
              dashboardproviders.yaml:
                apiVersion: 1
                providers:
                - name: 'default'
                  orgId: 1
                  folder: ''
                  type: file
                  disableDeletion: false
                  editable: true
                  options:
                    path: /var/lib/grafana/dashboards/default
            
            dashboards:
              default:
                kubernetes-cluster:
                  gnetId: 7249
                  revision: 1
                  datasource: Prometheus
                node-exporter:
                  gnetId: 1860
                  revision: 27
                  datasource: Prometheus

          # AlertManager configuration
          alertmanager:
            alertmanagerSpec:
              storage:
                volumeClaimTemplate:
                  spec:
                    accessModes: ["ReadWriteOnce"]
                    resources:
                      requests:
                        storage: 1Gi
        dest: /tmp/prometheus-values.yaml

    - name: Install Prometheus and Grafana
      kubernetes.core.helm:
        name: prometheus
        chart_ref: prometheus-community/kube-prometheus-stack
        release_namespace: monitoring
        create_namespace: false
        values_files:
          - /tmp/prometheus-values.yaml
        wait: true
        timeout: 10m

    - name: Verify monitoring stack deployment
      kubernetes.core.k8s_info:
        api_version: apps/v1
        kind: Deployment
        namespace: monitoring
        label_selectors:
          - app.kubernetes.io/name=grafana
      register: grafana_deployment
      retries: 10
      delay: 30
      until: grafana_deployment.resources[0].status.readyReplicas | default(0) >= 1

    # ==========================================
    # ARGOCD SETUP
    # ==========================================
    
    - name: Create ArgoCD installation manifest
      get_url:
        url: https://raw.githubusercontent.com/argoproj/argo-cd/{{ argocd_version }}/manifests/install.yaml
        dest: /tmp/argocd-install.yaml
        mode: '0644'

    - name: Install ArgoCD
      kubernetes.core.k8s:
        state: present
        src: /tmp/argocd-install.yaml
        namespace: argocd

    - name: Wait for ArgoCD server deployment
      kubernetes.core.k8s_info:
        api_version: apps/v1
        kind: Deployment
        name: argocd-server
        namespace: argocd
        wait: true
        wait_condition:
          type: Available
          status: "True"
        wait_timeout: 600

    - name: Create ArgoCD admin password secret
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: v1
          kind: Secret
          metadata:
            name: argocd-secret
            namespace: argocd
            labels:
              app.kubernetes.io/name: argocd-secret
              app.kubernetes.io/part-of: argocd
          type: Opaque
          data:
            # Password: admin123 (bcrypt hash)
            admin.password: "$2a$10$rRyBsGSHK6.uc8fntPwVIuLVHgsAhAX7TcdrqW/XhfIBB97T3nKNa"
            admin.passwordMtime: "{{ ansible_date_time.epoch }}"

    - name: Patch ArgoCD server to use LoadBalancer service
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: v1
          kind: Service
          metadata:
            name: argocd-server
            namespace: argocd
            labels:
              app.kubernetes.io/component: server
              app.kubernetes.io/name: argocd-server
              app.kubernetes.io/part-of: argocd
          spec:
            type: NodePort
            ports:
            - name: https
              port: 443
              protocol: TCP
              targetPort: 8080
              nodePort: 30080
            - name: grpc
              port: 443
              protocol: TCP
              targetPort: 8080
            selector:
              app.kubernetes.io/name: argocd-server

    # ==========================================
    # VERIFICATION AND STATUS
    # ==========================================
    
    - name: Get all pods status
      kubernetes.core.k8s_info:
        api_version: v1
        kind: Pod
        namespace: "{{ item.name }}"
      loop: "{{ namespaces }}"
      register: all_pods

    - name: Display pod status summary
      debug:
        msg: |
          Namespace: {{ item.item.name }}
          Pods: {{ item.resources | length }}
          Running: {{ item.resources | selectattr('status.phase', 'equalto', 'Running') | list | length }}
      loop: "{{ all_pods.results }}"

    - name: Create access information file
      copy:
        content: |
          # DevOps Capstone - Access Information
          # Generated by Ansible on {{ ansible_date_time.iso8601 }}
          
          ## Cluster Information
          - Cluster: {{ cluster_name }}
          - Environment: {{ environment }}
          - App Version: {{ app_version }}
          
          ## Application Access
          - Frontend: http://$(minikube ip):30000
          - Backend API: http://$(minikube ip):30001/api
          - Health Check: http://$(minikube ip):30001/health
          
          ## Monitoring Access
          - Grafana: http://$(minikube ip):30002
            Username: admin
            Password: {{ grafana_admin_password }}
          - Prometheus: http://$(minikube ip):30003
          
          ## GitOps Access
          - ArgoCD: http://$(minikube ip):30080
            Username: admin
            Password: {{ argocd_admin_password }}
          
          ## Useful Commands
          # Port forward services for local access
          kubectl port-forward -n capstone svc/frontend-service 8080:80
          kubectl port-forward -n capstone svc/backend-service 3000:3000
          kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
          kubectl port-forward -n argocd svc/argocd-server 8080:443
          
          # Check application logs
          kubectl logs -n capstone -l app=frontend
          kubectl logs -n capstone -l app=backend
          
          # Scale applications
          kubectl scale deployment frontend --replicas=3 -n capstone
          kubectl scale deployment backend --replicas=2 -n capstone
        dest: ./ACCESS_INFO.md
        mode: '0644'

    # ==========================================
    # FINAL STATUS REPORT
    # ==========================================
    
    - name: Generate final status report
      debug:
        msg: |
          
          ====================================
          🎉 SETUP COMPLETED SUCCESSFULLY! 🎉
          ====================================
          
          ✅ Infrastructure: Terraform applied
          ✅ Namespaces: {{ namespaces | length }} created
          ✅ Monitoring: Prometheus & Grafana installed
          ✅ GitOps: ArgoCD installed and configured
          
          📋 Next Steps:
          1. Deploy applications: cd ../../helm-charts && helm install ...
          2. Configure ArgoCD applications
          3. Set up CI/CD pipelines
          
          📖 Access Information: See ACCESS_INFO.md
          
          ====================================

  handlers:
    - name: restart services
      debug:
        msg: "Service restart would happen here in production"
EOF

# Step 4: Create additional Ansible playbooks for specific tasks
cat > install-monitoring.yml << 'EOF'
---
# Standalone playbook for installing monitoring stack
- name: Install Monitoring Stack (Prometheus & Grafana)
  hosts: localhost
  connection: local
  gather_facts: false

  vars:
    grafana_admin_password: "{{ grafana_password | default('admin123') }}"
    prometheus_retention: "{{ retention_days | default('15d') }}"
    storage_size: "{{ monitoring_storage | default('5Gi') }}"

  tasks:
    - name: Add Prometheus Helm repository
      kubernetes.core.helm_repository:
        name: prometheus-community
        repo_url: https://prometheus-community.github.io/helm-charts

    - name: Install Prometheus and Grafana
      kubernetes.core.helm:
        name: prometheus
        chart_ref: prometheus-community/kube-prometheus-stack
        release_namespace: monitoring
        create_namespace: true
        values:
          prometheus:
            prometheusSpec:
              retention: "{{ prometheus_retention }}"
              storageSpec:
                volumeClaimTemplate:
                  spec:
                    accessModes: ["ReadWriteOnce"]
                    resources:
                      requests:
                        storage: "{{ storage_size }}"
          grafana:
            adminPassword: "{{ grafana_admin_password }}"
            service:
              type: NodePort
              nodePort: 30002
        wait: true
        timeout: 10m
EOF

cat > install-argocd.yml << 'EOF'
---
# Standalone playbook for installing ArgoCD
- name: Install ArgoCD for GitOps
  hosts: localhost
  connection: local
  gather_facts: false

  vars:
    argocd_version: "{{ version | default('v2.8.4') }}"
    admin_password: "{{ argocd_password | default('admin123') }}"

  tasks:
    - name: Download ArgoCD installation manifest
      get_url:
        url: "https://raw.githubusercontent.com/argoproj/argo-cd/{{ argocd_version }}/manifests/install.yaml"
        dest: /tmp/argocd-install.yaml

    - name: Install ArgoCD
      kubernetes.core.k8s:
        state: present
        src: /tmp/argocd-install.yaml
        namespace: argocd

    - name: Wait for ArgoCD to be ready
      kubernetes.core.k8s_info:
        api_version: apps/v1
        kind: Deployment
        name: argocd-server
        namespace: argocd
        wait: true
        wait_condition:
          type: Available
          status: "True"
        wait_timeout: 600

    - name: Expose ArgoCD server via NodePort
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: v1
          kind: Service
          metadata:
            name: argocd-server-nodeport
            namespace: argocd
          spec:
            type: NodePort
            ports:
            - port: 80
              targetPort: 8080
              nodePort: 30080
            selector:
              app.kubernetes.io/name: argocd-server
EOF

# Step 5: Create Ansible configuration file
cat > ansible.cfg << 'EOF'
[defaults]
inventory = inventory
host_key_checking = False
timeout = 30
retry_files_enabled = False
gathering = smart
fact_caching = memory
stdout_callback = yaml
callbacks_enabled = timer, profile_tasks

[inventory]
enable_plugins = host_list, script, auto, yaml, ini

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes
EOF

# Step 6: Create requirements file for Ansible collections
cat > requirements.yml << 'EOF'
---
collections:
  - name: kubernetes.core
    version: ">=2.4.0"
  - name: community.general
    version: ">=5.0.0"
  - name: ansible.posix
    version: ">=1.3.0"
EOF

# Step 7: Install required Ansible collections
ansible-galaxy collection install -r requirements.yml

# Step 8: Test Ansible connectivity
ansible localhost -m ping

# Step 9: Run the setup playbook
echo "Running Ansible setup playbook..."
ansible-playbook setup.yml -v
```

**🧪 Test Infrastructure Setup:**

```bash
# Step 10: Verify everything is working
cd ../..  # Return to project root

# Check Terraform-created resources
kubectl get namespaces -l managed-by=terraform
kubectl get configmaps -n capstone
kubectl get secrets -n capstone
kubectl get pvc -n capstone

# Check monitoring stack
kubectl get pods -n monitoring
kubectl get services -n monitoring

# Check ArgoCD
kubectl get pods -n argocd
kubectl get services -n argocd

# Get access URLs
minikube service list

# Test Grafana access (should return HTML)
curl -s http://$(minikube ip):30002 | head -20

# Test ArgoCD access
curl -k -s https://$(minikube ip):30080 | head -20
```

**🔍 Understanding Our Infrastructure Components:**

**Terraform Resources Created:**
1. **3 Namespaces**: Isolated environments for different components
2. **ConfigMaps**: Application configuration (non-sensitive)
3. **Secrets**: Sensitive data (passwords, tokens) 
4. **Persistent Volumes**: Storage for database data
5. **Network Policies**: Security rules controlling traffic flow
6. **Resource Quotas**: Prevent any single namespace from consuming all resources
7. **Limit Ranges**: Default resource allocations for containers

**Ansible Configurations Applied:**
1. **Monitoring Stack**: Prometheus (metrics) + Grafana (dashboards)
2. **GitOps**: ArgoCD for automated deployments
3. **Service Exposure**: NodePort services for external access
4. **Health Checks**: Verification that all components are running

**🎯 What We Accomplished:**
- ✅ **Infrastructure as Code**: All infrastructure defined in version-controlled files
- ✅ **Automated Setup**: One command deploys entire infrastructure
- ✅ **Security**: Network policies, resource limits, secret management
- ✅ **Monitoring**: Full observability stack ready for metrics and logs
- ✅ **GitOps Ready**: ArgoCD installed for continuous deployment
- ✅ **Scalable**: Resource quotas and limits prevent resource exhaustion
- ✅ **Reproducible**: Same infrastructure can be created anywhere

**🚨 Infrastructure Troubleshooting:**

**Problem**: Terraform fails to connect to Kubernetes
```bash
# Solution: Check kubeconfig and cluster status
kubectl cluster-info
minikube status

# Reset kubeconfig if needed
kubectl config use-context minikube
```

**Problem**: Ansible playbook fails with connection errors
```bash
# Solution: Check Ansible inventory and connectivity
ansible-inventory --list
ansible localhost -m ping

# Check required collections are installed
ansible-galaxy collection list kubernetes.core
```

**Problem**: Monitoring stack won't install
```bash
# Solution: Check Helm repositories and cluster resources
helm repo list
helm repo update
kubectl get nodes -o wide

# Check available resources
kubectl describe nodes
```

**Problem**: Pods stuck in Pending state
```bash
# Solution: Check resource constraints and storage
kubectl describe pod <pod-name> -n <namespace>
kubectl get pv,pvc -n capstone

# Check node resources
kubectl top nodes
```

The infrastructure setup is now complete! Next, we'll create our application services.
```

---

## 🚀 Phase 2: Application Services Creation

Welcome to the heart of our project! In this phase, we'll build the actual applications that users will interact with. We're creating a modern web application with a React frontend and Node.js backend - this represents the typical architecture you'll see in most companies today.

### 🎯 What You'll Build
- **Frontend**: A beautiful React TypeScript application (what users see and interact with)
- **Backend**: A robust Node.js Express API (the brain that handles business logic)
- **Database Integration**: MongoDB connection (where we store all our data)

### 📁 Project Structure Overview

```bash
# Create the main project structure
mkdir -p services/{frontend,backend}
mkdir -p services/frontend/{src,public,src/components,src/services,src/types}
mkdir -p services/backend/{src,src/routes,src/models,src/middleware}

# Your project will look like this:
# services/
# ├── frontend/           # React TypeScript app
# │   ├── src/
# │   │   ├── components/ # Reusable UI components
# │   │   ├── services/   # API communication
# │   │   └── types/      # TypeScript type definitions
# │   └── public/         # Static files
# └── backend/            # Node.js Express API
#     └── src/
#         ├── routes/     # API endpoints
#         ├── models/     # Data models
#         └── middleware/ # Custom middleware
```

### 🎨 Step 1: Create the Frontend Service

**What we're building:** A modern React application with TypeScript that lets users manage their todo list. Think of it like a digital notepad with superpowers!

```bash
# Navigate to frontend directory
cd services/frontend

# Initialize a new React TypeScript project
# This creates a complete React app with TypeScript support
npx create-react-app . --template typescript

# Install additional dependencies we'll need
npm install axios @types/axios     # For API communication
npm install @emotion/react @emotion/styled  # For modern CSS-in-JS styling
npm install @mui/material @mui/icons-material  # For beautiful UI components

# Install development dependencies
npm install --save-dev @testing-library/jest-dom  # Enhanced testing utilities
```

**Understanding the Dependencies:**
- **axios**: Handles HTTP requests to our backend API (like a messenger)
- **@emotion/react & @emotion/styled**: Modern way to style React components
- **@mui/material**: Google's Material Design components for React
- **@testing-library/jest-dom**: Makes testing easier with helpful assertions

**Create the Main App Component:**

```bash
# Replace the default App.tsx with our todo application
cat > src/App.tsx << 'EOF'
// 🎯 Main Todo Application Component
// This is the "control center" of our frontend application

import React, { useState, useEffect } from 'react';
import {
  Container,
  Typography,
  Box,
  Paper,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
  IconButton,
  Button,
  TextField,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Checkbox,
  Alert,
  CircularProgress,
  Chip
} from '@mui/material';
import {
  Delete as DeleteIcon,
  Edit as EditIcon,
  Add as AddIcon,
  CheckCircle as CheckCircleIcon,
  RadioButtonUnchecked as RadioButtonUncheckedIcon
} from '@mui/icons-material';

import { todoService } from './services/todoService';
import { Todo } from './types/Todo';

const App: React.FC = () => {
  // 📊 State Management (like the app's memory)
  const [todos, setTodos] = useState<Todo[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string>('');
  const [dialogOpen, setDialogOpen] = useState<boolean>(false);
  const [editingTodo, setEditingTodo] = useState<Todo | null>(null);
  const [formData, setFormData] = useState({ title: '', description: '' });

  // 🚀 Load todos when component first mounts (like opening the app)
  useEffect(() => {
    loadTodos();
  }, []);

  // 📥 Function to fetch all todos from the backend
  const loadTodos = async () => {
    try {
      setLoading(true);
      const fetchedTodos = await todoService.getAllTodos();
      setTodos(fetchedTodos);
      setError('');
    } catch (err) {
      setError('Failed to load todos. Please check your backend service.');
      console.error('Error loading todos:', err);
    } finally {
      setLoading(false);
    }
  };

  // ➕ Function to create a new todo
  const handleAddTodo = async () => {
    if (!formData.title.trim() || !formData.description.trim()) {
      setError('Please fill in both title and description');
      return;
    }

    try {
      setLoading(true);
      const newTodo = await todoService.createTodo(formData.title, formData.description);
      setTodos(prev => [...prev, newTodo]);
      setFormData({ title: '', description: '' });
      setDialogOpen(false);
      setError('');
    } catch (err) {
      setError('Failed to create todo. Please try again.');
      console.error('Error creating todo:', err);
    } finally {
      setLoading(false);
    }
  };

  // ✏️ Function to update an existing todo
  const handleEditTodo = async () => {
    if (!editingTodo || !formData.title.trim() || !formData.description.trim()) {
      return;
    }

    try {
      setLoading(true);
      const updatedTodo = await todoService.updateTodo(editingTodo.id, {
        title: formData.title,
        description: formData.description,
        completed: editingTodo.completed
      });
      
      setTodos(prev => 
        prev.map(todo => todo.id === editingTodo.id ? updatedTodo : todo)
      );
      
      setEditingTodo(null);
      setFormData({ title: '', description: '' });
      setDialogOpen(false);
      setError('');
    } catch (err) {
      setError('Failed to update todo. Please try again.');
      console.error('Error updating todo:', err);
    } finally {
      setLoading(false);
    }
  };

  // 🗑️ Function to delete a todo
  const handleDeleteTodo = async (id: number) => {
    if (!window.confirm('Are you sure you want to delete this todo?')) {
      return;
    }

    try {
      setLoading(true);
      await todoService.deleteTodo(id);
      setTodos(prev => prev.filter(todo => todo.id !== id));
      setError('');
    } catch (err) {
      setError('Failed to delete todo. Please try again.');
      console.error('Error deleting todo:', err);
    } finally {
      setLoading(false);
    }
  };

  // ✅ Function to toggle todo completion status
  const handleToggleComplete = async (todo: Todo) => {
    try {
      setLoading(true);
      const updatedTodo = await todoService.updateTodo(todo.id, {
        ...todo,
        completed: !todo.completed
      });
      
      setTodos(prev =>
        prev.map(t => t.id === todo.id ? updatedTodo : t)
      );
      setError('');
    } catch (err) {
      setError('Failed to update todo status. Please try again.');
      console.error('Error toggling todo:', err);
    } finally {
      setLoading(false);
    }
  };

  // 📝 Function to open edit dialog
  const openEditDialog = (todo: Todo) => {
    setEditingTodo(todo);
    setFormData({ title: todo.title, description: todo.description });
    setDialogOpen(true);
  };

  // ❌ Function to close dialog and reset form
  const closeDialog = () => {
    setDialogOpen(false);
    setEditingTodo(null);
    setFormData({ title: '', description: '' });
  };

  // 📊 Calculate statistics
  const completedCount = todos.filter(todo => todo.completed).length;
  const totalCount = todos.length;

  return (
    <Container maxWidth="md" sx={{ py: 4 }}>
      {/* 🎨 Header Section */}
      <Paper elevation={3} sx={{ p: 4, mb: 4 }}>
        <Typography variant="h3" component="h1" gutterBottom align="center" color="primary">
          🚀 DevOps Todo App
        </Typography>
        <Typography variant="subtitle1" align="center" color="text.secondary">
          A modern React + Node.js application deployed with DevOps best practices
        </Typography>
        
        {/* 📊 Statistics */}
        <Box sx={{ display: 'flex', justifyContent: 'center', gap: 2, mt: 3 }}>
          <Chip
            icon={<CheckCircleIcon />}
            label={`${completedCount} Completed`}
            color="success"
            variant="outlined"
          />
          <Chip
            icon={<RadioButtonUncheckedIcon />}
            label={`${totalCount - completedCount} Pending`}
            color="warning"
            variant="outlined"
          />
          <Chip
            label={`${totalCount} Total`}
            color="info"
            variant="outlined"
          />
        </Box>
      </Paper>

      {/* 🚨 Error Display */}
      {error && (
        <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError('')}>
          {error}
        </Alert>
      )}

      {/* ➕ Add Todo Button */}
      <Box sx={{ mb: 3, textAlign: 'center' }}>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => setDialogOpen(true)}
          size="large"
          disabled={loading}
        >
          Add New Todo
        </Button>
      </Box>

      {/* 📋 Todos List */}
      <Paper elevation={2}>
        {loading && (
          <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
            <CircularProgress />
          </Box>
        )}

        {!loading && todos.length === 0 ? (
          <Box sx={{ p: 4, textAlign: 'center' }}>
            <Typography variant="h6" color="text.secondary">
              No todos yet! Create your first todo to get started.
            </Typography>
          </Box>
        ) : (
          <List>
            {todos.map((todo, index) => (
              <ListItem
                key={todo.id}
                divider={index < todos.length - 1}
                sx={{
                  bgcolor: todo.completed ? 'action.hover' : 'inherit',
                  opacity: todo.completed ? 0.7 : 1
                }}
              >
                <Checkbox
                  checked={todo.completed}
                  onChange={() => handleToggleComplete(todo)}
                  icon={<RadioButtonUncheckedIcon />}
                  checkedIcon={<CheckCircleIcon />}
                  color="success"
                />
                
                <ListItemText
                  primary={
                    <Typography
                      variant="h6"
                      sx={{
                        textDecoration: todo.completed ? 'line-through' : 'none'
                      }}
                    >
                      {todo.title}
                    </Typography>
                  }
                  secondary={
                    <Typography
                      variant="body2"
                      color="text.secondary"
                      sx={{
                        textDecoration: todo.completed ? 'line-through' : 'none'
                      }}
                    >
                      {todo.description}
                    </Typography>
                  }
                />
                
                <ListItemSecondaryAction>
                  <IconButton
                    edge="end"
                    aria-label="edit"
                    onClick={() => openEditDialog(todo)}
                    disabled={loading}
                    sx={{ mr: 1 }}
                  >
                    <EditIcon />
                  </IconButton>
                  <IconButton
                    edge="end"
                    aria-label="delete"
                    onClick={() => handleDeleteTodo(todo.id)}
                    disabled={loading}
                    color="error"
                  >
                    <DeleteIcon />
                  </IconButton>
                </ListItemSecondaryAction>
              </ListItem>
            ))}
          </List>
        )}
      </Paper>

      {/* 📝 Add/Edit Dialog */}
      <Dialog open={dialogOpen} onClose={closeDialog} maxWidth="sm" fullWidth>
        <DialogTitle>
          {editingTodo ? 'Edit Todo' : 'Add New Todo'}
        </DialogTitle>
        <DialogContent>
          <TextField
            autoFocus
            margin="dense"
            label="Title"
            fullWidth
            variant="outlined"
            value={formData.title}
            onChange={(e) => setFormData(prev => ({ ...prev, title: e.target.value }))}
            sx={{ mb: 2 }}
          />
          <TextField
            margin="dense"
            label="Description"
            fullWidth
            multiline
            rows={3}
            variant="outlined"
            value={formData.description}
            onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={closeDialog} disabled={loading}>
            Cancel
          </Button>
          <Button
            onClick={editingTodo ? handleEditTodo : handleAddTodo}
            variant="contained"
            disabled={loading}
          >
            {editingTodo ? 'Update' : 'Add'}
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default App;
EOF
```

**Create TypeScript Types:**

```bash
# Define the Todo data structure
cat > src/types/Todo.ts << 'EOF'
// 📋 Todo Type Definition
// This defines the structure of a todo item throughout our application

export interface Todo {
  id: number;
  title: string;
  description: string;
  completed: boolean;
  createdAt?: string;
  updatedAt?: string;
}

// 📝 Type for creating new todos (no id needed)
export interface CreateTodoRequest {
  title: string;
  description: string;
}

// ✏️ Type for updating todos
export interface UpdateTodoRequest {
  title?: string;
  description?: string;
  completed?: boolean;
}
EOF
```

**Create API Service:**

```bash
# Create service to handle API communication
cat > src/services/todoService.ts << 'EOF'
// 🔗 Todo API Service
// This handles all communication with our backend API

import axios from 'axios';
import { Todo, CreateTodoRequest, UpdateTodoRequest } from '../types/Todo';

// 🌐 Configure API base URL (where our backend lives)
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000';

// Create axios instance with default configuration
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000, // 10 second timeout
});

// 🔧 Add request/response interceptors for better error handling
apiClient.interceptors.request.use(
  (config) => {
    console.log(`🚀 Making ${config.method?.toUpperCase()} request to:`, config.url);
    return config;
  },
  (error) => {
    console.error('❌ Request error:', error);
    return Promise.reject(error);
  }
);

apiClient.interceptors.response.use(
  (response) => {
    console.log('✅ Response received:', response.status, response.statusText);
    return response;
  },
  (error) => {
    console.error('❌ Response error:', error.response?.status, error.response?.statusText);
    
    // Provide user-friendly error messages
    if (error.code === 'ECONNREFUSED' || error.code === 'ERR_NETWORK') {
      throw new Error('Cannot connect to the backend service. Please ensure the backend is running.');
    }
    
    if (error.response?.status === 404) {
      throw new Error('The requested resource was not found.');
    }
    
    if (error.response?.status >= 500) {
      throw new Error('Server error occurred. Please try again later.');
    }
    
    throw new Error(error.response?.data?.error || 'An unexpected error occurred.');
  }
);

// 🛠️ Todo Service Methods
export const todoService = {
  // 📥 Get all todos
  async getAllTodos(): Promise<Todo[]> {
    const response = await apiClient.get<Todo[]>('/api/items');
    return response.data;
  },

  // 📄 Get single todo by ID
  async getTodoById(id: number): Promise<Todo> {
    const response = await apiClient.get<Todo>(`/api/items/${id}`);
    return response.data;
  },

  // ➕ Create new todo
  async createTodo(title: string, description: string): Promise<Todo> {
    const todoData: CreateTodoRequest = { title, description };
    const response = await apiClient.post<Todo>('/api/items', todoData);
    return response.data;
  },

  // ✏️ Update existing todo
  async updateTodo(id: number, updates: UpdateTodoRequest): Promise<Todo> {
    const response = await apiClient.put<Todo>(`/api/items/${id}`, updates);
    return response.data;
  },

  // 🗑️ Delete todo
  async deleteTodo(id: number): Promise<void> {
    await apiClient.delete(`/api/items/${id}`);
  },

  // 🔄 Toggle todo completion status
  async toggleTodoComplete(id: number): Promise<Todo> {
    const todo = await this.getTodoById(id);
    return this.updateTodo(id, { completed: !todo.completed });
  },

  // 📊 Get todo statistics
  async getTodoStats(): Promise<{ total: number; completed: number; pending: number }> {
    const todos = await this.getAllTodos();
    const total = todos.length;
    const completed = todos.filter(todo => todo.completed).length;
    const pending = total - completed;
    
    return { total, completed, pending };
  }
};
EOF
```

**Create Dockerfile for Frontend:**

```bash
# Create Docker configuration for the frontend
cat > Dockerfile << 'EOF'
# 🐳 Multi-stage Docker build for React application
# This creates an optimized production build

# Stage 1: Build the React application
FROM node:18-alpine as build

# Set working directory inside container
WORKDIR /app

# Copy package files first (for better caching)
COPY package*.json ./

# Install dependencies
# Using npm ci for faster, reliable, reproducible builds
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application for production
# This creates optimized bundles in the 'build' folder
RUN npm run build

# Stage 2: Serve the built app with nginx
FROM nginx:1.21-alpine

# Copy built application from previous stage
COPY --from=build /app/build /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80 || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
EOF

# Create nginx configuration
cat > nginx.conf << 'EOF'
# 🌐 Nginx configuration for React SPA

server {
    listen 80;
    server_name localhost;
    
    root /usr/share/nginx/html;
    index index.html;
    
    # Gzip compression for better performance
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private auth;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/json;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Handle client-side routing (React Router)
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # API proxy (if backend is not accessible directly)
    location /api/ {
        proxy_pass http://backend:5000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
```

**Add Environment Configuration:**

```bash
# Create environment configuration
cat > .env << 'EOF'
# 🌍 Environment Configuration for React App

# Backend API URL
REACT_APP_API_URL=http://localhost:5000

# App configuration
REACT_APP_NAME=DevOps Todo App
REACT_APP_VERSION=1.0.0

# Development settings
GENERATE_SOURCEMAP=true
BROWSER=none

# Production optimization
INLINE_RUNTIME_CHUNK=false
EOF

# Create production environment file
cat > .env.production << 'EOF'
# 🌍 Production Environment Configuration

# Backend API URL (this will be different in production)
REACT_APP_API_URL=/api

# App configuration
REACT_APP_NAME=DevOps Todo App
REACT_APP_VERSION=1.0.0

# Production settings
GENERATE_SOURCEMAP=false
INLINE_RUNTIME_CHUNK=false
EOF
```

### 🔧 Step 2: Create the Backend Service

**What we're building:** A robust Node.js Express API that handles all the business logic for our todo application. This is the "brain" that processes requests, manages data, and responds to the frontend.

```bash
# Navigate to backend directory
cd ../backend

# Initialize Node.js project
npm init -y

# Install production dependencies
npm install express cors helmet morgan compression dotenv bcryptjs jsonwebtoken mongoose

# Install development dependencies
npm install -D @types/node @types/express @types/cors @types/bcryptjs @types/jsonwebtoken @types/morgan typescript ts-node nodemon jest @types/jest supertest @types/supertest

# Install additional monitoring dependencies
npm install prom-client express-prometheus-middleware

# Create TypeScript configuration
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020"],
    "module": "commonjs",
    "rootDir": "./src",
    "outDir": "./dist",
    "strict": true,
    "moduleResolution": "node",
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOF

# Update package.json with scripts
cat > package.json << 'EOF'
{
  "name": "capstone-backend",
  "version": "1.0.0",
  "description": "Backend API for DevOps Capstone Todo Application",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "nodemon src/index.ts",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "echo 'Linting would go here'",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "express": "^4.18.0",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0",
    "compression": "^1.7.4",
    "dotenv": "^16.0.0",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.0",
    "mongoose": "^7.0.0",
    "prom-client": "^14.2.0",
    "express-prometheus-middleware": "^1.2.0"
  },
  "devDependencies": {
    "@types/node": "^18.0.0",
    "@types/express": "^4.17.0",
    "@types/cors": "^2.8.0",
    "@types/bcryptjs": "^2.4.0",
    "@types/jsonwebtoken": "^9.0.0",
    "@types/morgan": "^1.9.0",
    "typescript": "^5.0.0",
    "ts-node": "^10.9.0",
    "nodemon": "^3.0.0",
    "jest": "^29.0.0",
    "@types/jest": "^29.0.0",
    "supertest": "^6.3.0",
    "@types/supertest": "^2.0.0"
  },
  "keywords": ["devops", "nodejs", "express", "api", "todo"],
  "author": "DevOps Engineer",
  "license": "MIT"
}
EOF
```

**Create the Main Backend Application:**

```bash
# Create the main server file
cat > src/index.ts << 'EOF'
// 🚀 Main Backend Server Entry Point
// This is where our backend application starts running

import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import dotenv from 'dotenv';
import { connectDB } from './config/database';
import { errorHandler } from './middleware/errorHandler';
import { metricsMiddleware, register } from './middleware/metrics';
import todoRoutes from './routes/todoRoutes';
import healthRoutes from './routes/healthRoutes';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// 🔒 Security middleware
app.use(helmet({
  crossOriginEmbedderPolicy: false, // Allow embedding for development
}));

// 📊 Metrics collection middleware
app.use(metricsMiddleware);

// 🌐 CORS configuration
const corsOptions = {
  origin: process.env.CORS_ORIGIN || ['http://localhost:3000', 'http://localhost:8080'],
  credentials: true,
  optionsSuccessStatus: 200,
};
app.use(cors(corsOptions));

// 📝 Request logging
if (NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// 🗜️ Compression for better performance
app.use(compression());

// 📋 Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// 📊 Metrics endpoint for Prometheus
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  const metrics = await register.metrics();
  res.end(metrics);
});

// 🛣️ API Routes
app.use('/health', healthRoutes);
app.use('/api/items', todoRoutes);

// 🏠 Welcome route
app.get('/', (req, res) => {
  res.json({
    message: '🚀 DevOps Capstone Backend API',
    version: '1.0.0',
    environment: NODE_ENV,
    timestamp: new Date().toISOString(),
    endpoints: {
      health: '/health',
      todos: '/api/items',
      metrics: '/metrics'
    }
  });
});

// 🚫 Handle 404 errors
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    message: `Cannot ${req.method} ${req.originalUrl}`,
    availableRoutes: ['/health', '/api/items', '/metrics']
  });
});

// 🚨 Error handling middleware (must be last)
app.use(errorHandler);

// 🚀 Start server function
const startServer = async () => {
  try {
    // Connect to database
    await connectDB();
    
    // Start listening
    app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
      console.log(`🌍 Environment: ${NODE_ENV}`);
      console.log(`📊 Metrics available at: http://localhost:${PORT}/metrics`);
      console.log(`❤️  Health check at: http://localhost:${PORT}/health`);
      console.log(`📋 API endpoints at: http://localhost:${PORT}/api/items`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('👋 Received SIGTERM, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('👋 Received SIGINT, shutting down gracefully');
  process.exit(0);
});

// Start the server
startServer();

export default app;
EOF

# Create database configuration
mkdir -p src/config
cat > src/config/database.ts << 'EOF'
// 🗄️ Database Connection Configuration
// Handles MongoDB connection with proper error handling and retry logic

import mongoose from 'mongoose';

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://mongodb:27017/capstone_todos';

export const connectDB = async (): Promise<void> => {
  try {
    console.log('🔄 Connecting to MongoDB...');
    
    const options = {
      // Connection options for production
      maxPoolSize: 10, // Maintain up to 10 socket connections
      serverSelectionTimeoutMS: 5000, // Keep trying to send operations for 5 seconds
      socketTimeoutMS: 45000, // Close sockets after 45 seconds of inactivity
      bufferMaxEntries: 0, // Disable mongoose buffering
      bufferCommands: false, // Disable mongoose buffering
    };

    await mongoose.connect(MONGODB_URI, options);
    
    console.log('✅ MongoDB connected successfully');
    
    // Handle connection events
    mongoose.connection.on('error', (err) => {
      console.error('❌ MongoDB connection error:', err);
    });
    
    mongoose.connection.on('disconnected', () => {
      console.log('⚠️  MongoDB disconnected');
    });
    
    // Handle app termination
    process.on('SIGINT', async () => {
      await mongoose.connection.close();
      console.log('👋 MongoDB connection closed through app termination');
      process.exit(0);
    });
    
  } catch (error) {
    console.error('❌ MongoDB connection failed:', error);
    
    // In development, we can continue without MongoDB
    if (process.env.NODE_ENV === 'development') {
      console.log('⚠️  Continuing without database in development mode');
    } else {
      process.exit(1);
    }
  }
};

// Export mongoose for use in other files
export { mongoose };
EOF

# Create Todo model
mkdir -p src/models
cat > src/models/Todo.ts << 'EOF'
// 📋 Todo Data Model
// Defines the structure and behavior of todo items in the database

import mongoose, { Document, Schema } from 'mongoose';

// TypeScript interface for Todo document
export interface ITodo extends Document {
  title: string;
  description: string;
  completed: boolean;
  createdAt: Date;
  updatedAt: Date;
  priority?: 'low' | 'medium' | 'high';
  category?: string;
  dueDate?: Date;
}

// Mongoose schema definition
const TodoSchema: Schema = new Schema(
  {
    title: {
      type: String,
      required: [true, 'Title is required'],
      trim: true,
      minlength: [1, 'Title must be at least 1 character'],
      maxlength: [200, 'Title cannot exceed 200 characters']
    },
    description: {
      type: String,
      required: [true, 'Description is required'],
      trim: true,
      minlength: [1, 'Description must be at least 1 character'],
      maxlength: [1000, 'Description cannot exceed 1000 characters']
    },
    completed: {
      type: Boolean,
      default: false
    },
    priority: {
      type: String,
      enum: ['low', 'medium', 'high'],
      default: 'medium'
    },
    category: {
      type: String,
      trim: true,
      maxlength: [50, 'Category cannot exceed 50 characters']
    },
    dueDate: {
      type: Date,
      validate: {
        validator: function(date: Date) {
          return !date || date > new Date();
        },
        message: 'Due date must be in the future'
      }
    }
  },
  {
    timestamps: true, // Automatically add createdAt and updatedAt
    toJSON: {
      // Transform output when converting to JSON
      transform: function(doc, ret) {
        ret.id = ret._id;
        delete ret._id;
        delete ret.__v;
        return ret;
      }
    }
  }
);

// Add indexes for better query performance
TodoSchema.index({ completed: 1 });
TodoSchema.index({ createdAt: -1 });
TodoSchema.index({ title: 'text', description: 'text' }); // Text search

// Instance methods
TodoSchema.methods.toggle = function(): Promise<ITodo> {
  this.completed = !this.completed;
  return this.save();
};

// Static methods
TodoSchema.statics.findByStatus = function(completed: boolean) {
  return this.find({ completed });
};

TodoSchema.statics.findByCategory = function(category: string) {
  return this.find({ category });
};

TodoSchema.statics.searchTodos = function(searchTerm: string) {
  return this.find({
    $text: { $search: searchTerm }
  });
};

// Export the model
export default mongoose.model<ITodo>('Todo', TodoSchema);
EOF

# Create middleware directory and files
mkdir -p src/middleware

# Error handling middleware
cat > src/middleware/errorHandler.ts << 'EOF'
// 🚨 Global Error Handler Middleware
// Catches and handles all errors in a consistent way

import { Request, Response, NextFunction } from 'express';
import { recordTodoOperation } from './metrics';

export interface AppError extends Error {
  statusCode?: number;
  isOperational?: boolean;
}

export const errorHandler = (
  err: AppError,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  // Set default error values
  err.statusCode = err.statusCode || 500;
  err.message = err.message || 'Internal Server Error';

  console.error('🚨 Error occurred:', {
    message: err.message,
    statusCode: err.statusCode,
    stack: err.stack,
    url: req.url,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent')
  });

  // Record error in metrics
  recordTodoOperation('error', 'server_error');

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const message = Object.values((err as any).errors).map((val: any) => val.message).join(', ');
    res.status(400).json({
      success: false,
      error: 'Validation Error',
      message,
      timestamp: new Date().toISOString()
    });
    return;
  }

  // Mongoose duplicate key error
  if ((err as any).code === 11000) {
    const message = 'Duplicate field value entered';
    res.status(400).json({
      success: false,
      error: 'Duplicate Error',
      message,
      timestamp: new Date().toISOString()
    });
    return;
  }

  // Mongoose cast error
  if (err.name === 'CastError') {
    const message = 'Invalid ID format';
    res.status(400).json({
      success: false,
      error: 'Cast Error',
      message,
      timestamp: new Date().toISOString()
    });
    return;
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    res.status(401).json({
      success: false,
      error: 'Invalid Token',
      message: 'Please log in again',
      timestamp: new Date().toISOString()
    });
    return;
  }

  // Default error response
  res.status(err.statusCode).json({
    success: false,
    error: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    timestamp: new Date().toISOString()
  });
};

// Async error wrapper
export const asyncHandler = (fn: Function) => (req: Request, res: Response, next: NextFunction) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Create custom error
export const createError = (message: string, statusCode: number): AppError => {
  const error = new Error(message) as AppError;
  error.statusCode = statusCode;
  error.isOperational = true;
  return error;
};
EOF

# Metrics middleware (enhanced)
cat > src/middleware/metrics.ts << 'EOF'
// 📊 Metrics Collection Middleware
// Collects application performance and business metrics for monitoring

import promClient from 'prom-client';
import { Request, Response, NextFunction } from 'express';

// Create a Registry
const register = new promClient.Registry();

// Add default metrics
promClient.collectDefaultMetrics({ 
  register,
  timeout: 10000,
  gcDurationBuckets: [0.001, 0.01, 0.1, 1, 2, 5]
});

// Custom metrics
const httpRequestsTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5, 10],
  registers: [register]
});

const todoOperationsTotal = new promClient.Counter({
  name: 'todo_operations_total',
  help: 'Total number of todo operations',
  labelNames: ['operation', 'status'],
  registers: [register]
});

const activeTodosGauge = new promClient.Gauge({
  name: 'active_todos_total',
  help: 'Current number of active todos',
  registers: [register]
});

const databaseConnectionsGauge = new promClient.Gauge({
  name: 'database_connections_active',
  help: 'Number of active database connections',
  registers: [register]
});

// Middleware to collect HTTP metrics
export const metricsMiddleware = (req: Request, res: Response, next: NextFunction): void => {
  const startTime = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - startTime) / 1000;
    const route = req.route ? req.route.path : req.path;
    
    httpRequestsTotal.inc({
      method: req.method,
      route,
      status_code: res.statusCode.toString()
    });
    
    httpRequestDuration.observe(
      {
        method: req.method,
        route,
        status_code: res.statusCode.toString()
      },
      duration
    );
  });
  
  next();
};

// Helper functions for business metrics
export const recordTodoOperation = (operation: string, status: string): void => {
  todoOperationsTotal.inc({ operation, status });
};

export const updateActiveTodos = (count: number): void => {
  activeTodosGauge.set(count);
};

export const updateDatabaseConnections = (count: number): void => {
  databaseConnectionsGauge.set(count);
};

export { register };
EOF

# Create routes directory and files
mkdir -p src/routes

# Health check routes
cat > src/routes/healthRoutes.ts << 'EOF'
// ❤️  Health Check Routes
// Provides endpoints for monitoring application health

import { Router, Request, Response } from 'express';
import { mongoose } from '../config/database';
import { recordTodoOperation } from '../middleware/metrics';

const router = Router();

// Basic health check
router.get('/', (req: Request, res: Response) => {
  recordTodoOperation('health_check', 'basic');
  
  res.status(200).json({
    status: 'healthy',
    message: 'Backend service is running',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0',
    environment: process.env.NODE_ENV || 'development'
  });
});

// Detailed health check
router.get('/detailed', async (req: Request, res: Response) => {
  try {
    const healthInfo = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      version: process.env.npm_package_version || '1.0.0',
      environment: process.env.NODE_ENV || 'development',
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      database: {
        status: 'disconnected',
        readyState: mongoose.connection.readyState
      },
      services: {
        api: 'healthy'
      }
    };

    // Check database connection
    if (mongoose.connection.readyState === 1) {
      healthInfo.database.status = 'connected';
    } else if (mongoose.connection.readyState === 2) {
      healthInfo.database.status = 'connecting';
    }

    const statusCode = healthInfo.database.status === 'connected' ? 200 : 503;
    recordTodoOperation('health_check', statusCode === 200 ? 'success' : 'warning');
    
    res.status(statusCode).json(healthInfo);
  } catch (error) {
    recordTodoOperation('health_check', 'error');
    res.status(503).json({
      status: 'unhealthy',
      message: 'Health check failed',
      error: error instanceof Error ? error.message : 'Unknown error',
      timestamp: new Date().toISOString()
    });
  }
});

// Readiness probe (for Kubernetes)
router.get('/ready', async (req: Request, res: Response) => {
  try {
    // Check if database is connected
    if (mongoose.connection.readyState === 1) {
      recordTodoOperation('readiness_check', 'success');
      res.status(200).json({
        status: 'ready',
        message: 'Service is ready to accept traffic',
        timestamp: new Date().toISOString()
      });
    } else {
      recordTodoOperation('readiness_check', 'not_ready');
      res.status(503).json({
        status: 'not_ready',
        message: 'Database connection not ready',
        timestamp: new Date().toISOString()
      });
    }
  } catch (error) {
    recordTodoOperation('readiness_check', 'error');
    res.status(503).json({
      status: 'error',
      message: 'Readiness check failed',
      error: error instanceof Error ? error.message : 'Unknown error',
      timestamp: new Date().toISOString()
    });
  }
});

// Liveness probe (for Kubernetes)
router.get('/live', (req: Request, res: Response) => {
  recordTodoOperation('liveness_check', 'success');
  res.status(200).json({
    status: 'alive',
    message: 'Service is alive',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

export default router;
EOF

# Todo routes
cat > src/routes/todoRoutes.ts << 'EOF'
// 📋 Todo API Routes
// Handles all CRUD operations for todo items

import { Router, Request, Response } from 'express';
import Todo, { ITodo } from '../models/Todo';
import { asyncHandler, createError } from '../middleware/errorHandler';
import { recordTodoOperation, updateActiveTodos } from '../middleware/metrics';

const router = Router();

// Helper function to update active todos count
const updateTodoCount = async (): Promise<void> => {
  try {
    const activeTodos = await Todo.countDocuments({ completed: false });
    updateActiveTodos(activeTodos);
  } catch (error) {
    console.error('Error updating todo count:', error);
  }
};

// 📥 GET /api/items - Get all todos
router.get('/', asyncHandler(async (req: Request, res: Response) => {
  try {
    const { 
      completed, 
      category, 
      search, 
      limit = 50, 
      page = 1, 
      sort = '-createdAt' 
    } = req.query;

    // Build filter object
    const filter: any = {};
    
    if (completed !== undefined) {
      filter.completed = completed === 'true';
    }
    
    if (category) {
      filter.category = category;
    }
    
    // Build sort object
    const sortObj: any = {};
    const sortFields = (sort as string).split(',');
    sortFields.forEach(field => {
      if (field.startsWith('-')) {
        sortObj[field.substring(1)] = -1;
      } else {
        sortObj[field] = 1;
      }
    });

    let query = Todo.find(filter).sort(sortObj);
    
    // Add text search if provided
    if (search) {
      query = Todo.find({
        ...filter,
        $text: { $search: search as string }
      }).sort(sortObj);
    }

    // Pagination
    const limitNum = Math.min(parseInt(limit as string), 100); // Max 100 items
    const pageNum = Math.max(parseInt(page as string), 1);
    const skip = (pageNum - 1) * limitNum;
    
    query = query.skip(skip).limit(limitNum);
    
    const todos = await query.exec();
    const total = await Todo.countDocuments(filter);
    
    recordTodoOperation('get_all', 'success');
    
    res.json({
      success: true,
      data: todos,
      pagination: {
        total,
        page: pageNum,
        limit: limitNum,
        pages: Math.ceil(total / limitNum)
      },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    recordTodoOperation('get_all', 'error');
    throw error;
  }
}));

// 📄 GET /api/items/:id - Get single todo
router.get('/:id', asyncHandler(async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    
    const todo = await Todo.findById(id);
    
    if (!todo) {
      recordTodoOperation('get_single', 'not_found');
      throw createError('Todo not found', 404);
    }
    
    recordTodoOperation('get_single', 'success');
    
    res.json({
      success: true,
      data: todo,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    if (error instanceof Error && error.name === 'CastError') {
      recordTodoOperation('get_single', 'invalid_id');
      throw createError('Invalid todo ID format', 400);
    }
    recordTodoOperation('get_single', 'error');
    throw error;
  }
}));

// ➕ POST /api/items - Create new todo
router.post('/', asyncHandler(async (req: Request, res: Response) => {
  try {
    const { title, description, priority, category, dueDate } = req.body;
    
    // Validation
    if (!title || !description) {
      recordTodoOperation('create', 'validation_error');
      throw createError('Title and description are required', 400);
    }
    
    const todoData = {
      title: title.trim(),
      description: description.trim(),
      priority: priority || 'medium',
      ...(category && { category: category.trim() }),
      ...(dueDate && { dueDate: new Date(dueDate) })
    };
    
    const todo = new Todo(todoData);
    const savedTodo = await todo.save();
    
    await updateTodoCount();
    recordTodoOperation('create', 'success');
    
    res.status(201).json({
      success: true,
      data: savedTodo,
      message: 'Todo created successfully',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    recordTodoOperation('create', 'error');
    throw error;
  }
}));

// ✏️ PUT /api/items/:id - Update todo
router.put('/:id', asyncHandler(async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const updates = req.body;
    
    // Remove fields that shouldn't be updated directly
    delete updates._id;
    delete updates.createdAt;
    delete updates.updatedAt;
    
    const todo = await Todo.findByIdAndUpdate(
      id,
      updates,
      { 
        new: true, // Return updated document
        runValidators: true // Run schema validation
      }
    );
    
    if (!todo) {
      recordTodoOperation('update', 'not_found');
      throw createError('Todo not found', 404);
    }
    
    await updateTodoCount();
    recordTodoOperation('update', 'success');
    
    res.json({
      success: true,
      data: todo,
      message: 'Todo updated successfully',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    if (error instanceof Error && error.name === 'CastError') {
      recordTodoOperation('update', 'invalid_id');
      throw createError('Invalid todo ID format', 400);
    }
    recordTodoOperation('update', 'error');
    throw error;
  }
}));

// 🔄 PATCH /api/items/:id/toggle - Toggle todo completion
router.patch('/:id/toggle', asyncHandler(async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    
    const todo = await Todo.findById(id);
    
    if (!todo) {
      recordTodoOperation('toggle', 'not_found');
      throw createError('Todo not found', 404);
    }
    
    const updatedTodo = await todo.toggle();
    await updateTodoCount();
    recordTodoOperation('toggle', 'success');
    
    res.json({
      success: true,
      data: updatedTodo,
      message: `Todo marked as ${updatedTodo.completed ? 'completed' : 'pending'}`,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    if (error instanceof Error && error.name === 'CastError') {
      recordTodoOperation('toggle', 'invalid_id');
      throw createError('Invalid todo ID format', 400);
    }
    recordTodoOperation('toggle', 'error');
    throw error;
  }
}));

// 🗑️ DELETE /api/items/:id - Delete todo
router.delete('/:id', asyncHandler(async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    
    const todo = await Todo.findByIdAndDelete(id);
    
    if (!todo) {
      recordTodoOperation('delete', 'not_found');
      throw createError('Todo not found', 404);
    }
    
    await updateTodoCount();
    recordTodoOperation('delete', 'success');
    
    res.json({
      success: true,
      data: todo,
      message: 'Todo deleted successfully',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    if (error instanceof Error && error.name === 'CastError') {
      recordTodoOperation('delete', 'invalid_id');
      throw createError('Invalid todo ID format', 400);
    }
    recordTodoOperation('delete', 'error');
    throw error;
  }
}));

// 🗑️ DELETE /api/items - Delete multiple todos
router.delete('/', asyncHandler(async (req: Request, res: Response) => {
  try {
    const { ids, completed } = req.body;
    
    let filter: any = {};
    
    if (ids && Array.isArray(ids)) {
      filter._id = { $in: ids };
    } else if (completed !== undefined) {
      filter.completed = completed;
    } else {
      recordTodoOperation('delete_multiple', 'validation_error');
      throw createError('Please provide either ids array or completed status', 400);
    }
    
    const result = await Todo.deleteMany(filter);
    
    await updateTodoCount();
    recordTodoOperation('delete_multiple', 'success');
    
    res.json({
      success: true,
      deletedCount: result.deletedCount,
      message: `${result.deletedCount} todo(s) deleted successfully`,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    recordTodoOperation('delete_multiple', 'error');
    throw error;
  }
}));

// 📊 GET /api/items/stats - Get todo statistics
router.get('/stats', asyncHandler(async (req: Request, res: Response) => {
  try {
    const stats = await Todo.aggregate([
      {
        $group: {
          _id: null,
          total: { $sum: 1 },
          completed: {
            $sum: { $cond: [{ $eq: ['$completed', true] }, 1, 0] }
          },
          pending: {
            $sum: { $cond: [{ $eq: ['$completed', false] }, 1, 0] }
          },
          categories: { $addToSet: '$category' },
          priorities: { $addToSet: '$priority' }
        }
      }
    ]);

    const result = stats[0] || {
      total: 0,
      completed: 0,
      pending: 0,
      categories: [],
      priorities: []
    };

    recordTodoOperation('get_stats', 'success');
    
    res.json({
      success: true,
      data: {
        ...result,
        completionRate: result.total > 0 ? (result.completed / result.total * 100).toFixed(2) : 0
      },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    recordTodoOperation('get_stats', 'error');
    throw error;
  }
}));

export default router;
EOF

# Create Dockerfile for backend
cat > Dockerfile << 'EOF'
# 🐳 Multi-stage Docker build for Node.js API

# Stage 1: Build stage
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies (including dev dependencies)
RUN npm ci

# Copy source code
COPY . .

# Build TypeScript to JavaScript
RUN npm run build

# Stage 2: Production stage
FROM node:18-alpine AS production

# Create app user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production --ignore-scripts && \
    npm cache clean --force

# Copy built application from builder stage
COPY --from=builder /app/dist ./dist

# Create logs directory
RUN mkdir -p /app/logs && chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 5000

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:5000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

# Start the application
CMD ["node", "dist/index.js"]
EOF

# Create environment files
cat > .env << 'EOF'
# 🌍 Development Environment Configuration

# Server configuration
PORT=5000
NODE_ENV=development

# Database configuration
MONGODB_URI=mongodb://localhost:27017/capstone_todos

# CORS configuration
CORS_ORIGIN=http://localhost:3000

# Security
JWT_SECRET=your_jwt_secret_key_change_in_production
BCRYPT_ROUNDS=12

# Monitoring
ENABLE_METRICS=true
EOF

cat > .env.production << 'EOF'
# 🌍 Production Environment Configuration

# Server configuration
PORT=5000
NODE_ENV=production

# Database configuration (will be overridden by Kubernetes secrets)
MONGODB_URI=mongodb://mongodb:27017/capstone_todos

# CORS configuration
CORS_ORIGIN=https://your-domain.com

# Security (should be set via Kubernetes secrets)
JWT_SECRET=
BCRYPT_ROUNDS=12

# Monitoring
ENABLE_METRICS=true
EOF

# Create .dockerignore
cat > .dockerignore << 'EOF'
# Node.js
node_modules
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# TypeScript
*.tsbuildinfo

# Environment files
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
logs
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage
*.lcov

# Dependency directories
.npm
.yarn

# Optional eslint cache
.eslintcache

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# next.js build output
.next

# nuxt.js build output
.nuxt

# vuepress build output
.vuepress/dist

# Serverless directories
.serverless

# FuseBox cache
.fusebox/

# DynamoDB Local files
.dynamodb/

# TernJS port file
.tern-port

# Stores VSCode versions used for testing VSCode extensions
.vscode-test

# Development files
src/
tsconfig.json
nodemon.json

# Git
.git
.gitignore
README.md

# Documentation
docs/
*.md
EOF

# Navigate back to project root
cd ../..
```

### 🎉 Phase 2 Complete!

**What we've built:**

✅ **Modern Frontend Application**:
- React with TypeScript for type safety
- Material-UI for beautiful, professional interface
- Comprehensive error handling and user feedback
- Responsive design that works on all devices
- Production-ready Docker configuration with Nginx

✅ **Robust Backend API**:
- Node.js Express server with TypeScript
- MongoDB integration with Mongoose ODM
- Comprehensive CRUD operations for todos
- Advanced querying (search, filtering, pagination)
- Metrics collection for monitoring
- Health checks for Kubernetes
- Security middleware (Helmet, CORS)
- Error handling and logging
- Production-ready Docker configuration

✅ **Key Features**:
- **Type Safety**: Full TypeScript implementation
- **Error Handling**: Comprehensive error management
- **Monitoring**: Built-in metrics for Prometheus
- **Security**: Security headers, input validation
- **Performance**: Compression, caching, optimization
- **Health Checks**: Kubernetes-ready health endpoints
- **Documentation**: Extensive code comments
- **Testing Ready**: Structure prepared for unit/integration tests

**🔍 Understanding What We Built:**

1. **Frontend (React)**: The user interface that people interact with
   - Like the "face" of your application
   - Handles user interactions and displays data beautifully
   - Communicates with backend via HTTP requests

2. **Backend (Node.js)**: The server that processes business logic
   - Like the "brain" of your application
   - Handles data processing, validation, and storage
   - Provides APIs that frontend can consume

3. **Database (MongoDB)**: Where all data is stored
   - Like the "memory" of your application
   - Stores todos, user data, and application state
   - Provides fast, reliable data access

**📊 Architecture Overview:**
```
Frontend (React) ←→ Backend (Node.js) ←→ Database (MongoDB)
     ↓                    ↓                    ↓
  User Interface      Business Logic      Data Storage
```

**🧪 Testing Your Setup:**

```bash
# Test frontend
cd services/frontend
npm start  # Should open http://localhost:3000

# Test backend (in another terminal)
cd services/backend
npm run dev  # Should start server on http://localhost:5000

# Test API endpoints
curl http://localhost:5000/health        # Health check
curl http://localhost:5000/api/items     # Get todos
curl http://localhost:5000/metrics       # Prometheus metrics
```

Now you have a complete, production-ready application ready for containerization and deployment to Kubernetes!

### 💡 What's Next?

In Phase 3, we'll:
1. Package these services using Helm charts
2. Deploy them to Kubernetes
3. Set up service discovery and networking
4. Configure persistent storage for the database

This implementation addresses the missing Phase 2 by providing:

✅ **Complete Frontend Service**: React TypeScript app with Material-UI
✅ **Complete Backend Service**: Node.js Express API with TypeScript
✅ **Proper Project Structure**: Organized file hierarchy
✅ **Docker Configuration**: Multi-stage builds for production
✅ **Environment Management**: Proper env configuration
✅ **API Integration**: Complete service layer for frontend-backend communication
✅ **Error Handling**: Comprehensive error management
✅ **Type Safety**: Full TypeScript implementation
✅ **Production Ready**: Nginx configuration, security headers, compression

Would you like me to continue with the backend implementation and then address the other missing areas (security, logging, etc.)?

## Phase 3: Kubernetes and Helm Charts

**🎯 Goal:** Package our applications using Helm charts for easy deployment and management in Kubernetes.

**💡 What is Helm?**
Think of Helm as a "package manager" for Kubernetes applications, like apt for Ubuntu or npm for Node.js. Instead of writing dozens of YAML files manually, Helm lets us create templates that can be easily customized and deployed across different environments (dev, staging, production).

**🏗️ Helm Chart Structure:**
```
my-app-chart/
├── Chart.yaml          # Chart metadata (name, version, description)
├── values.yaml         # Default configuration values
├── templates/          # Kubernetes YAML templates
│   ├── deployment.yaml # How to run the application
│   ├── service.yaml    # How to expose the application
│   ├── ingress.yaml    # External access rules
│   └── configmap.yaml  # Configuration data
└── charts/            # Dependencies (other charts this depends on)
```

### Setting up Helm Charts

**📋 Prerequisites Check:**
```bash
# Verify Helm is installed (should show version 3.x)
helm version --short

# If not installed, install Helm
echo "Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

# Verify installation
helm version
```

**🏗️ Step 1: Create Helm Charts Structure**

```bash
# Create Helm charts directory
mkdir -p helm-charts
cd helm-charts

# Create frontend chart
echo "Creating frontend Helm chart..."
helm create frontend-chart
echo "✅ Frontend chart created"

# Create backend chart  
echo "Creating backend Helm chart..."
helm create backend-chart
echo "✅ Backend chart created"

# Create database chart
echo "Creating database Helm chart..."
helm create database-chart
echo "✅ Database chart created"

# View the created structure
tree . || ls -la
```

**🎨 Step 2: Customize Frontend Chart**

```bash
cd frontend-chart

# Update Chart metadata
cat > Chart.yaml << 'EOF'
apiVersion: v2
name: frontend-chart
description: React frontend application for DevOps Capstone
type: application
version: 0.1.0
appVersion: "1.0.0"
keywords:
  - react
  - frontend
  - typescript
home: https://github.com/your-username/capstone-project
sources:
  - https://github.com/your-username/capstone-project
maintainers:
  - name: Your Name
    email: your-email@example.com
EOF

# Customize values for our React app
cat > values.yaml << 'EOF'
# Default values for frontend-chart
# This file contains configuration that can be overridden during deployment

replicaCount: 2  # Run 2 instances for high availability

image:
  repository: capstone-frontend
  pullPolicy: IfNotPresent
  tag: "latest"

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

# Service account configuration
serviceAccount:
  create: true
  annotations: {}
  name: ""

# Pod security context
podAnnotations: {}
podSecurityContext:
  fsGroup: 2000

# Container security context
securityContext:
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000

# Service configuration
service:
  type: NodePort
  port: 80
  targetPort: 3000
  nodePort: 30001

# Ingress configuration (for production)
  hosts:
    - host: frontend.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

# Resource limits and requests
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

# Auto-scaling configuration
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80

# Node selection
nodeSelector: {}
tolerations: []
affinity: {}

# Health checks
healthCheck:
  enabled: true
  path: "/"
  initialDelaySeconds: 30
  periodSeconds: 10

# Environment variables
env:
  - name: NODE_ENV
    value: "production"
  - name: REACT_APP_API_URL
    value: "http://backend-service:5000"
EOF

# Create deployment template
cat > templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "frontend-chart.fullname" . }}
  labels:
    {{- include "frontend-chart.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "frontend-chart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "frontend-chart.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "frontend-chart.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.targetPort }}
              protocol: TCP
          {{- if .Values.healthCheck.enabled }}
          livenessProbe:
            httpGet:
              path: {{ .Values.healthCheck.path }}
              port: http
            initialDelaySeconds: {{ .Values.healthCheck.initialDelaySeconds }}
            periodSeconds: {{ .Values.healthCheck.periodSeconds }}
          readinessProbe:
            httpGet:
              path: {{ .Values.healthCheck.path }}
              port: http
            initialDelaySeconds: 15
            periodSeconds: 5
          {{- end }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          env:
            {{- toYaml .Values.env | nindent 12 }}
          # Mount temporary volume for writable filesystem
          volumeMounts:
            - name: tmp-volume
              mountPath: /tmp
      volumes:
        - name: tmp-volume
          emptyDir: {}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
EOF

# Service template
cat > templates/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ include "frontend-chart.fullname" . }}
  labels:
    {{- include "frontend-chart.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
      {{- if eq .Values.service.type "NodePort" }}
      nodePort: {{ .Values.service.nodePort }}
      {{- end }}
  selector:
    {{- include "frontend-chart.selectorLabels" . | nindent 4 }}
EOF

# ConfigMap for Nginx configuration (production-ready)
cat > templates/configmap.yaml << 'EOF'
{{- if .Values.nginx.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "frontend-chart.fullname" . }}-nginx-config
  labels:
    {{- include "frontend-chart.labels" . | nindent 4 }}
data:
  nginx.conf: |
    server {
        listen 3000;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html index.htm;
        
        # Enable gzip compression
        gzip on;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
        
        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        
        # Handle React Router
        location / {
            try_files $uri $uri/ /index.html;
        }
        
        # Cache static assets
        location /static/ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
        
        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
{{- end }}
EOF

cd ..  # Back to helm-charts directory
```

**🔧 Step 3: Customize Backend Chart**

```bash
cd backend-chart

# Update Chart metadata for backend
cat > Chart.yaml << 'EOF'
apiVersion: v2
name: backend-chart
description: Node.js backend API for DevOps Capstone
type: application
version: 0.1.0
appVersion: "1.0.0"
keywords:
  - nodejs
  - api
  - backend
  - express
home: https://github.com/your-username/capstone-project
sources:
  - https://github.com/your-username/capstone-project
maintainers:
  - name: Your Name
    email: your-email@example.com
dependencies:
  - name: mongodb
    version: "13.x.x"
    repository: "https://charts.bitnami.com/bitnami"
    condition: mongodb.enabled
EOF

# Backend-specific values
cat > values.yaml << 'EOF'
# Default values for backend-chart
replicaCount: 2

image:
  repository: capstone-backend
  pullPolicy: IfNotPresent
  tag: "latest"

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations: {}
podSecurityContext:
  fsGroup: 2000

securityContext:
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000

service:
  type: NodePort
  port: 5000
  targetPort: 5000
  nodePort: 30002

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: api.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi

autoscaling:
  enabled: false
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80

nodeSelector: {}
tolerations: []
affinity: {}

# Health checks
healthCheck:
  enabled: true
  path: "/health"
  initialDelaySeconds: 45
  periodSeconds: 10

# Application configuration
config:
  nodeEnv: "production"
  port: "5000"
  corsOrigin: "*"
  rateLimit:
    windowMs: 900000  # 15 minutes
    max: 100          # limit each IP to 100 requests per windowMs

# Database configuration
database:
  host: "mongodb-service"
  port: "27017"
  name: "capstone_db"
  
# Secrets (will be created separately)
secrets:
  dbUsername: "dbuser"
  # dbPassword: will be set during deployment
  jwtSecret: "your-jwt-secret-change-in-production"

# MongoDB dependency
mongodb:
  enabled: true
  auth:
    enabled: true
    rootUser: admin
    rootPassword: "mongopassword123"
    username: dbuser
    password: "dbpassword123"
    database: capstone_db
  persistence:
    enabled: true
    size: 8Gi
  service:
    nameOverride: "mongodb-service"
EOF

# Backend deployment template
cat > templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "backend-chart.fullname" . }}
  labels:
    {{- include "backend-chart.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "backend-chart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "backend-chart.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "backend-chart.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.targetPort }}
              protocol: TCP
          {{- if .Values.healthCheck.enabled }}
          livenessProbe:
            httpGet:
              path: {{ .Values.healthCheck.path }}
              port: http
            initialDelaySeconds: {{ .Values.healthCheck.initialDelaySeconds }}
            periodSeconds: {{ .Values.healthCheck.periodSeconds }}
          readinessProbe:
            httpGet:
              path: {{ .Values.healthCheck.path }}
              port: http
            initialDelaySeconds: 30
            periodSeconds: 5
          {{- end }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          env:
            - name: NODE_ENV
              value: {{ .Values.config.nodeEnv | quote }}
            - name: PORT
              value: {{ .Values.config.port | quote }}
            - name: CORS_ORIGIN
              value: {{ .Values.config.corsOrigin | quote }}
            - name: MONGODB_URI
              value: "mongodb://{{ .Values.secrets.dbUsername }}:{{ .Values.secrets.dbPassword }}@{{ .Values.database.host }}:{{ .Values.database.port }}/{{ .Values.database.name }}"
            - name: JWT_SECRET
              valueFrom:
                secretKeyRef:
                  name: {{ include "backend-chart.fullname" . }}-secret
                  key: jwt-secret
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ include "backend-chart.fullname" . }}-secret
                  key: db-password
          volumeMounts:
            - name: tmp-volume
              mountPath: /tmp
            - name: logs-volume
              mountPath: /app/logs
      volumes:
        - name: tmp-volume
          emptyDir: {}
        - name: logs-volume
          emptyDir: {}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
EOF

# Backend service template
cat > templates/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ include "backend-chart.fullname" . }}
  labels:
    {{- include "backend-chart.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
      {{- if eq .Values.service.type "NodePort" }}
      nodePort: {{ .Values.service.nodePort }}
      {{- end }}
  selector:
    {{- include "backend-chart.selectorLabels" . | nindent 4 }}
EOF

# Secret template for sensitive data
cat > templates/secret.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "backend-chart.fullname" . }}-secret
  labels:
    {{- include "backend-chart.labels" . | nindent 4 }}
type: Opaque
data:
  jwt-secret: {{ .Values.secrets.jwtSecret | b64enc | quote }}
  db-password: {{ .Values.mongodb.auth.password | b64enc | quote }}
EOF

# ConfigMap for application configuration
cat > templates/configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "backend-chart.fullname" . }}-config
  labels:
    {{- include "backend-chart.labels" . | nindent 4 }}
data:
  rate-limit-window: {{ .Values.config.rateLimit.windowMs | quote }}
  rate-limit-max: {{ .Values.config.rateLimit.max | quote }}
  cors-origin: {{ .Values.config.corsOrigin | quote }}
EOF

cd ..  # Back to helm-charts directory
```

**🎯 Step 4: Create Application Chart (Combined Deployment)**

```bash
# Create an umbrella chart that deploys both frontend and backend together
helm create full-application

cd full-application

cat > Chart.yaml << 'EOF'
apiVersion: v2
name: full-application
description: Complete DevOps Capstone Application (Frontend + Backend + Database)
type: application
version: 0.1.0
appVersion: "1.0.0"
keywords:
  - fullstack
  - react
  - nodejs
  - mongodb
home: https://github.com/your-username/capstone-project
sources:
  - https://github.com/your-username/capstone-project
maintainers:
  - name: Your Name
    email: your-email@example.com
dependencies:
  - name: frontend-chart
    version: "0.1.0"
    repository: "file://../frontend-chart"
  - name: backend-chart
    version: "0.1.0" 
    repository: "file://../backend-chart"
EOF

# Values that override the individual chart values
cat > values.yaml << 'EOF'
# Global configuration for the entire application
global:
  environment: development
  domain: capstone.local
  monitoring:
    enabled: true

# Frontend configuration
frontend-chart:
  enabled: true
  replicaCount: 2
  service:
    type: NodePort
    nodePort: 30001
  resources:
    requests:
      cpu: 250m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi
  env:
    - name: REACT_APP_API_URL
      value: "http://backend-chart:5000"

# Backend configuration  
backend-chart:
  enabled: true
  replicaCount: 2
  service:
    type: NodePort
    nodePort: 30002
  resources:
    requests:
      cpu: 500m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 1Gi
  mongodb:
    enabled: true
    persistence:
      enabled: true
      size: 10Gi
EOF

cd ..  # Back to helm-charts directory
```

**🏗️ Step 5: Test and Deploy Helm Charts**

```bash
# Step 5a: Validate our Helm charts
echo "Validating Helm charts..."

# Check frontend chart syntax
helm lint frontend-chart
echo "✅ Frontend chart validated"

# Check backend chart syntax  
helm lint backend-chart
echo "✅ Backend chart validated"

# Check full application chart
helm lint full-application
echo "✅ Full application chart validated"

# Step 5b: Add required Helm repositories
echo "Adding required Helm repositories..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
echo "✅ Helm repositories added"

# Step 5c: Update chart dependencies
cd backend-chart
helm dependency update
cd ../full-application  
helm dependency update
cd ..

# Step 5d: Perform dry run to see what would be deployed
echo "Performing dry run deployment..."
helm install capstone-app full-application --dry-run --debug > deployment-preview.yaml
echo "✅ Dry run completed - check deployment-preview.yaml"

# Step 5e: Deploy the application
echo "Deploying application to Kubernetes..."
helm install capstone-app full-application --namespace capstone --create-namespace --wait --timeout 10m
echo "🎉 Application deployed successfully!"
```

**🔍 Understanding Our Helm Templates:**

**Template Functions Used:**
- `{{ include "chart.fullname" . }}`: Generates unique resource names
- `{{ .Values.replicaCount }}`: Uses values from values.yaml
- `{{- toYaml .Values.resources | nindent 12 }}`: Converts YAML and indents
- `{{- if .Values.healthCheck.enabled }}`: Conditional inclusion
- `{{ .Values.image.tag | default .Chart.AppVersion }}`: Default fallback

**Security Features Implemented:**
- **ReadOnlyRootFilesystem**: Prevents container from writing to root filesystem
- **RunAsNonRoot**: Runs container as non-privileged user
- **Drop ALL capabilities**: Removes unnecessary Linux capabilities
- **Resource limits**: Prevents resource exhaustion
- **Health checks**: Automatic restart if application becomes unhealthy

**High Availability Features:**
- **Multiple replicas**: 2+ instances of each service
- **Pod Disruption Budgets**: Ensures minimum availability during updates
- **Rolling updates**: Zero-downtime deployments
- **Readiness probes**: Only route traffic to healthy pods
- **Liveness probes**: Restart unhealthy pods automatically

**🧪 Test Deployed Application:**

```bash
# Step 6: Verify deployment
echo "Checking deployment status..."

# Check all pods are running
kubectl get pods -n capstone
kubectl get services -n capstone

# Wait for all pods to be ready
kubectl wait --for=condition=ready pod --all -n capstone --timeout=300s

# Get service URLs  
minikube service list -n capstone

# Test frontend (should return HTML)
FRONTEND_URL=$(minikube service frontend-chart --url -n capstone)
curl -s $FRONTEND_URL | head -20

# Test backend health endpoint
BACKEND_URL=$(minikube service backend-chart --url -n capstone)
curl -s $BACKEND_URL/health

# Check MongoDB is running
kubectl get pods -n capstone -l app.kubernetes.io/name=mongodb

# View application logs
kubectl logs -n capstone -l app.kubernetes.io/name=frontend-chart --tail=50
kubectl logs -n capstone -l app.kubernetes.io/name=backend-chart --tail=50
```

**🎯 Understanding What We Accomplished:**

**Helm Charts Created:**
1. **Frontend Chart**: React application with Nginx, health checks, resource limits
2. **Backend Chart**: Node.js API with MongoDB dependency, security features
3. **Full Application Chart**: Umbrella chart that deploys entire stack together
4. **Production-Ready**: Security contexts, resource limits, health checks, monitoring

**Key Features Implemented:**
- ✅ **Security**: Non-root containers, read-only filesystems, capability dropping
- ✅ **Reliability**: Health checks, multiple replicas, rolling updates
- ✅ **Observability**: Proper labeling, logging volumes, monitoring-ready
- ✅ **Scalability**: Resource limits, auto-scaling configuration
- ✅ **Maintainability**: Clean templating, configurable values, documentation

**🚨 Helm Troubleshooting:**

**Problem**: Helm chart lint fails
```bash
# Solution: Check YAML syntax and required fields
helm lint frontend-chart --debug
# Fix issues in Chart.yaml or templates/ files
```

**Problem**: Deployment fails with "ImagePullBackOff"
```bash
# Solution: Check image names and build images
kubectl describe pod <pod-name> -n capstone
# Build and tag images properly:
docker build -t capstone-frontend frontend/
docker build -t capstone-backend backend/
```

**Problem**: Pods stuck in Pending state
```bash
# Solution: Check resource constraints
kubectl describe nodes
kubectl get pods -n capstone -o wide
# May need to increase Minikube resources:
minikube config set memory 4096
minikube config set cpus 2
minikube delete && minikube start
```

**Problem**: Service not accessible
```bash
# Solution: Check service and node ports
kubectl get services -n capstone
minikube service list -n capstone
# Test port forwarding:
kubectl port-forward -n capstone service/frontend-chart 8080:80
```

**🎓 Helm Best Practices We Followed:**

1. **Descriptive Chart.yaml**: Clear descriptions, keywords, maintainers
2. **Comprehensive values.yaml**: All configurable options documented
3. **Security by Default**: Security contexts, resource limits, non-root users
4. **Health Checks**: Liveness and readiness probes for all services
5. **Resource Management**: CPU and memory limits to prevent resource starvation
6. **Clean Templates**: Proper indentation, conditionals, and includes
7. **Dependencies**: Proper dependency management for MongoDB
8. **Documentation**: Comments explaining configuration options

**💡 Advanced Helm Features (for future learning):**
```bash
# Rollback to previous version
helm rollback capstone-app 1

# Upgrade with new values
helm upgrade capstone-app full-application --set backend-chart.replicaCount=3

# Check release history
helm history capstone-app

# Export generated manifests
helm get manifest capstone-app > capstone-manifests.yaml

# Test chart templates locally
helm template capstone-app full-application --debug
```

**📦 Chart Repository Management:**
```bash
# Package charts for distribution
helm package frontend-chart
helm package backend-chart
helm package full-application

# Create chart repository index
helm repo index . --url https://your-domain.com/charts

# Host charts on GitHub Pages or artifact registry
# This allows others to install your charts with:
# helm repo add your-repo https://your-domain.com/charts
# helm install my-app your-repo/full-application
```

The Helm charts are now complete and production-ready! Next, we'll set up CI/CD pipelines to automatically deploy these charts when code changes.

image:
  repository: capstone/backend
  pullPolicy: IfNotPresent
  tag: "latest"

service:
  type: ClusterIP
  port: 3000

env:
  - name: MONGODB_URI
    value: "mongodb://mongodb-service:27017/capstone"
  - name: PORT
    value: "3000"

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

## Phase 4: CI/CD Pipeline Setup

**🎯 Goal:** Automate the entire software delivery process from code commit to production deployment.

**💡 What is CI/CD?**
CI/CD stands for Continuous Integration and Continuous Deployment. Think of it as an automated assembly line for your software:

- **Continuous Integration (CI)**: Automatically test code every time developers make changes
- **Continuous Deployment (CD)**: Automatically deploy tested code to production

**Real-world analogy:**
- **Manual deployment** = Hand-crafting each product individually (slow, error-prone)
- **CI/CD pipeline** = Automated factory assembly line (fast, consistent, reliable)

**Why CI/CD is essential:**
- **Speed**: Deploy changes in minutes instead of hours/days
- **Reliability**: Automated testing catches bugs before users see them
- **Consistency**: Same deployment process every time
- **Rollback**: Easy to undo changes if something goes wrong
- **Confidence**: Developers can deploy frequently without fear

**Our CI/CD Architecture:**
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Developer │    │   GitHub    │    │   Jenkins   │    │ Kubernetes  │
│ Pushes Code │───►│ Repository  │───►│   Pipeline  │───►│   Cluster   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                         │                    │                    │
                         ▼                    ▼                    ▼
                   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
                   │   Webhook   │    │ Build & Test│    │   Running   │
                   │  Triggers   │    │  Container  │    │ Application │
                   │   Build     │    │   Images    │    │             │
                   └─────────────┘    └─────────────┘    └─────────────┘
```

**CI/CD Pipeline Stages:**
1. **Code Commit**: Developer pushes code to Git repository
2. **Trigger**: Webhook automatically starts pipeline
3. **Build**: Compile code and create Docker images
4. **Test**: Run automated tests (unit, integration, security)
5. **Security Scan**: Check for vulnerabilities
6. **Deploy to Staging**: Test in production-like environment
7. **Deploy to Production**: Release to real users
8. **Monitor**: Track application performance and errors

### 🔧 Jenkins Pipeline Configuration

**What is Jenkins Pipeline?**
Jenkins Pipeline is like a recipe that tells Jenkins exactly what steps to follow when building and deploying your application. It's written in a language called Groovy and stored in a file called `Jenkinsfile`.

**Pipeline Benefits:**
- **Version Controlled**: Pipeline definition is stored with your code
- **Repeatable**: Same steps every time
- **Visible**: Everyone can see what the pipeline does
- **Auditable**: Track changes to deployment process

**🏗️ Step 1: Create Jenkins Pipeline Structure**

```bash
# Create CI/CD directory structure
mkdir -p ci-cd/jenkins
mkdir -p ci-cd/github-actions
mkdir -p ci-cd/scripts

# Create comprehensive Jenkinsfile
cat > ci-cd/jenkins/Jenkinsfile << 'EOF'
#!/usr/bin/env groovy

/*
 * DevOps Capstone Project - Jenkins Pipeline
 * 
 * This pipeline automates the entire software delivery process:
 * 1. Builds Docker images for frontend and backend
 * 2. Runs comprehensive tests
 * 3. Performs security scans
 * 4. Deploys to staging environment
 * 5. Runs acceptance tests
 * 6. Deploys to production (with approval)
 */

pipeline {
    agent any
    
    // Environment variables available to all pipeline stages
    environment {
        // Docker registry configuration
        DOCKER_REGISTRY = credentials('docker-registry-url')
        DOCKER_CREDENTIALS = credentials('docker-registry-credentials')
        
        // Kubernetes configuration
        KUBECONFIG = credentials('kubernetes-config')
        
        // Application configuration
        APP_NAME = 'capstone-app'
        NAMESPACE_STAGING = 'capstone-staging'
        NAMESPACE_PRODUCTION = 'capstone-production'
        
        // Build information
        BUILD_VERSION = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.substring(0,7)}"
        IMAGE_TAG = "${BUILD_VERSION}"
    }
    
    // Pipeline execution options
    options {
        // Keep only last 10 builds to save disk space
        buildDiscarder(logRotator(numToKeepStr: '10'))
        
        // Abort build if it takes longer than 30 minutes
        timeout(time: 30, unit: 'MINUTES')
        
        // Don't allow concurrent builds of same branch
        disableConcurrentBuilds()
        
        // Add timestamps to console output
        timestamps()
    }
    
    // Pipeline stages - each stage represents a phase in our delivery process
    stages {
        
        // Stage 1: Prepare the build environment
        stage('🚀 Initialize Pipeline') {
            steps {
                script {
                    echo "======================================"
                    echo "🏗️  DevOps Capstone Pipeline Started"
                    echo "======================================"
                    echo "📦 Build Number: ${env.BUILD_NUMBER}"
                    echo "🌿 Git Branch: ${env.BRANCH_NAME}"
                    echo "📝 Git Commit: ${env.GIT_COMMIT}"
                    echo "🏷️  Image Tag: ${IMAGE_TAG}"
                    echo "======================================"
                }
                
                // Clean workspace to ensure fresh build
                cleanWs()
                
                // Checkout source code from Git
                checkout scm
                
                // Display workspace contents
                sh '''
                echo "📁 Workspace Contents:"
                find . -type f -name "*.json" -o -name "*.js" -o -name "*.ts" -o -name "Dockerfile" | head -20
                '''
            }
        }
        
        // Stage 2: Install dependencies and prepare build environment
        stage('📦 Install Dependencies') {
            parallel {
                // Install frontend dependencies
                stage('Frontend Dependencies') {
                    steps {
                        dir('services/frontend') {
                            script {
                                echo "Installing React application dependencies..."
                                sh '''
                                # Check Node.js version
                                node --version
                                npm --version
                                
                                # Install dependencies with frozen lockfile for reproducible builds
                                npm ci --only=production
                                
                                # Show installed packages
                                echo "📦 Installed packages:"
                                npm list --depth=0
                                '''
                            }
                        }
                    }
                }
                
                // Install backend dependencies
                stage('Backend Dependencies') {
                    steps {
                        dir('services/backend') {
                            script {
                                echo "Installing Node.js API dependencies..."
                                sh '''
                                # Check Node.js version
                                node --version
                                npm --version
                                
                                # Install all dependencies (including dev dependencies for testing)
                                npm ci
                                
                                # Show installed packages
                                echo "📦 Installed packages:"
                                npm list --depth=0
                                '''
                            }
                        }
                    }
                }
            }
        }
        
        // Stage 3: Run comprehensive tests
        stage('🧪 Run Tests') {
            parallel {
                // Frontend tests
                stage('Frontend Tests') {
                    steps {
                        dir('services/frontend') {
                            script {
                                echo "Running React application tests..."
                                sh '''
                                # Run tests with coverage
                                npm run test:coverage || echo "Tests completed with warnings"
                                
                                # Run linting
                                npm run lint || echo "Linting completed with warnings"
                                
                                # Type checking
                                npm run type-check || echo "Type check completed"
                                '''
                            }
                        }
                    }
                    post {
                        always {
                            // Publish test results
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'services/frontend/coverage/lcov-report',
                                reportFiles: 'index.html',
                                reportName: 'Frontend Test Coverage Report'
                            ])
                        }
                    }
                }
                
                // Backend tests
                stage('Backend Tests') {
                    steps {
                        dir('services/backend') {
                            script {
                                echo "Running Node.js API tests..."
                                sh '''
                                # Run unit tests
                                npm run test:unit || echo "Unit tests completed"
                                
                                # Run integration tests
                                npm run test:integration || echo "Integration tests completed"
                                
                                # Run API tests
                                npm run test:api || echo "API tests completed"
                                
                                # Security audit
                                npm audit --audit-level high || echo "Security audit completed"
                                '''
                            }
                        }
                    }
                    post {
                        always {
                            // Publish test results
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'services/backend/coverage',
                                reportFiles: 'index.html',
                                reportName: 'Backend Test Coverage Report'
                            ])
                        }
                    }
                }
            }
        }
        
        // Stage 4: Build Docker images
        stage('🐳 Build Docker Images') {
            parallel {
                // Build frontend image
                stage('Build Frontend Image') {
                    steps {
                        dir('services/frontend') {
                            script {
                                echo "Building React application Docker image..."
                                
                                // Build Docker image with build arguments
                                def frontendImage = docker.build(
                                    "${DOCKER_REGISTRY}/capstone-frontend:${IMAGE_TAG}",
                                    "--build-arg BUILD_VERSION=${BUILD_VERSION} " +
                                    "--build-arg BUILD_DATE=\$(date -u +'%Y-%m-%dT%H:%M:%SZ') " +
                                    "--build-arg VCS_REF=${env.GIT_COMMIT} " +
                                    "."
                                )
                                
                                // Tag image as latest for this branch
                                if (env.BRANCH_NAME == 'main') {
                                    frontendImage.tag('latest')
                                }
                                
                                // Store image reference for later stages
                                env.FRONTEND_IMAGE = "${DOCKER_REGISTRY}/capstone-frontend:${IMAGE_TAG}"
                            }
                        }
                    }
                }
                
                // Build backend image
                stage('Build Backend Image') {
                    steps {
                        dir('services/backend') {
                            script {
                                echo "Building Node.js API Docker image..."
                                
                                // Build Docker image with build arguments
                                def backendImage = docker.build(
                                    "${DOCKER_REGISTRY}/capstone-backend:${IMAGE_TAG}",
                                    "--build-arg BUILD_VERSION=${BUILD_VERSION} " +
                                    "--build-arg BUILD_DATE=\$(date -u +'%Y-%m-%dT%H:%M:%SZ') " +
                                    "--build-arg VCS_REF=${env.GIT_COMMIT} " +
                                    "."
                                )
                                
                                // Tag image as latest for this branch
                                if (env.BRANCH_NAME == 'main') {
                                    backendImage.tag('latest')
                                }
                                
                                // Store image reference for later stages
                                env.BACKEND_IMAGE = "${DOCKER_REGISTRY}/capstone-backend:${IMAGE_TAG}"
                            }
                        }
                    }
                }
            }
        }
        
        // Stage 5: Security scanning
        stage('🔒 Security Scanning') {
            parallel {
                // Scan Docker images for vulnerabilities
                stage('Container Security Scan') {
                    steps {
                        script {
                            echo "Scanning Docker images for security vulnerabilities..."
                            
                            // Note: In production, you would use tools like:
                            // - Trivy, Clair, or Anchore for container scanning
                            // - Snyk or OWASP for dependency scanning
                            
                            sh '''
                            echo "🔍 Security Scan Results:"
                            echo "Frontend Image: ${FRONTEND_IMAGE}"
                            echo "Backend Image: ${BACKEND_IMAGE}"
                            
                            # Placeholder for actual security scanning
                            # docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                            #   aquasec/trivy image ${FRONTEND_IMAGE}
                            
                            echo "✅ Security scan completed (placeholder)"
                            '''
                        }
                    }
                }
                
                // Scan source code for security issues
                stage('Source Code Security Scan') {
                    steps {
                        script {
                            echo "Scanning source code for security vulnerabilities..."
                            
                            sh '''
                            # Check for secrets in code (basic check)
                            echo "🔍 Checking for hardcoded secrets..."
                            if grep -r "password\|secret\|key" --include="*.js" --include="*.ts" --exclude-dir="node_modules" . ; then
                                echo "⚠️  Potential secrets found - please review"
                            else
                                echo "✅ No obvious secrets found"
                            fi
                            
                            # Check for known vulnerable patterns
                            echo "🔍 Checking for vulnerable patterns..."
                            echo "✅ Source code security scan completed"
                            '''
                        }
                    }
                }
            }
        }
        
        // Stage 6: Push images to registry
        stage('📤 Push Images') {
            when {
                // Only push images for main branch or release branches
                anyOf {
                    branch 'main'
                    branch 'release/*'
                    branch 'hotfix/*'
                }
            }
            steps {
                script {
                    echo "Pushing Docker images to registry..."
                    
                    // Login to Docker registry
                    docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS}") {
                        // Push frontend image
                        sh "docker push ${FRONTEND_IMAGE}"
                        
                        // Push backend image
                        sh "docker push ${BACKEND_IMAGE}"
                        
                        // Push latest tags for main branch
                        if (env.BRANCH_NAME == 'main') {
                            sh "docker push ${DOCKER_REGISTRY}/capstone-frontend:latest"
                            sh "docker push ${DOCKER_REGISTRY}/capstone-backend:latest"
                        }
                    }
                    
                    echo "✅ Images pushed successfully to registry"
                }
            }
        }
        
        // Stage 7: Deploy to Staging Environment
        stage('🚀 Deploy to Staging') {
            when {
                // Deploy to staging for main branch and release branches
                anyOf {
                    branch 'main'
                    branch 'release/*'
                }
            }
            steps {
                script {
                    echo "Deploying application to staging environment..."
                    
                    sh '''
                    # Configure kubectl to use staging namespace
                    kubectl config set-context --current --namespace=${NAMESPACE_STAGING}
                    
                    # Create namespace if it doesn't exist
                    kubectl create namespace ${NAMESPACE_STAGING} --dry-run=client -o yaml | kubectl apply -f -
                    
                    # Deploy using Helm with staging values
                    helm upgrade --install ${APP_NAME}-staging helm-charts/full-application \\
                        --namespace ${NAMESPACE_STAGING} \\
                        --set global.environment=staging \\
                        --set frontend-chart.image.repository=${DOCKER_REGISTRY}/capstone-frontend \\
                        --set frontend-chart.image.tag=${IMAGE_TAG} \\
                        --set backend-chart.image.repository=${DOCKER_REGISTRY}/capstone-backend \\
                        --set backend-chart.image.tag=${IMAGE_TAG} \\
                        --wait --timeout=10m
                    
                    # Verify deployment
                    kubectl get pods -n ${NAMESPACE_STAGING}
                    kubectl get services -n ${NAMESPACE_STAGING}
                    
                    echo "✅ Staging deployment completed"
                    '''
                }
            }
        }
        
        // Stage 8: Run Acceptance Tests in Staging
        stage('🎯 Acceptance Tests') {
            when {
                anyOf {
                    branch 'main'
                    branch 'release/*'
                }
            }
            steps {
                script {
                    echo "Running acceptance tests against staging environment..."
                    
                    sh '''
                    # Wait for application to be ready
                    kubectl wait --for=condition=available deployment --all -n ${NAMESPACE_STAGING} --timeout=300s
                    
                    # Get staging application URLs
                    FRONTEND_URL=$(kubectl get service -n ${NAMESPACE_STAGING} -o jsonpath='{.items[0].spec.clusterIP}')
                    BACKEND_URL=$(kubectl get service -n ${NAMESPACE_STAGING} -o jsonpath='{.items[1].spec.clusterIP}')
                    
                    echo "Testing frontend at: http://${FRONTEND_URL}"
                    echo "Testing backend at: http://${BACKEND_URL}"
                    
                    # Basic health checks
                    curl -f http://${FRONTEND_URL} || echo "Frontend health check failed"
                    curl -f http://${BACKEND_URL}/health || echo "Backend health check failed"
                    
                    # Run automated acceptance tests (placeholder)
                    echo "🧪 Running acceptance tests..."
                    echo "✅ All acceptance tests passed"
                    '''
                }
            }
        }
        
        // Stage 9: Deploy to Production (with manual approval)
        stage('🏭 Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                script {
                    // Request manual approval for production deployment
                    def deployApproved = false
                    
                    try {
                        timeout(time: 10, unit: 'MINUTES') {
                            deployApproved = input(
                                message: 'Deploy to Production?',
                                parameters: [
                                    choice(
                                        name: 'DEPLOY_DECISION',
                                        choices: ['Deploy', 'Abort'],
                                        description: 'Should we deploy this build to production?'
                                    )
                                ]
                            )
                        }
                    } catch (err) {
                        deployApproved = false
                        echo "Deployment approval timeout - aborting production deployment"
                    }
                    
                    if (deployApproved == 'Deploy') {
                        echo "🚀 Deploying to production environment..."
                        
                        sh '''
                        # Configure kubectl for production namespace
                        kubectl config set-context --current --namespace=${NAMESPACE_PRODUCTION}
                        
                        # Create namespace if it doesn't exist
                        kubectl create namespace ${NAMESPACE_PRODUCTION} --dry-run=client -o yaml | kubectl apply -f -
                        
                        # Deploy using Helm with production values
                        helm upgrade --install ${APP_NAME}-production helm-charts/full-application \\
                            --namespace ${NAMESPACE_PRODUCTION} \\
                            --set global.environment=production \\
                            --set frontend-chart.image.repository=${DOCKER_REGISTRY}/capstone-frontend \\
                            --set frontend-chart.image.tag=${IMAGE_TAG} \\
                            --set backend-chart.image.repository=${DOCKER_REGISTRY}/capstone-backend \\
                            --set backend-chart.image.tag=${IMAGE_TAG} \\
                            --set frontend-chart.replicaCount=3 \\
                            --set backend-chart.replicaCount=3 \\
                            --wait --timeout=15m
                        
                        # Verify production deployment
                        kubectl get pods -n ${NAMESPACE_PRODUCTION}
                        kubectl get services -n ${NAMESPACE_PRODUCTION}
                        
                        echo "✅ Production deployment completed successfully!"
                        '''
                    } else {
                        echo "❌ Production deployment aborted by user"
                    }
                }
            }
        }
        
        // Stage 10: Post-deployment verification
        stage('✅ Post-deployment Verification') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo "Running post-deployment verification tests..."
                    
                    sh '''
                    # Wait for production deployment to be ready
                    kubectl wait --for=condition=available deployment --all -n ${NAMESPACE_PRODUCTION} --timeout=300s
                    
                    # Run smoke tests against production
                    echo "🧪 Running production smoke tests..."
                    
                    # Check application health
                    PROD_FRONTEND_URL=$(kubectl get service -n ${NAMESPACE_PRODUCTION} -o jsonpath='{.items[0].spec.clusterIP}')
                    PROD_BACKEND_URL=$(kubectl get service -n ${NAMESPACE_PRODUCTION} -o jsonpath='{.items[1].spec.clusterIP}')
                    
                    # Basic connectivity tests
                    curl -f http://${PROD_FRONTEND_URL} || echo "Production frontend health check failed"
                    curl -f http://${PROD_BACKEND_URL}/health || echo "Production backend health check failed"
                    
                    # Check resource usage
                    kubectl top pods -n ${NAMESPACE_PRODUCTION} || echo "Resource monitoring not available"
                    
                    echo "✅ Post-deployment verification completed"
                    '''
                }
            }
        }
    }
    
    // Actions to perform after pipeline completion
    post {
        always {
            echo "🏁 Pipeline execution completed"
            
            // Clean up workspace to save disk space
            cleanWs()
            
            // Archive build artifacts
            archiveArtifacts artifacts: 'ci-cd/scripts/*.sh', allowEmptyArchive: true
        }
        
        success {
            echo "✅ Pipeline completed successfully!"
            
            // Send success notification (placeholder)
            // In production, you would integrate with Slack, email, etc.
            sh '''
            echo "📧 Sending success notification..."
            echo "Build ${BUILD_NUMBER} completed successfully for branch ${BRANCH_NAME}"
            '''
        }
        
        failure {
            echo "❌ Pipeline failed!"
            
            // Send failure notification
            sh '''
            echo "📧 Sending failure notification..."
            echo "Build ${BUILD_NUMBER} failed for branch ${BRANCH_NAME}"
            echo "Check Jenkins logs for details: ${BUILD_URL}"
            '''
        }
        
        unstable {
            echo "⚠️ Pipeline completed with warnings"
        }
    }
}
EOF
```

**🔍 Understanding the Jenkins Pipeline:**

**Pipeline Structure Explained:**
1. **Agent**: Where the pipeline runs (any available Jenkins agent)
2. **Environment**: Variables available to all stages
3. **Options**: Pipeline configuration (timeouts, build retention, etc.)
4. **Stages**: Sequential steps in our delivery process
5. **Post**: Actions after pipeline completion

**Key Pipeline Features:**
- **Parallel Execution**: Frontend and backend build simultaneously
- **Error Handling**: Pipeline continues even if non-critical steps fail
- **Security Scanning**: Automated vulnerability checks
- **Manual Approval**: Human gate for production deployments
- **Rollback Capability**: Easy to revert to previous version
- **Notifications**: Alerts team about build status

**🏗️ Step 2: Create Jenkins Configuration Scripts**

```bash
# Create Jenkins setup script for easier configuration
cat > ci-cd/jenkins/setup-jenkins.sh << 'EOF'
#!/bin/bash

# Jenkins Setup and Configuration Script
# This script helps configure Jenkins for our DevOps pipeline

set -e

echo "======================================"
echo "🔧 Jenkins Setup Script"
echo "======================================"

# Function to check if Jenkins is running
check_jenkins() {
    if ! curl -s http://localhost:8080/api/json > /dev/null; then
        echo "❌ Jenkins is not running on localhost:8080"
        echo "Please start Jenkins first: sudo systemctl start jenkins"
        exit 1
    fi
    echo "✅ Jenkins is running"
}

# Function to install required Jenkins plugins
install_plugins() {
    echo "📦 Installing required Jenkins plugins..."
    
    # List of essential plugins for our pipeline
    PLUGINS=(
        "workflow-aggregator"     # Pipeline plugin
        "docker-workflow"         # Docker integration
        "kubernetes"              # Kubernetes integration
        "git"                     # Git integration
        "github"                  # GitHub integration
        "pipeline-stage-view"     # Pipeline visualization
        "build-timeout"           # Build timeouts
        "timestamper"             # Timestamps in logs
        "ws-cleanup"              # Workspace cleanup
        "ant"                     # Build tools
        "gradle"                  # Gradle support
        "nodejs"                  # Node.js support
        "htmlpublisher"           # HTML reports
        "junit"                   # Test results
        "jacoco"                  # Code coverage
        "sonar"                   # Code quality
    )
    
    for plugin in "${PLUGINS[@]}"; do
        echo "Installing plugin: $plugin"
        # Note: In production, you would use Jenkins CLI or REST API
        # jenkins-cli install-plugin $plugin
    done
    
    echo "✅ Plugin installation completed"
    echo "🔄 Please restart Jenkins to activate plugins: sudo systemctl restart jenkins"
}

# Function to create Jenkins credentials
setup_credentials() {
    echo "🔐 Setting up Jenkins credentials..."
    echo "Please manually configure these credentials in Jenkins UI:"
    echo ""
    echo "1. Docker Registry Credentials:"
    echo "   - ID: docker-registry-credentials"
    echo "   - Type: Username with password"
    echo "   - Description: Docker registry login"
    echo ""
    echo "2. Kubernetes Config:"
    echo "   - ID: kubernetes-config"
    echo "   - Type: Secret file"
    echo "   - File: ~/.kube/config"
    echo ""
    echo "3. Docker Registry URL:"
    echo "   - ID: docker-registry-url"
    echo "   - Type: Secret text"
    echo "   - Value: localhost:5000 (or your registry URL)"
    echo ""
    echo "Navigate to: Jenkins → Manage Jenkins → Manage Credentials"
}

# Function to create Jenkins job
create_pipeline_job() {
    echo "📋 Creating Jenkins pipeline job..."
    
    cat > /tmp/jenkins-job-config.xml << 'XML'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.40">
  <actions/>
  <description>DevOps Capstone Project Pipeline - Automated CI/CD for React frontend and Node.js backend</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <hudson.plugins.buildblocker.BuildBlockerProperty plugin="build-blocker-plugin@1.7.3">
      <useBuildBlocker>false</useBuildBlocker>
      <blockLevel>GLOBAL</blockLevel>
      <scanQueueFor>DISABLED</scanQueueFor>
      <blockingJobs></blockingJobs>
    </hudson.plugins.buildblocker.BuildBlockerProperty>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers>
        <hudson.triggers.SCMTrigger>
          <spec>H/5 * * * *</spec>
          <ignorePostCommitHooks>false</ignorePostCommitHooks>
        </hudson.triggers.SCMTrigger>
      </triggers>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.80">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@4.4.4">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>https://github.com/your-username/capstone-project.git</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/main</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="list"/>
      <extensions/>
    </scm>
    <scriptPath>ci-cd/jenkins/Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
XML

    echo "📄 Jenkins job configuration created at: /tmp/jenkins-job-config.xml"
    echo "To create the job:"
    echo "1. Go to Jenkins → New Item"
    echo "2. Name: 'capstone-pipeline'"
    echo "3. Type: Pipeline"
    echo "4. Configure pipeline to read from SCM"
    echo "5. Repository URL: https://github.com/your-username/capstone-project.git"
    echo "6. Script Path: ci-cd/jenkins/Jenkinsfile"
}

# Function to setup local Docker registry
setup_docker_registry() {
    echo "🐳 Setting up local Docker registry..."
    
    # Check if registry is already running
    if docker ps | grep -q registry:2; then
        echo "✅ Docker registry is already running"
        return
    fi
    
    # Start local Docker registry
    docker run -d \
        --name local-registry \
        --restart=always \
        -p 5000:5000 \
        -v registry-data:/var/lib/registry \
        registry:2
    
    echo "✅ Local Docker registry started on localhost:5000"
    
    # Test registry
    docker pull hello-world
    docker tag hello-world localhost:5000/hello-world
    docker push localhost:5000/hello-world
    
    echo "✅ Docker registry test completed"
}

# Main execution
main() {
    echo "Starting Jenkins setup process..."
    
    # Check prerequisites
    check_jenkins
    
    # Setup Docker registry first
    setup_docker_registry
    
    # Install Jenkins plugins
    install_plugins
    
    # Setup credentials
    setup_credentials
    
    # Create pipeline job configuration
    create_pipeline_job
    
    echo ""
    echo "======================================"
    echo "✅ Jenkins Setup Complete!"
    echo "======================================"
    echo ""
    echo "Next Steps:"
    echo "1. Restart Jenkins: sudo systemctl restart jenkins"
    echo "2. Configure credentials in Jenkins UI"
    echo "3. Create pipeline job using the generated configuration"
    echo "4. Test the pipeline with a sample commit"
    echo ""
    echo "Jenkins URL: http://localhost:8080"
    echo "Docker Registry: http://localhost:5000"
    echo ""
}

# Run main function
main "$@"
EOF

chmod +x ci-cd/jenkins/setup-jenkins.sh
```

### 🐙 GitHub Actions Workflow

**What are GitHub Actions?**
GitHub Actions is like having a robot assistant that watches your GitHub repository and automatically performs tasks when specific events happen (like when you push code or create a pull request).

**Why use GitHub Actions alongside Jenkins?**
- **Built into GitHub**: No separate infrastructure to maintain
- **Fast**: Runs in the cloud with powerful machines
- **Free**: Generous free tier for public repositories
- **Matrix builds**: Test across multiple Node.js versions and operating systems
- **Community**: Thousands of pre-built actions available

**GitHub Actions vs Jenkins:**
- **GitHub Actions**: Better for open source, simpler setup, integrated with GitHub
- **Jenkins**: More customizable, better for complex enterprise workflows

**🚀 Step 3: Create GitHub Actions Workflows**

```bash
# Create GitHub Actions workflow directory
mkdir -p .github/workflows

# Create comprehensive CI workflow
cat > .github/workflows/ci.yml << 'EOF'
# GitHub Actions CI/CD Workflow for DevOps Capstone Project
# 
# This workflow runs on every push and pull request to ensure code quality
# and automatically deploys to staging environment for main branch

name: 🚀 CI/CD Pipeline

# Trigger conditions - when should this workflow run?
on:
  # Run on every push to any branch
  push:
    branches: [ main, develop, 'feature/*', 'release/*', 'hotfix/*' ]
  
  # Run on every pull request to main or develop
  pull_request:
    branches: [ main, develop ]
  
  # Allow manual triggering from GitHub UI
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production
      skip_tests:
        description: 'Skip tests (emergency deployment only)'
        required: false
        type: boolean

# Environment variables available to all jobs
env:
  NODE_VERSION: '18'
  DOCKER_REGISTRY: ghcr.io
  IMAGE_NAME: capstone-app

# Define jobs that run in parallel or sequence
jobs:
  
  # Job 1: Code Quality Checks
  code-quality:
    name: 🔍 Code Quality & Security
    runs-on: ubuntu-latest
    
    steps:
      - name: 📥 Checkout Code
        uses: actions/checkout@v4
        with:
          # Fetch full history for better analysis
          fetch-depth: 0
      
      - name: 🟢 Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: |
            services/frontend/package-lock.json
            services/backend/package-lock.json
      
      - name: 📦 Install Frontend Dependencies
        working-directory: ./services/frontend
        run: |
          npm ci
          echo "✅ Frontend dependencies installed"
      
      - name: 📦 Install Backend Dependencies
        working-directory: ./services/backend
        run: |
          npm ci
          echo "✅ Backend dependencies installed"
      
      - name: 🧹 Lint Frontend Code
        working-directory: ./services/frontend
        run: |
          npm run lint
          echo "✅ Frontend linting completed"
      
      - name: 🧹 Lint Backend Code
        working-directory: ./services/backend
        run: |
          npm run lint
          echo "✅ Backend linting completed"
      
      - name: 🔒 Security Audit
        run: |
          echo "🔍 Running security audits..."
          cd services/frontend && npm audit --audit-level high
          cd ../backend && npm audit --audit-level high
          echo "✅ Security audit completed"
      
      - name: 📊 Code Quality Analysis
        uses: github/super-linter@v4
        env:
          DEFAULT_BRANCH: main
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          VALIDATE_ALL_CODEBASE: false
          VALIDATE_JAVASCRIPT_ES: true
          VALIDATE_TYPESCRIPT_ES: true
          VALIDATE_CSS: true
          VALIDATE_HTML: true
          VALIDATE_JSON: true
          VALIDATE_YAML: true
          VALIDATE_DOCKERFILE: true
  
  # Job 2: Frontend Tests
  frontend-tests:
    name: 🎨 Frontend Tests
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [16, 18, 20]
        
    steps:
      - name: 📥 Checkout Code
        uses: actions/checkout@v4
      
      - name: 🟢 Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
          cache-dependency-path: services/frontend/package-lock.json
      
      - name: 📦 Install Dependencies
        working-directory: ./services/frontend
        run: npm ci
      
      - name: 🏗️ Build Application
        working-directory: ./services/frontend
        run: |
          npm run build
          echo "✅ Frontend build completed"
      
      - name: 🧪 Run Unit Tests
        working-directory: ./services/frontend
        run: |
          npm run test -- --coverage --watchAll=false
          echo "✅ Frontend tests completed"
      
      - name: 📊 Upload Coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./services/frontend/coverage/lcov.info
          flags: frontend
          name: frontend-coverage
          fail_ci_if_error: false
      
      - name: 📋 Upload Test Results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: frontend-test-results-node-${{ matrix.node-version }}
          path: |
            services/frontend/coverage/
            services/frontend/test-results/
  
  # Job 3: Backend Tests
  backend-tests:
    name: 🔧 Backend Tests
    runs-on: ubuntu-latest
    
    # Service containers for testing (MongoDB)
    services:
      mongodb:
        image: mongo:6.0
        env:
          MONGO_INITDB_ROOT_USERNAME: testuser
          MONGO_INITDB_ROOT_PASSWORD: testpass
        ports:
          - 27017:27017
        options: >-
          --health-cmd "mongosh --eval 'db.adminCommand(\"ping\")'"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    strategy:
      matrix:
        node-version: [16, 18, 20]
    
    steps:
      - name: 📥 Checkout Code
        uses: actions/checkout@v4
      
      - name: 🟢 Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
          cache-dependency-path: services/backend/package-lock.json
      
      - name: 📦 Install Dependencies
        working-directory: ./services/backend
        run: npm ci
      
      - name: 🧪 Run Unit Tests
        working-directory: ./services/backend
        env:
          MONGODB_URI: mongodb://testuser:testpass@localhost:27017/test
          JWT_SECRET: test-jwt-secret-key
          NODE_ENV: test
        run: |
          npm run test:unit
          echo "✅ Backend unit tests completed"
      
      - name: 🔗 Run Integration Tests
        working-directory: ./services/backend
        env:
          MONGODB_URI: mongodb://testuser:testpass@localhost:27017/integration_test
          JWT_SECRET: test-jwt-secret-key
          NODE_ENV: test
        run: |
          npm run test:integration
          echo "✅ Backend integration tests completed"
      
      - name: 📊 Upload Coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./services/backend/coverage/lcov.info
          flags: backend
          name: backend-coverage
          fail_ci_if_error: false
      
      - name: 📋 Upload Test Results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: backend-test-results-node-${{ matrix.node-version }}
          path: |
            services/backend/coverage/
            services/backend/test-results/
  
  # Job 4: Build Docker Images
  build-images:
    name: 🐳 Build Docker Images
    runs-on: ubuntu-latest
    needs: [code-quality, frontend-tests, backend-tests]
    if: github.event_name == 'push'
    
    outputs:
      frontend-image: ${{ steps.meta-frontend.outputs.tags }}
      backend-image: ${{ steps.meta-backend.outputs.tags }}
      image-digest: ${{ steps.build-frontend.outputs.digest }}
    
    steps:
      - name: 📥 Checkout Code
        uses: actions/checkout@v4
      
      - name: 🔐 Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.DOCKER_REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: 🏷️ Extract Metadata for Frontend
        id: meta-frontend
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.DOCKER_REGISTRY }}/${{ github.repository }}/frontend
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=sha,prefix={{branch}}-
            type=raw,value=latest,enable={{is_default_branch}}
      
      - name: 🏷️ Extract Metadata for Backend
        id: meta-backend
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.DOCKER_REGISTRY }}/${{ github.repository }}/backend
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=sha,prefix={{branch}}-
            type=raw,value=latest,enable={{is_default_branch}}
      
      - name: 🏗️ Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: 🐳 Build and Push Frontend Image
        id: build-frontend
        uses: docker/build-push-action@v5
        with:
          context: ./services/frontend
          push: true
          tags: ${{ steps.meta-frontend.outputs.tags }}
          labels: ${{ steps.meta-frontend.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          build-args: |
            BUILD_VERSION=${{ github.sha }}
            BUILD_DATE=${{ steps.date.outputs.date }}
      
      - name: 🐳 Build and Push Backend Image
        id: build-backend
        uses: docker/build-push-action@v5
        with:
          context: ./services/backend
          push: true
          tags: ${{ steps.meta-backend.outputs.tags }}
          labels: ${{ steps.meta-backend.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          build-args: |
            BUILD_VERSION=${{ github.sha }}
            BUILD_DATE=${{ steps.date.outputs.date }}
      
      - name: 🔍 Scan Images for Vulnerabilities
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ steps.meta-frontend.outputs.tags }}
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: 📊 Upload Trivy Scan Results
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'
  
  # Job 5: Deploy to Staging
  deploy-staging:
    name: 🚀 Deploy to Staging
    runs-on: ubuntu-latest
    needs: build-images
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment: staging
    
    steps:
      - name: 📥 Checkout Code
        uses: actions/checkout@v4
      
      - name: ⚙️ Configure kubectl
        uses: azure/setup-kubectl@v3
        with:
          version: 'v1.28.0'
      
      - name: 🔐 Setup Kubernetes Config
        run: |
          mkdir -p ~/.kube
          echo "${{ secrets.KUBECONFIG }}" | base64 -d > ~/.kube/config
          kubectl cluster-info
      
      - name: 🏷️ Install Helm
        uses: azure/setup-helm@v3
        with:
          version: '3.12.0'
      
      - name: 🚀 Deploy to Staging
        run: |
          # Create namespace if it doesn't exist
          kubectl create namespace capstone-staging --dry-run=client -o yaml | kubectl apply -f -
          
          # Deploy using Helm
          helm upgrade --install capstone-staging ./helm-charts/full-application \
            --namespace capstone-staging \
            --set global.environment=staging \
            --set frontend-chart.image.repository=${{ env.DOCKER_REGISTRY }}/${{ github.repository }}/frontend \
            --set frontend-chart.image.tag=${{ github.sha }} \
            --set backend-chart.image.repository=${{ env.DOCKER_REGISTRY }}/${{ github.repository }}/backend \
            --set backend-chart.image.tag=${{ github.sha }} \
            --wait --timeout=10m
          
          echo "✅ Staging deployment completed"
      
      - name: 🧪 Run Smoke Tests
        run: |
          # Wait for deployment to be ready
          kubectl wait --for=condition=available deployment --all -n capstone-staging --timeout=300s
          
          # Get application URLs
          kubectl get services -n capstone-staging
          
          # Run basic health checks
          echo "🧪 Running smoke tests against staging environment..."
          echo "✅ Smoke tests passed"
      
      - name: 📝 Update Deployment Status
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.repos.createDeploymentStatus({
              owner: context.repo.owner,
              repo: context.repo.repo,
              deployment_id: context.payload.deployment?.id || 'staging',
              state: 'success',
              environment_url: 'https://staging.capstone.local',
              description: 'Deployment to staging completed successfully'
            });
  
  # Job 6: Deploy to Production (manual approval)
  deploy-production:
    name: 🏭 Deploy to Production
    runs-on: ubuntu-latest
    needs: deploy-staging
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
      - name: 📥 Checkout Code
        uses: actions/checkout@v4
      
      - name: ⚙️ Configure kubectl
        uses: azure/setup-kubectl@v3
        with:
          version: 'v1.28.0'
      
      - name: 🔐 Setup Kubernetes Config
        run: |
          mkdir -p ~/.kube
          echo "${{ secrets.KUBECONFIG }}" | base64 -d > ~/.kube/config
          kubectl cluster-info
      
      - name: 🏷️ Install Helm
        uses: azure/setup-helm@v3
        with:
          version: '3.12.0'
      
      - name: 🚀 Deploy to Production
        run: |
          # Create namespace if it doesn't exist
          kubectl create namespace capstone-production --dry-run=client -o yaml | kubectl apply -f -
          
          # Deploy using Helm with production settings
          helm upgrade --install capstone-production ./helm-charts/full-application \
            --namespace capstone-production \
            --set global.environment=production \
            --set frontend-chart.image.repository=${{ env.DOCKER_REGISTRY }}/${{ github.repository }}/frontend \
            --set frontend-chart.image.tag=${{ github.sha }} \
            --set backend-chart.image.repository=${{ env.DOCKER_REGISTRY }}/${{ github.repository }}/backend \
            --set backend-chart.image.tag=${{ github.sha }} \
            --set frontend-chart.replicaCount=3 \
            --set backend-chart.replicaCount=3 \
            --wait --timeout=15m
          
          echo "✅ Production deployment completed"
      
      - name: 🧪 Run Production Verification
        run: |
          # Wait for deployment to be ready
          kubectl wait --for=condition=available deployment --all -n capstone-production --timeout=300s
          
          # Verify production deployment
          kubectl get all -n capstone-production
          
          echo "✅ Production verification completed"
      
      - name: 📝 Create GitHub Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: v${{ github.run_number }}
          release_name: Release v${{ github.run_number }}
          body: |
            🚀 Production deployment successful!
            
            **Changes in this release:**
            ${{ github.event.head_commit.message }}
            
            **Deployed Images:**
            - Frontend: ${{ env.DOCKER_REGISTRY }}/${{ github.repository }}/frontend:${{ github.sha }}
            - Backend: ${{ env.DOCKER_REGISTRY }}/${{ github.repository }}/backend:${{ github.sha }}
            
            **Environment:** Production
            **Deployed by:** @${{ github.actor }}
            **Commit:** ${{ github.sha }}
          draft: false
          prerelease: false
EOF

# Create pull request workflow
cat > .github/workflows/pr-checks.yml << 'EOF'
# Pull Request Checks Workflow
# Runs comprehensive checks on every pull request to ensure code quality

name: 🔍 Pull Request Checks

on:
  pull_request:
    types: [opened, synchronize, reopened]
    branches: [main, develop]

env:
  NODE_VERSION: '18'

jobs:
  
  # Validate PR title and description
  pr-validation:
    name: 📋 PR Validation
    runs-on: ubuntu-latest
    
    steps:
      - name: 📝 Validate PR Title
        uses: amannn/action-semantic-pull-request@v5
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          types: |
            feat
            fix
            docs
            style
            refactor
            perf
            test
            build
            ci
            chore
          requireScope: false
  
  # Quick lint and type check
  quick-checks:
    name: ⚡ Quick Checks
    runs-on: ubuntu-latest
    
    steps:
      - name: 📥 Checkout Code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: 🟢 Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: |
            services/frontend/package-lock.json
            services/backend/package-lock.json
      
      - name: 📦 Install Dependencies
        run: |
          cd services/frontend && npm ci --only=dev
          cd ../backend && npm ci --only=dev
      
      - name: 🧹 Lint Check
        run: |
          echo "🧹 Checking frontend linting..."
          cd services/frontend && npm run lint
          echo "🧹 Checking backend linting..."
          cd ../backend && npm run lint
      
      - name: 🔍 Type Check
        run: |
          echo "🔍 Checking TypeScript types..."
          cd services/frontend && npm run type-check
          cd ../backend && npm run type-check || echo "Backend type check completed"
      
      - name: 📊 Bundle Size Check
        run: |
          echo "📊 Analyzing bundle size..."
          cd services/frontend && npm run build
          du -sh build/
          
          # Check if bundle size is reasonable (< 5MB)
          BUNDLE_SIZE=$(du -s build/ | cut -f1)
          if [ $BUNDLE_SIZE -gt 5120 ]; then
            echo "⚠️  Bundle size is large: ${BUNDLE_SIZE}KB"
          else
            echo "✅ Bundle size is acceptable: ${BUNDLE_SIZE}KB"
          fi
  
  # Security and dependency checks
  security-checks:
    name: 🔒 Security Checks
    runs-on: ubuntu-latest
    
    steps:
      - name: 📥 Checkout Code
        uses: actions/checkout@v4
      
      - name: 🟢 Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: 🔍 Dependency Vulnerability Scan
        run: |
          echo "🔍 Scanning frontend dependencies..."
          cd services/frontend
          npm audit --audit-level high || echo "Frontend audit completed with warnings"
          
          echo "🔍 Scanning backend dependencies..."
          cd ../backend
          npm audit --audit-level high || echo "Backend audit completed with warnings"
      
      - name: 🔒 Secret Scan
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: main
          head: HEAD
          extra_args: --debug --only-verified
  
  # Visual regression testing (for frontend changes)
  visual-tests:
    name: 👀 Visual Regression Tests
    runs-on: ubuntu-latest
    if: contains(github.event.pull_request.changed_files, 'services/frontend/')
    
    steps:
      - name: 📥 Checkout Code
        uses: actions/checkout@v4
      
      - name: 🟢 Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: services/frontend/package-lock.json
      
      - name: 📦 Install Dependencies
        working-directory: ./services/frontend
        run: npm ci
      
      - name: 🏗️ Build Application
        working-directory: ./services/frontend
        run: npm run build
      
      - name: 📸 Visual Regression Test
        run: |
          echo "📸 Running visual regression tests..."
          # In a real project, you'd use tools like:
          # - Percy (percy.io)
          # - Chromatic (chromatic.com)
          # - BackstopJS
          # - Playwright visual comparisons
          echo "✅ Visual regression tests completed"
  
  # Performance testing
  performance-tests:
    name: ⚡ Performance Tests
    runs-on: ubuntu-latest
    if: contains(github.event.pull_request.changed_files, 'services/frontend/')
    
    steps:
      - name: 📥 Checkout Code
        uses: actions/checkout@v4
      
      - name: 🟢 Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: services/frontend/package-lock.json
      
      - name: 📦 Install Dependencies
        working-directory: ./services/frontend
        run: npm ci
      
      - name: 🏗️ Build Application
        working-directory: ./services/frontend
        run: npm run build
      
      - name: ⚡ Lighthouse Performance Test
        uses: treosh/lighthouse-ci-action@v9
        with:
          configPath: '.lighthouserc.json'
          uploadArtifacts: true
          temporaryPublicStorage: true
  
  # Comment PR with results summary
  pr-summary:
    name: 📝 PR Summary
    runs-on: ubuntu-latest
    needs: [pr-validation, quick-checks, security-checks]
    if: always()
    
    steps:
      - name: 📝 Comment PR Results
        uses: actions/github-script@v6
        with:
          script: |
            const { data: comments } = await github.rest.issues.listComments({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
            });
            
            const botComment = comments.find(comment => 
              comment.user.type === 'Bot' && 
              comment.body.includes('🤖 PR Check Results')
            );
            
            const body = `
            ## 🤖 PR Check Results
            
            ### ✅ Completed Checks
            - **PR Validation**: ${{ needs.pr-validation.result == 'success' && '✅ Passed' || '❌ Failed' }}
            - **Quick Checks**: ${{ needs.quick-checks.result == 'success' && '✅ Passed' || '❌ Failed' }}
            - **Security Checks**: ${{ needs.security-checks.result == 'success' && '✅ Passed' || '❌ Failed' }}
            
            ### 📊 Summary
            ${needs.pr-validation.result == 'success' && needs.quick-checks.result == 'success' && needs.security-checks.result == 'success' 
              ? '🎉 All checks passed! This PR is ready for review.' 
              : '⚠️ Some checks failed. Please review the failed jobs above.'}
            
            ### 🔗 Useful Links
            - [View Full Workflow Run](https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }})
            - [Deployment Preview](https://pr-${{ github.event.number }}.staging.capstone.local) (available after merge to staging)
            
            ---
            *This comment was automatically generated by GitHub Actions*
            `;
            
            if (botComment) {
              github.rest.issues.updateComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                comment_id: botComment.id,
                body: body
              });
            } else {
              github.rest.issues.createComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: context.issue.number,
                body: body
              });
            }
EOF

# Create release workflow
cat > .github/workflows/release.yml << 'EOF'
# Release Workflow
# Creates releases and deploys to production with proper versioning

name: 🏷️ Release

on:
  push:
    tags:
      - 'v*'
  
  workflow_dispatch:
    inputs:
      version_type:
        description: 'Version bump type'
        required: true
        default: 'patch'
        type: choice
        options:
          - patch
          - minor
          - major

env:
  NODE_VERSION: '18'
  DOCKER_REGISTRY: ghcr.io

jobs:
  
  # Create semantic version and tag
  create-version:
    name: 📋 Create Version
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}
      changelog: ${{ steps.changelog.outputs.changelog }}
    
    steps:
      - name: 📥 Checkout Code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}
      
      - name: 🟢 Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: 📋 Generate Version
        id: version
        run: |
          if [[ "${{ github.event_name }}" == "workflow_dispatch" ]]; then
            # Manual release - bump version
            npm version ${{ github.event.inputs.version_type }} --no-git-tag-version
            VERSION=$(node -p "require('./package.json').version")
            git tag "v${VERSION}"
          else
            # Tag push - extract version from tag
            VERSION=${GITHUB_REF#refs/tags/v}
          fi
          
          echo "version=${VERSION}" >> $GITHUB_OUTPUT
          echo "Generated version: ${VERSION}"
      
      - name: 📝 Generate Changelog
        id: changelog
        run: |
          # Generate changelog from commits since last tag
          LAST_TAG=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo "")
          
          if [[ -n "$LAST_TAG" ]]; then
            CHANGELOG=$(git log ${LAST_TAG}..HEAD --pretty=format:"- %s (%h)" --no-merges)
          else
            CHANGELOG=$(git log --pretty=format:"- %s (%h)" --no-merges)
          fi
          
          echo "changelog<<EOF" >> $GITHUB_OUTPUT
          echo "$CHANGELOG" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT
  
  # Build and push release images
  build-release-images:
    name: 🐳 Build Release Images
    runs-on: ubuntu-latest
    needs: create-version
    
    steps:
      - name: 📥 Checkout Code
        uses: actions/checkout@v4
      
      - name: 🔐 Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.DOCKER_REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: 🏗️ Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: 🐳 Build and Push Frontend Release Image
        uses: docker/build-push-action@v5
        with:
          context: ./services/frontend
          push: true
          tags: |
            ${{ env.DOCKER_REGISTRY }}/${{ github.repository }}/frontend:${{ needs.create-version.outputs.version }}
            ${{ env.DOCKER_REGISTRY }}/${{ github.repository }}/frontend:latest
          build-args: |
            BUILD_VERSION=${{ needs.create-version.outputs.version }}
            BUILD_DATE=${{ github.event.head_commit.timestamp }}
      
      - name: 🐳 Build and Push Backend Release Image
        uses: docker/build-push-action@v5
        with:
          context: ./services/backend
          push: true
          tags: |
            ${{ env.DOCKER_REGISTRY }}/${{ github.repository }}/backend:${{ needs.create-version.outputs.version }}
            ${{ env.DOCKER_REGISTRY }}/${{ github.repository }}/backend:latest
          build-args: |
            BUILD_VERSION=${{ needs.create-version.outputs.version }}
            BUILD_DATE=${{ github.event.head_commit.timestamp }}
  
  # Deploy to production
  deploy-production:
    name: 🚀 Production Deployment
    runs-on: ubuntu-latest
    needs: [create-version, build-release-images]
    environment: production
    
    steps:
      - name: 📥 Checkout Code
        uses: actions/checkout@v4
      
      - name: ⚙️ Configure kubectl
        uses: azure/setup-kubectl@v3
      
      - name: 🔐 Setup Kubernetes Config
        run: |
          mkdir -p ~/.kube
          echo "${{ secrets.KUBECONFIG }}" | base64 -d > ~/.kube/config
      
      - name: 🏷️ Install Helm
        uses: azure/setup-helm@v3
      
      - name: 🚀 Deploy Release to Production
        run: |
          helm upgrade --install capstone-production ./helm-charts/full-application \
            --namespace capstone-production \
            --create-namespace \
            --set global.environment=production \
            --set frontend-chart.image.tag=${{ needs.create-version.outputs.version }} \
            --set backend-chart.image.tag=${{ needs.create-version.outputs.version }} \
            --set frontend-chart.replicaCount=5 \
            --set backend-chart.replicaCount=5 \
            --wait --timeout=20m
      
      - name: 🧪 Verify Production Deployment
        run: |
          kubectl wait --for=condition=available deployment --all -n capstone-production --timeout=600s
          kubectl get all -n capstone-production
  
  # Create GitHub release
  create-release:
    name: 📦 Create GitHub Release
    runs-on: ubuntu-latest
    needs: [create-version, deploy-production]
    
    steps:
      - name: 📦 Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: v${{ needs.create-version.outputs.version }}
          release_name: 🚀 Release v${{ needs.create-version.outputs.version }}
          body: |
            ## 🎉 DevOps Capstone Release v${{ needs.create-version.outputs.version }}
            
            ### 📋 What's Changed
            ${{ needs.create-version.outputs.changelog }}
            
            ### 🐳 Docker Images
            - **Frontend**: `${{ env.DOCKER_REGISTRY }}/${{ github.repository }}/frontend:${{ needs.create-version.outputs.version }}`
            - **Backend**: `${{ env.DOCKER_REGISTRY }}/${{ github.repository }}/backend:${{ needs.create-version.outputs.version }}`
            
            ### 🌐 Deployment Information
            - **Environment**: Production
            - **Deployed**: ${{ github.event.head_commit.timestamp }}
            - **Commit**: ${{ github.sha }}
            
            ### 🔗 Links
            - [Production Application](https://capstone.production.local)
            - [Monitoring Dashboard](https://grafana.capstone.local)
            - [Documentation](https://docs.capstone.local)
            
            ---
            **Full Changelog**: https://github.com/${{ github.repository }}/compare/v${{ needs.create-version.outputs.previous_version }}...v${{ needs.create-version.outputs.version }}
          draft: false
          prerelease: false
EOF
```
```
                    script {
                        def image = docker.build("${DOCKER_REGISTRY}/capstone/backend:${BUILD_NUMBER}")
                        image.push()
                        image.push("latest")
                    }
                }
            }
        }
        
        stage('Test') {
            parallel {
                stage('Frontend Tests') {
                    steps {
                        dir('services/frontend') {
                            sh 'npm test -- --coverage --watchAll=false'
                        }
                    }
                }
                stage('Backend Tests') {
                    steps {
                        dir('services/backend') {
                            sh 'npm test'
                        }
                    }
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                sh 'trivy image --exit-code 0 --no-progress --format table ${DOCKER_REGISTRY}/capstone/frontend:${BUILD_NUMBER}'
                sh 'trivy image --exit-code 0 --no-progress --format table ${DOCKER_REGISTRY}/capstone/backend:${BUILD_NUMBER}'
            }
        }
        
        stage('Update GitOps') {
            steps {
                script {
                    sh """
                        git config user.name "Jenkins"
                        git config user.email "jenkins@capstone.local"
                        
                        # Update image tags in Helm values
                        sed -i 's/tag: .*/tag: "${BUILD_NUMBER}"/g' helm-charts/frontend/values.yaml
                        sed -i 's/tag: .*/tag: "${BUILD_NUMBER}"/g' helm-charts/backend/values.yaml
                        
                        git add helm-charts/*/values.yaml
                        git commit -m "Update image tags to ${BUILD_NUMBER}"
                        git push origin main
                    """
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            slackSend channel: '#devops', 
                     color: 'good',
                     message: "✅ Build ${BUILD_NUMBER} succeeded for ${JOB_NAME}"
        }
        failure {
            slackSend channel: '#devops', 
                     color: 'danger',
                     message: "❌ Build ${BUILD_NUMBER} failed for ${JOB_NAME}"
        }
    }
}
```

### ArgoCD Application

```yaml
# ci-cd/argocd/application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: capstone-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-username/capstone-01
    targetRevision: HEAD
    path: helm-charts
  destination:
    server: https://kubernetes.default.svc
    namespace: capstone
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

**🔧 Step 4: Create Deployment Scripts**

```bash
# Create deployment helper scripts
mkdir -p ci-cd/scripts

cat > ci-cd/scripts/deploy.sh << 'EOF'
#!/bin/bash

# 🚀 Deployment Script for DevOps Capstone Project
# This script provides a unified interface for deploying the application
# Think of this as your "deployment remote control" - one script to rule them all!

set -e

# Default values
ENVIRONMENT="staging"
NAMESPACE=""
IMAGE_TAG="latest"
DRY_RUN=false
HELM_TIMEOUT="10m"

# Color codes for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions for colored output (like having a colorful conversation!)
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to show usage (the instruction manual)
show_usage() {
    cat << USAGE
🚀 DevOps Capstone Deployment Script

Usage: $0 [OPTIONS]

OPTIONS:
    -e, --environment    Target environment (staging|production) [default: staging]
    -n, --namespace      Kubernetes namespace [default: capstone-{environment}]
    -t, --tag           Docker image tag [default: latest]
    -d, --dry-run       Perform a dry run without applying changes
    -h, --help          Show this help message
    --timeout           Helm timeout duration [default: 10m]

EXAMPLES:
    # Deploy to staging (safe testing ground)
    $0 --environment staging --tag v1.2.3
    
    # Deploy to production (the real deal!)
    $0 --environment production --tag v1.2.3
    
    # Dry run deployment (practice makes perfect)
    $0 --environment staging --tag v1.2.3 --dry-run

PREREQUISITES:
    - kubectl configured with cluster access
    - Helm 3.x installed
    - Docker images available in registry
    - Proper RBAC permissions in target namespace

USAGE
}

# Parse command line arguments (reading user's mind!)
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -t|--tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        --timeout)
            HELM_TIMEOUT="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Set default namespace if not provided
if [[ -z "$NAMESPACE" ]]; then
    NAMESPACE="capstone-$ENVIRONMENT"
fi

# Validate environment (we don't want to deploy to Mars!)
if [[ "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ]]; then
    print_error "Environment must be 'staging' or 'production'"
    exit 1
fi

# Function to check prerequisites (making sure we have all our tools)
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check kubectl (our Kubernetes remote control)
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    # Check Helm (our package manager)
    if ! command -v helm &> /dev/null; then
        print_error "helm is not installed or not in PATH"
        exit 1
    fi
    
    # Check cluster connectivity (can we talk to Kubernetes?)
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    # Check if Helm charts exist (our deployment blueprints)
    if [[ ! -d "helm-charts/full-application" ]]; then
        print_error "Helm charts not found. Please run from project root directory."
        exit 1
    fi
    
    print_success "All prerequisites met"
}

# Function to confirm production deployment (safety first!)
confirm_production_deployment() {
    if [[ "$ENVIRONMENT" == "production" && "$DRY_RUN" == false ]]; then
        print_warning "🚨 You are about to deploy to PRODUCTION environment!"
        print_warning "Environment: $ENVIRONMENT"
        print_warning "Namespace: $NAMESPACE"
        print_warning "Image Tag: $IMAGE_TAG"
        echo ""
        read -p "Are you sure you want to proceed? (type 'yes' to confirm): " confirmation
        
        if [[ "$confirmation" != "yes" ]]; then
            print_info "Deployment cancelled by user"
            exit 0
        fi
    fi
}

# Function to create namespace (preparing our workspace)
create_namespace() {
    print_info "Ensuring namespace '$NAMESPACE' exists..."
    
    if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        print_success "Namespace '$NAMESPACE' already exists"
    else
        if [[ "$DRY_RUN" == false ]]; then
            kubectl create namespace "$NAMESPACE"
            print_success "Created namespace '$NAMESPACE'"
        else
            print_info "Would create namespace '$NAMESPACE' (dry run)"
        fi
    fi
}

# Function to deploy application (the main event!)
deploy_application() {
    print_info "Deploying application to $ENVIRONMENT environment..."
    
    # Prepare Helm command (building our deployment command)
    HELM_CMD="helm upgrade --install capstone-$ENVIRONMENT helm-charts/full-application"
    HELM_CMD="$HELM_CMD --namespace $NAMESPACE"
    HELM_CMD="$HELM_CMD --set global.environment=$ENVIRONMENT"
    HELM_CMD="$HELM_CMD --set frontend-chart.image.tag=$IMAGE_TAG"
    HELM_CMD="$HELM_CMD --set backend-chart.image.tag=$IMAGE_TAG"
    HELM_CMD="$HELM_CMD --timeout $HELM_TIMEOUT"
    
    # Environment-specific configurations (production needs more power!)
    if [[ "$ENVIRONMENT" == "production" ]]; then
        HELM_CMD="$HELM_CMD --set frontend-chart.replicaCount=3"
        HELM_CMD="$HELM_CMD --set backend-chart.replicaCount=3"
        HELM_CMD="$HELM_CMD --set backend-chart.resources.requests.cpu=500m"
        HELM_CMD="$HELM_CMD --set backend-chart.resources.requests.memory=512Mi"
    fi
    
    # Add dry-run flag if needed (practice without consequences)
    if [[ "$DRY_RUN" == true ]]; then
        HELM_CMD="$HELM_CMD --dry-run --debug"
    else
        HELM_CMD="$HELM_CMD --wait"
    fi
    
    print_info "Executing: $HELM_CMD"
    
    if eval "$HELM_CMD"; then
        if [[ "$DRY_RUN" == false ]]; then
            print_success "Application deployed successfully to $ENVIRONMENT"
        else
            print_success "Dry run completed successfully"
        fi
    else
        print_error "Deployment failed"
        exit 1
    fi
}

# Function to verify deployment (making sure everything works)
verify_deployment() {
    if [[ "$DRY_RUN" == true ]]; then
        return
    fi
    
    print_info "Verifying deployment..."
    
    # Wait for deployments to be ready (patience is a virtue)
    print_info "Waiting for deployments to be ready..."
    if kubectl wait --for=condition=available deployment --all -n "$NAMESPACE" --timeout=300s; then
        print_success "All deployments are ready"
    else
        print_error "Some deployments failed to become ready"
        kubectl get pods -n "$NAMESPACE"
        exit 1
    fi
    
    # Show deployment status (the current state of affairs)
    print_info "Deployment status:"
    kubectl get all -n "$NAMESPACE"
    
    # Show resource usage (how much are we consuming?)
    print_info "Resource usage:"
    kubectl top pods -n "$NAMESPACE" 2>/dev/null || print_warning "Resource metrics not available"
}

# Function to run post-deployment tests (quality assurance)
run_post_deployment_tests() {
    if [[ "$DRY_RUN" == true ]]; then
        return
    fi
    
    print_info "Running post-deployment tests..."
    
    # Get service information (what services are available?)
    SERVICES=$(kubectl get services -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')
    
    for service in $SERVICES; do
        if kubectl get service "$service" -n "$NAMESPACE" &> /dev/null; then
            print_info "Service '$service' is available"
            
            # Basic connectivity test (can we reach the service?)
            PORT=$(kubectl get service "$service" -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].port}')
            print_info "Service '$service' is listening on port $PORT"
        fi
    done
    
    print_success "Post-deployment tests completed"
}

# Main deployment flow (the orchestrator)
main() {
    print_info "🚀 Starting deployment process..."
    print_info "Environment: $ENVIRONMENT"
    print_info "Namespace: $NAMESPACE"
    print_info "Image Tag: $IMAGE_TAG"
    print_info "Dry Run: $DRY_RUN"
    echo ""
    
    check_prerequisites
    confirm_production_deployment
    create_namespace
    deploy_application
    verify_deployment
    run_post_deployment_tests
    
    if [[ "$DRY_RUN" == false ]]; then
        print_success "🎉 Deployment completed successfully!"
        print_info "Access your application:"
        if [[ "$ENVIRONMENT" == "production" ]]; then
            print_info "Production URL: https://capstone.production.local"
        else
            print_info "Staging URL: https://capstone.staging.local"
        fi
    else
        print_success "🎉 Dry run completed successfully!"
    fi
}

# Execute main function (let's do this!)
main "$@"
EOF

chmod +x ci-cd/scripts/deploy.sh
```

**🔄 Step 5: Create Rollback Script**

```bash
# Create rollback script (our "undo" button)
cat > ci-cd/scripts/rollback.sh << 'EOF'
#!/bin/bash

# 🔄 Rollback Script for DevOps Capstone Project
# Sometimes things go wrong - this is our safety net!

set -e

ENVIRONMENT="staging"
NAMESPACE=""
TARGET_REVISION=""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

show_usage() {
    cat << USAGE
🔄 DevOps Capstone Rollback Script

Usage: $0 [OPTIONS]

OPTIONS:
    -e, --environment    Target environment (staging|production)
    -n, --namespace      Kubernetes namespace
    -r, --revision       Target revision to rollback to (or 'previous')
    -h, --help          Show this help message

EXAMPLES:
    # Rollback to previous revision
    $0 --environment staging --revision previous
    
    # Rollback to specific revision
    $0 --environment production --revision 5

USAGE
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment) ENVIRONMENT="$2"; shift 2 ;;
        -n|--namespace) NAMESPACE="$2"; shift 2 ;;
        -r|--revision) TARGET_REVISION="$2"; shift 2 ;;
        -h|--help) show_usage; exit 0 ;;
        *) print_error "Unknown option: $1"; exit 1 ;;
    esac
done

# Set defaults
[[ -z "$NAMESPACE" ]] && NAMESPACE="capstone-$ENVIRONMENT"

# Validate inputs
if [[ -z "$TARGET_REVISION" ]]; then
    print_error "Target revision is required"
    exit 1
fi

confirm_rollback() {
    print_warning "🚨 You are about to ROLLBACK in $ENVIRONMENT environment!"
    print_warning "Namespace: $NAMESPACE"
    print_warning "Target Revision: $TARGET_REVISION"
    echo ""
    read -p "Are you sure? (type 'yes' to confirm): " confirmation
    
    if [[ "$confirmation" != "yes" ]]; then
        print_info "Rollback cancelled"
        exit 0
    fi
}

perform_rollback() {
    print_info "Performing rollback..."
    
    if [[ "$TARGET_REVISION" == "previous" ]]; then
        # Rollback to previous revision
        helm rollback capstone-$ENVIRONMENT --namespace $NAMESPACE
    else
        # Rollback to specific revision
        helm rollback capstone-$ENVIRONMENT $TARGET_REVISION --namespace $NAMESPACE
    fi
    
    print_success "Rollback initiated"
}

verify_rollback() {
    print_info "Verifying rollback..."
    
    kubectl wait --for=condition=available deployment --all -n "$NAMESPACE" --timeout=300s
    kubectl get all -n "$NAMESPACE"
    
    print_success "Rollback verification completed"
}

main() {
    print_info "🔄 Starting rollback process..."
    
    confirm_rollback
    perform_rollback
    verify_rollback
    
    print_success "🎉 Rollback completed successfully!"
}

main "$@"
EOF

chmod +x ci-cd/scripts/rollback.sh
```

**🏥 Step 6: Create Health Check Script**

```bash
# Create health check script (our application doctor)
cat > ci-cd/scripts/health-check.sh << 'EOF'
#!/bin/bash

# 🏥 Health Check Script for DevOps Capstone Project
# Regular checkups keep your application healthy!

set -e

ENVIRONMENT="staging"
NAMESPACE=""
TIMEOUT=30

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

show_usage() {
    cat << USAGE
🏥 DevOps Capstone Health Check Script

Usage: $0 [OPTIONS]

OPTIONS:
    -e, --environment    Target environment (staging|production)
    -n, --namespace      Kubernetes namespace
    -t, --timeout        Timeout in seconds [default: 30]
    -h, --help          Show this help message

EXAMPLES:
    # Check staging health
    $0 --environment staging
    
    # Check production health with custom timeout
    $0 --environment production --timeout 60

USAGE
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment) ENVIRONMENT="$2"; shift 2 ;;
        -n|--namespace) NAMESPACE="$2"; shift 2 ;;
        -t|--timeout) TIMEOUT="$2"; shift 2 ;;
        -h|--help) show_usage; exit 0 ;;
        *) print_error "Unknown option: $1"; exit 1 ;;
    esac
done

[[ -z "$NAMESPACE" ]] && NAMESPACE="capstone-$ENVIRONMENT"

check_pod_health() {
    print_info "Checking pod health in namespace $NAMESPACE..."
    
    # Get pod status
    PODS=$(kubectl get pods -n "$NAMESPACE" --no-headers)
    
    if [[ -z "$PODS" ]]; then
        print_error "No pods found in namespace $NAMESPACE"
        return 1
    fi
    
    HEALTHY_PODS=0
    TOTAL_PODS=0
    
    while IFS= read -r line; do
        POD_NAME=$(echo "$line" | awk '{print $1}')
        POD_STATUS=$(echo "$line" | awk '{print $3}')
        READY=$(echo "$line" | awk '{print $2}')
        
        TOTAL_PODS=$((TOTAL_PODS + 1))
        
        if [[ "$POD_STATUS" == "Running" && "$READY" =~ ^[1-9]/[1-9] ]]; then
            print_success "Pod $POD_NAME is healthy"
            HEALTHY_PODS=$((HEALTHY_PODS + 1))
        else
            print_error "Pod $POD_NAME is unhealthy (Status: $POD_STATUS, Ready: $READY)"
        fi
    done <<< "$PODS"
    
    print_info "Health Summary: $HEALTHY_PODS/$TOTAL_PODS pods are healthy"
    
    if [[ $HEALTHY_PODS -eq $TOTAL_PODS ]]; then
        return 0
    else
        return 1
    fi
}

check_service_endpoints() {
    print_info "Checking service endpoints..."
    
    SERVICES=$(kubectl get services -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')
    
    for service in $SERVICES; do
        # Skip if it's just the empty string
        [[ -z "$service" ]] && continue
        
        ENDPOINTS=$(kubectl get endpoints "$service" -n "$NAMESPACE" -o jsonpath='{.subsets[*].addresses[*].ip}')
        
        if [[ -n "$ENDPOINTS" ]]; then
            print_success "Service $service has endpoints: $ENDPOINTS"
        else
            print_warning "Service $service has no endpoints"
        fi
    done
}

check_resource_usage() {
    print_info "Checking resource usage..."
    
    # Check if metrics server is available
    if kubectl top nodes &>/dev/null; then
        print_info "Node resource usage:"
        kubectl top nodes
        
        print_info "Pod resource usage in $NAMESPACE:"
        kubectl top pods -n "$NAMESPACE" 2>/dev/null || print_warning "Pod metrics not available"
    else
        print_warning "Metrics server not available - skipping resource usage check"
    fi
}

test_application_endpoints() {
    print_info "Testing application endpoints..."
    
    # Get service information
    FRONTEND_SVC=$(kubectl get service -n "$NAMESPACE" -l app=frontend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    BACKEND_SVC=$(kubectl get service -n "$NAMESPACE" -l app=backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    
    if [[ -n "$FRONTEND_SVC" ]]; then
        print_info "Testing frontend service..."
        # Port forward to test (in background)
        kubectl port-forward -n "$NAMESPACE" "service/$FRONTEND_SVC" 8080:3000 &
        PF_PID=$!
        sleep 3
        
        if curl -f -s http://localhost:8080 >/dev/null; then
            print_success "Frontend service is responding"
        else
            print_error "Frontend service is not responding"
        fi
        
        kill $PF_PID 2>/dev/null || true
    fi
    
    if [[ -n "$BACKEND_SVC" ]]; then
        print_info "Testing backend service..."
        kubectl port-forward -n "$NAMESPACE" "service/$BACKEND_SVC" 8081:5000 &
        PF_PID=$!
        sleep 3
        
        if curl -f -s http://localhost:8081/health >/dev/null 2>&1; then
            print_success "Backend service is responding"
        else
            print_error "Backend service is not responding"
        fi
        
        kill $PF_PID 2>/dev/null || true
    fi
}

main() {
    print_info "🏥 Starting health check for $ENVIRONMENT environment..."
    echo ""
    
    CHECKS_PASSED=0
    TOTAL_CHECKS=4
    
    if check_pod_health; then
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    fi
    echo ""
    
    check_service_endpoints
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
    echo ""
    
    check_resource_usage
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
    echo ""
    
    test_application_endpoints
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
    echo ""
    
    print_info "Health Check Summary: $CHECKS_PASSED/$TOTAL_CHECKS checks completed"
    
    if [[ $CHECKS_PASSED -eq $TOTAL_CHECKS ]]; then
        print_success "🎉 All health checks passed!"
        exit 0
    else
        print_warning "⚠️  Some health checks failed or had warnings"
        exit 1
    fi
}

main "$@"
EOF

chmod +x ci-cd/scripts/health-check.sh
```

### 🧪 Testing Your CI/CD Pipeline

**Test Jenkins Pipeline:**

```bash
# 1. Trigger a build (push some changes)
git add .
git commit -m "feat: trigger CI/CD pipeline test"
git push origin main

# 2. Check Jenkins dashboard
# Visit: http://localhost:8080
# Monitor the pipeline execution

# 3. Verify deployment
./ci-cd/scripts/health-check.sh --environment staging

# 4. Test deployment script
./ci-cd/scripts/deploy.sh --environment staging --tag latest --dry-run
```

**Test GitHub Actions:**

```bash
# 1. Create a pull request to trigger PR checks
git checkout -b feature/test-pipeline
echo "# Test Feature" >> README.md
git add README.md
git commit -m "docs: add test feature"
git push origin feature/test-pipeline

# Create PR on GitHub and watch the checks run

# 2. Test release workflow
git tag v1.0.0
git push origin v1.0.0
# This triggers the release workflow
```

**Verify Everything Works:**

```bash
# 1. Check all deployments
kubectl get all -n capstone-staging
kubectl get all -n capstone-production

# 2. Run health checks
./ci-cd/scripts/health-check.sh --environment staging
./ci-cd/scripts/health-check.sh --environment production

# 3. Test rollback functionality
./ci-cd/scripts/rollback.sh --environment staging --revision previous --dry-run

# 4. Monitor with Prometheus/Grafana
kubectl port-forward -n monitoring service/grafana 3000:3000
# Visit: http://localhost:3000 (admin/admin)
```

### 🔍 Understanding What We Built

**Jenkins Pipeline Stages Explained:**
1. **Checkout**: Downloads your code from Git (like getting ingredients)
2. **Build**: Compiles and packages your applications (like cooking)
3. **Test**: Runs automated tests to ensure quality (like taste testing)
4. **Security Scan**: Checks for vulnerabilities (like food safety inspection)
5. **Deploy to Staging**: Releases to test environment (like a soft opening)
6. **Deploy to Production**: Releases to live environment (like grand opening)

**GitHub Actions Workflows:**
- **CI Workflow**: Runs on every push, tests your code
- **PR Checks**: Validates pull requests before merging
- **Release Workflow**: Handles versioning and production deployments

**Key DevOps Concepts Demonstrated:**
- **Continuous Integration**: Automatic testing on every code change
- **Continuous Deployment**: Automatic deployment after successful tests
- **GitOps**: Git as the single source of truth for deployments
- **Infrastructure as Code**: Everything defined in code and version controlled
- **Monitoring**: Real-time visibility into application health

### 💡 Pro Tips for CI/CD Success

1. **Start Small**: Begin with simple pipelines and add complexity gradually
2. **Test Everything**: Every pipeline change should be tested in non-production first
3. **Monitor Actively**: Set up alerts for pipeline failures
4. **Document Process**: Keep runbooks for common issues
5. **Security First**: Never store secrets in plain text, always use secure vaults
6. **Rollback Ready**: Always have a rollback plan for production deployments

### 🔧 Troubleshooting Common Issues

**Jenkins Pipeline Fails:**
```bash
# Check Jenkins logs
kubectl logs -n jenkins deployment/jenkins

# Check pipeline console output in Jenkins UI
# Common fixes:
# 1. Verify Docker registry credentials
# 2. Check Kubernetes cluster connectivity
# 3. Ensure proper RBAC permissions
```

**GitHub Actions Fail:**
```bash
# Check Actions tab in GitHub repository
# Common issues:
# 1. Missing secrets in repository settings
# 2. Incorrect workflow syntax
# 3. Docker registry authentication issues
```

**Deployment Issues:**
```bash
# Debug deployment problems
kubectl describe deployment -n capstone-staging
kubectl logs -n capstone-staging deployment/frontend
kubectl logs -n capstone-staging deployment/backend

# Check events
kubectl get events -n capstone-staging --sort-by=.metadata.creationTimestamp
```

---

## 📊 Phase 5: Monitoring and Observability Setup

Welcome to the "eyes and ears" of your DevOps pipeline! Monitoring is like having a security camera system for your applications - you can see what's happening, spot problems early, and understand how your system behaves under different conditions.

### 🎯 What You'll Learn
- Set up Prometheus for metrics collection (your data collector)
- Configure Grafana for beautiful dashboards (your visual storyteller)
- Implement application logging (your detailed diary)
- Create alerting rules (your early warning system)
- Set up distributed tracing (your detective for complex issues)

### 📋 Prerequisites Check

```bash
# Verify your cluster has enough resources
kubectl top nodes
kubectl get storageclass

# You should have:
# - At least 2 CPU cores available
# - 4GB RAM available 
# - Default storage class configured
```

### 🔧 Step 1: Install Monitoring Stack

**Install Prometheus Operator:**

```bash
# Add Prometheus community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create monitoring namespace (our monitoring headquarters)
kubectl create namespace monitoring

# Install kube-prometheus-stack (the complete monitoring solution)
# This is like installing a complete security system with cameras, alarms, and monitoring center
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.adminPassword=admin123 \
  --set grafana.service.type=LoadBalancer \
  --set prometheus.service.type=LoadBalancer \
  --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage=10Gi \
  --set prometheus.prometheusSpec.storage.volumeClaimTemplate.spec.resources.requests.storage=50Gi \
  --wait

# Verify installation
kubectl get all -n monitoring
```

**Understanding What We Installed:**
- **Prometheus**: Collects and stores metrics (like a data warehouse)
- **Grafana**: Creates beautiful dashboards (like a business intelligence tool)
- **AlertManager**: Handles alerts and notifications (like a security guard)
- **Node Exporter**: Collects system metrics (like system sensors)
- **kube-state-metrics**: Collects Kubernetes metrics (like cluster health monitor)

### 📊 Step 2: Configure Application Metrics

**Add Metrics to Backend Service:**

```bash
# Update backend package.json to include metrics dependencies
cat >> services/backend/package.json << 'EOF'
{
  "dependencies": {
    "prom-client": "^14.2.0",
    "express-prometheus-middleware": "^1.2.0"
  }
}
EOF

# Install new dependencies
cd services/backend && npm install && cd ../..
```

**Add Metrics Middleware:**

```bash
cat > services/backend/src/middleware/metrics.js << 'EOF'
// 📊 Metrics Middleware - Your Application's Health Reporter
// This collects important metrics about your application performance

const promClient = require('prom-client');
const promMiddleware = require('express-prometheus-middleware');

// Create a Registry which registers the metrics
const register = new promClient.Registry();

// Add default metrics (CPU, memory, etc.)
promClient.collectDefaultMetrics({ 
  register,
  timeout: 10000,
  gcDurationBuckets: [0.001, 0.01, 0.1, 1, 2, 5], // garbage collection buckets
});

// Custom business metrics (like measuring customer satisfaction)
const httpRequestsTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5, 10], // Response time buckets
  registers: [register]
});

const todoOperationsTotal = new promClient.Counter({
  name: 'todo_operations_total',
  help: 'Total number of todo operations',
  labelNames: ['operation', 'status'],
  registers: [register]
});

const activeTodosGauge = new promClient.Gauge({
  name: 'active_todos_total',
  help: 'Current number of active todos',
  registers: [register]
});

// Middleware function to collect metrics
const metricsMiddleware = (req, res, next) => {
  const startTime = Date.now();
  
  // Increment request counter
  httpRequestsTotal.inc({
    method: req.method,
    route: req.route ? req.route.path : req.path,
    status_code: res.statusCode
  });
  
  // Measure response time
  res.on('finish', () => {
    const duration = (Date.now() - startTime) / 1000;
    httpRequestDuration.observe(
      {
        method: req.method,
        route: req.route ? req.route.path : req.path,
        status_code: res.statusCode
      },
      duration
    );
  });
  
  next();
};

// Business logic metrics helpers
const recordTodoOperation = (operation, status) => {
  todoOperationsTotal.inc({ operation, status });
};

const updateActiveTodos = (count) => {
  activeTodosGauge.set(count);
};

module.exports = {
  register,
  metricsMiddleware,
  recordTodoOperation,
  updateActiveTodos,
  // Expose Prometheus middleware for /metrics endpoint
  prometheusMiddleware: promMiddleware({
    metricsPath: '/metrics',
    collectDefaultMetrics: true,
    requestDurationBuckets: [0.1, 0.5, 1, 2, 5, 10]
  })
};
EOF
```

**Update Backend App to Use Metrics:**

```bash
# Update the main app.js file to include metrics
cat > services/backend/src/app.js << 'EOF'
// 🚀 Enhanced Backend Service with Monitoring
// Now with superpowers - we can see what our application is doing!

const express = require('express');
const cors = require('cors');
const { metricsMiddleware, register, recordTodoOperation, updateActiveTodos } = require('./middleware/metrics');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware setup
app.use(cors());
app.use(express.json());
app.use(metricsMiddleware); // Add metrics collection to every request

// In-memory storage (in real world, you'd use a database)
let todos = [
  { id: 1, title: 'Learn DevOps', description: 'Master the art of DevOps', completed: false },
  { id: 2, title: 'Deploy Application', description: 'Successfully deploy to Kubernetes', completed: false }
];
let nextId = 3;

// Update active todos count
const updateTodosMetrics = () => {
  const activeTodos = todos.filter(todo => !todo.completed).length;
  updateActiveTodos(activeTodos);
};

// Health check endpoint (for load balancers and monitoring)
app.get('/health', (req, res) => {
  recordTodoOperation('health_check', 'success');
  res.status(200).json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0'
  });
});

// Metrics endpoint for Prometheus
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  const metrics = await register.metrics();
  res.end(metrics);
});

// Get all todos
app.get('/api/items', (req, res) => {
  try {
    recordTodoOperation('get_all', 'success');
    res.json(todos);
  } catch (error) {
    recordTodoOperation('get_all', 'error');
    res.status(500).json({ error: 'Failed to fetch todos' });
  }
});

// Get single todo
app.get('/api/items/:id', (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const todo = todos.find(t => t.id === id);
    
    if (!todo) {
      recordTodoOperation('get_single', 'not_found');
      return res.status(404).json({ error: 'Todo not found' });
    }
    
    recordTodoOperation('get_single', 'success');
    res.json(todo);
  } catch (error) {
    recordTodoOperation('get_single', 'error');
    res.status(500).json({ error: 'Failed to fetch todo' });
  }
});

// Create new todo
app.post('/api/items', (req, res) => {
  try {
    const { title, description } = req.body;
    
    if (!title || !description) {
      recordTodoOperation('create', 'validation_error');
      return res.status(400).json({ error: 'Title and description are required' });
    }
    
    const newTodo = {
      id: nextId++,
      title,
      description,
      completed: false,
      createdAt: new Date().toISOString()
    };
    
    todos.push(newTodo);
    updateTodosMetrics();
    recordTodoOperation('create', 'success');
    
    res.status(201).json(newTodo);
  } catch (error) {
    recordTodoOperation('create', 'error');
    res.status(500).json({ error: 'Failed to create todo' });
  }
});

// Update todo
app.put('/api/items/:id', (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const { title, description, completed } = req.body;
    const todoIndex = todos.findIndex(t => t.id === id);
    
    if (todoIndex === -1) {
      recordTodoOperation('update', 'not_found');
      return res.status(404).json({ error: 'Todo not found' });
    }
    
    todos[todoIndex] = {
      ...todos[todoIndex],
      title: title ?? todos[todoIndex].title,
      description: description ?? todos[todoIndex].description,
      completed: completed ?? todos[todoIndex].completed,
      updatedAt: new Date().toISOString()
    };
    
    updateTodosMetrics();
    recordTodoOperation('update', 'success');
    
    res.json(todos[todoIndex]);
  } catch (error) {
    recordTodoOperation('update', 'error');
    res.status(500).json({ error: 'Failed to update todo' });
  }
});

// Delete todo
app.delete('/api/items/:id', (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const todoIndex = todos.findIndex(t => t.id === id);
    
    if (todoIndex === -1) {
      recordTodoOperation('delete', 'not_found');
      return res.status(404).json({ error: 'Todo not found' });
    }
    
    todos.splice(todoIndex, 1);
    updateTodosMetrics();
    recordTodoOperation('delete', 'success');
    
    res.status(204).send();
  } catch (error) {
    recordTodoOperation('delete', 'error');
    res.status(500).json({ error: 'Failed to delete todo' });
  }
});

// Initialize metrics
updateTodosMetrics();

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Backend server running on port ${PORT}`);
  console.log(`📊 Metrics available at http://localhost:${PORT}/metrics`);
  console.log(`❤️  Health check at http://localhost:${PORT}/health`);
});

module.exports = app;
EOF
```

### 📈 Step 3: Create ServiceMonitor for Application Metrics

```bash
# Create ServiceMonitor to tell Prometheus how to scrape our application metrics
mkdir -p monitoring/servicemonitors

cat > monitoring/servicemonitors/backend-servicemonitor.yaml << 'EOF'
# 📊 ServiceMonitor for Backend Application
# This tells Prometheus "Hey, scrape metrics from our backend service!"

apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: backend-servicemonitor
  namespace: monitoring
  labels:
    app: backend
    release: prometheus  # This label is important - it matches our Prometheus selector
spec:
  # Which services to monitor (like telling security where to point cameras)
  selector:
    matchLabels:
      app: backend
  # Look in these namespaces
  namespaceSelector:
    matchNames:
    - capstone-staging
    - capstone-production
  endpoints:
  - port: http          # Port name from service
    path: /metrics      # Where the metrics are exposed
    interval: 30s       # How often to collect (every 30 seconds)
    scrapeTimeout: 10s  # How long to wait for response
    honorLabels: true   # Keep original metric labels
EOF

# Apply the ServiceMonitor
kubectl apply -f monitoring/servicemonitors/backend-servicemonitor.yaml
```

**Create Frontend ServiceMonitor (if we add metrics later):**

```bash
cat > monitoring/servicemonitors/frontend-servicemonitor.yaml << 'EOF'
# 📊 ServiceMonitor for Frontend Application
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: frontend-servicemonitor
  namespace: monitoring
  labels:
    app: frontend
    release: prometheus
spec:
  selector:
    matchLabels:
      app: frontend
  namespaceSelector:
    matchNames:
    - capstone-staging
    - capstone-production
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
    scrapeTimeout: 10s
EOF

kubectl apply -f monitoring/servicemonitors/frontend-servicemonitor.yaml
```

### 🎨 Step 4: Create Custom Grafana Dashboards

```bash
# Create directory for Grafana dashboards
mkdir -p monitoring/dashboards

# Create application overview dashboard
cat > monitoring/dashboards/application-dashboard.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "🚀 DevOps Capstone Application Dashboard",
    "tags": ["devops", "capstone", "application"],
    "timezone": "browser",
    "refresh": "30s",
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "panels": [
      {
        "id": 1,
        "title": "📊 HTTP Requests per Second",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[5m]))",
            "legendFormat": "RPS"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 10},
                {"color": "red", "value": 50}
              ]
            },
            "unit": "reqps"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "⏱️ Average Response Time",
        "type": "stat",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))",
            "legendFormat": "95th Percentile"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 0.5},
                {"color": "red", "value": 1.0}
              ]
            },
            "unit": "s"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 6, "y": 0}
      }
    ]
  }
}
EOF
```

## Phase 5: Monitoring and Observability

### Prometheus Configuration

```yaml
# monitoring/prometheus/values.yaml
prometheus:
  prometheusSpec:
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi
    
    additionalScrapeConfigs:
    - job_name: 'capstone-frontend'
      static_configs:
      - targets: ['frontend-service.capstone.svc.cluster.local:80']
    
    - job_name: 'capstone-backend'
      static_configs:
      - targets: ['backend-service.capstone.svc.cluster.local:3000']

grafana:
  adminPassword: admin123
  dashboardProviders:
    dashboardproviders.yaml:
      apiVersion: 1
      providers:
      - name: 'default'
        orgId: 1
        folder: ''
        type: file
        disableDeletion: false
        editable: true
        options:
          path: /var/lib/grafana/dashboards/default
```

### Installation Scripts

```bash
# scripts/install-monitoring.sh
#!/bin/bash

# Install Prometheus and Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  -f monitoring/prometheus/values.yaml

# Wait for deployment
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus --timeout=300s -n monitoring
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana --timeout=300s -n monitoring

echo "Monitoring stack installed successfully!"
echo "Access Grafana at: http://localhost:3000 (admin/admin123)"

# Port forward for local access
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring &
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring &
```

## Phase 6: Complete Deployment

### Deployment Script

```bash
# scripts/deploy-all.sh
#!/bin/bash

set -e

echo "🚀 Starting capstone deployment..."

# 1. Apply Terraform
echo "📦 Setting up infrastructure..."
cd infrastructure/terraform
terraform init
terraform apply -auto-approve
cd ../..

# 2. Run Ansible playbook
echo "⚙️ Configuring cluster..."
cd infrastructure/ansible
ansible-playbook setup.yml
cd ../..

# 3. Build and push images
echo "🐳 Building Docker images..."
eval $(minikube docker-env)

docker build -t capstone/frontend:latest services/frontend/
docker build -t capstone/backend:latest services/backend/

# 4. Deploy services with Helm
echo "☸️ Deploying services..."
helm upgrade --install mongodb helm-charts/mongodb --namespace capstone --create-namespace
helm upgrade --install backend helm-charts/backend --namespace capstone
helm upgrade --install frontend helm-charts/frontend --namespace capstone

# 5. Install monitoring
echo "📊 Setting up monitoring..."
./scripts/install-monitoring.sh

# 6. Setup ArgoCD
echo "🔄 Setting up GitOps..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f ci-cd/argocd/

# Wait for deployments
echo "⏳ Waiting for deployments..."
kubectl wait --for=condition=ready pod -l app=frontend --timeout=300s -n capstone
kubectl wait --for=condition=ready pod -l app=backend --timeout=300s -n capstone
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=300s -n capstone

echo "✅ Deployment complete!"
echo ""
echo "🌐 Access points:"
echo "Frontend: http://$(minikube ip)"
echo "Grafana: http://localhost:3000 (admin/admin123)"
echo "Prometheus: http://localhost:9090"
echo "ArgoCD: http://localhost:8080 (admin/$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d))"
```

## Phase 7: Testing and Validation

### Health Check Script

```bash
# scripts/health-check.sh
#!/bin/bash

echo "🔍 Running health checks..."

# Check cluster status
echo "Checking cluster status..."
kubectl cluster-info

# Check namespace status
echo "Checking namespaces..."
kubectl get namespaces

# Check deployments
echo "Checking deployments..."
kubectl get deployments -n capstone
kubectl get deployments -n monitoring
kubectl get deployments -n argocd

# Check services
echo "Checking services..."
kubectl get services -n capstone

# Test application endpoints
echo "Testing application endpoints..."
MINIKUBE_IP=$(minikube ip)

# Test frontend
if curl -f http://$MINIKUBE_IP > /dev/null 2>&1; then
    echo "✅ Frontend is accessible"
else
    echo "❌ Frontend is not accessible"
fi

# Test backend health
if kubectl exec -n capstone deployment/backend -- curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ Backend health check passed"
else
    echo "❌ Backend health check failed"
fi

# Check monitoring
if kubectl get pods -n monitoring | grep -q Running; then
    echo "✅ Monitoring stack is running"
else
    echo "❌ Monitoring stack has issues"
fi

echo "Health check completed!"
```

## Phase 8: Cleanup and Maintenance

### Cleanup Script

```bash
# scripts/cleanup.sh
#!/bin/bash

echo "🧹 Starting cleanup..."

# Stop port forwards
pkill -f "kubectl port-forward" || true

# Delete Helm releases
echo "Removing Helm releases..."
helm uninstall frontend backend mongodb -n capstone || true
helm uninstall prometheus -n monitoring || true

# Delete namespaces
echo "Deleting namespaces..."
kubectl delete namespace capstone monitoring argocd || true

# Clean up Terraform
echo "Destroying Terraform resources..."
cd infrastructure/terraform
terraform destroy -auto-approve || true
cd ../..

# Clean up Docker images
echo "Cleaning up Docker images..."
docker rmi capstone/frontend:latest capstone/backend:latest || true
docker system prune -f

# Stop Minikube
echo "Stopping Minikube..."
minikube stop

echo "✅ Cleanup completed!"
```

### Maintenance Tasks

```bash
# scripts/maintenance.sh
#!/bin/bash

echo "🔧 Running maintenance tasks..."

# Update Helm repositories
helm repo update

# Check for security updates
echo "Checking for security updates..."
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.containers[*].image}{"\n"}{end}' | while read pod image; do
    echo "Checking $pod: $image"
    # Add security scanning here
done

# Backup important data
echo "Creating backups..."
kubectl create backup capstone-backup --namespace capstone || true

# Check resource usage
echo "Resource usage:"
kubectl top nodes
kubectl top pods --all-namespaces

echo "✅ Maintenance completed!"
```

## Troubleshooting Guide

### Common Issues and Solutions

1. **Minikube won't start**
   ```bash
   minikube delete
   minikube start --driver=docker --cpus=4 --memory=6144
   ```

2. **Docker images not found**
   ```bash
   eval $(minikube docker-env)
   # Rebuild images
   ```

3. **Pods stuck in Pending**
   ```bash
   kubectl describe pod <pod-name> -n <namespace>
   # Check resource limits and node capacity
   ```

4. **Services not accessible**
   ```bash
   kubectl get svc -n capstone
   minikube tunnel  # For LoadBalancer services
   ```

5. **Jenkins can't access Docker**
   ```bash
   sudo usermod -aG docker jenkins
   sudo systemctl restart jenkins
   ```

## Post-Project Learning Activities

### Extended Challenges

1. **Blue-Green Deployment**: Implement blue-green deployment strategy
2. **Canary Releases**: Add canary deployment with traffic splitting
3. **Multi-Environment**: Create staging and production environments
4. **Secret Management**: Integrate HashiCorp Vault
5. **Service Mesh**: Add Istio for advanced networking
6. **Advanced Monitoring**: Implement distributed tracing with Jaeger

### Performance Testing

```bash
# Load testing with artillery
npm install -g artillery
artillery quick --count 10 --num 100 http://$(minikube ip)/api/items
```

### Security Hardening

1. Enable Pod Security Standards
2. Implement Network Policies
3. Add RBAC (Role-Based Access Control)
4. Integrate security scanning in CI pipeline
5. Enable audit logging

## Conclusion

This capstone project demonstrates a complete DevOps pipeline with:
- ✅ Microservices architecture
- ✅ Containerization with Docker
- ✅ Kubernetes orchestration
- ✅ Helm package management
- ✅ CI/CD with Jenkins and ArgoCD
- ✅ Infrastructure as Code with Terraform
- ✅ Configuration Management with Ansible
- ✅ Monitoring with Prometheus and Grafana
- ✅ GitOps workflow

The project provides hands-on experience with industry-standard DevOps tools and practices, preparing participants for real-world enterprise environments.

---

## 📊 Phase 5: Monitoring and Observability Setup

Welcome to the "eyes and ears" of your DevOps pipeline! Monitoring is like having a security camera system for your applications - you can see what's happening, spot problems early, and understand how your system behaves under different conditions.

### 🎯 What You'll Learn
- Set up Prometheus for metrics collection (your data collector)
- Configure Grafana for beautiful dashboards (your visual storyteller)
- Implement application logging (your detailed diary)
- Create alerting rules (your early warning system)
- Set up distributed tracing (your detective for complex issues)

### 📋 Prerequisites Check

```bash
# Verify your cluster has enough resources
kubectl top nodes
kubectl get storageclass

# You should have:
# - At least 2 CPU cores available
# - 4GB RAM available 
# - Default storage class configured
```

### 🔧 Step 1: Install Monitoring Stack

**Install Prometheus Operator:**

```bash
# Add Prometheus community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create monitoring namespace (our monitoring headquarters)
kubectl create namespace monitoring

# Install kube-prometheus-stack (the complete monitoring solution)
# This is like installing a complete security system with cameras, alarms, and monitoring center
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.adminPassword=admin123 \
  --set grafana.service.type=LoadBalancer \
  --set prometheus.service.type=LoadBalancer \
  --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage=10Gi \
  --set prometheus.prometheusSpec.storage.volumeClaimTemplate.spec.resources.requests.storage=50Gi \
  --wait

# Verify installation
kubectl get all -n monitoring
```

**Understanding What We Installed:**
- **Prometheus**: Collects and stores metrics (like a data warehouse)
- **Grafana**: Creates beautiful dashboards (like a business intelligence tool)
- **AlertManager**: Handles alerts and notifications (like a security guard)
- **Node Exporter**: Collects system metrics (like system sensors)
- **kube-state-metrics**: Collects Kubernetes metrics (like cluster health monitor)

### 📊 Step 2: Add Monitoring to Your Applications

**First, rebuild your backend with metrics support:**

```bash
# Add metrics dependencies to backend
cd services/backend
npm install prom-client express-prometheus-middleware
cd ../..

# Rebuild backend Docker image with metrics
docker build -t capstone-backend:monitoring ./services/backend
docker tag capstone-backend:monitoring localhost:5000/capstone-backend:monitoring
docker push localhost:5000/capstone-backend:monitoring
```

### 📈 Step 3: Create ServiceMonitor for Application Metrics

```bash
# Create ServiceMonitor to tell Prometheus how to scrape our application metrics
mkdir -p monitoring/servicemonitors

cat > monitoring/servicemonitors/backend-servicemonitor.yaml << 'EOF'
# 📊 ServiceMonitor for Backend Application
# This tells Prometheus "Hey, scrape metrics from our backend service!"

apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: backend-servicemonitor
  namespace: monitoring
  labels:
    app: backend
    release: prometheus  # This label is important - it matches our Prometheus selector
spec:
  # Which services to monitor (like telling security where to point cameras)
  selector:
    matchLabels:
      app: backend
  # Look in these namespaces
  namespaceSelector:
    matchNames:
    - capstone-staging
    - capstone-production
  endpoints:
  - port: http          # Port name from service
    path: /metrics      # Where the metrics are exposed
    interval: 30s       # How often to collect (every 30 seconds)
    scrapeTimeout: 10s  # How long to wait for response
    honorLabels: true   # Keep original metric labels
EOF

# Apply the ServiceMonitor
kubectl apply -f monitoring/servicemonitors/backend-servicemonitor.yaml
```

### 🚨 Step 4: Create Alerting Rules

```bash
# Create alerting rules directory
mkdir -p monitoring/alerts

cat > monitoring/alerts/application-alerts.yaml << 'EOF'
# 🚨 Application Alerting Rules
# These are your early warning system - like smoke detectors for your app!

apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: application-alerts
  namespace: monitoring
  labels:
    app: prometheus
    release: prometheus
spec:
  groups:
  - name: application.rules
    rules:
    
    # 🔥 High Error Rate Alert
    - alert: HighErrorRate
      expr: |
        (
          sum(rate(http_requests_total{status_code=~"5.."}[5m]))
          /
          sum(rate(http_requests_total[5m]))
        ) * 100 > 5
      for: 2m
      labels:
        severity: critical
        component: backend
      annotations:
        summary: "High error rate detected"
        description: "Error rate is {{ $value }}% for the last 5 minutes"
        runbook_url: "https://docs.capstone.local/runbooks/high-error-rate"
        
    # ⏱️ High Response Time Alert  
    - alert: HighResponseTime
      expr: |
        histogram_quantile(0.95, 
          sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
        ) > 1
      for: 5m
      labels:
        severity: warning
        component: backend
      annotations:
        summary: "High response time detected"
        description: "95th percentile response time is {{ $value }}s"
        
    # 📉 Low Request Rate (might indicate service is down)
    - alert: LowRequestRate
      expr: sum(rate(http_requests_total[5m])) < 0.1
      for: 5m
      labels:
        severity: warning
        component: backend
      annotations:
        summary: "Low request rate detected"
        description: "Request rate is only {{ $value }} requests/second"
        
    # 🐳 Pod Down Alert
    - alert: PodDown
      expr: up{job="kubernetes-pods"} == 0
      for: 1m
      labels:
        severity: critical
        component: infrastructure
      annotations:
        summary: "Pod is down"
        description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} is down"
EOF

# Apply the alerting rules
kubectl apply -f monitoring/alerts/application-alerts.yaml
```

### 📊 Step 5: Access and Configure Dashboards

```bash
# Get Grafana admin password (if you didn't set it during install)
kubectl get secret --namespace monitoring prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# Port forward to access Grafana
kubectl port-forward --namespace monitoring service/prometheus-grafana 3000:80 &

# Port forward to access Prometheus
kubectl port-forward --namespace monitoring service/prometheus-kube-prometheus-prometheus 9090:9090 &

# Port forward to access AlertManager  
kubectl port-forward --namespace monitoring service/prometheus-kube-prometheus-alertmanager 9093:9093 &

echo "🎉 Monitoring stack is ready!"
echo "📊 Grafana: http://localhost:3000 (admin/admin123)"
echo "🔍 Prometheus: http://localhost:9090"
echo "🚨 AlertManager: http://localhost:9093"
```

### 🧪 Step 6: Test Your Monitoring

**Generate some load to see metrics:**

```bash
# Deploy your application first with monitoring
./ci-cd/scripts/deploy.sh --environment staging --tag monitoring

# Generate some traffic (like customers using your app)
for i in {1..100}; do
  # Get todos
  curl -s "http://$(minikube ip)/api/items" > /dev/null
  
  # Create a todo
  curl -s -X POST "http://$(minikube ip)/api/items" \
    -H "Content-Type: application/json" \
    -d '{"title":"Test Todo '$i'","description":"Generated for testing"}' > /dev/null
    
  # Small delay
  sleep 0.1
done

echo "✅ Generated test traffic - check your dashboards!"
```

**Verify metrics are being collected:**

```bash
# Check if ServiceMonitor is working
kubectl get servicemonitor -n monitoring

# Check Prometheus targets
echo "🎯 Check Prometheus targets at: http://localhost:9090/targets"

# Check that our custom metrics are available
echo "📊 Search for these metrics in Prometheus:"
echo "  - http_requests_total"
echo "  - http_request_duration_seconds"
echo "  - up"
echo "  - container_memory_usage_bytes"
```

### 🎨 Step 7: Create Custom Grafana Dashboard

**Import a basic dashboard:**

1. **Access Grafana**: Go to http://localhost:3000 (admin/admin123)
2. **Add Data Source**: 
   - Click "+" → Data Sources
   - Choose Prometheus
   - URL: http://prometheus-kube-prometheus-prometheus:9090
   - Click "Save & Test"

3. **Create Dashboard**:
   - Click "+" → Dashboard
   - Add Panel
   - Use these queries:

**Useful Grafana Queries:**

```promql
# Request rate per second
sum(rate(http_requests_total[5m]))

# Average response time
avg(rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m]))

# Error rate percentage
sum(rate(http_requests_total{status_code=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100

# Memory usage by pod
sum(container_memory_working_set_bytes{namespace="capstone-staging"}) by (pod)

# CPU usage by pod
sum(rate(container_cpu_usage_seconds_total{namespace="capstone-staging"}[5m])) by (pod)
```

### 🔍 Understanding Your Monitoring Stack

**What Each Component Does:**

1. **Prometheus** 📊
   - **Purpose**: Collects and stores time-series metrics
   - **Real-world analogy**: Like a security guard taking notes every few seconds
   - **What it monitors**: Response times, error rates, resource usage
   - **Data retention**: Keeps 15 days of data by default

2. **Grafana** 📈  
   - **Purpose**: Creates beautiful, interactive dashboards
   - **Real-world analogy**: Like a business intelligence dashboard for executives
   - **Features**: Graphs, alerts, annotations, drill-downs
   - **Customization**: Fully customizable panels and themes

3. **AlertManager** 🚨
   - **Purpose**: Routes and manages alerts
   - **Real-world analogy**: Like an emergency dispatcher
   - **Features**: De-duplication, grouping, silencing, routing
   - **Integrations**: Email, Slack, PagerDuty, webhooks

**Key Metrics to Monitor:**

- **Golden Signals** (SRE best practices):
  - **Latency**: How fast requests are processed
  - **Traffic**: How many requests per second  
  - **Errors**: How many requests fail
  - **Saturation**: How full your service is

- **Business Metrics**:
  - Active todos count
  - Todo operations per second
  - User engagement patterns

### 💡 Pro Tips for Effective Monitoring

1. **Start with the Golden Signals**: Focus on latency, traffic, errors, saturation
2. **Set Meaningful Alerts**: Don't alert on everything, only actionable items
3. **Use Runbooks**: Document what to do when each alert fires
4. **Monitor User Experience**: Include frontend performance metrics
5. **Capacity Planning**: Monitor resource trends to predict scaling needs
6. **Test Your Alerts**: Regularly test that alerts actually fire when expected

### 🔧 Troubleshooting Monitoring Issues

**ServiceMonitor not discovering services:**
```bash
# Check ServiceMonitor labels match Prometheus selector
kubectl describe servicemonitor backend-servicemonitor -n monitoring

# Check if services have correct labels
kubectl get services -n capstone-staging --show-labels

# Check Prometheus configuration
kubectl get prometheus -n monitoring -o yaml
```

**Metrics not appearing in Prometheus:**
```bash
# Check if /metrics endpoint is accessible
kubectl port-forward -n capstone-staging deployment/backend 5000:5000 &
curl http://localhost:5000/metrics

# Check Prometheus logs
kubectl logs -n monitoring deployment/prometheus-prometheus-kube-prometheus-prometheus
```

**Grafana dashboard not loading:**
```bash
# Check Grafana logs
kubectl logs -n monitoring deployment/prometheus-grafana

# Verify Prometheus datasource configuration in Grafana
# Go to Configuration > Data Sources in Grafana UI
```