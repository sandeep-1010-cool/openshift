# Day 10: Advanced Topics - GitOps, Multi-tenancy & Cluster Upgrades

## 🎯 Learning Objectives

By the end of this lesson, you will be able to:
- Implement GitOps workflows with ArgoCD
- Configure multi-tenancy and resource isolation
- Perform OpenShift cluster upgrades
- Implement advanced networking features
- Configure cluster-wide policies and governance
- Manage cluster backups and disaster recovery
- Implement advanced monitoring and alerting
- Configure cluster autoscaling and performance tuning
- Troubleshoot advanced cluster issues

---

## 📚 Theory Section

### GitOps with ArgoCD

GitOps is a methodology for managing infrastructure and applications using Git as the single source of truth:

#### **GitOps Principles**
- **Declarative**: All configurations are declarative
- **Versioned**: All changes are version controlled
- **Automated**: Changes are automatically applied
- **Observable**: All changes are observable and auditable

#### **ArgoCD Architecture**
- **Application Controller**: Manages application deployments
- **Repo Server**: Handles Git repository access
- **API Server**: Provides REST API and web UI
- **Redis**: Caches application state

#### **ArgoCD Features**
- **Multi-cluster Management**: Manage multiple clusters
- **Helm Support**: Native Helm chart support
- **Kustomize Support**: Kustomize overlay support
- **Health Monitoring**: Application health checks
- **Rollback Capabilities**: Automatic rollback on failures

### Multi-tenancy in OpenShift

Multi-tenancy provides resource isolation and management across different teams or organizations:

#### **Multi-tenancy Models**
- **Namespace-based**: Each tenant gets dedicated namespaces
- **Cluster-based**: Dedicated clusters per tenant
- **Hybrid**: Combination of namespace and cluster isolation

#### **Resource Isolation**
- **Network Policies**: Control pod-to-pod communication
- **Resource Quotas**: Limit resource consumption
- **RBAC**: Control access to resources
- **Storage Isolation**: Dedicated storage for tenants

#### **Tenant Management**
- **Project Templates**: Standardized project creation
- **Resource Limits**: Per-tenant resource limits
- **Monitoring**: Tenant-specific monitoring
- **Billing**: Resource usage tracking

### Cluster Upgrades

OpenShift cluster upgrades ensure security, stability, and new features:

#### **Upgrade Types**
- **In-place Upgrades**: Upgrade existing cluster
- **Blue-green Upgrades**: Deploy new cluster and migrate
- **Rolling Upgrades**: Upgrade components gradually

#### **Upgrade Process**
- **Pre-upgrade Checks**: Validate cluster health
- **Backup**: Create cluster backup
- **Upgrade Execution**: Perform upgrade steps
- **Post-upgrade Validation**: Verify upgrade success

#### **Upgrade Considerations**
- **Compatibility**: Check application compatibility
- **Downtime**: Plan for potential downtime
- **Rollback**: Prepare rollback procedures
- **Testing**: Test upgrade in non-production

---

## 🛠️ Hands-On Lab

### Prerequisites

> **📋 Reference**: See [shared/prerequisites.md](../shared/prerequisites.md) for detailed prerequisites and installation instructions.

- OpenShift cluster access (from previous days)
- OpenShift CLI (`oc`) installed and configured
- Admin access for cluster operations
- Understanding of Git and version control
- Access to Git repository (GitHub, GitLab, etc.)

### Exercise 1: GitOps with ArgoCD

#### Step 1: Install ArgoCD
```bash
# Create a new project for Day 10
oc new-project day10-advanced --description="Day 10 advanced topics"

# Create ArgoCD namespace
oc new-project argocd

# Install ArgoCD using OperatorHub
cat > argocd-subscription.yaml << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: argocd-operator
  namespace: argocd
spec:
  channel: alpha
  name: argocd-operator
  source: community-operators
  sourceNamespace: openshift-marketplace
EOF

oc apply -f argocd-subscription.yaml

# Wait for ArgoCD operator to be ready
oc get csv -n argocd
```

#### Step 2: Deploy ArgoCD Server
```bash
# Create ArgoCD server instance
cat > argocd-server.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: ArgoCD
metadata:
  name: argocd-server
  namespace: argocd
spec:
  server:
    route:
      enabled: true
  dex:
    enabled: false
  rbac:
    defaultPolicy: role:readonly
    policy: |
      g, admin, role:admin
  resourceCustomizations: |
    apps/Deployment:
      ignoreDifferences: |
        jsonPointers:
        - /spec/replicas
EOF

oc apply -f argocd-server.yaml

# Check ArgoCD deployment
oc get pods -n argocd
oc get route -n argocd
```

#### Step 3: Create Git Repository Structure
```bash
# Create local Git repository structure
mkdir -p gitops-demo/{base,overlays/{dev,staging,prod}}
cd gitops-demo

# Create base application manifests
cat > base/deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gitops-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gitops-app
  template:
    metadata:
      labels:
        app: gitops-app
    spec:
      containers:
      - name: app
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
EOF

cat > base/service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: gitops-app-service
spec:
  selector:
    app: gitops-app
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

cat > base/route.yaml << EOF
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: gitops-app-route
spec:
  to:
    kind: Service
    name: gitops-app-service
  port:
    targetPort: 80
EOF

# Create Kustomization files
cat > base/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
- route.yaml
commonLabels:
  app: gitops-app
  managed-by: argocd
EOF

# Create overlay for development
cat > overlays/dev/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: gitops-dev
bases:
- ../../base
patches:
- target:
    kind: Deployment
    name: gitops-app
  patch: |-
    - op: replace
      path: /spec/replicas
      value: 1
- target:
    kind: Deployment
    name: gitops-app
  patch: |-
    - op: replace
      path: /spec/template/spec/containers/0/image
      value: nginx:1.19
EOF

# Create overlay for staging
cat > overlays/staging/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: gitops-staging
bases:
- ../../base
patches:
- target:
    kind: Deployment
    name: gitops-app
  patch: |-
    - op: replace
      path: /spec/replicas
      value: 2
- target:
    kind: Deployment
    name: gitops-app
  patch: |-
    - op: replace
      path: /spec/template/spec/containers/0/image
      value: nginx:1.20
EOF

# Create overlay for production
cat > overlays/prod/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: gitops-prod
bases:
- ../../base
patches:
- target:
    kind: Deployment
    name: gitops-app
  patch: |-
    - op: replace
      path: /spec/replicas
      value: 3
- target:
    kind: Deployment
    name: gitops-app
  patch: |-
    - op: replace
      path: /spec/template/spec/containers/0/image
      value: nginx:1.21
EOF

cd ..
```

#### Step 4: Create ArgoCD Applications
```bash
# Create ArgoCD applications for different environments
cat > argocd-app-dev.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: gitops-app-dev
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/gitops-demo
    targetRevision: HEAD
    path: overlays/dev
  destination:
    server: https://kubernetes.default.svc
    namespace: gitops-dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

cat > argocd-app-staging.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: gitops-app-staging
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/gitops-demo
    targetRevision: HEAD
    path: overlays/staging
  destination:
    server: https://kubernetes.default.svc
    namespace: gitops-staging
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

cat > argocd-app-prod.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: gitops-app-prod
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/gitops-demo
    targetRevision: HEAD
    path: overlays/prod
  destination:
    server: https://kubernetes.default.svc
    namespace: gitops-prod
  syncPolicy:
    syncOptions:
    - CreateNamespace=true
EOF

oc apply -f argocd-app-dev.yaml
oc apply -f argocd-app-staging.yaml
oc apply -f argocd-app-prod.yaml

# Check ArgoCD applications
oc get application -n argocd
```

### Exercise 2: Multi-tenancy Implementation

#### Step 1: Create Tenant Structure
```bash
# Create tenant namespaces
oc new-project tenant-a
oc new-project tenant-b
oc new-project tenant-c

# Create tenant labels
oc label namespace tenant-a tenant=tenant-a
oc label namespace tenant-b tenant=tenant-b
oc label namespace tenant-c tenant=tenant-c

# Create tenant resource quotas
cat > tenant-a-quota.yaml << EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: tenant-a-quota
  namespace: tenant-a
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    persistentvolumeclaims: "10"
    services: "20"
    replicationcontrollers: "20"
    requests.storage: 100Gi
EOF

oc apply -f tenant-a-quota.yaml

# Create similar quotas for other tenants
cat > tenant-b-quota.yaml << EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: tenant-b-quota
  namespace: tenant-b
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    persistentvolumeclaims: "5"
    services: "10"
    replicationcontrollers: "10"
    requests.storage: 50Gi
EOF

oc apply -f tenant-b-quota.yaml
```

#### Step 2: Implement Network Policies
```bash
# Create network policies for tenant isolation
cat > tenant-a-network-policy.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: tenant-a-isolation
  namespace: tenant-a
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          tenant: tenant-a
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          tenant: tenant-a
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
EOF

oc apply -f tenant-a-network-policy.yaml

# Create similar policies for other tenants
cat > tenant-b-network-policy.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: tenant-b-isolation
  namespace: tenant-b
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          tenant: tenant-b
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          tenant: tenant-b
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
EOF

oc apply -f tenant-b-network-policy.yaml
```

#### Step 3: Create Tenant RBAC
```bash
# Create tenant-specific roles
cat > tenant-a-role.yaml << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: tenant-a-admin
  namespace: tenant-a
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["networking.k8s.io"]
  resources: ["networkpolicies"]
  verbs: ["get", "list", "watch"]
EOF

oc apply -f tenant-a-role.yaml

# Create role bindings
oc create rolebinding tenant-a-admin-binding \
  --role=tenant-a-admin \
  --user=tenant-a-admin

# Create tenant groups
oc adm groups new tenant-a-users
oc adm groups new tenant-b-users
oc adm groups new tenant-c-users

# Add users to tenant groups
oc adm groups add-users tenant-a-users tenant-a-user1 tenant-a-user2
oc adm groups add-users tenant-b-users tenant-b-user1 tenant-b-user2
```

#### Step 4: Deploy Tenant Applications
```bash
# Deploy applications for each tenant
cat > tenant-a-app.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tenant-a-app
  namespace: tenant-a
spec:
  replicas: 2
  selector:
    matchLabels:
      app: tenant-a-app
  template:
    metadata:
      labels:
        app: tenant-a-app
    spec:
      containers:
      - name: app
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
EOF

oc apply -f tenant-a-app.yaml

# Create service for tenant A
cat > tenant-a-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: tenant-a-service
  namespace: tenant-a
spec:
  selector:
    app: tenant-a-app
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

oc apply -f tenant-a-service.yaml

# Create similar applications for other tenants
cat > tenant-b-app.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tenant-b-app
  namespace: tenant-b
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tenant-b-app
  template:
    metadata:
      labels:
        app: tenant-b-app
    spec:
      containers:
      - name: app
        image: httpd:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
EOF

oc apply -f tenant-b-app.yaml
```

### Exercise 3: Cluster Upgrade Preparation

#### Step 1: Pre-upgrade Health Check
```bash
# Check cluster health
oc get clusterversion
oc get nodes
oc get pods --all-namespaces

# Check cluster operators
oc get clusteroperators
oc get clusteroperator -o yaml | grep -A 5 -B 5 "Degraded\|NotAvailable"

# Check cluster events
oc get events --all-namespaces --sort-by='.lastTimestamp' | tail -20

# Check resource usage
oc adm top nodes
oc adm top pods --all-namespaces

# Check storage
oc get pv
oc get pvc --all-namespaces
```

#### Step 2: Create Cluster Backup
```bash
# Create backup directory
mkdir -p cluster-backup/$(date +%Y%m%d-%H%M%S)
cd cluster-backup/$(date +%Y%m%d-%H%M%S)

# Backup cluster resources
oc get all --all-namespaces -o yaml > all-resources.yaml
oc get configmap --all-namespaces -o yaml > configmaps.yaml
oc get secret --all-namespaces -o yaml > secrets.yaml
oc get pvc --all-namespaces -o yaml > persistentvolumeclaims.yaml
oc get route --all-namespaces -o yaml > routes.yaml

# Backup cluster configuration
oc get clusterversion -o yaml > clusterversion.yaml
oc get clusteroperator -o yaml > clusteroperators.yaml
oc get nodes -o yaml > nodes.yaml

# Backup RBAC
oc get clusterrole -o yaml > clusterroles.yaml
oc get clusterrolebinding -o yaml > clusterrolebindings.yaml
oc get role --all-namespaces -o yaml > roles.yaml
oc get rolebinding --all-namespaces -o yaml > rolebindings.yaml

# Create backup script
cat > backup-script.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="cluster-backup/$(date +%Y%m%d-%H%M%S)"
mkdir -p $BACKUP_DIR
cd $BACKUP_DIR

echo "Creating cluster backup..."

# Backup all resources
oc get all --all-namespaces -o yaml > all-resources.yaml
oc get configmap --all-namespaces -o yaml > configmaps.yaml
oc get secret --all-namespaces -o yaml > secrets.yaml
oc get pvc --all-namespaces -o yaml > persistentvolumeclaims.yaml
oc get route --all-namespaces -o yaml > routes.yaml

# Backup cluster configuration
oc get clusterversion -o yaml > clusterversion.yaml
oc get clusteroperator -o yaml > clusteroperators.yaml
oc get nodes -o yaml > nodes.yaml

# Backup RBAC
oc get clusterrole -o yaml > clusterroles.yaml
oc get clusterrolebinding -o yaml > clusterrolebindings.yaml
oc get role --all-namespaces -o yaml > roles.yaml
oc get rolebinding --all-namespaces -o yaml > rolebindings.yaml

echo "Backup completed in $BACKUP_DIR"
EOF

chmod +x backup-script.sh
cd ../..
```

#### Step 3: Check Upgrade Compatibility
```bash
# Check current OpenShift version
oc version

# Check available upgrades
oc adm upgrade

# Check cluster upgrade channel
oc get clusterversion version -o jsonpath='{.spec.channel}'

# Check upgrade history
oc get clusterversion version -o jsonpath='{.status.history}'

# Check for deprecated APIs
oc get apiservice -o yaml | grep -i deprecated

# Check for custom resources that might be affected
oc get crd | grep -v "openshift\|k8s"
```

#### Step 4: Create Upgrade Plan
```bash
# Create upgrade plan document
cat > upgrade-plan.md << EOF
# OpenShift Cluster Upgrade Plan

## Pre-upgrade Checklist
- [ ] Cluster health verified
- [ ] All operators healthy
- [ ] Sufficient storage available
- [ ] Backup completed
- [ ] Applications tested
- [ ] Team notified

## Upgrade Steps
1. **Pre-upgrade validation**
   - Run health checks
   - Verify operator status
   - Check resource usage

2. **Backup creation**
   - Create cluster backup
   - Export critical configurations
   - Document current state

3. **Upgrade execution**
   - Update cluster version
   - Monitor upgrade progress
   - Verify each step

4. **Post-upgrade validation**
   - Verify cluster health
   - Test applications
   - Update documentation

## Rollback Plan
- [ ] Identify rollback trigger conditions
- [ ] Prepare rollback procedures
- [ ] Test rollback process
- [ ] Document rollback steps

## Communication Plan
- [ ] Notify stakeholders
- [ ] Schedule maintenance window
- [ ] Prepare status updates
- [ ] Plan post-upgrade review
EOF
```

### Exercise 4: Advanced Networking

#### Step 1: Configure Network Policies
```bash
# Create comprehensive network policies
cat > advanced-network-policies.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitoring
  namespace: day10-advanced
spec:
  podSelector:
    matchLabels:
      app: monitoring
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    ports:
    - protocol: TCP
      port: 9090
    - protocol: TCP
      port: 8080
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-database-access
  namespace: day10-advanced
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 5432
  - from:
    - namespaceSelector:
        matchLabels:
          name: admin
    ports:
    - protocol: TCP
      port: 5432
EOF

oc apply -f advanced-network-policies.yaml
```

#### Step 2: Configure Ingress Controllers
```bash
# Create custom ingress controller
cat > custom-ingress-controller.yaml << EOF
apiVersion: operator.openshift.io/v1
kind: IngressController
metadata:
  name: custom-ingress
  namespace: openshift-ingress-operator
spec:
  domain: custom.example.com
  replicas: 2
  endpointPublishingStrategy:
    type: LoadBalancerService
  nodePlacement:
    nodeSelector:
      matchLabels:
        node-role.kubernetes.io/worker: ""
  tls:
    securityProfile:
      type: Intermediate
EOF

oc apply -f custom-ingress-controller.yaml

# Check ingress controller status
oc get ingresscontroller -n openshift-ingress-operator
oc describe ingresscontroller custom-ingress -n openshift-ingress-operator
```

### Exercise 5: Advanced Monitoring and Alerting

#### Step 1: Deploy Prometheus Stack
```bash
# Install Prometheus operator
cat > prometheus-subscription.yaml << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: prometheus-operator
  namespace: day10-advanced
spec:
  channel: beta
  name: prometheus-operator
  source: community-operators
  sourceNamespace: openshift-marketplace
EOF

oc apply -f prometheus-subscription.yaml

# Create Prometheus instance
cat > prometheus-instance.yaml << EOF
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: cluster-prometheus
  namespace: day10-advanced
spec:
  replicas: 2
  retention: 30d
  storage:
    volumeClaimTemplate:
      spec:
        storageClassName: fast
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 50Gi
  serviceAccountName: prometheus-k8s
  serviceMonitorSelector: {}
  ruleSelector: {}
EOF

oc apply -f prometheus-instance.yaml
```

#### Step 2: Create Custom Alerts
```bash
# Create PrometheusRule for custom alerts
cat > custom-alerts.yaml << EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: custom-alerts
  namespace: day10-advanced
spec:
  groups:
  - name: custom.rules
    rules:
    - alert: HighCPUUsage
      expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage on {{ \$labels.instance }}"
        description: "CPU usage is above 80% for 5 minutes"
    
    - alert: HighMemoryUsage
      expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage on {{ \$labels.instance }}"
        description: "Memory usage is above 85% for 5 minutes"
    
    - alert: PodRestarting
      expr: increase(kube_pod_container_status_restarts_total[15m]) > 5
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "Pod {{ \$labels.pod }} is restarting frequently"
        description: "Pod has restarted more than 5 times in 15 minutes"
EOF

oc apply -f custom-alerts.yaml
```

### Exercise 6: Cluster Performance Tuning

#### Step 1: Configure Resource Limits
```bash
# Create cluster-wide resource limits
cat > cluster-resource-limits.yaml << EOF
apiVersion: v1
kind: LimitRange
metadata:
  name: cluster-limits
  namespace: day10-advanced
spec:
  limits:
  - default:
      memory: 512Mi
      cpu: 500m
    defaultRequest:
      memory: 256Mi
      cpu: 250m
    type: Container
  - default:
      memory: 1Gi
      cpu: 1000m
    defaultRequest:
      memory: 512Mi
      cpu: 500m
    type: Pod
EOF

oc apply -f cluster-resource-limits.yaml

# Create HPA for applications
cat > hpa-config.yaml << EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
  namespace: day10-advanced
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: advanced-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
EOF

oc apply -f hpa-config.yaml
```

#### Step 2: Configure Cluster Autoscaling
```bash
# Create cluster autoscaler
cat > cluster-autoscaler.yaml << EOF
apiVersion: autoscaling.openshift.io/v1
kind: ClusterAutoscaler
metadata:
  name: default
spec:
  scaleDown:
    enabled: true
    delayAfterAdd: 10m
    delayAfterDelete: 10s
    delayAfterFailure: 3m
    unneededTime: 10m
  maxNodeProvisionTime: 15m
  maxPodGracePeriod: 600
  podPriorityThreshold: -10
  resourceLimits:
    maxNodesTotal: 100
    cores:
      min: 8
      max: 128
    memory:
      min: 4G
      max: 2T
EOF

oc apply -f cluster-autoscaler.yaml

# Create machine autoscaler
cat > machine-autoscaler.yaml << EOF
apiVersion: autoscaling.openshift.io/v1beta1
kind: MachineAutoscaler
metadata:
  name: worker-autoscaler
spec:
  minReplicas: 3
  maxReplicas: 10
  scaleTargetRef:
    apiVersion: machine.openshift.io/v1beta1
    kind: MachineSet
    name: worker
EOF

oc apply -f machine-autoscaler.yaml
```

---

## 📋 Lab Tasks

### Task 1: GitOps Implementation
- [ ] Install and configure ArgoCD
- [ ] Create Git repository structure
- [ ] Deploy applications using GitOps
- [ ] Test automated deployments

### Task 2: Multi-tenancy Setup
- [ ] Create tenant namespaces and isolation
- [ ] Implement network policies
- [ ] Configure RBAC for tenants
- [ ] Deploy tenant applications

### Task 3: Cluster Upgrade Preparation
- [ ] Perform pre-upgrade health checks
- [ ] Create cluster backup
- [ ] Check upgrade compatibility
- [ ] Create upgrade plan

### Task 4: Advanced Networking
- [ ] Configure network policies
- [ ] Set up custom ingress controllers
- [ ] Implement service mesh features
- [ ] Test network isolation

### Task 5: Advanced Monitoring
- [ ] Deploy Prometheus stack
- [ ] Create custom alerts
- [ ] Configure Grafana dashboards
- [ ] Set up alerting rules

### Task 6: Performance Tuning
- [ ] Configure resource limits
- [ ] Set up HPA
- [ ] Configure cluster autoscaling
- [ ] Monitor performance metrics

---

## 🧪 Challenge Exercise

### Advanced Challenge: Enterprise Multi-cluster GitOps

Create a complete enterprise multi-cluster GitOps solution:

1. **Multi-cluster ArgoCD Setup**
   ```bash
   # Create ArgoCD cluster management
   cat > argocd-cluster-management.yaml << EOF
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: cluster-management
     namespace: argocd
   spec:
     project: default
     source:
       repoURL: https://github.com/your-org/cluster-management
       targetRevision: HEAD
       path: clusters
     destination:
       server: https://kubernetes.default.svc
       namespace: cluster-management
     syncPolicy:
       automated:
         prune: true
         selfHeal: true
   EOF
   oc apply -f argocd-cluster-management.yaml
   ```

2. **Multi-tenant Application Deployment**
   ```bash
   # Create tenant-specific applications
   cat > tenant-applications.yaml << EOF
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: tenant-apps
     namespace: argocd
   spec:
     project: default
     source:
       repoURL: https://github.com/your-org/tenant-apps
       targetRevision: HEAD
       path: tenants
     destination:
       server: https://kubernetes.default.svc
       namespace: tenant-apps
     syncPolicy:
       automated:
         prune: true
         selfHeal: true
   EOF
   oc apply -f tenant-applications.yaml
   ```

3. **Advanced Monitoring Stack**
   ```bash
   # Deploy comprehensive monitoring
   cat > monitoring-stack.yaml << EOF
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: monitoring-stack
     namespace: argocd
   spec:
     project: default
     source:
       repoURL: https://github.com/your-org/monitoring-stack
       targetRevision: HEAD
       path: monitoring
     destination:
       server: https://kubernetes.default.svc
       namespace: monitoring
     syncPolicy:
       automated:
         prune: true
         selfHeal: true
   EOF
   oc apply -f monitoring-stack.yaml
   ```

4. **Disaster Recovery Setup**
   ```bash
   # Create backup and recovery procedures
   cat > disaster-recovery.yaml << EOF
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: disaster-recovery-procedures
     namespace: day10-advanced
   data:
     backup-script.sh: |
       #!/bin/bash
       # Automated backup script
       BACKUP_DIR="/backup/\$(date +%Y%m%d-%H%M%S)"
       mkdir -p \$BACKUP_DIR
       
       # Backup cluster resources
       oc get all --all-namespaces -o yaml > \$BACKUP_DIR/all-resources.yaml
       oc get configmap --all-namespaces -o yaml > \$BACKUP_DIR/configmaps.yaml
       oc get secret --all-namespaces -o yaml > \$BACKUP_DIR/secrets.yaml
       
       # Backup persistent data
       oc get pvc --all-namespaces -o yaml > \$BACKUP_DIR/persistentvolumeclaims.yaml
       
       echo "Backup completed: \$BACKUP_DIR"
     
     recovery-script.sh: |
       #!/bin/bash
       # Recovery script
       BACKUP_DIR="\$1"
       
       if [ -z "\$BACKUP_DIR" ]; then
         echo "Usage: \$0 <backup-directory>"
         exit 1
       fi
       
       # Restore cluster resources
       oc apply -f \$BACKUP_DIR/all-resources.yaml
       oc apply -f \$BACKUP_DIR/configmaps.yaml
       oc apply -f \$BACKUP_DIR/secrets.yaml
       oc apply -f \$BACKUP_DIR/persistentvolumeclaims.yaml
       
       echo "Recovery completed from: \$BACKUP_DIR"
   EOF
   oc apply -f disaster-recovery.yaml
   ```

5. **Performance Optimization**
   ```bash
   # Create performance tuning configurations
   cat > performance-tuning.yaml << EOF
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: performance-tuning
     namespace: day10-advanced
   data:
     node-tuning.yaml: |
       apiVersion: tuned.openshift.io/v1
       kind: Tuned
       metadata:
         name: performance-tuning
         namespace: openshift-cluster-node-tuning-operator
       spec:
         profile:
         - name: performance-tuning
           data: |
             [main]
             summary=Performance tuning for OpenShift cluster
             
             [sysctl]
             vm.swappiness=1
             vm.dirty_ratio=15
             vm.dirty_background_ratio=5
             kernel.sched_rt_runtime_us=-1
             
             [scheduler]
             group.openshift-io=0
             group.openshift-io.cpu=0
             
         recommend:
         - profile: performance-tuning
           priority: 10
           match:
           - label: node-role.kubernetes.io/worker
   EOF
   oc apply -f performance-tuning.yaml
   ```

---

## 📊 Key Commands Summary

> **📋 Reference**: See [shared/common-commands.md](../shared/common-commands.md) for comprehensive OpenShift command reference.

### GitOps Management
```bash
oc get application -n argocd
oc get application <name> -n argocd -o yaml
oc patch application <name> -n argocd --type='merge' -p='{"spec":{"syncPolicy":{"automated":{"prune":true}}}}'
```

### Multi-tenancy
```bash
oc get resourcequota --all-namespaces
oc get networkpolicy --all-namespaces
oc get rolebinding --all-namespaces
oc adm groups add-users <group> <user>
```

### Cluster Upgrade
```bash
oc adm upgrade
oc get clusterversion
oc get clusteroperator
oc adm upgrade --to-latest=true
```

### Advanced Monitoring
```bash
oc get prometheus -n monitoring
oc get prometheusrule -n monitoring
oc get servicemonitor -n monitoring
```

---

## 🚨 Common Issues & Solutions

> **📋 Reference**: See [shared/troubleshooting.md](../shared/troubleshooting.md) for comprehensive troubleshooting guide.

### Issue: ArgoCD Application Sync Fails
```bash
# Check application status
oc get application <name> -n argocd -o yaml

# Check ArgoCD logs
oc logs deployment/argocd-server -n argocd

# Check Git repository access
oc get secret -n argocd

# Check application events
oc get events -n argocd --sort-by='.lastTimestamp'
```

### Issue: Multi-tenant Isolation Problems
```bash
# Check network policies
oc get networkpolicy --all-namespaces

# Check resource quotas
oc get resourcequota --all-namespaces

# Check RBAC permissions
oc auth can-i <action> <resource> --as=<user>

# Check tenant labels
oc get namespace --show-labels
```

### Issue: Cluster Upgrade Failures
```bash
# Check cluster version
oc get clusterversion

# Check cluster operators
oc get clusteroperator

# Check upgrade events
oc get events --all-namespaces --sort-by='.lastTimestamp' | grep -i upgrade

# Check cluster health
oc get nodes
oc get pods --all-namespaces
```

### Issue: Performance Problems
```bash
# Check resource usage
oc adm top nodes
oc adm top pods --all-namespaces

# Check HPA status
oc get hpa --all-namespaces

# Check cluster autoscaler
oc get clusterautoscaler
oc get machineautoscaler

# Check node resources
oc describe node <node-name>
```

---

## 📚 Next Steps

After completing Day 10:
1. **Day 11**: GitOps and ArgoCD (Advanced)
2. **Day 12**: Multi-cluster Management
3. **Day 13**: Service Mesh and Advanced Networking
4. **Day 14**: Security Hardening and Compliance

---

## 🔗 Additional Resources

> **📋 Reference**: See [shared/common-commands.md](../shared/common-commands.md) for comprehensive OpenShift command reference.

- [OpenShift GitOps Documentation](https://docs.openshift.com/container-platform/4.10/cicd/gitops/understanding-openshift-gitops.html)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [OpenShift Multi-tenancy](https://docs.openshift.com/container-platform/4.10/applications/projects/working-with-projects.html)
- [OpenShift Cluster Upgrades](https://docs.openshift.com/container-platform/4.10/updating/updating-cluster-cli.html)

---

**💡 Pro Tip**: Use `oc adm upgrade --to-latest=true` to upgrade to the latest available version!

**💡 Pro Tip**: Use `oc get application <name> -n argocd -o jsonpath='{.status.sync.status}'` to check ArgoCD sync status! 