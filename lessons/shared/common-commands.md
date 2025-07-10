# Common OpenShift Commands Reference

## 🔧 Basic Commands

### Authentication & Context
```bash
# Login to cluster
oc login -u <username> -p <password> <cluster-url>

# Check current user
oc whoami

# Check current project
oc project

# Get current context
oc whoami --show-console

# Logout
oc logout
```

### Project Management
```bash
# Create new project
oc new-project <project-name> --description="Description"

# Switch to project
oc project <project-name>

# List projects
oc get projects

# Delete project
oc delete project <project-name>

# Get project details
oc describe project <project-name>
```

### Resource Management
```bash
# List all resources
oc get all

# List specific resources
oc get pods
oc get services
oc get routes
oc get deployments
oc get configmaps
oc get secrets

# Get resource details
oc describe <resource-type> <resource-name>

# Edit resource
oc edit <resource-type> <resource-name>

# Delete resource
oc delete <resource-type> <resource-name>

# Delete all resources in project
oc delete all --all
```

### Output Formatting
```bash
# Different output formats
oc get <resource> -o wide
oc get <resource> -o yaml
oc get <resource> -o json

# Custom columns
oc get <resource> -o custom-columns=NAME:.metadata.name,STATUS:.status.phase

# Watch resources
oc get <resource> -w

# JSONPath queries
oc get <resource> -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'
```

### Resource Creation
```bash
# Create from file
oc create -f <filename.yaml>

# Create imperatively
oc create deployment <name> --image=<image>

# Expose service
oc expose deployment <name> --port=<port> --target-port=<port>

# Create route
oc expose service <service-name> --name=<route-name>
```

### Scaling & Updates
```bash
# Scale deployment
oc scale deployment <name> --replicas=<number>

# Update image
oc set image deployment/<name> <container>=<new-image>

# Trigger new deployment
oc rollout latest deploymentconfig/<name>

# Check rollout status
oc rollout status deploymentconfig/<name>
```

## 🔍 Monitoring & Debugging

### Pod Operations
```bash
# Get pod logs
oc logs <pod-name>

# Follow logs
oc logs -f <pod-name>

# Previous container logs
oc logs <pod-name> --previous

# Execute command in pod
oc exec <pod-name> -- <command>

# Port forward
oc port-forward <pod-name> <local-port>:<container-port>
```

### Resource Queries
```bash
# Check permissions
oc auth can-i <action> <resource>

# Check permissions for specific user
oc auth can-i <action> <resource> --as=<username>

# Get resource events
oc get events

# Get events for specific resource
oc get events --field-selector involvedObject.name=<resource-name>
```

## 🛡️ Security & Access Control

### User Management
```bash
# List users
oc get users

# Add user to project
oc adm policy add-user-to-project <project> <user>

# Remove user from project
oc adm policy remove-user-from-project <project> <user>

# Check user permissions
oc auth can-i <action> <resource> --as=<user>
```

### Group Management
```bash
# List groups
oc get groups

# Create group
oc adm groups new <group-name>

# Add users to group
oc adm groups add-users <group> <user1> <user2>

# Remove users from group
oc adm groups remove-users <group> <user1> <user2>
```

### Role Management
```bash
# List roles
oc get roles

# List role bindings
oc get rolebindings

# Add role to user
oc adm policy add-role-to-user <role> <user> -n <project>

# Add role to group
oc adm policy add-role-to-group <role> <group> -n <project>

# Remove role from user
oc adm policy remove-role-from-user <role> <user> -n <project>
```

## 📊 Resource Quotas & Limits

### Quota Management
```bash
# Create resource quota
oc create quota <quota-name> --hard=cpu=1,memory=1Gi

# Get quota details
oc describe quota <quota-name>

# List quotas
oc get quota
```

### Limit Ranges
```bash
# Create limit range
oc create limitrange <name> --min=cpu=100m,memory=128Mi --max=cpu=1,memory=1Gi --default=cpu=200m,memory=256Mi

# Get limit range details
oc describe limitrange <name>

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

# Check cluster operators
oc get clusteroperators

# Check cluster version
oc get clusterversion
```

### Network Diagnostics
```bash
# Check routes
oc get routes

# Test route connectivity
curl -I <route-url>

# Check service endpoints
oc get endpoints
```

### Storage Diagnostics
```bash
# Check persistent volumes
oc get pv

# Check persistent volume claims
oc get pvc

# Check storage classes
oc get storageclass
```

## 📝 Template Commands

### Template Management
```bash
# List templates
oc get templates

# Create from template
oc new-app --template=<template-name>

# Export project as template
oc export project <project> --as-template=<template-name>

# Process template
oc process <template-name> -p PARAM1=value1 -p PARAM2=value2
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

# Cancel build
oc cancel-build <build-name>
```

### Deployment Operations
```bash
# List deployment configs
oc get deploymentconfigs

# Rollback deployment
oc rollout undo deploymentconfig/<name>

# Pause deployment
oc rollout pause deploymentconfig/<name>

# Resume deployment
oc rollout resume deploymentconfig/<name>
``` 