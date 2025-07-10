 # Day 09: Operators & Helm - OperatorHub & Helm Charts

## 🎯 Learning Objectives

By the end of this lesson, you will be able to:
- Understand OpenShift Operators and their architecture
- Install and manage operators from OperatorHub
- Create and deploy Helm charts
- Use Helm with OpenShift
- Manage operator lifecycles
- Create custom operators
- Deploy applications using Helm
- Troubleshoot operator and Helm issues
- Implement GitOps with operators

---

## 📚 Theory Section

### OpenShift Operators

Operators are Kubernetes-native applications that extend Kubernetes to manage complex applications:

#### **Operator Architecture**
- **Custom Resource Definitions (CRDs)**: Extend Kubernetes API
- **Custom Controllers**: Implement business logic
- **Operator Lifecycle Manager (OLM)**: Manages operator installation and updates
- **OperatorHub**: Central repository for operators

#### **Operator Types**
- **Cluster Operators**: Manage cluster-wide resources
- **Application Operators**: Manage specific applications
- **Infrastructure Operators**: Manage infrastructure components

#### **Operator Benefits**
- **Automation**: Automated application lifecycle management
- **Consistency**: Standardized deployment and configuration
- **Scalability**: Handle complex distributed applications
- **Reliability**: Self-healing and monitoring capabilities

### Helm Charts

Helm is the package manager for Kubernetes:

#### **Helm Components**
- **Charts**: Package format containing Kubernetes resources
- **Templates**: YAML files with templating capabilities
- **Values**: Configuration parameters for charts
- **Releases**: Instances of deployed charts

#### **Helm Architecture**
- **Chart Repository**: Central storage for charts
- **Helm Client**: Command-line interface
- **Tiller (deprecated)**: Server-side component
- **Helm 3**: Direct Kubernetes API integration

#### **Chart Structure**
```
chart-name/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default values
├── charts/             # Dependencies
├── templates/          # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
└── README.md           # Documentation
```

### OperatorHub Integration

OpenShift provides seamless integration with OperatorHub:

#### **OperatorHub Features**
- **Curated Operators**: Pre-tested and validated operators
- **Community Operators**: Community-contributed operators
- **Red Hat Operators**: Officially supported operators
- **Custom Operators**: Self-hosted operators

#### **Operator Installation Methods**
- **Web Console**: GUI-based installation
- **CLI**: Command-line installation
- **OLM**: Operator Lifecycle Manager
- **Custom Resources**: Direct CRD installation

---

## 🛠️ Hands-On Lab

### Prerequisites

> **📋 Reference**: See [shared/prerequisites.md](../shared/prerequisites.md) for detailed prerequisites and installation instructions.

- OpenShift cluster access (from previous days)
- OpenShift CLI (`oc`) installed and configured
- Admin access for operator installation
- Understanding of basic Kubernetes concepts
- Helm 3 installed (optional for advanced exercises)

### Exercise 1: OperatorHub Exploration

#### Step 1: Access OperatorHub
```bash
# Create a new project for Day 09
oc new-project day09-operators --description="Day 09 operators and helm"

# Check operator catalog sources
oc get catalogsource -n openshift-marketplace

# List available operators
oc get packagemanifest -n openshift-marketplace

# Get operator details
oc describe packagemanifest postgresql-operator -n openshift-marketplace
```

#### Step 2: Install Operator via CLI
```bash
# Create operator group
cat > operator-group.yaml << EOF
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: day09-operator-group
  namespace: day09-operators
spec:
  targetNamespaces:
  - day09-operators
EOF

oc apply -f operator-group.yaml

# Create subscription for PostgreSQL operator
cat > postgresql-subscription.yaml << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: postgresql-operator
  namespace: day09-operators
spec:
  channel: v5.3
  name: postgresql-operator
  source: community-operators
  sourceNamespace: openshift-marketplace
EOF

oc apply -f postgresql-subscription.yaml

# Check subscription status
oc get subscription postgresql-operator -o yaml
oc get csv -n day09-operators
```

#### Step 3: Verify Operator Installation
```bash
# Check operator deployment
oc get deployment -n day09-operators

# Check operator pods
oc get pods -n day09-operators

# Check operator logs
oc logs deployment/postgresql-operator-controller-manager -n day09-operators

# Check custom resource definitions
oc get crd | grep postgresql
```

### Exercise 2: Deploy Application with Operator

#### Step 1: Create PostgreSQL Database
```bash
# Create PostgreSQL cluster
cat > postgresql-cluster.yaml << EOF
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: postgresql-cluster
  namespace: day09-operators
spec:
  instances: 3
  postgresql:
    parameters:
      max_connections: "100"
      shared_buffers: "256MB"
  bootstrap:
    initdb:
      database: myapp
      owner: myapp
      secret:
        name: postgresql-cluster-app
  storage:
    size: 1Gi
EOF

oc apply -f postgresql-cluster.yaml

# Check cluster status
oc get cluster postgresql-cluster -o yaml
oc get pods -l cnpg.io/cluster=postgresql-cluster
```

#### Step 2: Create Application Secret
```bash
# Create application secret
cat > app-secret.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: postgresql-cluster-app
  namespace: day09-operators
type: Opaque
stringData:
  username: myapp
  password: myapp123
EOF

oc apply -f app-secret.yaml
```

#### Step 3: Deploy Application
```bash
# Create application deployment
cat > app-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: day09-operators
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: postgres:13
        command: ["sleep", "infinity"]
        env:
        - name: POSTGRES_HOST
          value: postgresql-cluster-rw.day09-operators.svc.cluster.local
        - name: POSTGRES_DB
          value: myapp
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: postgresql-cluster-app
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgresql-cluster-app
              key: password
EOF

oc apply -f app-deployment.yaml

# Check application status
oc get deployment myapp
oc get pods -l app=myapp
```

### Exercise 3: Helm Charts

#### Step 1: Install Helm
```bash
# Download and install Helm (if not already installed)
curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar xz
sudo mv linux-amd64/helm /usr/local/bin/helm

# Verify Helm installation
helm version

# Add OpenShift repository
helm repo add openshift https://charts.openshift.io
helm repo update
```

#### Step 2: Create Simple Helm Chart
```bash
# Create new chart
helm create myapp-chart

# Explore chart structure
ls -la myapp-chart/
cat myapp-chart/Chart.yaml
cat myapp-chart/values.yaml
ls -la myapp-chart/templates/
```

#### Step 3: Customize Chart
```bash
# Update values.yaml
cat > myapp-chart/values.yaml << EOF
replicaCount: 3

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "latest"

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations: {}

podSecurityContext: {}

securityContext: {}

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []

resources: {}

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80

nodeSelector: {}

tolerations: []

affinity: {}
EOF

# Update deployment template
cat > myapp-chart/templates/deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp-chart.fullname" . }}
  labels:
    {{- include "myapp-chart.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "myapp-chart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "myapp-chart.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "myapp-chart.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /
              port: http
          readinessProbe:
            httpGet:
              path: /
              port: http
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
EOF

# Update service template
cat > myapp-chart/templates/service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: {{ include "myapp-chart.fullname" . }}
  labels:
    {{- include "myapp-chart.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
  selector:
    {{- include "myapp-chart.selectorLabels" . | nindent 4 }}
EOF
```

#### Step 4: Deploy Helm Chart
```bash
# Create namespace for Helm deployment
oc new-project helm-demo

# Deploy chart
helm install myapp-release ./myapp-chart --namespace helm-demo

# Check deployment
helm list -n helm-demo
oc get deployment -n helm-demo
oc get service -n helm-demo

# Upgrade chart
helm upgrade myapp-release ./myapp-chart --namespace helm-demo --set replicaCount=5

# Check upgrade
oc get deployment -n helm-demo
```

### Exercise 4: Advanced Operator Management

#### Step 1: Install Multiple Operators
```bash
# Install Redis operator
cat > redis-subscription.yaml << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: redis-operator
  namespace: day09-operators
spec:
  channel: alpha
  name: redis-operator
  source: community-operators
  sourceNamespace: openshift-marketplace
EOF

oc apply -f redis-subscription.yaml

# Install MongoDB operator
cat > mongodb-subscription.yaml << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: mongodb-enterprise
  namespace: day09-operators
spec:
  channel: "1.0"
  name: mongodb-enterprise
  source: certified-operators
  sourceNamespace: openshift-marketplace
EOF

oc apply -f mongodb-subscription.yaml

# Check operator status
oc get csv -n day09-operators
oc get subscription -n day09-operators
```

#### Step 2: Create Multi-Operator Application
```bash
# Create Redis instance
cat > redis-instance.yaml << EOF
apiVersion: redis.redis.opstreelabs.in/v1beta1
kind: Redis
metadata:
  name: redis-instance
  namespace: day09-operators
spec:
  mode: cluster
  cluster:
    size: 3
  redisExporter:
    enabled: true
EOF

oc apply -f redis-instance.yaml

# Create MongoDB instance
cat > mongodb-instance.yaml << EOF
apiVersion: mongodb.com/v1
kind: MongoDB
metadata:
  name: mongodb-instance
  namespace: day09-operators
spec:
  members: 3
  type: ReplicaSet
  version: "4.4.6"
  security:
    authentication:
      modes: ["SCRAM"]
EOF

oc apply -f mongodb-instance.yaml

# Check instances
oc get redis redis-instance
oc get mongodb mongodb-instance
```

#### Step 3: Create Application with Multiple Dependencies
```bash
# Create application deployment with multiple databases
cat > multi-db-app.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multi-db-app
  namespace: day09-operators
spec:
  replicas: 2
  selector:
    matchLabels:
      app: multi-db-app
  template:
    metadata:
      labels:
        app: multi-db-app
    spec:
      containers:
      - name: app
        image: nginx:latest
        ports:
        - containerPort: 80
        env:
        - name: REDIS_HOST
          value: redis-instance-headless.day09-operators.svc.cluster.local
        - name: MONGODB_HOST
          value: mongodb-instance-svc.day09-operators.svc.cluster.local
        - name: POSTGRES_HOST
          value: postgresql-cluster-rw.day09-operators.svc.cluster.local
EOF

oc apply -f multi-db-app.yaml

# Create service for the application
cat > multi-db-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: multi-db-app-service
  namespace: day09-operators
spec:
  selector:
    app: multi-db-app
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

oc apply -f multi-db-service.yaml

# Create route
oc expose service multi-db-app-service
```

### Exercise 5: Custom Operator Development

#### Step 1: Create Custom Resource Definition
```bash
# Create custom resource definition
cat > custom-app-crd.yaml << EOF
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: customapps.example.com
spec:
  group: example.com
  names:
    kind: CustomApp
    listKind: CustomAppList
    plural: customapps
    singular: customapp
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              replicas:
                type: integer
                minimum: 1
                maximum: 10
              image:
                type: string
              port:
                type: integer
            required:
            - replicas
            - image
            - port
    additionalPrinterColumns:
    - name: Replicas
      type: integer
      jsonPath: .spec.replicas
    - name: Image
      type: string
      jsonPath: .spec.image
    - name: Port
      type: integer
      jsonPath: .spec.port
EOF

oc apply -f custom-app-crd.yaml

# Verify CRD creation
oc get crd customapps.example.com
```

#### Step 2: Create Custom Controller
```bash
# Create controller deployment
cat > custom-controller.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: custom-app-controller
  namespace: day09-operators
spec:
  replicas: 1
  selector:
    matchLabels:
      app: custom-app-controller
  template:
    metadata:
      labels:
        app: custom-app-controller
    spec:
      serviceAccountName: custom-controller-sa
      containers:
      - name: controller
        image: nginx:latest
        command: ["sleep", "infinity"]
        env:
        - name: WATCH_NAMESPACE
          value: day09-operators
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
EOF

oc apply -f custom-controller.yaml

# Create service account
cat > controller-sa.yaml << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: custom-controller-sa
  namespace: day09-operators
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: custom-controller-role
rules:
- apiGroups: ["example.com"]
  resources: ["customapps"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: custom-controller-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: custom-controller-role
subjects:
- kind: ServiceAccount
  name: custom-controller-sa
  namespace: day09-operators
EOF

oc apply -f controller-sa.yaml
```

#### Step 3: Create Custom Resource Instance
```bash
# Create custom app instance
cat > custom-app-instance.yaml << EOF
apiVersion: example.com/v1
kind: CustomApp
metadata:
  name: my-custom-app
  namespace: day09-operators
spec:
  replicas: 3
  image: nginx:latest
  port: 80
EOF

oc apply -f custom-app-instance.yaml

# Check custom resource
oc get customapp my-custom-app
oc describe customapp my-custom-app
```

### Exercise 6: Helm Advanced Features

#### Step 1: Create Complex Helm Chart
```bash
# Create complex application chart
helm create complex-app

# Update Chart.yaml
cat > complex-app/Chart.yaml << EOF
apiVersion: v2
name: complex-app
description: A complex application with multiple components
type: application
version: 0.1.0
appVersion: "1.0.0"
dependencies:
  - name: postgresql
    version: 12.x.x
    repository: https://charts.bitnami.com/bitnami
  - name: redis
    version: 17.x.x
    repository: https://charts.bitnami.com/bitnami
EOF

# Update values.yaml
cat > complex-app/values.yaml << EOF
# Application configuration
app:
  replicaCount: 3
  image:
    repository: nginx
    tag: latest
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "256Mi"
      cpu: "200m"

# Database configuration
postgresql:
  enabled: true
  auth:
    postgresPassword: "postgres123"
    database: "myapp"
  primary:
    persistence:
      enabled: true
      size: 1Gi

# Cache configuration
redis:
  enabled: true
  auth:
    enabled: false
  master:
    persistence:
      enabled: true
      size: 1Gi

# Ingress configuration
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: complex-app.local
      paths:
        - path: /
          pathType: Prefix
EOF

# Create application templates
cat > complex-app/templates/deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "complex-app.fullname" . }}-app
  labels:
    {{- include "complex-app.labels" . | nindent 4 }}
    component: app
spec:
  replicas: {{ .Values.app.replicaCount }}
  selector:
    matchLabels:
      {{- include "complex-app.selectorLabels" . | nindent 6 }}
      component: app
  template:
    metadata:
      labels:
        {{- include "complex-app.selectorLabels" . | nindent 8 }}
        component: app
    spec:
      containers:
        - name: app
          image: "{{ .Values.app.image.repository }}:{{ .Values.app.image.tag }}"
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          resources:
            {{- toYaml .Values.app.resources | nindent 12 }}
          env:
            - name: DATABASE_URL
              value: "postgresql://{{ .Values.postgresql.auth.postgresPassword }}@{{ include "complex-app.fullname" . }}-postgresql:5432/{{ .Values.postgresql.auth.database }}"
            - name: REDIS_URL
              value: "redis://{{ include "complex-app.fullname" . }}-redis-master:6379"
EOF

# Create service template
cat > complex-app/templates/service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: {{ include "complex-app.fullname" . }}-app
  labels:
    {{- include "complex-app.labels" . | nindent 4 }}
    component: app
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: http
      protocol: TCP
      name: http
  selector:
    {{- include "complex-app.selectorLabels" . | nindent 4 }}
    component: app
EOF

# Create ingress template
cat > complex-app/templates/ingress.yaml << EOF
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "complex-app.fullname" . }}-app
  labels:
    {{- include "complex-app.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  ingressClassName: {{ .Values.ingress.className }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ include "complex-app.fullname" $ }}-app
                port:
                  number: 80
          {{- end }}
    {{- end }}
{{- end }}
EOF
```

#### Step 2: Deploy Complex Helm Chart
```bash
# Update dependencies
helm dependency update ./complex-app

# Install complex application
helm install complex-release ./complex-app --namespace helm-demo

# Check deployment
helm list -n helm-demo
oc get all -n helm-demo

# Upgrade with new values
helm upgrade complex-release ./complex-app --namespace helm-demo --set app.replicaCount=5

# Check upgrade
oc get deployment -n helm-demo
```

#### Step 3: Helm Chart Management
```bash
# Create chart repository
mkdir -p chart-repo
helm package ./complex-app -d chart-repo

# Create index
helm repo index chart-repo

# Add local repository
helm repo add local-repo file://$(pwd)/chart-repo

# Install from local repository
helm install local-release local-repo/complex-app --namespace helm-demo

# Rollback deployment
helm rollback complex-release 1 --namespace helm-demo

# Uninstall release
helm uninstall complex-release --namespace helm-demo
```

---

## 📋 Lab Tasks

### Task 1: OperatorHub Exploration
- [ ] Explore available operators in OperatorHub
- [ ] Install PostgreSQL operator via CLI
- [ ] Verify operator installation and status
- [ ] Check operator custom resources

### Task 2: Operator Application Deployment
- [ ] Deploy PostgreSQL database using operator
- [ ] Create application secrets
- [ ] Deploy application with database connection
- [ ] Test application functionality

### Task 3: Helm Chart Creation
- [ ] Create simple Helm chart structure
- [ ] Customize chart templates and values
- [ ] Deploy chart to OpenShift
- [ ] Upgrade and manage chart releases

### Task 4: Advanced Operator Management
- [ ] Install multiple operators (Redis, MongoDB)
- [ ] Deploy multi-database application
- [ ] Create application with multiple dependencies
- [ ] Test cross-operator functionality

### Task 5: Custom Operator Development
- [ ] Create custom resource definitions
- [ ] Deploy custom controller
- [ ] Create custom resource instances
- [ ] Test custom operator functionality

### Task 6: Advanced Helm Features
- [ ] Create complex Helm chart with dependencies
- [ ] Deploy multi-component application
- [ ] Manage chart repositories
- [ ] Implement chart lifecycle management

---

## 🧪 Challenge Exercise

### Advanced Challenge: Complete Operator and Helm Ecosystem

Create a comprehensive application ecosystem using operators and Helm:

1. **Multi-Operator Application Stack**
   ```bash
   # Create namespace for challenge
   oc new-project operator-helm-challenge
   
   # Install required operators
   cat > challenge-operators.yaml << EOF
   apiVersion: operators.coreos.com/v1alpha1
   kind: Subscription
   metadata:
     name: postgresql-operator
     namespace: operator-helm-challenge
   spec:
     channel: v5.3
     name: postgresql-operator
     source: community-operators
     sourceNamespace: openshift-marketplace
   ---
   apiVersion: operators.coreos.com/v1alpha1
   kind: Subscription
   metadata:
     name: redis-operator
     namespace: operator-helm-challenge
   spec:
     channel: alpha
     name: redis-operator
     source: community-operators
     sourceNamespace: openshift-marketplace
   ---
   apiVersion: operators.coreos.com/v1alpha1
   kind: Subscription
   metadata:
     name: prometheus-operator
     namespace: operator-helm-challenge
   spec:
     channel: beta
     name: prometheus-operator
     source: community-operators
     sourceNamespace: openshift-marketplace
   EOF
   oc apply -f challenge-operators.yaml
   ```

2. **Create Comprehensive Helm Chart**
   ```bash
   # Create enterprise application chart
   helm create enterprise-app
   
   # Update Chart.yaml with dependencies
   cat > enterprise-app/Chart.yaml << EOF
   apiVersion: v2
   name: enterprise-app
   description: Enterprise application with monitoring
   type: application
   version: 1.0.0
   appVersion: "2.0.0"
   dependencies:
     - name: postgresql
       version: 12.x.x
       repository: https://charts.bitnami.com/bitnami
     - name: redis
       version: 17.x.x
       repository: https://charts.bitnami.com/bitnami
     - name: prometheus
       version: 19.x.x
       repository: https://prometheus-community.github.io/helm-charts
     - name: grafana
       version: 7.x.x
       repository: https://grafana.github.io/helm-charts
   EOF
   
   # Create comprehensive values.yaml
   cat > enterprise-app/values.yaml << EOF
   # Application configuration
   app:
     replicaCount: 3
     image:
       repository: nginx
       tag: latest
     resources:
       requests:
         memory: "256Mi"
         cpu: "200m"
       limits:
         memory: "512Mi"
         cpu: "500m"
     autoscaling:
       enabled: true
       minReplicas: 2
       maxReplicas: 10
       targetCPUUtilizationPercentage: 80
   
   # Database configuration
   postgresql:
     enabled: true
     auth:
       postgresPassword: "secure123"
       database: "enterprise"
     primary:
       persistence:
         enabled: true
         size: 10Gi
     readReplicas:
       persistence:
         enabled: true
         size: 5Gi
   
   # Cache configuration
   redis:
     enabled: true
     auth:
       enabled: true
       sentinel: true
     master:
       persistence:
         enabled: true
         size: 5Gi
     replica:
       replicaCount: 2
       persistence:
         enabled: true
         size: 2Gi
   
   # Monitoring configuration
   prometheus:
     enabled: true
     prometheusSpec:
       retention: 30d
       storageSpec:
         volumeClaimTemplate:
           spec:
             storageClassName: fast
             accessModes: ["ReadWriteOnce"]
             resources:
               requests:
                 storage: 50Gi
   
   grafana:
     enabled: true
     adminPassword: "admin123"
     persistence:
       enabled: true
       size: 10Gi
     dashboardProviders:
       dashboardproviders.yaml:
         apiVersion: 1
         providers:
         - name: 'default'
           orgId: 1
           folder: ''
           type: file
           disableDeletion: false
           editable: true
           options:
             path: /var/lib/grafana/dashboards/default
   
   # Ingress configuration
   ingress:
     enabled: true
     className: nginx
     annotations:
       cert-manager.io/cluster-issuer: letsencrypt-prod
     hosts:
       - host: enterprise-app.local
         paths:
           - path: /
             pathType: Prefix
     tls:
       - secretName: enterprise-app-tls
         hosts:
           - enterprise-app.local
   EOF
   ```

3. **Deploy Complete Application Stack**
   ```bash
   # Update dependencies
   helm dependency update ./enterprise-app
   
   # Install enterprise application
   helm install enterprise-release ./enterprise-app --namespace operator-helm-challenge
   
   # Check deployment status
   helm list -n operator-helm-challenge
   oc get all -n operator-helm-challenge
   
   # Monitor application health
   oc get pods -n operator-helm-challenge
   oc get services -n operator-helm-challenge
   ```

4. **Create Custom Monitoring Operator**
   ```bash
   # Create custom monitoring CRD
   cat > custom-monitoring-crd.yaml << EOF
   apiVersion: apiextensions.k8s.io/v1
   kind: CustomResourceDefinition
   metadata:
     name: custommonitors.example.com
   spec:
     group: example.com
     names:
       kind: CustomMonitor
       listKind: CustomMonitorList
       plural: custommonitors
       singular: custommonitor
     scope: Namespaced
     versions:
     - name: v1
       served: true
       storage: true
       schema:
         openAPIV3Schema:
           type: object
           properties:
             spec:
               type: object
               properties:
                 target:
                   type: string
                 interval:
                   type: string
                 threshold:
                   type: integer
   EOF
   oc apply -f custom-monitoring-crd.yaml
   
   # Create custom monitor instance
   cat > custom-monitor.yaml << EOF
   apiVersion: example.com/v1
   kind: CustomMonitor
   metadata:
     name: app-monitor
     namespace: operator-helm-challenge
   spec:
     target: "enterprise-release-app"
     interval: "30s"
     threshold: 80
   EOF
   oc apply -f custom-monitor.yaml
   ```

5. **Implement GitOps Workflow**
   ```bash
   # Create GitOps configuration
   cat > gitops-config.yaml << EOF
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: enterprise-app-gitops
     namespace: argocd
   spec:
     project: default
     source:
       repoURL: https://github.com/your-org/enterprise-app
       targetRevision: HEAD
       path: k8s
     destination:
       server: https://kubernetes.default.svc
       namespace: operator-helm-challenge
     syncPolicy:
       automated:
         prune: true
         selfHeal: true
       syncOptions:
       - CreateNamespace=true
   EOF
   oc apply -f gitops-config.yaml
   ```

6. **Create Application Dashboard**
   ```bash
   # Create Grafana dashboard
   cat > app-dashboard.json << EOF
   {
     "dashboard": {
       "title": "Enterprise Application Dashboard",
       "panels": [
         {
           "title": "Application Health",
           "type": "stat",
           "targets": [
             {
               "expr": "up{app=\"enterprise-release-app\"}"
             }
           ]
         },
         {
           "title": "Database Connections",
           "type": "graph",
           "targets": [
             {
               "expr": "pg_stat_database_numbackends"
             }
           ]
         },
         {
           "title": "Redis Memory Usage",
           "type": "graph",
           "targets": [
             {
               "expr": "redis_memory_used_bytes"
             }
           ]
         }
       ]
     }
   }
   EOF
   
   # Apply dashboard
   oc create configmap grafana-dashboard --from-file=app-dashboard.json -n operator-helm-challenge
   ```

---

## 📊 Key Commands Summary

> **📋 Reference**: See [shared/common-commands.md](../shared/common-commands.md) for comprehensive OpenShift command reference.

### Operator Management
```bash
oc get packagemanifest -n openshift-marketplace
oc get subscription -n <namespace>
oc get csv -n <namespace>
oc get crd | grep <operator>
```

### Helm Chart Management
```bash
helm create <chart-name>
helm install <release-name> <chart-path> --namespace <namespace>
helm upgrade <release-name> <chart-path> --namespace <namespace>
helm list -n <namespace>
helm uninstall <release-name> -n <namespace>
```

### Custom Resource Management
```bash
oc get crd
oc apply -f custom-resource.yaml
oc get <custom-resource-type>
oc describe <custom-resource-type> <name>
```

### Operator Lifecycle
```bash
oc get operatorgroup
oc get subscription
oc get csv
oc get deployment -n <operator-namespace>
```

---

## 🚨 Common Issues & Solutions

> **📋 Reference**: See [shared/troubleshooting.md](../shared/troubleshooting.md) for comprehensive troubleshooting guide.

### Issue: Operator Installation Fails
```bash
# Check operator catalog
oc get catalogsource -n openshift-marketplace

# Check subscription status
oc describe subscription <operator-name>

# Check CSV status
oc describe csv <csv-name>

# Check operator logs
oc logs deployment/<operator-deployment> -n <namespace>
```

### Issue: Helm Chart Deployment Fails
```bash
# Check chart syntax
helm lint <chart-path>

# Check values
helm template <chart-path> --values <values-file>

# Check deployment status
helm status <release-name> -n <namespace>

# Check OpenShift resources
oc get all -n <namespace>
```

### Issue: Custom Resources Not Working
```bash
# Check CRD installation
oc get crd | grep <custom-resource>

# Check custom resource instances
oc get <custom-resource-type>

# Check controller logs
oc logs deployment/<controller-name> -n <namespace>

# Check RBAC permissions
oc auth can-i create <custom-resource-type>
```

### Issue: Operator Updates Fail
```bash
# Check available updates
oc get csv -n <namespace>

# Check update channel
oc describe subscription <operator-name>

# Check operator health
oc get deployment -n <operator-namespace>

# Check operator events
oc get events -n <operator-namespace> --sort-by='.lastTimestamp'
```

---

## 📚 Next Steps

After completing Day 09:
1. **Day 10**: Advanced Topics
2. **Day 11**: GitOps and ArgoCD
3. **Day 12**: Multi-cluster Management

---

## 🔗 Additional Resources

> **📋 Reference**: See [shared/common-commands.md](../shared/common-commands.md) for comprehensive OpenShift command reference.

- [OpenShift Operators Documentation](https://docs.openshift.com/container-platform/4.10/operators/understanding/olm-what-operators-are.html)
- [OperatorHub Documentation](https://operatorhub.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [OpenShift Helm Integration](https://docs.openshift.com/container-platform/4.10/cli_reference/helm_cli/getting-started-with-helm-on-openshift.html)

---

**💡 Pro Tip**: Use `oc get packagemanifest -n openshift-marketplace` to explore available operators before installation!

**💡 Pro Tip**: Use `helm dependency update <chart-path>` to update chart dependencies before deployment!