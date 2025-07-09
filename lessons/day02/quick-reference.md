# Day 02 Quick Reference Guide

## 🚀 Essential OpenShift CLI Commands

### Authentication & Context
```bash
# Login to cluster
oc login -u <username> -p <password> <cluster-url>

# Check current user and project
oc whoami
oc project

# Get current project name
oc project -q

# View cluster information
oc cluster-info

# Get help
oc help <command>
```

### Project Management
```bash
# List all projects
oc get projects

# Create new project
oc new-project <name> --description="Description"

# Switch to project
oc project <name>

# Get project details
oc describe project <name>

# Delete project
oc delete project <name>
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
oc get configmaps
oc get secrets

# Describe resources
oc describe <resource> <name>

# Edit resources
oc edit <resource> <name>

# Delete resources
oc delete <resource> <name>
```

### Output Formatting
```bash
# Different output formats
oc get pods -o wide
oc get pods -o yaml
oc get pods -o json
oc get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase

# Custom jsonpath output
oc get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'

# Watch resources
oc get pods -w
```

## 👥 User & Group Management

### Users
```bash
# List users
oc get users

# Add user to project
oc adm policy add-user-to-project <project> <user>

# Remove user from project
oc adm policy remove-user-from-project <project> <user>

# Check user permissions
oc auth can-i <action> <resource> --as=<username>
```

### Groups
```bash
# List groups
oc get groups

# Create group
oc adm groups new <group-name>

# Add users to group
oc adm groups add-users <group> <user1> <user2>

# Remove users from group
oc adm groups remove-users <group> <user>
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

## 🔧 Advanced Operations

### Resource Creation
```bash
# Create deployment
oc create deployment <name> --image=<image>

# Expose service
oc expose deployment <name> --port=<port> --target-port=<target-port>

# Create route
oc expose service <name> --name=<route-name>

# Create from YAML
oc create -f <filename.yaml>
```

### Resource Modification
```bash
# Scale deployment
oc scale deployment <name> --replicas=<number>

# Patch resource
oc patch deployment <name> -p '{"spec":{"replicas":3}}'

# Edit resource
oc edit deployment <name>
```

### Quotas & Limits
```bash
# Create resource quota
oc create quota <name> --hard=cpu=2,memory=4Gi,pods=10

# Create limit range
oc create limitrange <name> --min=cpu=100m,memory=128Mi --max=cpu=1,memory=1Gi --default=cpu=200m,memory=256Mi

# Check project quotas
oc describe project <name>
```

## 📊 Key Concepts

### OpenShift vs Kubernetes CLI
| Feature | kubectl | oc |
|---------|---------|----|
| **Compatibility** | Kubernetes only | Kubernetes + OpenShift |
| **Projects** | Manual namespace mgmt | Enhanced project mgmt |
| **Users** | External tools needed | Built-in user mgmt |
| **RBAC** | Basic RBAC | Enhanced RBAC |
| **Templates** | No built-in | Rich template system |

### RBAC Components
- **Users**: Individual accounts with authentication
- **Groups**: Collections of users for easier management
- **Roles**: Define permissions (admin, edit, view, basic-user)
- **Role Bindings**: Connect users/groups to roles

### Project Structure
```
Project (Namespace)
├── Users & Groups
├── Resources (Pods, Services, Routes, etc.)
├── Quotas & Limits
└── Security (SCC, Network Policies, Role Bindings)
```

## 🎯 Common Tasks

### 1. Initial Setup
```bash
# 1. Login to cluster
oc login -u <username> -p <password> <cluster-url>

# 2. Create your project
oc new-project my-project --description="My project"

# 3. Switch to project
oc project my-project

# 4. Verify setup
oc whoami
oc project
```

### 2. User Management
```bash
# 1. Create a group
oc adm groups new developers

# 2. Add users to group
oc adm groups add-users developers user1 user2

# 3. Assign role to group
oc adm policy add-role-to-group edit developers -n my-project

# 4. Test permissions
oc auth can-i list pods -n my-project --as=user1
```

### 3. Resource Management
```bash
# 1. Create a deployment
oc create deployment nginx --image=nginx:latest

# 2. Expose the service
oc expose deployment nginx --port=80 --target-port=80

# 3. Create a route
oc expose service nginx --name=nginx-route

# 4. Scale the deployment
oc scale deployment nginx --replicas=3
```

### 4. Monitoring & Debugging
```bash
# Watch resources
oc get pods -w

# View logs
oc logs <pod-name>
oc logs -f <pod-name>

# Check events
oc get events

# Check resource usage
oc adm top pods
oc adm top nodes
```

## 🔍 Troubleshooting

### Permission Issues
```bash
# Check your permissions
oc auth can-i list projects
oc auth can-i create projects

# Check role bindings
oc get rolebindings

# Check your roles
oc get roles
```

### Project Issues
```bash
# List all projects
oc get projects

# Check current project
oc project

# Switch to correct project
oc project <project-name>
```

### Resource Issues
```bash
# Check resource status
oc get all

# Describe specific resource
oc describe pod <pod-name>

# Check events
oc get events --sort-by='.lastTimestamp'
```

## 📝 Lab Checklist

- [ ] Successfully login to OpenShift cluster
- [ ] Create a new project
- [ ] List all resources in the project
- [ ] Use different output formats
- [ ] Create a deployment using CLI
- [ ] Manage users and groups
- [ ] Create role bindings
- [ ] Test user permissions
- [ ] Create resource quotas
- [ ] Export project as template
- [ ] Complete the challenge exercise

## 🚨 Common Issues & Solutions

### Issue: Permission Denied
```bash
# Check your permissions
oc auth can-i list projects
oc auth can-i create projects

# Check your role bindings
oc get rolebindings
```

### Issue: Project Not Found
```bash
# List all projects you have access to
oc get projects

# Check if you're in the right context
oc project
```

### Issue: User Not Found
```bash
# List all users
oc get users

# Check if user exists
oc get user <username>
```

### Issue: Resource Creation Fails
```bash
# Check project quotas
oc describe project <project-name>

# Check resource limits
oc get limitranges

# Check events for errors
oc get events --sort-by='.lastTimestamp'
```

## 📚 Next Steps

After completing Day 02:
1. **Day 03**: Deploy your first application
2. **Day 04**: Work with ConfigMaps and Secrets
3. **Day 05**: Understand persistent storage
4. **Day 06**: CI/CD Pipelines

---

**💡 Pro Tip**: Use `oc explain <resource>` to get detailed information about any OpenShift resource type and its fields!

**💡 Pro Tip**: Use `oc get <resource> -o yaml` to see the full YAML definition of any resource for learning purposes! 