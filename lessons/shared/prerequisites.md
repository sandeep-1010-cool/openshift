# Shared Prerequisites

## 🛠️ Prerequisites

### Basic Requirements
- OpenShift cluster access (from previous days)
- OpenShift CLI (`oc`) installed and configured
- Web browser for console access
- Basic understanding of Kubernetes concepts (preferred)

### Day-Specific Requirements

#### Day 01: Introduction to OpenShift
- OpenShift cluster access (CRC, Minishift, or remote cluster)
- OpenShift CLI (`oc`) installed

#### Day 02: OpenShift CLI & Projects
- OpenShift cluster access (from Day 01)
- OpenShift CLI (`oc`) installed and configured
- Admin access or ability to create projects

#### Day 03: Deploying Applications
- OpenShift cluster access (from Day 01 & 02)
- OpenShift CLI (`oc`) installed and configured
- Basic understanding of container images and deployments
- Git repository with sample application code

#### Day 04: ConfigMaps & Secrets
- OpenShift cluster access (from previous days)
- OpenShift CLI (`oc`) installed and configured
- Understanding of basic application deployment

#### Day 05: Persistent Storage
- OpenShift cluster access (from previous days)
- OpenShift CLI (`oc`) installed and configured
- Understanding of basic storage concepts

#### Day 06: CI/CD Pipelines
- OpenShift cluster access (from previous days)
- OpenShift CLI (`oc`) installed and configured
- Understanding of CI/CD concepts
- Git repository access

#### Day 07: Monitoring & Logging
- OpenShift cluster access (from previous days)
- OpenShift CLI (`oc`) installed and configured
- Understanding of monitoring concepts

#### Day 08: Security & Policies
- OpenShift cluster access (from previous days)
- OpenShift CLI (`oc`) installed and configured
- Admin access for security configurations

#### Day 09: Operators & Helm
- OpenShift cluster access (from previous days)
- OpenShift CLI (`oc`) installed and configured
- Admin access for operator installation
- Understanding of basic Kubernetes concepts
- Helm 3 installed (optional for advanced exercises)

#### Day 10: Advanced Topics
- OpenShift cluster access (from previous days)
- OpenShift CLI (`oc`) installed and configured
- Admin access for cluster operations
- Understanding of Git and version control
- Access to Git repository (GitHub, GitLab, etc.)

### Installation Commands

#### Install OpenShift CLI
```bash
# Download OpenShift CLI
curl -L https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz | tar xz

# Move to PATH
sudo mv oc /usr/local/bin/

# Verify installation
oc version
```

#### Install Helm (for Day 09+)
```bash
# Download Helm
curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar xz

# Move to PATH
sudo mv linux-amd64/helm /usr/local/bin/

# Verify installation
helm version
```

### Cluster Access Commands

#### Login to OpenShift
```bash
# Basic login
oc login -u <username> -p <password> <cluster-url>

# Example for CRC (CodeReady Containers)
oc login -u kubeadmin -p <password> https://api.crc.testing:6443

# Check login status
oc whoami
```

#### Verify Cluster Access
```bash
# Check cluster information
oc cluster-info

# Check node status
oc get nodes

# Check cluster operators
oc get clusteroperators
``` 