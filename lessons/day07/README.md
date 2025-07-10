# Day 07: Monitoring & Logging - Prometheus, Grafana, Loki & EFK Stack

## 🎯 Learning Objectives

By the end of this lesson, you will be able to:
- Understand OpenShift's monitoring and logging architecture
- Configure and use Prometheus for metrics collection
- Set up Grafana dashboards for visualization
- Implement centralized logging with Loki
- Deploy and manage the EFK (Elasticsearch, Fluentd, Kibana) stack
- Create custom metrics and alerts
- Troubleshoot monitoring and logging issues
- Implement log aggregation and analysis

---

## 📚 Theory Section

### Monitoring & Logging Architecture in OpenShift

OpenShift provides a comprehensive monitoring and logging solution that includes:

#### **Monitoring Stack**
- **Prometheus**: Metrics collection and storage
- **Grafana**: Metrics visualization and dashboards
- **Alertmanager**: Alert routing and notification
- **Custom Metrics**: Application-specific metrics

#### **Logging Stack**
- **Loki**: Log aggregation and storage
- **Fluentd**: Log collection and forwarding
- **Kibana**: Log visualization and analysis
- **EFK Stack**: Alternative logging solution

### Monitoring Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Applications  │───▶│   Prometheus    │───▶│    Grafana      │
│   (Metrics)     │    │   (Collection)  │    │ (Visualization) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │ Alertmanager    │    │   Custom Alerts │
                       │ (Notifications) │    │   (Business)    │
                       └─────────────────┘    └─────────────────┘
```

### Logging Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Applications  │───▶│    Fluentd      │───▶│     Loki        │
│   (Logs)        │    │  (Collection)   │    │   (Storage)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   Grafana       │    │   Log Analysis  │
                       │ (Visualization) │    │   (Queries)     │
                       └─────────────────┘    └─────────────────┘
```

### Key Metrics Categories

#### **Infrastructure Metrics**
- **Node Metrics**: CPU, memory, disk usage
- **Pod Metrics**: Resource consumption, status
- **Network Metrics**: Bandwidth, latency, errors
- **Storage Metrics**: I/O, capacity, performance

#### **Application Metrics**
- **Business Metrics**: User activity, transactions
- **Performance Metrics**: Response time, throughput
- **Error Metrics**: Error rates, failure patterns
- **Custom Metrics**: Application-specific data

#### **Log Categories**
- **Application Logs**: Business logic, errors
- **System Logs**: OS, container runtime
- **Security Logs**: Authentication, authorization
- **Audit Logs**: User actions, changes

---

## 🛠️ Hands-On Lab

### Prerequisites

> **📋 Reference**: See [shared/prerequisites.md](../shared/prerequisites.md) for detailed prerequisites and installation instructions.

- OpenShift cluster access (from previous days)
- OpenShift CLI (`oc`) installed and configured
- Understanding of application deployment
- Access to monitoring and logging operators

### Exercise 1: OpenShift Monitoring Stack

#### Step 1: Check Monitoring Installation
```bash
# Create a new project for Day 07
oc new-project day07-monitoring --description="Day 07 monitoring and logging"

# Check if monitoring is installed
oc get csv -n openshift-monitoring

# Check monitoring operator status
oc get pods -n openshift-monitoring

# Check monitoring routes
oc get routes -n openshift-monitoring
```

#### Step 2: Access Monitoring Dashboards
```bash
# Get Grafana route
oc get route grafana -n openshift-monitoring

# Get Prometheus route
oc get route prometheus-k8s -n openshift-monitoring

# Get Alertmanager route
oc get route alertmanager-main -n openshift-monitoring

# Access Grafana (replace with your cluster URL)
echo "Grafana URL: https://$(oc get route grafana -n openshift-monitoring -o jsonpath='{.spec.host}')"
```

#### Step 3: Explore Prometheus Metrics
```bash
# Check Prometheus targets
oc get pods -n openshift-monitoring -l app=prometheus

# Access Prometheus API
oc exec -n openshift-monitoring deployment/prometheus-k8s -- curl -s http://localhost:9090/api/v1/targets

# Query metrics via API
oc exec -n openshift-monitoring deployment/prometheus-k8s -- curl -s "http://localhost:9090/api/v1/query?query=up"
```

### Exercise 2: Custom Metrics and Alerts

#### Step 1: Create Custom Metrics
```bash
# Deploy a sample application with metrics
cat > metrics-app.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metrics-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: metrics-app
  template:
    metadata:
      labels:
        app: metrics-app
    spec:
      containers:
      - name: metrics-app
        image: nginx:latest
        ports:
        - containerPort: 80
        - containerPort: 8080
        env:
        - name: METRICS_PORT
          value: "8080"
EOF

oc apply -f metrics-app.yaml

# Expose the application
oc expose deployment metrics-app --port=80
oc expose deployment metrics-app --port=8080 --name=metrics-app-metrics
```

#### Step 2: Create ServiceMonitor
```bash
# Create ServiceMonitor for custom metrics
cat > servicemonitor.yaml << EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: metrics-app-monitor
  namespace: day07-monitoring
spec:
  selector:
    matchLabels:
      app: metrics-app
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
EOF

oc apply -f servicemonitor.yaml

# Check ServiceMonitor status
oc get servicemonitor
oc describe servicemonitor metrics-app-monitor
```

#### Step 3: Create Custom Alerts
```bash
# Create PrometheusRule for custom alerts
cat > custom-alerts.yaml << EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: custom-alerts
  namespace: day07-monitoring
spec:
  groups:
  - name: custom.rules
    rules:
    - alert: HighCPUUsage
      expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage detected"
        description: "CPU usage is above 80% for 5 minutes"
    - alert: HighMemoryUsage
      expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage detected"
        description: "Memory usage is above 85% for 5 minutes"
EOF

oc apply -f custom-alerts.yaml

# Check PrometheusRule status
oc get prometheusrule
oc describe prometheusrule custom-alerts
```

### Exercise 3: Grafana Dashboards

#### Step 1: Access Grafana
```bash
# Get Grafana credentials
oc get secret grafana-datasources -n openshift-monitoring -o jsonpath='{.data.prometheus\.yaml}' | base64 -d

# Access Grafana dashboard
echo "Access Grafana at: https://$(oc get route grafana -n openshift-monitoring -o jsonpath='{.spec.host}')"
echo "Default credentials: admin / $(oc get secret grafana-datasources -n openshift-monitoring -o jsonpath='{.data.admin-password}' | base64 -d)"
```

#### Step 2: Create Custom Dashboard
```bash
# Create dashboard configuration
cat > custom-dashboard.json << EOF
{
  "dashboard": {
    "title": "Custom Application Dashboard",
    "panels": [
      {
        "title": "Application Pods",
        "type": "stat",
        "targets": [
          {
            "expr": "kube_deployment_status_replicas{deployment=\"metrics-app\"}",
            "legendFormat": "Replicas"
          }
        ]
      },
      {
        "title": "CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - (avg by(instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "CPU %"
          }
        ]
      },
      {
        "title": "Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100",
            "legendFormat": "Memory %"
          }
        ]
      }
    ]
  }
}
EOF
```

#### Step 3: Import Dashboard
```bash
# Note: Dashboard import is typically done via Grafana UI
echo "Import the dashboard JSON via Grafana UI:"
echo "1. Go to Grafana dashboard"
echo "2. Click '+' -> Import"
echo "3. Upload the custom-dashboard.json file"
echo "4. Configure data source as Prometheus"
echo "5. Save dashboard"
```

### Exercise 4: Centralized Logging with Loki

#### Step 1: Install Loki Operator
```bash
# Check if Loki is available
oc get csv -n openshift-operators | grep loki

# Install Loki operator if needed
cat > loki-subscription.yaml << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: loki-operator
  namespace: openshift-operators
spec:
  channel: stable
  name: loki-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

oc apply -f loki-subscription.yaml
```

#### Step 2: Deploy Loki Stack
```bash
# Create Loki instance
cat > loki-instance.yaml << EOF
apiVersion: loki.grafana.com/v1
kind: LokiStack
metadata:
  name: loki
  namespace: day07-monitoring
spec:
  size: 1x.extra-small
  storage:
    secret:
      name: loki-storage
  managementState: Managed
EOF

oc apply -f loki-instance.yaml

# Check Loki status
oc get lokistack
oc describe lokistack loki
```

#### Step 3: Configure Log Collection
```bash
# Create log forwarding configuration
cat > log-forwarding.yaml << EOF
apiVersion: logging.openshift.io/v1
kind: ClusterLogForwarder
metadata:
  name: instance
spec:
  outputs:
  - name: loki-output
    type: loki
    loki:
      url: http://loki-gateway-day07-monitoring.svc:80
  pipelines:
  - name: application-logs
    inputRefs:
    - application
    outputRefs:
    - loki-output
EOF

oc apply -f log-forwarding.yaml

# Check log forwarding status
oc get clusterlogforwarder
oc describe clusterlogforwarder instance
```

### Exercise 5: EFK Stack Deployment

#### Step 1: Install Elasticsearch Operator
```bash
# Check if Elasticsearch operator is available
oc get csv -n openshift-operators | grep elasticsearch

# Install Elasticsearch operator
cat > elasticsearch-subscription.yaml << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: elasticsearch-operator
  namespace: openshift-operators
spec:
  channel: stable
  name: elasticsearch-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

oc apply -f elasticsearch-subscription.yaml
```

#### Step 2: Deploy Elasticsearch
```bash
# Create Elasticsearch cluster
cat > elasticsearch-cluster.yaml << EOF
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: elasticsearch
  namespace: day07-monitoring
spec:
  version: 7.17.0
  nodeSets:
  - name: default
    count: 1
    config:
      node.roles: ["master", "data"]
    podTemplate:
      spec:
        containers:
        - name: elasticsearch
          resources:
            requests:
              memory: 1Gi
              cpu: 0.5
            limits:
              memory: 2Gi
              cpu: 1
EOF

oc apply -f elasticsearch-cluster.yaml

# Check Elasticsearch status
oc get elasticsearch
oc describe elasticsearch elasticsearch
```

#### Step 3: Deploy Kibana
```bash
# Create Kibana instance
cat > kibana-instance.yaml << EOF
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: kibana
  namespace: day07-monitoring
spec:
  version: 7.17.0
  count: 1
  elasticsearchRef:
    name: elasticsearch
EOF

oc apply -f kibana-instance.yaml

# Check Kibana status
oc get kibana
oc describe kibana kibana
```

#### Step 4: Configure Fluentd
```bash
# Create Fluentd configuration
cat > fluentd-config.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
  namespace: day07-monitoring
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      read_from_head true
      <parse>
        @type json
        time_format %Y-%m-%dT%H:%M:%S.%NZ
      </parse>
    </source>
    
    <filter kubernetes.**>
      @type kubernetes_metadata
    </filter>
    
    <match kubernetes.**>
      @type elasticsearch
      host elasticsearch-master
      port 9200
      logstash_format true
      logstash_prefix k8s
    </match>
EOF

oc apply -f fluentd-config.yaml
```

### Exercise 6: Log Analysis and Visualization

#### Step 1: Access Kibana
```bash
# Get Kibana route
oc get route kibana -n day07-monitoring

# Access Kibana
echo "Access Kibana at: https://$(oc get route kibana -n day07-monitoring -o jsonpath='{.spec.host}')"
```

#### Step 2: Create Log Queries
```bash
# Example log queries for Kibana
echo "Sample Kibana queries:"
echo "1. All application logs: kubernetes.container_name:*"
echo "2. Error logs: kubernetes.container_name:* AND log:ERROR"
echo "3. Specific pod logs: kubernetes.pod_name:metrics-app-*"
echo "4. Time-based query: @timestamp:[now-1h TO now]"
```

#### Step 3: Create Log Dashboards
```bash
# Create dashboard configuration
cat > log-dashboard.json << EOF
{
  "dashboard": {
    "title": "Application Logs Dashboard",
    "panels": [
      {
        "title": "Log Volume",
        "type": "visualization",
        "targets": [
          {
            "query": "kubernetes.container_name:*",
            "timeField": "@timestamp"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "visualization",
        "targets": [
          {
            "query": "kubernetes.container_name:* AND log:ERROR",
            "timeField": "@timestamp"
          }
        ]
      }
    ]
  }
}
EOF
```

### Exercise 7: Monitoring and Alerting

#### Step 1: Create Alert Rules
```bash
# Create comprehensive alert rules
cat > comprehensive-alerts.yaml << EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: comprehensive-alerts
  namespace: day07-monitoring
spec:
  groups:
  - name: infrastructure.rules
    rules:
    - alert: NodeDown
      expr: up == 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Node is down"
        description: "Node {{ \$labels.instance }} has been down for more than 5 minutes"
    
    - alert: HighPodRestartRate
      expr: increase(kube_pod_container_status_restarts_total[15m]) > 5
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High pod restart rate"
        description: "Pod {{ \$labels.pod }} has restarted more than 5 times in 15 minutes"
    
    - alert: HighErrorRate
      expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High error rate"
        description: "Error rate is above 10% for 5 minutes"
EOF

oc apply -f comprehensive-alerts.yaml
```

#### Step 2: Configure Alertmanager
```bash
# Create Alertmanager configuration
cat > alertmanager-config.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: alertmanager-main
  namespace: openshift-monitoring
type: Opaque
stringData:
  alertmanager.yaml: |
    global:
      resolve_timeout: 5m
    route:
      group_by: ['alertname']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'web.hook'
    receivers:
    - name: 'web.hook'
      webhook_configs:
      - url: 'http://127.0.0.1:5001/'
EOF

oc apply -f alertmanager-config.yaml
```

#### Step 3: Monitor Alerts
```bash
# Check alert status
oc get prometheusrule
oc describe prometheusrule comprehensive-alerts

# Check Alertmanager status
oc get pods -n openshift-monitoring -l app=alertmanager

# Access Alertmanager UI
echo "Access Alertmanager at: https://$(oc get route alertmanager-main -n openshift-monitoring -o jsonpath='{.spec.host}')"
```

---

## 📋 Lab Tasks

### Task 1: Monitoring Stack Setup
- [ ] Verify OpenShift monitoring installation
- [ ] Access Prometheus and Grafana dashboards
- [ ] Explore default metrics and dashboards
- [ ] Understand monitoring architecture

### Task 2: Custom Metrics and Alerts
- [ ] Deploy application with custom metrics
- [ ] Create ServiceMonitor for metrics collection
- [ ] Set up custom alert rules
- [ ] Test alert notifications

### Task 3: Grafana Dashboards
- [ ] Access Grafana dashboard
- [ ] Create custom dashboards
- [ ] Configure data sources
- [ ] Set up dashboard sharing

### Task 4: Logging Stack Implementation
- [ ] Install and configure Loki
- [ ] Set up log forwarding
- [ ] Deploy EFK stack components
- [ ] Configure log collection

### Task 5: Log Analysis and Visualization
- [ ] Access Kibana dashboard
- [ ] Create log queries and filters
- [ ] Build log dashboards
- [ ] Implement log analysis workflows

### Task 6: Advanced Monitoring
- [ ] Create comprehensive alert rules
- [ ] Configure Alertmanager notifications
- [ ] Monitor alert status
- [ ] Implement monitoring best practices

---

## 🧪 Challenge Exercise

### Advanced Challenge: Complete Observability Stack

Create a comprehensive monitoring and logging solution:

1. **Multi-Environment Monitoring**
   ```bash
   # Create environment-specific dashboards
   cat > environment-dashboards.yaml << EOF
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: environment-dashboards
     namespace: day07-monitoring
   data:
     dev-dashboard.json: |
       {
         "dashboard": {
           "title": "Development Environment",
           "panels": [
             {
               "title": "Dev Pod Status",
               "type": "stat",
               "targets": [
                 {
                   "expr": "kube_pod_status_phase{namespace=\"dev\"}",
                   "legendFormat": "{{pod}}"
                 }
               ]
             }
           ]
         }
       }
     prod-dashboard.json: |
       {
         "dashboard": {
           "title": "Production Environment",
           "panels": [
             {
               "title": "Prod Pod Status",
               "type": "stat",
               "targets": [
                 {
                   "expr": "kube_pod_status_phase{namespace=\"prod\"}",
                   "legendFormat": "{{pod}}"
                 }
               ]
             }
           ]
         }
       }
   EOF
   oc apply -f environment-dashboards.yaml
   ```

2. **Application Performance Monitoring**
   ```bash
   # Create APM metrics
   cat > apm-metrics.yaml << EOF
   apiVersion: monitoring.coreos.com/v1
   kind: ServiceMonitor
   metadata:
     name: apm-monitor
     namespace: day07-monitoring
   spec:
     selector:
       matchLabels:
         app: apm-app
     endpoints:
     - port: metrics
       interval: 15s
       path: /metrics
       metricRelabelings:
       - sourceLabels: [__name__]
         regex: 'http_request_duration_seconds'
         action: keep
   EOF
   oc apply -f apm-metrics.yaml
   ```

3. **Log Correlation and Analysis**
   ```bash
   # Create log correlation rules
   cat > log-correlation.yaml << EOF
   apiVersion: logging.openshift.io/v1
   kind: ClusterLogForwarder
   metadata:
     name: correlation-instance
   spec:
     outputs:
     - name: correlation-output
       type: loki
       loki:
         url: http://loki-gateway-day07-monitoring.svc:80
     pipelines:
     - name: correlation-pipeline
       inputRefs:
       - application
       - infrastructure
       outputRefs:
       - correlation-output
       filters:
       - type: regex
         regex: 'error|ERROR|Error'
   EOF
   oc apply -f log-correlation.yaml
   ```

4. **Business Metrics Dashboard**
   ```bash
   # Create business metrics
   cat > business-metrics.yaml << EOF
   apiVersion: monitoring.coreos.com/v1
   kind: PrometheusRule
   metadata:
     name: business-metrics
     namespace: day07-monitoring
   spec:
     groups:
     - name: business.rules
       rules:
       - alert: HighTransactionVolume
         expr: increase(transactions_total[5m]) > 1000
         for: 2m
         labels:
           severity: info
         annotations:
           summary: "High transaction volume"
           description: "Transaction volume is above 1000 in 5 minutes"
       - alert: LowUserActivity
         expr: rate(user_sessions_total[10m]) < 10
         for: 5m
         labels:
           severity: warning
         annotations:
           summary: "Low user activity"
           description: "User activity is below 10 sessions per minute"
   EOF
   oc apply -f business-metrics.yaml
   ```

5. **Automated Incident Response**
   ```bash
   # Create incident response automation
   cat > incident-response.yaml << EOF
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: incident-response
     namespace: day07-monitoring
   data:
     response-script.sh: |
       #!/bin/bash
       # Automated incident response script
       
       case "\$1" in
         "NodeDown")
           echo "Node down detected - scaling up replacement"
           oc scale deployment/node-replacement --replicas=1
           ;;
         "HighErrorRate")
           echo "High error rate detected - rolling back deployment"
           oc rollout undo deployment/metrics-app
           ;;
         *)
           echo "Unknown incident: \$1"
           ;;
       esac
   EOF
   oc apply -f incident-response.yaml
   ```

---

## 📊 Key Commands Summary

> **📋 Reference**: See [shared/common-commands.md](../shared/common-commands.md) for comprehensive OpenShift command reference.

### Monitoring Commands
```bash
oc get csv -n openshift-monitoring
oc get routes -n openshift-monitoring
oc get servicemonitor
oc get prometheusrule
oc describe prometheusrule <name>
```

### Logging Commands
```bash
oc get lokistack
oc get clusterlogforwarder
oc get elasticsearch
oc get kibana
oc describe clusterlogforwarder instance
```

### Dashboard Access
```bash
oc get route grafana -n openshift-monitoring
oc get route kibana -n day07-monitoring
oc get route prometheus-k8s -n openshift-monitoring
oc get route alertmanager-main -n openshift-monitoring
```

### Alert Management
```bash
oc get prometheusrule
oc describe prometheusrule <name>
oc get pods -n openshift-monitoring -l app=alertmanager
oc logs -n openshift-monitoring deployment/alertmanager-main
```

---

## 🚨 Common Issues & Solutions

> **📋 Reference**: See [shared/troubleshooting.md](../shared/troubleshooting.md) for comprehensive troubleshooting guide.

### Issue: Prometheus Not Collecting Metrics
```bash
# Check Prometheus targets
oc get pods -n openshift-monitoring -l app=prometheus
oc logs -n openshift-monitoring deployment/prometheus-k8s

# Check ServiceMonitor
oc get servicemonitor
oc describe servicemonitor <name>

# Check metrics endpoint
oc exec -n day07-monitoring deployment/metrics-app -- curl -s http://localhost:8080/metrics
```

### Issue: Grafana Dashboard Not Loading
```bash
# Check Grafana status
oc get pods -n openshift-monitoring -l app=grafana
oc logs -n openshift-monitoring deployment/grafana

# Check data source configuration
oc get secret grafana-datasources -n openshift-monitoring -o yaml

# Check route
oc get route grafana -n openshift-monitoring
```

### Issue: Logs Not Appearing in Loki
```bash
# Check Loki status
oc get lokistack
oc describe lokistack loki

# Check log forwarding
oc get clusterlogforwarder
oc describe clusterlogforwarder instance

# Check Fluentd configuration
oc get pods -n openshift-logging -l app=fluentd
oc logs -n openshift-logging deployment/fluentd
```

### Issue: Alerts Not Firing
```bash
# Check PrometheusRule
oc get prometheusrule
oc describe prometheusrule <name>

# Check Alertmanager
oc get pods -n openshift-monitoring -l app=alertmanager
oc logs -n openshift-monitoring deployment/alertmanager-main

# Check alert configuration
oc get secret alertmanager-main -n openshift-monitoring -o yaml
```

---

## 📚 Next Steps

After completing Day 07:
1. **Day 08**: Security and Policies
2. **Day 09**: Operators and Helm
3. **Day 10**: Advanced Topics
4. **Day 11**: GitOps and ArgoCD

---

## 🔗 Additional Resources

> **📋 Reference**: See [shared/common-commands.md](../shared/common-commands.md) for comprehensive OpenShift command reference.

- [OpenShift Monitoring Documentation](https://docs.openshift.com/container-platform/4.10/monitoring/index.html)
- [OpenShift Logging Documentation](https://docs.openshift.com/container-platform/4.10/logging/index.html)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)

---

**💡 Pro Tip**: Use `oc get routes -n openshift-monitoring` to quickly access all monitoring dashboards!

**💡 Pro Tip**: Use `oc logs -f deployment/<name>` to follow application logs in real-time for debugging! 