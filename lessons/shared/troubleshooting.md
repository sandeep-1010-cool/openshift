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
```

#### Permission Denied
```bash
# Check permissions
oc auth can-i list projects
oc auth can-i create projects

# Check role bindings
oc get rolebindings
```

### Project & Resource Issues

#### Project Not Found
```bash
# List projects
oc get projects

# Check current project
oc project

# Switch project
oc project <project-name>
```

#### Resource Not Found
```bash
# List all resources
oc get all

# Check specific resource
oc get <resource-type> <resource-name>
```

### Network Issues

#### Route Not Accessible
```bash
# Check route status
oc get routes

# Test route
curl -I <route-url>

# Check route details
oc describe route <route-name>
```

#### Service Communication Issues
```bash
# Check service status
oc get services

# Check endpoints
oc get endpoints

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

# Check events
oc get events --field-selector involvedObject.name=<pod-name>
```

#### Pod CrashLoopBackOff
```bash
# Check logs
oc logs <pod-name>
oc logs <pod-name> --previous

# Restart deployment
oc rollout restart deployment/<deployment-name>
```

#### Pod Pending
```bash
# Check pod details
oc describe pod <pod-name>

# Check node resources
oc get nodes -o wide

# Check quotas
oc get quota
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
```

### Build Issues

#### Build Failing
```bash
# Check build status
oc get builds

# Check build logs
oc logs bc/<buildconfig-name>

# Restart build
oc start-build <buildconfig-name>
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
```

### Network Diagnostics
```bash
# Check DNS resolution
oc exec <pod-name> -- nslookup <service-name>

# Check network connectivity
oc exec <pod-name> -- ping <target>
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

### For Network Issues
- [ ] Verify service endpoints
- [ ] Check route configuration
- [ ] Test connectivity

### For Storage Issues
- [ ] Check PVC status
- [ ] Verify storage class
- [ ] Check volume permissions

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