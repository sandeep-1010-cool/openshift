# Day 01: Introduction to OpenShift - Architecture & Cluster Components

## 🎯 Learning Objectives

By the end of this lesson, you will be able to:
- Understand OpenShift's architecture and how it extends Kubernetes
- Identify key OpenShift cluster components
- Explain the difference between OpenShift and vanilla Kubernetes
- Navigate the OpenShift web console
- Understand the concept of projects and namespaces
- Perform basic cluster exploration and resource investigation

---

## 📚 Theory Section

### What is OpenShift?

**Red Hat OpenShift** is a Kubernetes-based container platform that provides:
- **Enterprise Kubernetes**: Production-ready Kubernetes distribution
- **Developer Experience**: Built-in CI/CD, monitoring, and developer tools
- **Security**: Enhanced security features and compliance
- **Multi-tenancy**: Advanced project and user management
- **Operators**: Automated application lifecycle management

### OpenShift vs Kubernetes

| Feature | Kubernetes | OpenShift |
|---------|------------|-----------|
| **Installation** | Manual setup required | Automated installation |
| **Web Console** | Basic dashboard | Rich web interface |
| **Security** | Basic RBAC | Enhanced security policies |
| **Networking** | CNI plugins | OpenShift SDN |
| **Build Process** | Manual | Integrated build system |
| **Image Registry** | External | Built-in registry |

### OpenShift Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    OpenShift Cluster                       │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │
│  │   Master    │  │   Master    │  │   Master    │      │
│  │   Node      │  │   Node      │  │   Node      │      │
│  │             │  │             │  │             │      │
│  │ • API Server│  │ • API Server│  │ • API Server│      │
│  │ • etcd      │  │ • etcd      │  │ • etcd      │      │
│  │ • Controller│  │ • Controller│  │ • Controller│      │
│  │ • Scheduler │  │ • Scheduler │  │ • Scheduler │      │
│  └─────────────┘  └─────────────┘  └─────────────┘      │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │
│  │   Worker    │  │   Worker    │  │   Worker    │      │
│  │   Node      │  │   Node      │  │   Node      │      │
│  │             │  │             │  │             │      │
│  │ • Kubelet   │  │ • Kubelet   │  │ • Kubelet   │      │
│  │ • Container │  │ • Container │  │ • Container │      │
│  │ • Runtime   │  │ • Runtime   │  │ • Runtime   │      │
│  │ • Proxy     │  │ • Proxy     │  │ • Proxy     │      │
│  └─────────────┘  └─────────────┘  └─────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### Key OpenShift Components

#### 1. **Master Nodes**
- **API Server**: REST API endpoint for cluster operations
- **etcd**: Distributed key-value store for cluster data
- **Controller Manager**: Manages cluster state and controllers
- **Scheduler**: Assigns pods to nodes based on policies

#### 2. **Worker Nodes**
- **Kubelet**: Primary node agent that manages containers
- **Container Runtime**: Runs containers (CRI-O in OpenShift)
- **Kube-proxy**: Network proxy for service communication
- **OpenShift SDN**: Software-defined networking

#### 3. **Infrastructure Components**
- **OpenShift Router**: Ingress controller for external traffic
- **Registry**: Built-in container image registry
- **Build System**: Source-to-image (S2I) and Docker builds
- **Monitoring**: Prometheus, Grafana, and alerting

---

## 🛠️ Hands-On Lab

### Prerequisites

> **📋 Reference**: See [shared/prerequisites.md](../shared/prerequisites.md) for detailed prerequisites and installation instructions.

- OpenShift cluster access (CRC, Minishift, or remote cluster)
- OpenShift CLI (`oc`) installed
- Web browser for console access

### Exercise 1: Accessing Your OpenShift Cluster

#### Step 1: Login to OpenShift CLI
```bash
# Login to your cluster
oc login -u <username> -p <password> <cluster-url>

# Example for CRC (CodeReady Containers)
oc login -u kubeadmin -p <password> https://api.crc.testing:6443
```

#### Step 2: Check Cluster Status
```bash
# View cluster information
oc cluster-info

# Check node status
oc get nodes

# View cluster operators
oc get clusteroperators
```

#### Step 3: Access Web Console
```bash
# Get console URL
oc whoami --show-console

# Or use this command to open console
oc console
```

### Exercise 2: Exploring the Web Console

1. **Navigate to the Console**
   - Open your browser and go to the console URL
   - Login with your credentials

2. **Explore Key Areas**:
   - **Home**: Overview of your projects and resources
   - **Projects**: List of projects you have access to
   - **Catalog**: Application templates and operators
   - **Monitoring**: Metrics and alerts
   - **Storage**: Persistent volumes and storage classes

3. **Check Cluster Status**:
   - Go to **Administration** → **Cluster Settings**
   - Review cluster operators and their status
   - Check cluster version and updates

### Exercise 3: Understanding Projects and Namespaces

#### Step 1: List Projects
```bash
# List all projects you have access to
oc get projects
```

#### Step 2: Create a New Project
```bash
# Create a new project
oc new-project my-first-project --description="My first OpenShift project"

# Verify project creation
oc project my-first-project
```

#### Step 3: Explore Project Resources
```bash
# List all resources in the project
oc get all

# Check project quotas and limits
oc describe project my-first-project
```

### Exercise 4: Basic Resource Exploration

```bash
# Get current context
oc whoami
oc project

# List basic resources
oc get pods
oc get services
oc get routes

# Describe resources
oc describe pod <pod-name>
oc describe service <service-name>
```

---

## 📋 Lab Tasks

### Task 1: Cluster Exploration
- [ ] Login to your OpenShift cluster
- [ ] List all nodes and their status
- [ ] Check cluster operators status
- [ ] Access the web console

### Task 2: Project Management
- [ ] Create a new project called `day01-lab`
- [ ] List all projects you have access to
- [ ] Switch between different projects
- [ ] Explore project quotas and limits

### Task 3: Basic Resource Investigation
- [ ] List all resources in your project
- [ ] Describe a resource (pod, service, etc.)
- [ ] Check project events

### Task 4: Console Navigation
- [ ] Navigate through all main console sections
- [ ] Find cluster information in the console
- [ ] Explore the developer catalog
- [ ] Check monitoring dashboards

---

## 🧪 Challenge Exercise

### Advanced Challenge: Cluster Analysis

Create a comprehensive report of your OpenShift cluster:

1. **Cluster Information**
   ```bash
   # Gather cluster details
   oc cluster-info
   oc version
   oc get nodes -o wide
   ```

2. **Resource Analysis**
   ```bash
   # Check cluster capacity
   oc get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.capacity.cpu}{"\t"}{.status.capacity.memory}{"\n"}{end}'
   ```

3. **Operator Status**
   ```bash
   # Check all operators
   oc get clusteroperators
   oc get clusteroperators -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.conditions[?(@.type=="Available")].status}{"\n"}{end}'
   ```

4. **Create a Report**
   - Document your findings
   - Include screenshots of the web console
   - Note any issues or interesting observations

---

## 📖 Key Takeaways

### What You Learned Today:
- ✅ OpenShift extends Kubernetes with enterprise features
- ✅ Master and worker nodes have specific roles
- ✅ Projects provide multi-tenancy and resource isolation
- ✅ Web console offers rich management interface
- ✅ Basic CLI commands for cluster exploration
- ✅ Fundamental resource investigation techniques

### Next Steps:
- **Day 02**: OpenShift CLI mastery and user management
- **Day 03**: Deploying your first application
- **Day 04**: Configuration management with ConfigMaps and Secrets

---

## 🔗 Additional Resources

> **📋 Reference**: See [shared/common-commands.md](../shared/common-commands.md) for comprehensive OpenShift command reference.

- [OpenShift Documentation](https://docs.openshift.com/)
- [OpenShift Architecture](https://docs.openshift.com/container-platform/4.10/architecture/index.html)
- [OpenShift CLI Reference](https://docs.openshift.com/container-platform/4.10/cli_reference/openshift_cli/)
- [OpenShift Console Guide](https://docs.openshift.com/container-platform/4.10/web_console/index.html)

---

## ❓ Troubleshooting

> **📋 Reference**: See [shared/troubleshooting.md](../shared/troubleshooting.md) for comprehensive troubleshooting guide.

### Common Issues for This Lesson:

1. **Login Problems**
   ```bash
   # Clear login cache
   oc logout
   oc login -u <username> -p <password> <cluster-url>
   ```

2. **Permission Issues**
   ```bash
   # Check your permissions
   oc auth can-i list projects
   oc auth can-i create projects
   ```

3. **Console Access**
   ```bash
   # Get console URL
   oc whoami --show-console
   # Or use port-forward if needed
   oc port-forward svc/console 8080:443 -n openshift-console
   ```

---

**🎉 Congratulations! You've completed Day 01 of the OpenShift Learning Series!**

Ready for Day 02? Let's dive into OpenShift CLI mastery and user management! 