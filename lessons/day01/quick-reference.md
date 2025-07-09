# Day 01 Quick Reference Guide

## 🚀 Essential OpenShift Commands

### Authentication & Access
```bash
# Login to cluster
oc login -u <username> -p <password> <cluster-url>

# Check current user
oc whoami

# Get console URL
oc whoami --show-console

# Open web console
oc console

# Logout
oc logout
```

### Cluster Information
```bash
# Get cluster info
oc cluster-info

# Check OpenShift version
oc version

# List all nodes
oc get nodes

# List cluster operators
oc get clusteroperators

# Get detailed node info
oc get nodes -o wide
```

### Project Management
```bash
# List projects
oc get projects

# Create new project
oc new-project <project-name> --description="Description"

# Switch to project
oc project <project-name>

# Get current project
oc project -q

# Delete project
oc delete project <project-name>
```

### Resource Management
```bash
# List all resources in project
oc get all

# List specific resources
oc get pods
oc get services
oc get routes
oc get deployments

# Describe resource
oc describe <resource-type> <resource-name>

# View logs
oc logs <pod-name>
oc logs -f <pod-name>  # Follow logs
```

### Permissions & Security
```bash
# Check permissions
oc auth can-i <action> <resource>

# Examples
oc auth can-i list projects
oc auth can-i create projects
oc auth can-i list pods
oc auth can-i create pods
```

## 📊 Key Concepts

### OpenShift vs Kubernetes
| Aspect | Kubernetes | OpenShift |
|--------|------------|-----------|
| **Installation** | Manual | Automated |
| **Console** | Basic | Rich web interface |
| **Security** | Basic RBAC | Enhanced policies |
| **Projects** | Namespaces | Enhanced namespaces |
| **Build** | Manual | Integrated S2I |

### Cluster Components
- **Master Nodes**: API Server, etcd, Controller Manager, Scheduler
- **Worker Nodes**: Kubelet, Container Runtime, Kube-proxy
- **Infrastructure**: Router, Registry, Build System, Monitoring

### Project Structure
```
Project (Namespace)
├── Pods
├── Services
├── Routes
├── Deployments
├── ConfigMaps
├── Secrets
└── Persistent Volumes
```

## 🎯 Common Tasks

### 1. Initial Setup
```bash
# 1. Login to cluster
oc login -u kubeadmin -p <password> https://api.crc.testing:6443

# 2. Check cluster status
oc get nodes
oc get clusteroperators

# 3. Create your first project
oc new-project my-first-project
```

### 2. Explore Your Environment
```bash
# Check what you can access
oc get projects

# Switch to a project
oc project <project-name>

# See project status
oc status

# List all resources
oc get all
```

### 3. Troubleshooting
```bash
# Check if you're logged in
oc whoami

# Check your permissions
oc auth can-i list projects

# Get cluster events
oc get events

# Check node status
oc get nodes
```

## 🔧 Useful Output Formats

```bash
# Wide format (more details)
oc get nodes -o wide

# JSON format
oc get nodes -o json

# YAML format
oc get nodes -o yaml

# Custom format with jsonpath
oc get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.capacity.cpu}{"\n"}{end}'
```

## 📝 Lab Checklist

- [ ] Successfully login to OpenShift cluster
- [ ] Access the web console
- [ ] List all nodes and their status
- [ ] Check cluster operators
- [ ] Create a new project
- [ ] List all resources in the project
- [ ] Explore project quotas and limits
- [ ] Navigate through web console sections
- [ ] Complete the challenge exercise

## 🚨 Common Issues & Solutions

### Issue: Login Failed
```bash
# Solution: Clear login cache
oc logout
oc login -u <username> -p <password> <cluster-url>
```

### Issue: Permission Denied
```bash
# Check your permissions
oc auth can-i list projects
oc auth can-i create projects

# Check your role
oc get rolebindings
```

### Issue: Console Not Accessible
```bash
# Get console URL
oc whoami --show-console

# Use port-forward if needed
oc port-forward svc/console 8080:443 -n openshift-console
```

## 📚 Next Steps

After completing Day 01:
1. **Day 02**: Master OpenShift CLI commands
2. **Day 03**: Deploy your first application
3. **Day 04**: Work with ConfigMaps and Secrets
4. **Day 05**: Understand persistent storage

---

**💡 Pro Tip**: Use `oc explain <resource>` to get detailed information about any OpenShift resource type! 