# Essential OpenShift Commands

## 🔧 Core Commands

### Authentication
```bash
# Login
oc login -u <username> -p <password> <cluster-url>

# Check user
oc whoami

# Check project
oc project

# Logout
oc logout
```

### Project Management
```bash
# Create project
oc new-project <project-name>

# Switch project
oc project <project-name>

# List projects
oc get projects

# Delete project
oc delete project <project-name>
```

### Resource Management
```bash
# List resources
oc get all
oc get pods
oc get services
oc get routes
oc get deployments

# Get details
oc describe <resource-type> <resource-name>

# Edit resource
oc edit <resource-type> <resource-name>

# Delete resource
oc delete <resource-type> <resource-name>
```

### Output Formats
```bash
# Different formats
oc get <resource> -o wide
oc get <resource> -o yaml
oc get <resource> -o json

# Watch resources
oc get <resource> -w
```

### Resource Creation
```bash
# Create from file
oc create -f <filename.yaml>

# Create deployment
oc create deployment <name> --image=<image>

# Expose service
oc expose deployment <name> --port=<port>

# Create route
oc expose service <service-name>
```

### Scaling & Updates
```bash
# Scale deployment
oc scale deployment <name> --replicas=<number>

# Update image
oc set image deployment/<name> <container>=<new-image>

# Check rollout
oc rollout status deploymentconfig/<name>
```

## 🔍 Monitoring & Debugging

### Pod Operations
```bash
# Get logs
oc logs <pod-name>
oc logs -f <pod-name>

# Execute in pod
oc exec <pod-name> -- <command>

# Port forward
oc port-forward <pod-name> <local-port>:<container-port>
```

### Resource Queries
```bash
# Check permissions
oc auth can-i <action> <resource>

# Get events
oc get events
```

## 🛡️ Security & Access Control

### User Management
```bash
# List users
oc get users

# Add user to project
oc adm policy add-user-to-project <project> <user>

# Check permissions
oc auth can-i <action> <resource> --as=<user>
```

### Role Management
```bash
# List roles
oc get roles
oc get rolebindings

# Add role to user
oc adm policy add-role-to-user <role> <user> -n <project>
```

## 📊 Resource Quotas & Limits

### Quota Management
```bash
# Create quota
oc create quota <quota-name> --hard=cpu=1,memory=1Gi

# List quotas
oc get quota
```

### Limit Ranges
```bash
# Create limit range
oc create limitrange <name> --min=cpu=100m,memory=128Mi --max=cpu=1,memory=1Gi

# List limit ranges
oc get limitrange
```

## 🔧 Troubleshooting Commands

### Cluster Health
```bash
# Check cluster info
oc cluster-info

# Check nodes
oc get nodes

# Check operators
oc get clusteroperators
```

### Network Diagnostics
```bash
# Check routes
oc get routes

# Test connectivity
curl -I <route-url>
```

## 🚀 Build & Deploy Commands

### Build Operations
```bash
# List builds
oc get builds

# Start build
oc start-build <buildconfig-name>

# Watch build
oc logs -f bc/<buildconfig-name>
```

### Deployment Operations
```bash
# List deployments
oc get deploymentconfigs

# Rollback deployment
oc rollout undo deploymentconfig/<name>
```

## 📝 Template Commands

### Template Management
```bash
# List templates
oc get templates

# Create from template
oc new-app --template=<template-name>

# Process template
oc process <template-name> -p PARAM1=value1
``` 