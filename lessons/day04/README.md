# Day 04: ConfigMaps & Secrets - Application Configuration & Secrets Management

## 🎯 Learning Objectives

By the end of this lesson, you will be able to:
- Understand the difference between ConfigMaps and Secrets
- Create and manage ConfigMaps for application configuration
- Implement secure secrets management
- Mount ConfigMaps and Secrets in applications
- Use environment variables and volume mounts
- Implement configuration updates and versioning
- Secure sensitive data in OpenShift applications

---

## 📚 Theory Section

### Configuration Management in OpenShift

OpenShift provides two primary mechanisms for managing application configuration:

#### **ConfigMaps**
- Store non-sensitive configuration data
- Key-value pairs, configuration files, or entire directories
- Can be mounted as environment variables or files
- Versioned and manageable through GitOps

#### **Secrets**
- Store sensitive data (passwords, tokens, certificates)
- Automatically encrypted at rest
- Can be mounted as environment variables or files
- Support for different secret types (Opaque, TLS, Docker)

### ConfigMaps vs Secrets Comparison

| Feature | ConfigMaps | Secrets |
|---------|------------|---------|
| **Data Type** | Non-sensitive | Sensitive |
| **Encryption** | Base64 encoded | Encrypted at rest |
| **Size Limit** | 1MB | 1MB |
| **Use Cases** | Configuration files, environment variables | Passwords, tokens, certificates |
| **Access Control** | Standard RBAC | Enhanced security policies |
| **Versioning** | ✅ Supported | ✅ Supported |

### Configuration Management Patterns

#### 1. **Environment Variables Pattern**
```
Application ← Environment Variables ← ConfigMap/Secret
```

#### 2. **Volume Mount Pattern**
```
Application ← File System ← ConfigMap/Secret
```

#### 3. **Hybrid Pattern**
```
Application ← Environment Variables + File System ← ConfigMaps + Secrets
```

### Security Best Practices

#### **ConfigMaps**
- ✅ Store configuration data, not secrets
- ✅ Use meaningful keys and values
- ✅ Version control your configurations
- ✅ Limit access with RBAC

#### **Secrets**
- ✅ Never store secrets in ConfigMaps
- ✅ Use appropriate secret types
- ✅ Rotate secrets regularly
- ✅ Monitor secret access
- ✅ Use external secret management when possible

---

## 🛠️ Hands-On Lab

### Prerequisites

> **📋 Reference**: See [shared/prerequisites.md](../shared/prerequisites.md) for detailed prerequisites and installation instructions.

- OpenShift cluster access (from previous days)
- OpenShift CLI (`oc`) installed and configured
- Basic understanding of application deployment
- Sample application for configuration testing

### Exercise 1: Working with ConfigMaps

#### Step 1: Create ConfigMaps from Different Sources
```bash
# Create a new project for Day 04
oc new-project day04-config --description="Day 04 configuration management"

# Create ConfigMap from literal values
oc create configmap app-config \
  --from-literal=APP_NAME=my-application \
  --from-literal=ENVIRONMENT=production \
  --from-literal=LOG_LEVEL=info \
  --from-literal=API_TIMEOUT=30

# Create ConfigMap from a file
cat > database.conf << EOF
host=postgresql.example.com
port=5432
database=myapp
pool_size=10
EOF

oc create configmap database-config --from-file=database.conf

# Create ConfigMap from directory
mkdir -p configs
echo "server { listen 80; }" > configs/nginx.conf
echo "upstream backend { server app:8080; }" > configs/upstream.conf

oc create configmap nginx-config --from-file=configs/
```

#### Step 2: Examine ConfigMap Details
```bash
# List all ConfigMaps
oc get configmaps

# Get ConfigMap details
oc describe configmap app-config

# Get ConfigMap in YAML format
oc get configmap app-config -o yaml

# Get specific data from ConfigMap
oc get configmap app-config -o jsonpath='{.data.APP_NAME}'
```

#### Step 3: Update ConfigMaps
```bash
# Update ConfigMap with new values
oc patch configmap app-config -p '{"data":{"LOG_LEVEL":"debug","API_TIMEOUT":"60"}}'

# Replace entire ConfigMap
oc replace configmap app-config --from-literal=APP_NAME=new-app --from-literal=ENVIRONMENT=staging

# Delete and recreate ConfigMap
oc delete configmap app-config
oc create configmap app-config --from-literal=APP_NAME=updated-app
```

### Exercise 2: Working with Secrets

#### Step 1: Create Different Types of Secrets
```bash
# Create Opaque secret (generic)
oc create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=secret123 \
  --from-literal=host=postgresql.example.com

# Create TLS secret
oc create secret tls app-tls \
  --cert=tls.crt \
  --key=tls.key

# Create Docker registry secret
oc create secret docker-registry registry-secret \
  --docker-server=registry.example.com \
  --docker-username=user \
  --docker-password=password \
  --docker-email=user@example.com

# Create secret from file
echo "my-secret-data" > secret.txt
oc create secret generic file-secret --from-file=secret.txt
```

#### Step 2: Examine Secret Details
```bash
# List all secrets
oc get secrets

# Get secret details (data will be base64 encoded)
oc describe secret db-credentials

# Get secret in YAML format
oc get secret db-credentials -o yaml

# Decode secret data
oc get secret db-credentials -o jsonpath='{.data.password}' | base64 -d
```

#### Step 3: Update and Manage Secrets
```bash
# Update secret
oc patch secret db-credentials -p '{"data":{"password":"bmV3LXBhc3N3b3Jk"}}'  # base64 encoded

# Replace secret
oc replace secret db-credentials --from-literal=username=newuser --from-literal=password=newpass

# Delete secret
oc delete secret db-credentials
```

### Exercise 3: Mounting ConfigMaps and Secrets

#### Step 1: Environment Variable Mounting
```bash
# Deploy an application
oc new-app nginx:latest --name=config-app

# Mount ConfigMap as environment variables
oc set env deploymentconfig/config-app \
  --from=configmap/app-config

# Mount specific values from ConfigMap
oc set env deploymentconfig/config-app \
  APP_NAME=my-app \
  --from=configmap/app-config \
  --prefix=CONFIG_

# Mount secrets as environment variables
oc set env deploymentconfig/config-app \
  --from=secret/db-credentials
```

#### Step 2: Volume Mounting
```bash
# Mount ConfigMap as files
oc set volume deploymentconfig/config-app \
  --add \
  --name=config-volume \
  --type=configmap \
  --configmap-name=nginx-config \
  --mount-path=/etc/nginx/conf.d

# Mount secret as files
oc set volume deploymentconfig/config-app \
  --add \
  --name=secret-volume \
  --type=secret \
  --secret-name=db-credentials \
  --mount-path=/etc/secrets

# Mount specific keys from ConfigMap
oc set volume deploymentconfig/config-app \
  --add \
  --name=app-config \
  --type=configmap \
  --configmap-name=app-config \
  --mount-path=/app/config \
  --sub-path=APP_NAME
```

#### Step 3: Verify Mounting
```bash
# Check if environment variables are set
oc exec deploymentconfig/config-app -- env | grep -E "(APP_|CONFIG_|DB_)"

# Check if files are mounted
oc exec deploymentconfig/config-app -- ls -la /etc/nginx/conf.d/
oc exec deploymentconfig/config-app -- ls -la /etc/secrets/

# View mounted file contents
oc exec deploymentconfig/config-app -- cat /app/config/APP_NAME
```

### Exercise 4: Advanced Configuration Patterns

#### Step 1: Configuration Updates and Rollouts
```bash
# Update ConfigMap
oc patch configmap app-config -p '{"data":{"LOG_LEVEL":"debug"}}'

# Trigger deployment update
oc rollout latest deploymentconfig/config-app

# Check rollout status
oc rollout status deploymentconfig/config-app

# Rollback if needed
oc rollout undo deploymentconfig/config-app
```

#### Step 2: Configuration Versioning
```bash
# Create versioned ConfigMaps
oc create configmap app-config-v1 --from-literal=VERSION=v1 --from-literal=FEATURE_FLAG=old
oc create configmap app-config-v2 --from-literal=VERSION=v2 --from-literal=FEATURE_FLAG=new

# Switch between versions
oc set volume deploymentconfig/config-app \
  --add \
  --name=config-volume \
  --type=configmap \
  --configmap-name=app-config-v1 \
  --mount-path=/app/config

# Update to new version
oc set volume deploymentconfig/config-app \
  --add \
  --name=config-volume \
  --type=configmap \
  --configmap-name=app-config-v2 \
  --mount-path=/app/config
```

#### Step 3: Multi-Environment Configuration
```bash
# Create environment-specific ConfigMaps
oc create configmap app-config-dev \
  --from-literal=ENVIRONMENT=development \
  --from-literal=LOG_LEVEL=debug \
  --from-literal=API_URL=http://dev-api.example.com

oc create configmap app-config-prod \
  --from-literal=ENVIRONMENT=production \
  --from-literal=LOG_LEVEL=warn \
  --from-literal=API_URL=https://api.example.com

# Use development configuration
oc set env deploymentconfig/config-app --from=configmap/app-config-dev

# Switch to production configuration
oc set env deploymentconfig/config-app --from=configmap/app-config-prod
```

### Exercise 5: Security and Best Practices

#### Step 1: RBAC for ConfigMaps and Secrets
```bash
# Create a role for ConfigMap access
oc create role configmap-reader --verb=get,list --resource=configmaps

# Create a role binding
oc create rolebinding configmap-reader-binding \
  --role=configmap-reader \
  --user=developer

# Create a role for secret access
oc create role secret-reader --verb=get,list --resource=secrets

# Create a role binding for secrets
oc create rolebinding secret-reader-binding \
  --role=secret-reader \
  --user=developer
```

#### Step 2: Secret Rotation
```bash
# Create new secret with updated credentials
oc create secret generic db-credentials-new \
  --from-literal=username=admin \
  --from-literal=password=new-secure-password

# Update deployment to use new secret
oc set env deploymentconfig/config-app \
  --from=secret/db-credentials-new

# Verify the update
oc rollout status deploymentconfig/config-app

# Remove old secret
oc delete secret db-credentials
```

#### Step 3: Monitoring and Auditing
```bash
# Check who has access to secrets
oc get rolebindings --all-namespaces | grep secret

# Check secret access events
oc get events --sort-by='.lastTimestamp' | grep -i secret

# Monitor ConfigMap changes
oc get events --sort-by='.lastTimestamp' | grep -i configmap
```

---

## 📋 Lab Tasks

### Task 1: Basic ConfigMap Management
- [ ] Create ConfigMaps from different sources (literal, file, directory)
- [ ] Examine ConfigMap details and data
- [ ] Update and replace ConfigMaps
- [ ] List and manage ConfigMaps

### Task 2: Secret Management
- [ ] Create different types of secrets (Opaque, TLS, Docker)
- [ ] Examine secret details and decode data
- [ ] Update and manage secrets securely
- [ ] Implement secret rotation

### Task 3: Configuration Mounting
- [ ] Mount ConfigMaps as environment variables
- [ ] Mount ConfigMaps as volume files
- [ ] Mount secrets as environment variables
- [ ] Mount secrets as volume files
- [ ] Verify mounting and access

### Task 4: Advanced Patterns
- [ ] Implement configuration updates and rollouts
- [ ] Create versioned configurations
- [ ] Set up multi-environment configurations
- [ ] Test configuration switching

### Task 5: Security Implementation
- [ ] Set up RBAC for ConfigMaps and Secrets
- [ ] Implement secret rotation procedures
- [ ] Monitor configuration access
- [ ] Audit configuration changes

---

## 🧪 Challenge Exercise

### Advanced Challenge: Secure Multi-Tier Application Configuration

Create a complete configuration management system for a multi-tier application:

1. **Database Configuration**
   ```bash
   # Create database ConfigMap
   oc create configmap db-config \
     --from-literal=host=postgresql.example.com \
     --from-literal=port=5432 \
     --from-literal=database=myapp \
     --from-literal=pool_size=10

   # Create database secrets
   oc create secret generic db-secrets \
     --from-literal=username=app_user \
     --from-literal=password=secure_password_123 \
     --from-literal=ssl_mode=require
   ```

2. **Application Configuration**
   ```bash
   # Create application ConfigMap
   oc create configmap app-config \
     --from-literal=environment=production \
     --from-literal=log_level=info \
     --from-literal=api_timeout=30 \
     --from-literal=cache_ttl=3600

   # Create application secrets
   oc create secret generic app-secrets \
     --from-literal=api_key=sk-1234567890abcdef \
     --from-literal=jwt_secret=super-secret-jwt-key \
     --from-literal=encryption_key=encryption-key-123
   ```

3. **Deploy Application with Configuration**
   ```bash
   # Deploy application
   oc new-app nginx:latest --name=secure-app

   # Mount ConfigMaps as environment variables
   oc set env deploymentconfig/secure-app \
     --from=configmap/db-config \
     --from=configmap/app-config

   # Mount secrets as environment variables
   oc set env deploymentconfig/secure-app \
     --from=secret/db-secrets \
     --from=secret/app-secrets

   # Mount ConfigMaps as files
   oc set volume deploymentconfig/secure-app \
     --add \
     --name=config-volume \
     --type=configmap \
     --configmap-name=app-config \
     --mount-path=/app/config

   # Mount secrets as files
   oc set volume deploymentconfig/secure-app \
     --add \
     --name=secrets-volume \
     --type=secret \
     --secret-name=app-secrets \
     --mount-path=/app/secrets
   ```

4. **Configuration Updates and Rollouts**
   ```bash
   # Update configuration
   oc patch configmap app-config -p '{"data":{"log_level":"debug","api_timeout":"60"}}'

   # Trigger deployment update
   oc rollout latest deploymentconfig/secure-app

   # Monitor rollout
   oc rollout status deploymentconfig/secure-app

   # Verify configuration
   oc exec deploymentconfig/secure-app -- env | grep -E "(DB_|APP_)"
   ```

5. **Security and Monitoring**
   ```bash
   # Create RBAC for configuration access
   oc create role config-manager --verb=get,list,watch --resource=configmaps,secrets
   oc create rolebinding config-manager-binding --role=config-manager --user=developer

   # Monitor configuration access
   oc get events --sort-by='.lastTimestamp' | grep -E "(configmap|secret)"

   # Test configuration security
   oc auth can-i get configmaps --as=developer
   oc auth can-i get secrets --as=developer
   ```

---

## 📊 Key Commands Summary

> **📋 Reference**: See [shared/common-commands.md](../shared/common-commands.md) for comprehensive OpenShift command reference.

### ConfigMap Management
```bash
oc create configmap <name> --from-literal=<key>=<value>
oc create configmap <name> --from-file=<file>
oc create configmap <name> --from-file=<directory>
oc get configmaps
oc describe configmap <name>
oc patch configmap <name> -p '{"data":{"key":"value"}}'
oc delete configmap <name>
```

### Secret Management
```bash
oc create secret generic <name> --from-literal=<key>=<value>
oc create secret tls <name> --cert=<cert> --key=<key>
oc create secret docker-registry <name> --docker-server=<server>
oc get secrets
oc describe secret <name>
oc patch secret <name> -p '{"data":{"key":"base64-value"}}'
oc delete secret <name>
```

### Configuration Mounting
```bash
oc set env deploymentconfig/<name> --from=configmap/<configmap>
oc set env deploymentconfig/<name> --from=secret/<secret>
oc set volume deploymentconfig/<name> --add --type=configmap --configmap-name=<name>
oc set volume deploymentconfig/<name> --add --type=secret --secret-name=<name>
```

### Security and RBAC
```bash
oc create role <role-name> --verb=<verbs> --resource=<resources>
oc create rolebinding <binding-name> --role=<role> --user=<user>
oc auth can-i <action> <resource> --as=<user>
```

---

## 🚨 Common Issues & Solutions

> **📋 Reference**: See [shared/troubleshooting.md](../shared/troubleshooting.md) for comprehensive troubleshooting guide.

### Issue: ConfigMap Not Mounted
```bash
# Check if ConfigMap exists
oc get configmap <name>

# Check deployment configuration
oc describe deploymentconfig <name>

# Check volume mounts
oc get deploymentconfig <name> -o yaml | grep -A 10 volumes
```

### Issue: Secret Not Accessible
```bash
# Check if secret exists
oc get secret <name>

# Check permissions
oc auth can-i get secret <name>

# Check if secret is mounted
oc describe deploymentconfig <name>
```

### Issue: Environment Variables Not Set
```bash
# Check environment variables
oc exec deploymentconfig/<name> -- env | grep <variable>

# Check ConfigMap/Secret data
oc get configmap <name> -o yaml
oc get secret <name> -o yaml

# Verify mounting
oc describe deploymentconfig <name>
```

### Issue: Configuration Updates Not Applied
```bash
# Check if ConfigMap was updated
oc get configmap <name> -o yaml

# Trigger deployment update
oc rollout latest deploymentconfig/<name>

# Check rollout status
oc rollout status deploymentconfig/<name>

# Check pod logs
oc logs deploymentconfig/<name>
```

---

## 📚 Next Steps

After completing Day 04:
1. **Day 05**: Understand persistent storage
2. **Day 06**: CI/CD Pipelines
3. **Day 07**: Monitoring and Logging
4. **Day 08**: Security and Policies

---

## 🔗 Additional Resources

> **📋 Reference**: See [shared/common-commands.md](../shared/common-commands.md) for comprehensive OpenShift command reference.

- [OpenShift ConfigMaps Documentation](https://docs.openshift.com/container-platform/4.10/nodes/pods/nodes-pods-configmaps.html)
- [OpenShift Secrets Documentation](https://docs.openshift.com/container-platform/4.10/nodes/pods/nodes-pods-secrets.html)
- [Kubernetes Configuration Best Practices](https://kubernetes.io/docs/concepts/configuration/)
- [OpenShift Security Documentation](https://docs.openshift.com/container-platform/4.10/security/index.html)

---

**💡 Pro Tip**: Use `oc set env --help` to explore all options for setting environment variables from ConfigMaps and Secrets!

**💡 Pro Tip**: Use `oc set volume --help` to see all available options for mounting ConfigMaps and Secrets as volumes! 