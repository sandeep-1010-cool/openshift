# 🖥️ OpenShift Local Setup on Windows (for Testing)

## 🎯 Overview

This guide will help you set up **OpenShift Local** (formerly CodeReady Containers) on Windows for learning and testing purposes. OpenShift Local provides a single-node OpenShift cluster that runs on your local machine.

---

## ✅ Prerequisites

### System Requirements
- **OS**: Windows 10 or later (64-bit)
- **RAM**: Minimum 16 GB (32 GB recommended)
- **CPU**: Minimum 4 CPUs (8+ recommended)
- **Disk**: Minimum 40 GB free space (SSD recommended)
- **Virtualization**: Must be enabled in BIOS (Intel VT-x/AMD-V)

### Software Requirements
- **Hypervisor**: Hyper-V (Windows 10/11 Pro) or VirtualBox
- **Network**: Stable internet connection for initial download
- **Browser**: Modern web browser (Chrome, Firefox, Edge)

### Check Virtualization Support
```powershell
# Check if virtualization is enabled
systeminfo | findstr /i "Virtualization"
```

If virtualization is not enabled, you'll need to:
1. Restart your computer
2. Enter BIOS/UEFI settings
3. Enable Intel VT-x or AMD-V
4. Save and restart

---

## 🧰 Step-by-Step Setup Using CRC (CodeReady Containers)

### Step 1: Download CRC

1. **Visit Red Hat Developer Portal**
   - Go to: [https://developers.redhat.com/products/openshift-local/overview](https://developers.redhat.com/products/openshift-local/overview)
   - Sign in with a free Red Hat Developer account
   - If you don't have an account, create one for free

2. **Download CRC for Windows**
   - Click "Download" for Windows
   - Download the latest version (usually named `crc-windows-amd64.zip`)

### Step 2: Install CRC

1. **Extract the ZIP file**
   ```powershell
   # Extract to a convenient location (e.g., C:\crc)
   Expand-Archive -Path "crc-windows-amd64.zip" -DestinationPath "C:\crc"
   ```

2. **Add CRC to PATH**
   - Open System Properties → Advanced → Environment Variables
   - Add `C:\crc` to your PATH variable
   - Or run CRC from the extracted directory

3. **Verify Installation**
   ```powershell
   # Check CRC version
   crc version
   ```

### Step 3: Setup CRC

1. **Run CRC Setup**
   ```powershell
   # Initialize CRC
   crc setup
   ```

   This command will:
   - Check system requirements
   - Configure Hyper-V (if available)
   - Set up networking
   - Download required images

2. **Troubleshoot Setup Issues**
   ```powershell
   # Check setup status
   crc setup --check-only
   
   # View detailed setup logs
   crc setup --log-level debug
   ```

### Step 4: Start the Cluster

1. **Start CRC Cluster**
   ```powershell
   # Start the OpenShift cluster
   crc start
   ```

2. **Provide Pull Secret**
   - When prompted, you'll need a **pull secret**
   - Go to: [https://cloud.redhat.com/openshift/install/crc/installer-provisioned](https://cloud.redhat.com/openshift/install/crc/installer-provisioned)
   - Sign in with your Red Hat account
   - Copy the pull secret
   - Paste it when prompted during startup

3. **Wait for Startup**
   - Initial startup takes 10-15 minutes
   - The cluster will download and start all components
   - You'll see progress indicators

### Step 5: Access Your Cluster

1. **Get Login Credentials**
   ```powershell
   # Get login information
   crc console --credentials
   ```

   This will show:
   - Admin username: `kubeadmin`
   - Admin password: `<generated-password>`
   - API URL: `https://api.crc.testing:6443`

2. **Login via CLI**
   ```powershell
   # Login to OpenShift
   oc login -u kubeadmin -p <password> https://api.crc.testing:6443
   ```

3. **Verify Login**
   ```powershell
   # Check cluster status
   oc cluster-info
   
   # List nodes
   oc get nodes
   ```

### Step 6: Access Web Console

1. **Open Web Console**
   ```powershell
   # Open console in browser
   crc console
   ```

   Or manually navigate to:
   - URL: `https://console-openshift-console.apps-crc.testing`
   - Username: `kubeadmin`
   - Password: `<password-from-step-5>`

2. **Explore the Console**
   - **Home**: Overview of your cluster
   - **Projects**: Create and manage projects
   - **Catalog**: Browse application templates
   - **Monitoring**: View cluster metrics
   - **Administration**: Cluster settings and operators

---

## 📦 Useful Commands

### CRC Management
| Command | Purpose |
|---------|---------|
| `crc status` | Check CRC cluster status |
| `crc start` | Start the cluster |
| `crc stop` | Stop the cluster |
| `crc delete` | Delete the cluster |
| `crc console` | Open web console |
| `crc console --credentials` | Get login credentials |

### OpenShift CLI Commands
| Command | Purpose |
|---------|---------|
| `oc login` | Login to cluster |
| `oc logout` | Logout from cluster |
| `oc whoami` | Show current user |
| `oc cluster-info` | Show cluster information |
| `oc get nodes` | List cluster nodes |
| `oc get projects` | List projects |
| `oc console` | Open web console |

### Cluster Information
```powershell
# Check cluster health
oc get clusteroperators

# View cluster events
oc get events --all-namespaces

# Check resource usage
oc adm top nodes
oc adm top pods --all-namespaces
```

---

## 🔧 Troubleshooting

### Common Issues

#### Issue: CRC Setup Fails
```powershell
# Check system requirements
crc setup --check-only

# View detailed logs
crc setup --log-level debug

# Common solutions:
# 1. Enable virtualization in BIOS
# 2. Update Windows to latest version
# 3. Install Windows Hyper-V feature
```

#### Issue: Cluster Won't Start
```powershell
# Check CRC status
crc status

# View startup logs
crc start --log-level debug

# Reset cluster if needed
crc delete
crc start
```

#### Issue: Can't Access Console
```powershell
# Get console URL
crc console --credentials

# Check if cluster is running
crc status

# Try port forwarding
oc port-forward svc/console 8080:443 -n openshift-console
```

#### Issue: Network Problems
```powershell
# Check network configuration
crc config view

# Reset network settings
crc config set network-mode user
crc delete
crc start
```

### Performance Optimization

#### For Better Performance
1. **Allocate More Resources**
   ```powershell
   # Increase memory allocation
   crc config set memory 16384
   
   # Increase CPU allocation
   crc config set cpus 8
   
   # Apply changes
   crc delete
   crc start
   ```

2. **Use SSD Storage**
   - Ensure CRC is installed on an SSD
   - Move CRC data directory to SSD if needed

3. **Disable Antivirus Scanning**
   - Add CRC directories to antivirus exclusions
   - Temporarily disable real-time scanning during startup

---

## 🎯 First Steps After Setup

### 1. Create Your First Project
```powershell
# Create a new project
oc new-project my-first-project --description="My first OpenShift project"

# Switch to the project
oc project my-first-project

# Check project status
oc status
```

### 2. Explore the Web Console
1. Navigate to **Projects** → **my-first-project**
2. Explore the **Developer** perspective
3. Check out the **Catalog** for application templates
4. Visit **Monitoring** to see cluster metrics

### 3. Install OpenShift CLI (if not already installed)
```powershell
# Download oc CLI
# Visit: https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/windows/

# Add to PATH or run from download directory
oc version
```

---

## 📚 Next Steps

After successful setup:

1. **Complete Day 01 Lab**: Follow the exercises in `README.md`
2. **Practice CLI Commands**: Use the quick reference guide
3. **Deploy Applications**: Learn about deployments and services
4. **Explore Advanced Features**: Operators, monitoring, and security

---

## 🆘 Getting Help

### Useful Resources
- **Official Documentation**: [https://docs.openshift.com/container-platform/](https://docs.openshift.com/container-platform/)
- **CRC Documentation**: [https://access.redhat.com/documentation/en-us/red_hat_codeready_containers](https://access.redhat.com/documentation/en-us/red_hat_codeready_containers)
- **Red Hat Developer Portal**: [https://developers.redhat.com/products/openshift-local](https://developers.redhat.com/products/openshift-local)

### Community Support
- **Red Hat Community**: [https://community.redhat.com/](https://community.redhat.com/)
- **Stack Overflow**: Tag questions with `openshift` and `crc`
- **GitHub Issues**: [https://github.com/code-ready/crc/issues](https://github.com/code-ready/crc/issues)

---

**🎉 Congratulations!** You now have a working OpenShift cluster on your Windows machine. You're ready to start learning OpenShift and Kubernetes concepts!

**💡 Pro Tip**: Keep your CRC cluster running during your learning sessions to avoid the startup time. Use `crc stop` when you're done for the day to save system resources. 