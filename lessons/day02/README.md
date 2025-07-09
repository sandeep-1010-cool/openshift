# Day 02: OpenShift CLI & Projects - Mastering the `oc` Command

## 🎯 Learning Objectives

By the end of this lesson, you will be able to:
- Master essential OpenShift CLI (`oc`) commands
- Create and manage projects effectively
- Understand OpenShift RBAC (Role-Based Access Control)
- Work with users, groups, and permissions
- Use advanced CLI features for resource management
- Navigate between projects and contexts efficiently

---

## 📚 Theory Section

### OpenShift CLI (`oc`) Overview

The OpenShift CLI (`oc`) is a powerful command-line tool that extends Kubernetes `kubectl` with OpenShift-specific features:

#### Key Features
- **Kubernetes Compatibility**: All `kubectl` commands work with `oc`
- **OpenShift Extensions**: Additional commands for OpenShift features
- **Project Management**: Built-in project creation and management
- **User Management**: Direct user and group operations
- **Build & Deploy**: Integrated build and deployment commands

### OpenShift Projects vs Kubernetes Namespaces

| Aspect | Kubernetes Namespace | OpenShift Project |
|--------|---------------------|-------------------|
| **Creation** | Manual namespace creation | Enhanced project creation |
| **Quotas** | Manual quota setup | Automatic quota management |
| **Security** | Basic RBAC | Enhanced security policies |
| **User Access** | Manual role binding | Project-based access control |
| **Templates** | No built-in templates | Rich template system |

### RBAC in OpenShift

OpenShift uses a sophisticated RBAC system with these components:

#### 1. **Users**
- Individual accounts with authentication
- Can belong to multiple groups
- Have specific permissions across projects

#### 2. **Groups**
- Collections of users
- Simplify permission management
- Can be mapped to external identity providers

#### 3. **Roles**
- **Cluster Roles**: Apply across the entire cluster
- **Local Roles**: Apply to specific projects
- **Built-in Roles**: `admin`, `edit`, `view`, `basic-user`

#### 4. **Role Bindings**
- Connect users/groups to roles
- Define scope (cluster-wide or project-specific)
- Control access granularity

### Project Structure in OpenShift

```
Project (Namespace)
├── Users & Groups
│   ├── Project Members
│   ├── Project Admins
│   └── Project Viewers
├── Resources
│   ├── Pods
│   ├── Services
│   ├── Routes
│   ├── Deployments
│   ├── ConfigMaps
│   ├── Secrets
│   └── Persistent Volumes
├── Quotas & Limits
│   ├── Resource Quotas
│   ├── Limit Ranges
│   └── Resource Requests
└── Security
    ├── Security Context Constraints
    ├── Network Policies
    └── Role Bindings
```

---

## 🛠️ Hands-On Lab

### Prerequisites
- OpenShift cluster access (from Day 01)
- OpenShift CLI (`oc`) installed and configured
- Admin access or ability to create projects

### Exercise 1: Mastering Basic CLI Commands

#### Step 1: Authentication and Context
```bash
# Login to your cluster
oc login -u <username> -p <password> <cluster-url>

# Check current context
oc whoami
oc project

# View cluster information
oc cluster-info

# Get help on any command
oc help
oc help <command>
```

#### Step 2: Project Management
```bash
# List all projects you have access to
oc get projects

# Create a new project
oc new-project day02-lab --description="Day 02 learning project"

# Switch to the project
oc project day02-lab

# Verify current project
oc project -q

# Get project details
oc describe project day02-lab
```

#### Step 3: Resource Management
```bash
# List all resources in current project
oc get all

# List specific resource types
oc get pods
oc get services
oc get routes
oc get deployments
oc get configmaps
oc get secrets

# Get detailed information
oc describe pod <pod-name>
oc describe service <service-name>
oc describe project day02-lab
```

### Exercise 2: Advanced CLI Features

#### Step 1: Output Formatting
```bash
# Different output formats
oc get pods -o wide
oc get pods -o yaml
oc get pods -o json
oc get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase

# Custom output with jsonpath
oc get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'

# Watch resources in real-time
oc get pods -w
```

#### Step 2: Resource Creation
```bash
# Create resources from YAML
oc create -f <filename.yaml>

# Create resources imperatively
oc create deployment nginx --image=nginx:latest

# Expose a service
oc expose deployment nginx --port=80 --target-port=80

# Create a route
oc expose service nginx --name=nginx-route
```

#### Step 3: Resource Editing
```bash
# Edit resources directly
oc edit deployment nginx

# Patch resources
oc patch deployment nginx -p '{"spec":{"replicas":3}}'

# Scale resources
oc scale deployment nginx --replicas=2
```

### Exercise 3: User and Group Management

#### Step 1: Working with Users
```bash
# List users in the project
oc get users

# Add a user to the project
oc adm policy add-user-to-project day02-lab <username>

# Remove a user from the project
oc adm policy remove-user-from-project day02-lab <username>

# Check user permissions
oc auth can-i <action> <resource> --as=<username>
```

#### Step 2: Working with Groups
```bash
# List groups
oc get groups

# Create a group
oc adm groups new developers

# Add users to a group
oc adm groups add-users developers <username1> <username2>

# Remove users from a group
oc adm groups remove-users developers <username>
```

#### Step 3: Role Management
```bash
# List roles
oc get roles

# List role bindings
oc get rolebindings

# Create a role binding
oc adm policy add-role-to-user edit <username> -n day02-lab

# Create a role binding for a group
oc adm policy add-role-to-group view developers -n day02-lab

# Remove a role binding
oc adm policy remove-role-from-user edit <username> -n day02-lab
```

### Exercise 4: Advanced Project Operations

#### Step 1: Project Quotas and Limits
```bash
# Check project quotas
oc describe project day02-lab

# Create a resource quota
oc create quota my-quota --hard=cpu=2,memory=4Gi,pods=10

# Create a limit range
oc create limitrange my-limits --min=cpu=100m,memory=128Mi --max=cpu=1,memory=1Gi --default=cpu=200m,memory=256Mi
```

#### Step 2: Project Templates
```bash
# List available templates
oc get templates

# Create a project from template
oc new-project day02-template --template=my-template

# Export project as template
oc export project day02-lab --as-template=my-project-template
```

#### Step 3: Project Cleanup
```bash
# Delete all resources in a project
oc delete all --all

# Delete specific resources
oc delete deployment nginx
oc delete service nginx
oc delete route nginx-route

# Delete the entire project
oc delete project day02-lab
```

---

## 📋 Lab Tasks

### Task 1: CLI Mastery
- [ ] Login to OpenShift cluster
- [ ] Create a new project called `day02-practice`
- [ ] List all resources in the project
- [ ] Use different output formats for resource listing
- [ ] Create a simple deployment using CLI commands

### Task 2: User Management
- [ ] List all users in your project
- [ ] Create a new user (if you have admin access)
- [ ] Add a user to your project with appropriate role
- [ ] Test user permissions using `oc auth can-i`
- [ ] Create a group and add users to it

### Task 3: Role-Based Access Control
- [ ] List all roles in your project
- [ ] List all role bindings
- [ ] Create a custom role binding
- [ ] Test different user permissions
- [ ] Remove role bindings

### Task 4: Advanced Operations
- [ ] Create a resource quota for your project
- [ ] Create a limit range
- [ ] Export your project as a template
- [ ] Use watch mode to monitor resources
- [ ] Clean up all resources

---

## 🧪 Challenge Exercise

### Advanced Challenge: Multi-Project RBAC Setup

Create a comprehensive RBAC setup across multiple projects:

1. **Create Multiple Projects**
   ```bash
   # Create three projects
   oc new-project frontend-team
   oc new-project backend-team
   oc new-project devops-team
   ```

2. **Create User Groups**
   ```bash
   # Create groups for different teams
   oc adm groups new frontend-developers
   oc adm groups new backend-developers
   oc adm groups new devops-engineers
   ```

3. **Assign Appropriate Roles**
   ```bash
   # Frontend team gets edit access to frontend project
   oc adm policy add-role-to-group edit frontend-developers -n frontend-team
   
   # Backend team gets edit access to backend project
   oc adm policy add-role-to-group edit backend-developers -n backend-team
   
   # DevOps team gets admin access to all projects
   oc adm policy add-role-to-group admin devops-engineers -n frontend-team
   oc adm policy add-role-to-group admin devops-engineers -n backend-team
   oc adm policy add-role-to-group admin devops-engineers -n devops-team
   ```

4. **Test the Setup**
   ```bash
   # Test access as different users
   oc auth can-i list pods -n frontend-team --as=<frontend-user>
   oc auth can-i create deployments -n backend-team --as=<backend-user>
   oc auth can-i delete projects --as=<devops-user>
   ```

5. **Create a Report**
   ```bash
   # Generate a comprehensive RBAC report
   oc get rolebindings --all-namespaces -o wide
   oc get clusterrolebindings -o wide
   ```

---

## 📊 Key Commands Summary

### Project Management
```bash
oc new-project <name> --description="Description"
oc project <name>
oc get projects
oc delete project <name>
```

### User & Group Management
```bash
oc adm policy add-user-to-project <project> <user>
oc adm groups new <group-name>
oc adm groups add-users <group> <user1> <user2>
oc adm policy add-role-to-user <role> <user> -n <project>
oc adm policy add-role-to-group <role> <group> -n <project>
```

### Resource Management
```bash
oc get all
oc describe <resource> <name>
oc edit <resource> <name>
oc delete <resource> <name>
oc scale deployment <name> --replicas=<number>
```

### Advanced Features
```bash
oc get <resource> -o <format>
oc get <resource> -w
oc auth can-i <action> <resource>
oc whoami
oc project -q
```

---

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

# Check if user exists in the system
oc get user <username>
```

---

## 📚 Next Steps

After completing Day 02:
1. **Day 03**: Deploy your first application
2. **Day 04**: Work with ConfigMaps and Secrets
3. **Day 05**: Understand persistent storage
4. **Day 06**: CI/CD Pipelines

---

**💡 Pro Tip**: Use `oc explain <resource>` to get detailed information about any OpenShift resource type and its fields! 