# Day 03: Deploying Applications - BuildConfigs, DeploymentConfigs & Routes

## 🎯 Learning Objectives

By the end of this lesson, you will be able to:
- Understand OpenShift's application deployment concepts
- Create and manage BuildConfigs for application builds
- Deploy applications using DeploymentConfigs
- Configure Routes for external access
- Use Source-to-Image (S2I) for automated builds
- Manage application lifecycle and scaling
- Implement blue-green and rolling deployments

---

## 📚 Theory Section

### OpenShift Application Deployment Overview

OpenShift provides a comprehensive application deployment platform that extends Kubernetes with additional features:

#### Key Components
- **BuildConfigs**: Define how applications are built from source code
- **DeploymentConfigs**: Manage application deployment and updates
- **Routes**: Provide external access to applications
- **ImageStreams**: Manage container images and tags
- **Services**: Internal networking between application components

### BuildConfigs vs Kubernetes Jobs

| Feature | Kubernetes Jobs | OpenShift BuildConfigs |
|---------|----------------|----------------------|
| **Purpose** | One-time tasks | Application builds |
| **Triggers** | Manual execution | Webhooks, image changes |
| **Output** | Job completion | Container images |
| **Integration** | Standalone | Integrated with deployments |
| **Build Types** | Limited | S2I, Docker, Pipeline |

### DeploymentConfigs vs Kubernetes Deployments

| Feature | Kubernetes Deployments | OpenShift DeploymentConfigs |
|---------|----------------------|---------------------------|
| **Rolling Updates** | ✅ Supported | ✅ Enhanced |
| **Blue-Green** | Manual setup | ✅ Built-in |
| **Image Triggers** | Manual updates | ✅ Automatic |
| **Deployment Hooks** | Limited | ✅ Pre/Post hooks |
| **Scaling** | ✅ Supported | ✅ Enhanced |

### Application Deployment Flow

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Source Code   │───▶│   BuildConfig   │───▶│  Container Image│
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Routes      │◀───│ DeploymentConfig│◀───│  ImageStream    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## 🛠️ Hands-On Lab

### Prerequisites
- OpenShift cluster access (from Day 01 & 02)
- OpenShift CLI (`oc`) installed and configured
- Basic understanding of container images and deployments
- Git repository with sample application code

### Exercise 1: Understanding BuildConfigs

#### Step 1: Explore Build Types
```bash
# List available build strategies
oc explain buildconfig.spec.strategy

# Check available S2I builders
oc get is -n openshift
oc get is -n openshift | grep builder
```

#### Step 2: Create a Simple BuildConfig
```bash
# Create a new project for Day 03
oc new-project day03-apps --description="Day 03 application deployment"

# Create a BuildConfig from a Git repository
oc new-app https://github.com/openshift/nodejs-ex.git \
  --name=nodejs-app \
  --strategy=source \
  --labels=app=nodejs-app
```

#### Step 3: Examine BuildConfig Details
```bash
# Get the BuildConfig details
oc get buildconfig nodejs-app -o yaml

# List all builds
oc get builds

# Watch build progress
oc get builds -w
```

### Exercise 2: Working with DeploymentConfigs

#### Step 1: Create a DeploymentConfig
```bash
# Create a DeploymentConfig from the built image
oc new-app nodejs-app:latest \
  --name=nodejs-deployment \
  --labels=app=nodejs-app

# Or create from an existing image
oc new-app nginx:latest \
  --name=nginx-deployment \
  --labels=app=nginx
```

#### Step 2: Examine DeploymentConfig
```bash
# Get DeploymentConfig details
oc get deploymentconfig nodejs-deployment -o yaml

# List all DeploymentConfigs
oc get deploymentconfigs

# Check deployment status
oc rollout status deploymentconfig/nodejs-deployment
```

#### Step 3: Scale and Update
```bash
# Scale the deployment
oc scale deploymentconfig/nodejs-deployment --replicas=3

# Update the image
oc set image deploymentconfig/nodejs-deployment nodejs-app=nodejs-app:latest

# Trigger a new deployment
oc rollout latest deploymentconfig/nodejs-deployment
```

### Exercise 3: Configuring Routes

#### Step 1: Create Routes
```bash
# Expose the service as a route
oc expose service nodejs-deployment --name=nodejs-route

# Create a route with specific hostname
oc expose service nodejs-deployment \
  --name=nodejs-route-custom \
  --hostname=nodejs-app.apps.crc.testing

# Create a secure route
oc expose service nodejs-deployment \
  --name=nodejs-route-secure \
  --hostname=nodejs-secure.apps.crc.testing \
  --tls=reencrypt
```

#### Step 2: Manage Routes
```bash
# List all routes
oc get routes

# Get route details
oc describe route nodejs-route

# Test route access
curl -I http://nodejs-route-day03-apps.apps.crc.testing
```

### Exercise 4: Advanced Deployment Strategies

#### Step 1: Rolling Deployment
```bash
# Create a DeploymentConfig with rolling strategy
oc create deploymentconfig rolling-app \
  --image=nginx:latest \
  --replicas=3 \
  --strategy=rolling

# Update with rolling deployment
oc set image deploymentconfig/rolling-app nginx=nginx:1.19
```

#### Step 2: Blue-Green Deployment
```bash
# Create blue deployment
oc new-app nginx:1.18 --name=blue-app --labels=app=blue-green,version=blue

# Create green deployment
oc new-app nginx:1.19 --name=green-app --labels=app=blue-green,version=green

# Create a service that points to blue by default
oc expose service blue-app --name=blue-green-route
```

#### Step 3: Switch Between Blue and Green
```bash
# Switch to green deployment
oc patch route blue-green-route -p '{"spec":{"to":{"name":"green-app"}}}'

# Switch back to blue
oc patch route blue-green-route -p '{"spec":{"to":{"name":"blue-app"}}}'
```

### Exercise 5: Application Lifecycle Management

#### Step 1: Health Checks
```bash
# Add health checks to deployment
oc set probe deploymentconfig/nodejs-deployment \
  --liveness \
  --get-url=http://:8080/health \
  --initial-delay-seconds=30 \
  --timeout-seconds=5

oc set probe deploymentconfig/nodejs-deployment \
  --readiness \
  --get-url=http://:8080/ready \
  --initial-delay-seconds=5 \
  --timeout-seconds=3
```

#### Step 2: Resource Limits
```bash
# Set resource limits
oc set resources deploymentconfig/nodejs-deployment \
  --limits=cpu=500m,memory=512Mi \
  --requests=cpu=100m,memory=128Mi
```

#### Step 3: Environment Variables
```bash
# Set environment variables
oc set env deploymentconfig/nodejs-deployment \
  NODE_ENV=production \
  PORT=8080

# Set environment variables from ConfigMap
oc create configmap app-config \
  --from-literal=API_URL=https://api.example.com \
  --from-literal=DEBUG=false

oc set env deploymentconfig/nodejs-deployment \
  --from=configmap/app-config
```

### Exercise 6: Monitoring and Debugging

#### Step 1: Application Monitoring
```bash
# Check application status
oc get pods -l app=nodejs-app

# View application logs
oc logs deploymentconfig/nodejs-deployment

# Follow logs in real-time
oc logs deploymentconfig/nodejs-deployment -f

# Check application events
oc get events --sort-by='.lastTimestamp'
```

#### Step 2: Debugging Deployments
```bash
# Check deployment history
oc rollout history deploymentconfig/nodejs-deployment

# Rollback to previous version
oc rollout undo deploymentconfig/nodejs-deployment

# Rollback to specific version
oc rollout undo deploymentconfig/nodejs-deployment --to-revision=1
```

---

## 📋 Lab Tasks

### Task 1: Basic Application Deployment
- [ ] Create a new project for Day 03
- [ ] Deploy a simple application using `oc new-app`
- [ ] Examine the generated BuildConfig and DeploymentConfig
- [ ] Access the application through a route

### Task 2: BuildConfig Management
- [ ] Create a BuildConfig from a Git repository
- [ ] Monitor the build process
- [ ] Examine build logs and artifacts
- [ ] Trigger a new build manually

### Task 3: DeploymentConfig Operations
- [ ] Scale your application to multiple replicas
- [ ] Update the application image
- [ ] Perform a rolling update
- [ ] Rollback to a previous version

### Task 4: Route Configuration
- [ ] Create different types of routes (HTTP, HTTPS)
- [ ] Configure custom hostnames
- [ ] Test route accessibility
- [ ] Implement blue-green deployment

### Task 5: Advanced Features
- [ ] Add health checks to your application
- [ ] Configure resource limits and requests
- [ ] Set environment variables
- [ ] Monitor application performance

---

## 🧪 Challenge Exercise

### Advanced Challenge: Multi-Tier Application Deployment

Deploy a complete multi-tier application with proper configuration:

1. **Database Layer**
   ```bash
   # Deploy PostgreSQL database
   oc new-app postgresql:13 \
     --name=postgres-db \
     --env=POSTGRESQL_DATABASE=myapp \
     --env=POSTGRESQL_USER=myuser \
     --env=POSTGRESQL_PASSWORD=mypassword
   ```

2. **Application Layer**
   ```bash
   # Deploy Node.js application
   oc new-app https://github.com/openshift/nodejs-ex.git \
     --name=nodejs-app \
     --env=DATABASE_URL=postgresql://myuser:mypassword@postgres-db:5432/myapp
   ```

3. **Web Layer**
   ```bash
   # Deploy Nginx frontend
   oc new-app nginx:latest \
     --name=nginx-frontend \
     --env=APP_URL=http://nodejs-app:8080
   ```

4. **Route Configuration**
   ```bash
   # Expose the frontend
   oc expose service nginx-frontend --name=app-route
   
   # Create secure route for API
   oc expose service nodejs-app \
     --name=api-route \
     --hostname=api.apps.crc.testing \
     --tls=reencrypt
   ```

5. **Monitoring Setup**
   ```bash
   # Add health checks to all components
   oc set probe deploymentconfig/postgres-db --liveness --get-url=http://:5432
   oc set probe deploymentconfig/nodejs-app --liveness --get-url=http://:8080/health
   oc set probe deploymentconfig/nginx-frontend --liveness --get-url=http://:80
   ```

6. **Scaling and Testing**
   ```bash
   # Scale components
   oc scale deploymentconfig/nodejs-app --replicas=3
   oc scale deploymentconfig/nginx-frontend --replicas=2
   
   # Test the complete application
   curl -I http://app-route-day03-apps.apps.crc.testing
   ```

---

## 📊 Key Commands Summary

### BuildConfig Management
```bash
oc new-app <source> --name=<name> --strategy=<strategy>
oc get buildconfigs
oc start-build <buildconfig-name>
oc logs build/<build-name>
oc delete buildconfig <name>
```

### DeploymentConfig Management
```bash
oc new-app <image> --name=<name>
oc get deploymentconfigs
oc rollout status deploymentconfig/<name>
oc rollout latest deploymentconfig/<name>
oc rollout undo deploymentconfig/<name>
oc scale deploymentconfig/<name> --replicas=<number>
```

### Route Management
```bash
oc expose service <service-name> --name=<route-name>
oc get routes
oc describe route <route-name>
oc delete route <route-name>
```

### Application Updates
```bash
oc set image deploymentconfig/<name> <container>=<new-image>
oc set env deploymentconfig/<name> <key>=<value>
oc set resources deploymentconfig/<name> --limits=cpu=<cpu>,memory=<memory>
oc set probe deploymentconfig/<name> --liveness --get-url=<url>
```

---

## 🚨 Common Issues & Solutions

### Issue: Build Fails
```bash
# Check build logs
oc logs build/<build-name>

# Check build configuration
oc describe buildconfig <name>

# Restart build
oc start-build <buildconfig-name>
```

### Issue: Deployment Fails
```bash
# Check deployment status
oc rollout status deploymentconfig/<name>

# Check pod events
oc get events --sort-by='.lastTimestamp'

# Rollback deployment
oc rollout undo deploymentconfig/<name>
```

### Issue: Route Not Accessible
```bash
# Check route status
oc get routes
oc describe route <route-name>

# Check service
oc get services
oc describe service <service-name>

# Test connectivity
curl -I http://<route-url>
```

### Issue: Application Not Responding
```bash
# Check pod status
oc get pods -l app=<app-label>

# Check application logs
oc logs deploymentconfig/<name>

# Check health checks
oc describe pod <pod-name>
```

---

## 📚 Next Steps

After completing Day 03:
1. **Day 04**: Work with ConfigMaps and Secrets
2. **Day 05**: Understand persistent storage
3. **Day 06**: CI/CD Pipelines
4. **Day 07**: Monitoring and Logging

---

## 🔗 Additional Resources

- [OpenShift Builds Documentation](https://docs.openshift.com/container-platform/4.10/builds/index.html)
- [OpenShift Deployments Documentation](https://docs.openshift.com/container-platform/4.10/applications/deployments/index.html)
- [OpenShift Routes Documentation](https://docs.openshift.com/container-platform/4.10/networking/routes/index.html)
- [Source-to-Image (S2I) Documentation](https://docs.openshift.com/container-platform/4.10/builds/build-strategies.html)

---

**💡 Pro Tip**: Use `oc new-app --help` to explore all available options for creating applications in OpenShift!

**💡 Pro Tip**: Use `oc set --help` to see all available commands for modifying deployments, services, and routes! 