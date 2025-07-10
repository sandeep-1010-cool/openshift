# OpenShift Troubleshooting Guide

## ❓ Common Issues & Solutions

### Authentication Issues

#### Login Problems
```bash
# Clear login cache
oc logout
oc login -u <username> -p <password> <cluster-url>

# Check login status
oc whoami

# Verify cluster access
oc cluster-info
```

#### Permission Denied
```bash
# Check your permissions
oc auth can-i list projects
oc auth can-i create projects

# Check your role bindings
oc get rolebindings

# Check cluster role bindings
oc get clusterrolebindings
```

#### Console Access Issues
```bash
# Get console URL
oc whoami --show-console

# Port forward if needed
oc port-forward svc/console 8080:443 -n openshift-console

# Check console service
oc get svc -n openshift-console
```

### Project & Resource Issues

#### Project Not Found
```bash
# List all projects you have access to
oc get projects

# Check if you're in the right context
oc project

# Switch to project
oc project <project-name>
```

#### Resource Not Found
```bash
# List all resources
oc get all

# Check specific resource type
oc get <resource-type>

# Check if resource exists
oc get <resource-type> <resource-name>
```

#### User Not Found
```bash
# List all users
oc get users

# Check if user exists in the system
oc get user <username>

# Check user details
oc describe user <username>
```

### Network Issues

#### Route Not Accessible
```bash
# Check route status
oc get routes

# Test route connectivity
curl -I <route-url>

# Check route details
oc describe route <route-name>

# Check service endpoints
oc get endpoints
```

#### Service Communication Issues
```bash
# Check service status
oc get services

# Check service details
oc describe service <service-name>

# Check endpoints
oc get endpoints <service-name>

# Test service connectivity
oc exec <pod-name> -- curl <service-name>
```

### Pod Issues

#### Pod Not Starting
```bash
# Check pod status
oc get pods

# Check pod details
oc describe pod <pod-name>

# Check pod logs
oc logs <pod-name>

# Check previous container logs
oc logs <pod-name> --previous

# Check pod events
oc get events --field-selector involvedObject.name=<pod-name>
```

#### Pod CrashLoopBackOff
```bash
# Check pod logs
oc logs <pod-name>

# Check previous container logs
oc logs <pod-name> --previous

# Check pod details
oc describe pod <pod-name>

# Restart deployment
oc rollout restart deployment/<deployment-name>
```

#### Pod Pending
```bash
# Check pod details
oc describe pod <pod-name>

# Check node resources
oc get nodes -o wide

# Check resource quotas
oc get quota

# Check limit ranges
oc get limitrange
```

### Storage Issues

#### PVC Not Bound
```bash
# Check PVC status
oc get pvc

# Check PVC details
oc describe pvc <pvc-name>

# Check available PVs
oc get pv

# Check storage classes
oc get storageclass
```

#### Volume Mount Issues
```bash
# Check pod details for volume mounts
oc describe pod <pod-name>

# Check if volume is mounted
oc exec <pod-name> -- df -h

# Check volume permissions
oc exec <pod-name> -- ls -la /path/to/mount
```

### Build Issues

#### Build Failing
```bash
# Check build status
oc get builds

# Check build logs
oc logs bc/<buildconfig-name>

# Check build details
oc describe build <build-name>

# Restart build
oc start-build <buildconfig-name>
```

#### Image Pull Issues
```bash
# Check image stream
oc get is

# Check image stream details
oc describe is <imagestream-name>

# Import image
oc import-image <imagestream-name>:<tag>
```

### Deployment Issues

#### Deployment Failing
```bash
# Check deployment status
oc get deploymentconfigs

# Check deployment details
oc describe deploymentconfig <name>

# Check rollout status
oc rollout status deploymentconfig/<name>

# Rollback deployment
oc rollout undo deploymentconfig/<name>
```

#### Scaling Issues
```bash
# Check current replicas
oc get deploymentconfig <name> -o jsonpath='{.spec.replicas}'

# Scale deployment
oc scale deploymentconfig/<name> --replicas=<number>

# Check resource limits
oc describe deploymentconfig <name>
```

### Security Issues

#### Security Context Constraints
```bash
# Check SCCs
oc get scc

# Check SCC details
oc describe scc <scc-name>

# Check which SCC is applied
oc get pod <pod-name> -o jsonpath='{.metadata.annotations.openshift\.io/scc}'
```

#### Network Policies
```bash
# Check network policies
oc get networkpolicy

# Check network policy details
oc describe networkpolicy <name>

# Test connectivity
oc exec <pod-name> -- curl <target-service>
```

### Monitoring Issues

#### Metrics Not Available
```bash
# Check monitoring stack
oc get pods -n openshift-monitoring

# Check Prometheus status
oc get pods -n openshift-monitoring -l app=prometheus

# Check Grafana status
oc get pods -n openshift-monitoring -l app=grafana
```

#### Logging Issues
```bash
# Check logging stack
oc get pods -n openshift-logging

# Check Elasticsearch status
oc get pods -n openshift-logging -l component=elasticsearch

# Check Kibana status
oc get pods -n openshift-logging -l component=kibana
```

### Operator Issues

#### Operator Not Ready
```bash
# Check operator status
oc get csv

# Check operator pods
oc get pods -n <operator-namespace>

# Check operator logs
oc logs deployment/<operator-name> -n <operator-namespace>

# Check subscription status
oc get subscription -n <operator-namespace>
```

#### Custom Resource Issues
```bash
# Check CRD status
oc get crd

# Check custom resources
oc get <crd-name>

# Check custom resource details
oc describe <crd-name> <resource-name>
```

## 🔧 Diagnostic Commands

### Cluster Health Check
```bash
# Check cluster operators
oc get clusteroperators

# Check cluster version
oc get clusterversion

# Check node status
oc get nodes

# Check cluster events
oc get events --all-namespaces
```

### Resource Usage
```bash
# Check node resources
oc get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.capacity.cpu}{"\t"}{.status.capacity.memory}{"\n"}{end}'

# Check pod resource usage
oc adm top pods

# Check node resource usage
oc adm top nodes
```

### Network Diagnostics
```bash
# Check DNS resolution
oc exec <pod-name> -- nslookup <service-name>

# Check network connectivity
oc exec <pod-name> -- ping <target>

# Check network policies
oc get networkpolicy --all-namespaces
```

## 📋 Troubleshooting Checklist

### Before Starting
- [ ] Verify cluster access
- [ ] Check current project context
- [ ] Verify user permissions
- [ ] Check cluster health

### For Pod Issues
- [ ] Check pod status and events
- [ ] Review pod logs
- [ ] Check resource limits and requests
- [ ] Verify image availability
- [ ] Check volume mounts

### For Network Issues
- [ ] Verify service endpoints
- [ ] Check route configuration
- [ ] Test connectivity
- [ ] Review network policies

### For Storage Issues
- [ ] Check PVC status
- [ ] Verify storage class
- [ ] Check volume permissions
- [ ] Review quota limits

### For Security Issues
- [ ] Check SCC assignments
- [ ] Verify RBAC permissions
- [ ] Review network policies
- [ ] Check security contexts

## 🆘 Getting Help

### Useful Commands for Support
```bash
# Collect cluster information
oc cluster-info
oc version
oc get nodes -o wide

# Collect project information
oc get all -o yaml > project-backup.yaml

# Collect logs
oc logs <pod-name> > pod-logs.txt

# Collect events
oc get events > events.txt
```

### Documentation Resources
- [OpenShift Documentation](https://docs.openshift.com/)
- [OpenShift Troubleshooting Guide](https://docs.openshift.com/container-platform/4.10/support/troubleshooting/)
- [OpenShift CLI Reference](https://docs.openshift.com/container-platform/4.10/cli_reference/openshift_cli/)
- [OpenShift Knowledge Base](https://access.redhat.com/documentation/en-us/openshift_container_platform/) 