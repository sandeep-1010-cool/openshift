# Day 05: Persistent Storage - PVC, PV & Dynamic Provisioning

## 🎯 Learning Objectives

By the end of this lesson, you will be able to:
- Understand OpenShift's persistent storage architecture
- Create and manage Persistent Volume Claims (PVCs)
- Work with Persistent Volumes (PVs) and Storage Classes
- Implement dynamic provisioning for storage
- Configure storage for different application types
- Manage storage quotas and limits
- Troubleshoot storage-related issues
- Implement backup and recovery strategies

---

## 📚 Theory Section

### Persistent Storage in OpenShift

OpenShift provides persistent storage capabilities that allow applications to maintain data across pod restarts and deployments:

#### **Key Components**
- **Persistent Volume (PV)**: Physical storage resource in the cluster
- **Persistent Volume Claim (PVC)**: Request for storage by a user/application
- **Storage Class**: Defines the type of storage and provisioning method
- **Dynamic Provisioning**: Automatic PV creation based on PVC requests

### Storage Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │───▶│      PVC        │───▶│       PV        │
│     (Pod)       │    │   (Request)     │    │   (Resource)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │ Storage Class   │    │  Storage Backend│
                       │ (Provisioner)   │    │  (NFS, Ceph, etc)│
                       └─────────────────┘    └─────────────────┘
```

### Storage Types Comparison

| Storage Type | Use Case | Performance | Cost | Scalability |
|--------------|----------|-------------|------|-------------|
| **Local Storage** | High-performance apps | Very High | Low | Limited |
| **NFS** | Shared file storage | Medium | Low | Good |
| **Ceph/Rook** | Block storage | High | Medium | Excellent |
| **Cloud Storage** | Cloud-native apps | Variable | Variable | Excellent |
| **HostPath** | Development/testing | High | Low | Limited |

### Access Modes

#### **ReadWriteOnce (RWO)**
- Single node can mount for read/write
- Good for single-instance applications
- Example: Database storage

#### **ReadOnlyMany (ROX)**
- Multiple nodes can mount for read-only
- Good for shared configuration
- Example: Configuration files

#### **ReadWriteMany (RWM)**
- Multiple nodes can mount for read/write
- Good for shared applications
- Example: Web content, shared data

### Storage Classes

#### **Standard Storage Classes**
- **gp2**: AWS EBS General Purpose SSD
- **standard**: GCP Persistent Disk
- **managed-premium**: Azure Managed Disk
- **fast**: OpenShift default storage class

#### **Custom Storage Classes**
- **slow**: Lower cost, lower performance
- **fast**: Higher cost, higher performance
- **encrypted**: Encrypted storage
- **backup**: Backup-enabled storage

---

## 🛠️ Hands-On Lab

### Prerequisites

> **📋 Reference**: See [shared/prerequisites.md](../shared/prerequisites.md) for detailed prerequisites and installation instructions.

- OpenShift cluster access (from previous days)
- OpenShift CLI (`oc`) installed and configured
- Understanding of application deployment
- Access to storage resources

### Exercise 1: Understanding Storage Classes

#### Step 1: Explore Available Storage Classes
```bash
# Create a new project for Day 05
oc new-project day05-storage --description="Day 05 persistent storage"

# List available storage classes
oc get storageclass

# Get detailed information about storage classes
oc describe storageclass fast
oc describe storageclass slow

# Check default storage class
oc get storageclass -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}'
```

#### Step 2: Examine Storage Class Details
```bash
# Get storage class in YAML format
oc get storageclass fast -o yaml

# Check provisioner information
oc get storageclass fast -o jsonpath='{.provisioner}'

# List storage class parameters
oc get storageclass fast -o jsonpath='{.parameters}'
```

### Exercise 2: Creating Persistent Volume Claims

#### Step 1: Create Basic PVC
```bash
# Create a PVC with default storage class
cat > basic-pvc.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: basic-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

oc apply -f basic-pvc.yaml

# Create PVC with specific storage class
cat > fast-pvc.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fast-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast
  resources:
    requests:
      storage: 5Gi
EOF

oc apply -f fast-pvc.yaml
```

#### Step 2: Examine PVC Details
```bash
# List all PVCs
oc get pvc

# Get PVC details
oc describe pvc basic-pvc

# Check PVC status
oc get pvc -o wide

# Get PVC in YAML format
oc get pvc basic-pvc -o yaml
```

#### Step 3: Create Different Access Mode PVCs
```bash
# Create ReadWriteMany PVC
cat > shared-pvc.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
EOF

oc apply -f shared-pvc.yaml

# Create ReadOnlyMany PVC
cat > config-pvc.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: config-pvc
spec:
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 1Gi
EOF

oc apply -f config-pvc.yaml
```

### Exercise 3: Working with Persistent Volumes

#### Step 1: Examine PVs
```bash
# List all Persistent Volumes
oc get pv

# Get PV details
oc describe pv

# Check PV status
oc get pv -o wide

# Get PV in YAML format
oc get pv <pv-name> -o yaml
```

#### Step 2: Create Static PV (if available)
```bash
# Create a static PV (requires storage backend access)
cat > static-pv.yaml << EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: static-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: fast
  nfs:
    server: nfs.example.com
    path: /exports/data
EOF

oc apply -f static-pv.yaml
```

#### Step 3: Bind PVC to Static PV
```bash
# Create PVC that matches static PV
cat > static-pvc.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: static-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast
  resources:
    requests:
      storage: 5Gi
EOF

oc apply -f static-pvc.yaml
```

### Exercise 4: Mounting Storage in Applications

#### Step 1: Deploy Application with PVC
```bash
# Deploy application with persistent storage
oc new-app nginx:latest --name=storage-app

# Mount PVC to deployment
oc set volume deploymentconfig/storage-app \
  --add \
  --name=storage-volume \
  --type=pvc \
  --claim-name=basic-pvc \
  --mount-path=/data

# Check deployment configuration
oc describe deploymentconfig/storage-app
```

#### Step 2: Test Persistent Storage
```bash
# Write data to persistent storage
oc exec deploymentconfig/storage-app -- sh -c "echo 'Hello from persistent storage' > /data/test.txt"

# Verify data was written
oc exec deploymentconfig/storage-app -- cat /data/test.txt

# Restart the pod
oc rollout restart deploymentconfig/storage-app

# Verify data persists after restart
oc exec deploymentconfig/storage-app -- cat /data/test.txt
```

#### Step 3: Multiple Volume Mounts
```bash
# Create additional PVC
cat > data-pvc.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
EOF

oc apply -f data-pvc.yaml

# Mount multiple volumes
oc set volume deploymentconfig/storage-app \
  --add \
  --name=data-volume \
  --type=pvc \
  --claim-name=data-pvc \
  --mount-path=/app/data

# Check all volume mounts
oc describe deploymentconfig/storage-app
```

### Exercise 5: Dynamic Provisioning

#### Step 1: Create Storage Class (if needed)
```bash
# Create custom storage class
cat > custom-storage-class.yaml << EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: custom-fast
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
EOF

oc apply -f custom-storage-class.yaml
```

#### Step 2: Test Dynamic Provisioning
```bash
# Create PVC with custom storage class
cat > dynamic-pvc.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: custom-fast
  resources:
    requests:
      storage: 10Gi
EOF

oc apply -f dynamic-pvc.yaml

# Monitor PVC and PV creation
oc get pvc dynamic-pvc -w
oc get pv -w
```

#### Step 3: Volume Expansion
```bash
# Expand PVC (if supported)
oc patch pvc dynamic-pvc -p '{"spec":{"resources":{"requests":{"storage":"20Gi"}}}}'

# Check expansion status
oc get pvc dynamic-pvc
oc describe pvc dynamic-pvc
```

### Exercise 6: Storage Quotas and Limits

#### Step 1: Create Storage Quotas
```bash
# Create resource quota for storage
cat > storage-quota.yaml << EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: storage-quota
spec:
  hard:
    requests.storage: "50Gi"
    persistentvolumeclaims: "10"
EOF

oc apply -f storage-quota.yaml

# Check quota status
oc describe resourcequota storage-quota
```

#### Step 2: Test Quota Enforcement
```bash
# Try to create PVC that exceeds quota
cat > large-pvc.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: large-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
EOF

oc apply -f large-pvc.yaml

# Check quota usage
oc get resourcequota storage-quota -o yaml
```

### Exercise 7: Storage Troubleshooting

#### Step 1: Common Storage Issues
```bash
# Check PVC status
oc get pvc
oc describe pvc <pvc-name>

# Check PV status
oc get pv
oc describe pv <pv-name>

# Check storage class
oc get storageclass
oc describe storageclass <storage-class-name>

# Check events
oc get events --sort-by='.lastTimestamp' | grep -i storage
```

#### Step 2: Pod Storage Issues
```bash
# Check pod status
oc get pods -l app=storage-app

# Check pod events
oc describe pod <pod-name>

# Check volume mounts
oc get pod <pod-name> -o yaml | grep -A 10 volumes

# Check storage usage
oc exec <pod-name> -- df -h
```

#### Step 3: Storage Recovery
```bash
# Backup PVC data
oc exec <pod-name> -- tar czf /tmp/backup.tar.gz /data

# Copy backup from pod
oc cp <pod-name>:/tmp/backup.tar.gz ./backup.tar.gz

# Restore data to new PVC
oc exec <new-pod-name> -- tar xzf /tmp/backup.tar.gz -C /
```

---

## 📋 Lab Tasks

### Task 1: Storage Class Exploration
- [ ] List and examine available storage classes
- [ ] Understand storage class parameters
- [ ] Identify default storage class
- [ ] Compare different storage class features

### Task 2: PVC Creation and Management
- [ ] Create PVCs with different access modes
- [ ] Create PVCs with different storage classes
- [ ] Monitor PVC binding and status
- [ ] Manage PVC lifecycle

### Task 3: Application Storage Integration
- [ ] Deploy application with persistent storage
- [ ] Mount multiple volumes to application
- [ ] Test data persistence across pod restarts
- [ ] Verify storage performance

### Task 4: Dynamic Provisioning
- [ ] Test automatic PV creation
- [ ] Create custom storage classes
- [ ] Test volume expansion
- [ ] Monitor provisioning process

### Task 5: Storage Management
- [ ] Implement storage quotas
- [ ] Monitor storage usage
- [ ] Troubleshoot storage issues
- [ ] Implement backup strategies

---

## 🧪 Challenge Exercise

### Advanced Challenge: Multi-Tier Application with Persistent Storage

Create a complete application with different storage requirements:

1. **Database Layer with Persistent Storage**
   ```bash
   # Create database PVC
   cat > db-pvc.yaml << EOF
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: postgres-pvc
   spec:
     accessModes:
       - ReadWriteOnce
     storageClassName: fast
     resources:
       requests:
         storage: 20Gi
   EOF
   oc apply -f db-pvc.yaml

   # Deploy PostgreSQL with persistent storage
   oc new-app postgresql:13 \
     --name=postgres-db \
     --env=POSTGRESQL_DATABASE=myapp \
     --env=POSTGRESQL_USER=myuser \
     --env=POSTGRESQL_PASSWORD=mypassword

   # Mount PVC to database
   oc set volume deploymentconfig/postgres-db \
     --add \
     --name=db-storage \
     --type=pvc \
     --claim-name=postgres-pvc \
     --mount-path=/var/lib/pgsql/data
   ```

2. **Application Layer with Shared Storage**
   ```bash
   # Create shared storage PVC
   cat > shared-pvc.yaml << EOF
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: shared-pvc
   spec:
     accessModes:
       - ReadWriteMany
     resources:
       requests:
         storage: 10Gi
   EOF
   oc apply -f shared-pvc.yaml

   # Deploy application with shared storage
   oc new-app nginx:latest --name=app-server

   # Mount shared storage
   oc set volume deploymentconfig/app-server \
     --add \
     --name=shared-storage \
     --type=pvc \
     --claim-name=shared-pvc \
     --mount-path=/app/shared
   ```

3. **Backup Storage**
   ```bash
   # Create backup PVC
   cat > backup-pvc.yaml << EOF
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: backup-pvc
   spec:
     accessModes:
       - ReadWriteOnce
     storageClassName: slow
     resources:
       requests:
         storage: 50Gi
   EOF
   oc apply -f backup-pvc.yaml

   # Deploy backup application
   oc new-app alpine:latest --name=backup-app

   # Mount backup storage
   oc set volume deploymentconfig/backup-app \
     --add \
     --name=backup-storage \
     --type=pvc \
     --claim-name=backup-pvc \
     --mount-path=/backup
   ```

4. **Storage Monitoring and Management**
   ```bash
   # Create storage quota
   cat > storage-quota.yaml << EOF
   apiVersion: v1
   kind: ResourceQuota
   metadata:
     name: app-storage-quota
   spec:
     hard:
       requests.storage: "100Gi"
       persistentvolumeclaims: "10"
   EOF
   oc apply -f storage-quota.yaml

   # Monitor storage usage
   oc get pvc
   oc get pv
   oc describe resourcequota app-storage-quota

   # Test data persistence
   oc exec deploymentconfig/postgres-db -- psql -U myuser -d myapp -c "CREATE TABLE test (id serial, data text);"
   oc exec deploymentconfig/postgres-db -- psql -U myuser -d myapp -c "INSERT INTO test (data) VALUES ('persistent data');"
   ```

5. **Storage Performance Testing**
   ```bash
   # Test storage performance
   oc exec deploymentconfig/app-server -- dd if=/dev/zero of=/app/shared/testfile bs=1M count=100

   # Test database performance
   oc exec deploymentconfig/postgres-db -- pgbench -U myuser -d myapp -c 10 -t 1000

   # Monitor storage metrics
   oc adm top pods
   oc get events --sort-by='.lastTimestamp' | grep -i storage
   ```

---

## 📊 Key Commands Summary

> **📋 Reference**: See [shared/common-commands.md](../shared/common-commands.md) for comprehensive OpenShift command reference.

### Storage Class Management
```bash
oc get storageclass
oc describe storageclass <name>
oc create -f storage-class.yaml
oc delete storageclass <name>
```

### PVC Management
```bash
oc create -f pvc.yaml
oc get pvc
oc describe pvc <name>
oc patch pvc <name> -p '{"spec":{"resources":{"requests":{"storage":"10Gi"}}}}'
oc delete pvc <name>
```

### PV Management
```bash
oc get pv
oc describe pv <name>
oc create -f pv.yaml
oc delete pv <name>
```

### Volume Mounting
```bash
oc set volume deploymentconfig/<name> --add --type=pvc --claim-name=<pvc> --mount-path=<path>
oc set volume deploymentconfig/<name> --remove --name=<volume-name>
oc get deploymentconfig/<name> -o yaml | grep -A 10 volumes
```

### Storage Quotas
```bash
oc create -f quota.yaml
oc describe resourcequota <name>
oc get resourcequota <name> -o yaml
```

---

## 🚨 Common Issues & Solutions

> **📋 Reference**: See [shared/troubleshooting.md](../shared/troubleshooting.md) for comprehensive troubleshooting guide.

### Issue: PVC Pending
```bash
# Check storage class
oc get storageclass
oc describe storageclass <name>

# Check PV availability
oc get pv

# Check events
oc get events --sort-by='.lastTimestamp' | grep -i storage

# Check storage class provisioner
oc get storageclass <name> -o jsonpath='{.provisioner}'
```

### Issue: Pod Cannot Mount Volume
```bash
# Check PVC status
oc get pvc <name>
oc describe pvc <name>

# Check PV status
oc get pv
oc describe pv <name>

# Check pod events
oc describe pod <pod-name>

# Check volume mounts
oc get pod <pod-name> -o yaml | grep -A 10 volumes
```

### Issue: Storage Performance Problems
```bash
# Check storage class parameters
oc describe storageclass <name>

# Monitor storage usage
oc exec <pod-name> -- df -h

# Check storage metrics
oc adm top pods

# Test storage performance
oc exec <pod-name> -- dd if=/dev/zero of=/test bs=1M count=100
```

### Issue: Storage Quota Exceeded
```bash
# Check quota status
oc describe resourcequota <name>

# Check current usage
oc get pvc
oc get pv

# Delete unused PVCs
oc delete pvc <unused-pvc>

# Request quota increase
oc patch resourcequota <name> -p '{"spec":{"hard":{"requests.storage":"100Gi"}}}'
```

---

## 📚 Next Steps

After completing Day 05:
1. **Day 06**: CI/CD Pipelines
2. **Day 07**: Monitoring and Logging
3. **Day 08**: Security and Policies
4. **Day 09**: Operators and Helm

---

## 🔗 Additional Resources

> **📋 Reference**: See [shared/common-commands.md](../shared/common-commands.md) for comprehensive OpenShift command reference.

- [OpenShift Storage Documentation](https://docs.openshift.com/container-platform/4.10/storage/index.html)
- [Kubernetes Storage Documentation](https://kubernetes.io/docs/concepts/storage/)
- [OpenShift Storage Classes](https://docs.openshift.com/container-platform/4.10/storage/dynamic-provisioning.html)
- [OpenShift Persistent Storage](https://docs.openshift.com/container-platform/4.10/storage/persistent_storage/index.html)

---

**💡 Pro Tip**: Use `oc get pvc -o wide` to see storage class and status information for all PVCs!

**💡 Pro Tip**: Use `oc set volume --help` to explore all options for mounting volumes to deployments! 