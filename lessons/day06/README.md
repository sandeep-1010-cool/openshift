# Day 06: CI/CD Pipelines - OpenShift Pipelines (Tekton) & Triggers

## 🎯 Learning Objectives

By the end of this lesson, you will be able to:
- Understand OpenShift Pipelines (Tekton) architecture
- Create and manage Pipeline resources
- Implement automated CI/CD workflows
- Configure Pipeline triggers and webhooks
- Use Pipeline tasks and workspaces
- Implement multi-stage deployment pipelines
- Monitor and troubleshoot pipeline execution
- Integrate with external tools and services

---

## 📚 Theory Section

### OpenShift Pipelines Overview

OpenShift Pipelines is a cloud-native CI/CD solution based on Tekton that provides:
- **Kubernetes-native**: Runs as pods in your OpenShift cluster
- **Declarative**: Define pipelines using YAML
- **Reusable**: Share tasks and pipelines across projects
- **Scalable**: Automatically scales based on demand

### Pipeline Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Git Trigger   │───▶│   PipelineRun   │───▶│   TaskRun       │
│   (Webhook)     │    │   (Execution)   │    │   (Steps)       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   Pipeline      │    │   Workspace     │
                       │   (Definition)  │    │   (Storage)     │
                       └─────────────────┘    └─────────────────┘
```

### Key Components

#### **Pipeline**
- Defines the complete CI/CD workflow
- Contains multiple tasks in sequence
- Supports conditional execution
- Manages workspaces and parameters

#### **Task**
- Reusable unit of work
- Contains one or more steps
- Can be shared across pipelines
- Supports input/output resources

#### **PipelineRun**
- Instance of a pipeline execution
- Contains runtime parameters
- Manages workspace bindings
- Tracks execution status

#### **TaskRun**
- Instance of a task execution
- Contains step execution details
- Manages step logs and artifacts
- Reports success/failure status

### Pipeline Triggers

#### **Event Listeners**
- Listen for external events (Git pushes, PRs)
- Process event data and extract information
- Trigger pipeline execution with parameters

#### **Triggers**
- Define conditions for pipeline execution
- Map event data to pipeline parameters
- Support multiple trigger types

#### **Webhooks**
- HTTP endpoints for external services
- Secure authentication and authorization
- Support for GitHub, GitLab, Bitbucket

---

## 🛠️ Hands-On Lab

### Prerequisites
- OpenShift cluster access (from previous days)
- OpenShift CLI (`oc`) installed and configured
- Understanding of application deployment
- Git repository for testing pipelines

### Exercise 1: Installing OpenShift Pipelines

#### Step 1: Check Pipeline Operator
```bash
# Create a new project for Day 06
oc new-project day06-pipelines --description="Day 06 CI/CD pipelines"

# Check if OpenShift Pipelines is installed
oc get csv -n openshift-operators | grep pipelines

# Check pipeline operator status
oc get pods -n openshift-pipelines

# Verify pipeline resources are available
oc api-resources | grep tekton
```

#### Step 2: Install Pipeline Operator (if needed)
```bash
# Create operator subscription
cat > pipeline-subscription.yaml << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-pipelines-operator
  namespace: openshift-operators
spec:
  channel: stable
  name: openshift-pipelines-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

oc apply -f pipeline-subscription.yaml

# Wait for operator to be ready
oc get csv -n openshift-operators | grep pipelines
```

### Exercise 2: Creating Basic Tasks

#### Step 1: Create a Simple Task
```bash
# Create a basic task
cat > hello-task.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: hello-task
spec:
  steps:
    - name: hello
      image: ubuntu
      command: ["echo"]
      args: ["Hello from Tekton!"]
    - name: goodbye
      image: ubuntu
      command: ["echo"]
      args: ["Goodbye from Tekton!"]
EOF

oc apply -f hello-task.yaml

# List tasks
oc get tasks

# Get task details
oc describe task hello-task
```

#### Step 2: Create Task with Parameters
```bash
# Create task with parameters
cat > parameterized-task.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: parameterized-task
spec:
  params:
    - name: message
      type: string
      description: "Message to print"
    - name: count
      type: string
      description: "Number of times to print"
  steps:
    - name: print-message
      image: ubuntu
      command: ["bash"]
      args:
        - -c
        - |
          for i in \$(seq 1 \${params.count}); do
            echo "\${params.message} - \$i"
          done
EOF

oc apply -f parameterized-task.yaml
```

#### Step 3: Create Task with Workspaces
```bash
# Create task with workspace
cat > workspace-task.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: workspace-task
spec:
  workspaces:
    - name: source
      description: "Source code workspace"
  steps:
    - name: list-files
      image: ubuntu
      command: ["ls"]
      args: ["-la"]
      workingDir: \$(workspaces.source.path)
    - name: create-file
      image: ubuntu
      command: ["bash"]
      args:
        - -c
        - |
          echo "Created by Tekton at \$(date)" > \$(workspaces.source.path)/tekton-file.txt
          echo "File created successfully"
      workingDir: \$(workspaces.source.path)
EOF

oc apply -f workspace-task.yaml
```

### Exercise 3: Creating Pipelines

#### Step 1: Create a Simple Pipeline
```bash
# Create a basic pipeline
cat > simple-pipeline.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: simple-pipeline
spec:
  workspaces:
    - name: shared-workspace
  tasks:
    - name: first-task
      taskRef:
        name: hello-task
    - name: second-task
      taskRef:
        name: parameterized-task
      params:
        - name: message
          value: "Pipeline execution"
        - name: count
          value: "3"
      runAfter:
        - first-task
EOF

oc apply -f simple-pipeline.yaml

# List pipelines
oc get pipelines

# Get pipeline details
oc describe pipeline simple-pipeline
```

#### Step 2: Create Pipeline with Workspaces
```bash
# Create pipeline with workspaces
cat > workspace-pipeline.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: workspace-pipeline
spec:
  workspaces:
    - name: source
      description: "Source code workspace"
  tasks:
    - name: list-files
      taskRef:
        name: workspace-task
      workspaces:
        - name: source
          workspace: source
    - name: create-output
      taskRef:
        name: workspace-task
      workspaces:
        - name: source
          workspace: source
      runAfter:
        - list-files
EOF

oc apply -f workspace-pipeline.yaml
```

### Exercise 4: Running Pipelines

#### Step 1: Create PipelineRun
```bash
# Create a pipeline run
cat > simple-pipelinerun.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: simple-pipelinerun
spec:
  pipelineRef:
    name: simple-pipeline
  workspaces:
    - name: shared-workspace
      emptyDir: {}
EOF

oc apply -f simple-pipelinerun.yaml

# Monitor pipeline execution
oc get pipelineruns
oc describe pipelinerun simple-pipelinerun

# Watch pipeline logs
oc logs -f pipelinerun/simple-pipelinerun
```

#### Step 2: Create PipelineRun with Workspaces
```bash
# Create pipeline run with workspace
cat > workspace-pipelinerun.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: workspace-pipelinerun
spec:
  pipelineRef:
    name: workspace-pipeline
  workspaces:
    - name: source
      emptyDir: {}
EOF

oc apply -f workspace-pipelinerun.yaml

# Monitor execution
oc get pipelineruns
oc describe pipelinerun workspace-pipelinerun
```

### Exercise 5: Git Integration Pipeline

#### Step 1: Create Git Clone Task
```bash
# Create git clone task
cat > git-clone-task.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: git-clone
spec:
  workspaces:
    - name: output
      description: "Git repository to clone"
  params:
    - name: url
      type: string
      description: "Git repository URL"
    - name: revision
      type: string
      description: "Git revision to checkout"
      default: "main"
  steps:
    - name: clone
      image: alpine/git
      script: |
        cd \$(workspaces.output.path)
        git clone \$(params.url) .
        git checkout \$(params.revision)
        ls -la
      workingDir: \$(workspaces.output.path)
EOF

oc apply -f git-clone-task.yaml
```

#### Step 2: Create Build Task
```bash
# Create build task
cat > build-task.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: build-app
spec:
  workspaces:
    - name: source
      description: "Source code workspace"
  params:
    - name: image
      type: string
      description: "Docker image to build"
  steps:
    - name: build
      image: docker
      script: |
        cd \$(workspaces.source.path)
        echo "Building application..."
        echo "Image: \$(params.image)"
        echo "Build completed successfully"
      workingDir: \$(workspaces.source.path)
EOF

oc apply -f build-task.yaml
```

#### Step 3: Create Deploy Task
```bash
# Create deploy task
cat > deploy-task.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: deploy-app
spec:
  params:
    - name: image
      type: string
      description: "Docker image to deploy"
    - name: namespace
      type: string
      description: "Target namespace"
  steps:
    - name: deploy
      image: bitnami/kubectl
      script: |
        echo "Deploying application..."
        echo "Image: \$(params.image)"
        echo "Namespace: \$(params.namespace)"
        echo "Deployment completed successfully"
EOF

oc apply -f deploy-task.yaml
```

#### Step 4: Create Complete CI/CD Pipeline
```bash
# Create complete CI/CD pipeline
cat > cicd-pipeline.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: cicd-pipeline
spec:
  workspaces:
    - name: source
      description: "Source code workspace"
  params:
    - name: git-url
      type: string
      description: "Git repository URL"
    - name: git-revision
      type: string
      description: "Git revision"
      default: "main"
    - name: image
      type: string
      description: "Docker image to build"
    - name: namespace
      type: string
      description: "Target namespace"
  tasks:
    - name: clone
      taskRef:
        name: git-clone
      workspaces:
        - name: output
          workspace: source
      params:
        - name: url
          value: \$(params.git-url)
        - name: revision
          value: \$(params.git-revision)
    - name: build
      taskRef:
        name: build-app
      workspaces:
        - name: source
          workspace: source
      params:
        - name: image
          value: \$(params.image)
      runAfter:
        - clone
    - name: deploy
      taskRef:
        name: deploy-app
      params:
        - name: image
          value: \$(params.image)
        - name: namespace
          value: \$(params.namespace)
      runAfter:
        - build
EOF

oc apply -f cicd-pipeline.yaml
```

### Exercise 6: Pipeline Triggers

#### Step 1: Install Triggers (if needed)
```bash
# Check if triggers are installed
oc get pods -n openshift-pipelines | grep triggers

# Install triggers if needed
cat > triggers-subscription.yaml << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-pipelines-operator-triggers
  namespace: openshift-operators
spec:
  channel: stable
  name: openshift-pipelines-operator-triggers
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

oc apply -f triggers-subscription.yaml
```

#### Step 2: Create Event Listener
```bash
# Create event listener
cat > event-listener.yaml << EOF
apiVersion: triggers.tekton.dev/v1alpha1
kind: EventListener
metadata:
  name: git-listener
spec:
  serviceAccountName: pipeline
  triggers:
    - name: git-push-trigger
      interceptors:
        - ref:
            name: "github"
          params:
            - name: "secretRef"
              value:
                secretName: github-secret
                secretKey: secretToken
            - name: "eventTypes"
              value: ["push"]
      bindings:
        - ref: git-push-binding
      template:
        ref: cicd-pipeline-template
EOF

oc apply -f event-listener.yaml
```

#### Step 3: Create Trigger Resources
```bash
# Create trigger binding
cat > git-push-binding.yaml << EOF
apiVersion: triggers.tekton.dev/v1alpha1
kind: TriggerBinding
metadata:
  name: git-push-binding
spec:
  params:
    - name: git-revision
      value: \$(body.head_commit.id)
    - name: git-url
      value: \$(body.repository.clone_url)
    - name: image
      value: "myapp:latest"
    - name: namespace
      value: "day06-pipelines"
EOF

oc apply -f git-push-binding.yaml

# Create trigger template
cat > cicd-pipeline-template.yaml << EOF
apiVersion: triggers.tekton.dev/v1alpha1
kind: TriggerTemplate
metadata:
  name: cicd-pipeline-template
spec:
  params:
    - name: git-revision
      description: "Git revision"
    - name: git-url
      description: "Git repository URL"
    - name: image
      description: "Docker image"
    - name: namespace
      description: "Target namespace"
  resourcetemplates:
    - apiVersion: tekton.dev/v1beta1
      kind: PipelineRun
      metadata:
        generateName: cicd-pipeline-run-
      spec:
        pipelineRef:
          name: cicd-pipeline
        params:
          - name: git-url
            value: \$(params.git-url)
          - name: git-revision
            value: \$(params.git-revision)
          - name: image
            value: \$(params.image)
          - name: namespace
            value: \$(params.namespace)
        workspaces:
          - name: source
            emptyDir: {}
EOF

oc apply -f cicd-pipeline-template.yaml
```

### Exercise 7: Monitoring and Troubleshooting

#### Step 1: Monitor Pipeline Execution
```bash
# List all pipeline runs
oc get pipelineruns

# Get detailed pipeline run information
oc describe pipelinerun <pipelinerun-name>

# Check task runs
oc get taskruns

# Get task run details
oc describe taskrun <taskrun-name>

# View pipeline logs
oc logs pipelinerun/<pipelinerun-name>
```

#### Step 2: Troubleshoot Pipeline Issues
```bash
# Check pipeline status
oc get pipelineruns -o wide

# Check task run status
oc get taskruns -o wide

# Check pod status
oc get pods -l tekton.dev/pipelineRun=<pipelinerun-name>

# Check events
oc get events --sort-by='.lastTimestamp' | grep -i pipeline
```

#### Step 3: Pipeline Metrics
```bash
# Check pipeline metrics (if monitoring is enabled)
oc get routes -n openshift-pipelines

# Access Tekton dashboard
oc get route tekton-dashboard -n openshift-pipelines -o jsonpath='{.spec.host}'
```

---

## 📋 Lab Tasks

### Task 1: Basic Pipeline Setup
- [ ] Install and verify OpenShift Pipelines
- [ ] Create basic tasks and pipelines
- [ ] Run pipelines and monitor execution
- [ ] Understand pipeline components

### Task 2: Advanced Pipeline Features
- [ ] Create tasks with parameters and workspaces
- [ ] Build multi-stage pipelines
- [ ] Implement conditional execution
- [ ] Use pipeline workspaces effectively

### Task 3: Git Integration
- [ ] Create git clone tasks
- [ ] Build application tasks
- [ ] Deploy application tasks
- [ ] Create complete CI/CD pipeline

### Task 4: Pipeline Triggers
- [ ] Install and configure triggers
- [ ] Create event listeners
- [ ] Set up webhook integration
- [ ] Test automated pipeline execution

### Task 5: Monitoring and Troubleshooting
- [ ] Monitor pipeline execution
- [ ] Troubleshoot pipeline failures
- [ ] Access pipeline logs and metrics
- [ ] Implement pipeline best practices

---

## 🧪 Challenge Exercise

### Advanced Challenge: Multi-Environment CI/CD Pipeline

Create a complete CI/CD pipeline for a multi-environment deployment:

1. **Pipeline with Multiple Stages**
   ```bash
   # Create multi-stage pipeline
   cat > multi-stage-pipeline.yaml << EOF
   apiVersion: tekton.dev/v1beta1
   kind: Pipeline
   metadata:
     name: multi-stage-pipeline
   spec:
     workspaces:
       - name: source
     params:
       - name: git-url
       - name: git-revision
       - name: environment
     tasks:
       - name: clone
         taskRef:
           name: git-clone
         workspaces:
           - name: output
             workspace: source
         params:
           - name: url
             value: \$(params.git-url)
           - name: revision
             value: \$(params.git-revision)
       - name: test
         taskRef:
           name: test-app
         workspaces:
           - name: source
             workspace: source
         runAfter:
           - clone
       - name: build
         taskRef:
           name: build-app
         workspaces:
           - name: source
             workspace: source
         runAfter:
           - test
       - name: deploy-dev
         taskRef:
           name: deploy-app
         params:
           - name: environment
             value: "dev"
         runAfter:
           - build
         when:
           - input: \$(params.environment)
             operator: in
             values: ["dev", "staging", "prod"]
       - name: deploy-staging
         taskRef:
           name: deploy-app
         params:
           - name: environment
             value: "staging"
         runAfter:
           - deploy-dev
         when:
           - input: \$(params.environment)
             operator: in
             values: ["staging", "prod"]
       - name: deploy-prod
         taskRef:
           name: deploy-app
         params:
           - name: environment
             value: "prod"
         runAfter:
           - deploy-staging
         when:
           - input: \$(params.environment)
             operator: in
             values: ["prod"]
   EOF
   oc apply -f multi-stage-pipeline.yaml
   ```

2. **Environment-Specific Tasks**
   ```bash
   # Create test task
   cat > test-task.yaml << EOF
   apiVersion: tekton.dev/v1beta1
   kind: Task
   metadata:
     name: test-app
   spec:
     workspaces:
       - name: source
     steps:
       - name: unit-tests
         image: node:16
         script: |
           cd \$(workspaces.source.path)
           npm install
           npm test
         workingDir: \$(workspaces.source.path)
       - name: integration-tests
         image: node:16
         script: |
           cd \$(workspaces.source.path)
           npm run test:integration
         workingDir: \$(workspaces.source.path)
   EOF
   oc apply -f test-task.yaml

   # Create deploy task with environment support
   cat > deploy-env-task.yaml << EOF
   apiVersion: tekton.dev/v1beta1
   kind: Task
   metadata:
     name: deploy-app
   spec:
     params:
       - name: environment
         type: string
     steps:
       - name: deploy
         image: bitnami/kubectl
         script: |
           echo "Deploying to \$(params.environment) environment"
           # Add deployment logic here
           echo "Deployment to \$(params.environment) completed"
   EOF
   oc apply -f deploy-env-task.yaml
   ```

3. **Trigger Configuration**
   ```bash
   # Create environment-specific triggers
   cat > dev-trigger.yaml << EOF
   apiVersion: triggers.tekton.dev/v1alpha1
   kind: TriggerBinding
   metadata:
     name: dev-trigger-binding
   spec:
     params:
       - name: git-revision
         value: \$(body.head_commit.id)
       - name: git-url
         value: \$(body.repository.clone_url)
       - name: environment
         value: "dev"
   EOF
   oc apply -f dev-trigger.yaml

   # Create production trigger with approval
   cat > prod-trigger.yaml << EOF
   apiVersion: triggers.tekton.dev/v1alpha1
   kind: TriggerBinding
   metadata:
     name: prod-trigger-binding
   spec:
     params:
       - name: git-revision
         value: \$(body.head_commit.id)
       - name: git-url
         value: \$(body.repository.clone_url)
       - name: environment
         value: "prod"
   EOF
   oc apply -f prod-trigger.yaml
   ```

4. **Pipeline Execution and Monitoring**
   ```bash
   # Run pipeline for different environments
   cat > dev-pipelinerun.yaml << EOF
   apiVersion: tekton.dev/v1beta1
   kind: PipelineRun
   metadata:
     name: dev-pipeline-run
   spec:
     pipelineRef:
       name: multi-stage-pipeline
     params:
       - name: git-url
         value: "https://github.com/example/app.git"
       - name: git-revision
         value: "main"
       - name: environment
         value: "dev"
     workspaces:
       - name: source
         emptyDir: {}
   EOF
   oc apply -f dev-pipelinerun.yaml

   # Monitor execution
   oc get pipelineruns
   oc describe pipelinerun dev-pipeline-run
   oc logs pipelinerun/dev-pipeline-run
   ```

---

## 📊 Key Commands Summary

### Pipeline Management
```bash
oc apply -f pipeline.yaml
oc get pipelines
oc describe pipeline <name>
oc delete pipeline <name>
```

### Task Management
```bash
oc apply -f task.yaml
oc get tasks
oc describe task <name>
oc delete task <name>
```

### PipelineRun Management
```bash
oc apply -f pipelinerun.yaml
oc get pipelineruns
oc describe pipelinerun <name>
oc logs pipelinerun/<name>
oc delete pipelinerun <name>
```

### Trigger Management
```bash
oc apply -f eventlistener.yaml
oc get eventlisteners
oc describe eventlistener <name>
oc get routes -n <namespace>
```

### Monitoring
```bash
oc get taskruns
oc describe taskrun <name>
oc logs taskrun/<name>
oc get pods -l tekton.dev/pipelineRun=<name>
```

---

## 🚨 Common Issues & Solutions

### Issue: Pipeline Not Starting
```bash
# Check pipeline definition
oc describe pipeline <name>

# Check pipeline run status
oc describe pipelinerun <name>

# Check events
oc get events --sort-by='.lastTimestamp' | grep -i pipeline

# Check operator status
oc get pods -n openshift-pipelines
```

### Issue: Task Failure
```bash
# Check task run status
oc describe taskrun <name>

# Check task logs
oc logs taskrun/<name>

# Check pod status
oc get pods -l tekton.dev/taskRun=<name>

# Check task definition
oc describe task <name>
```

### Issue: Trigger Not Working
```bash
# Check event listener status
oc describe eventlistener <name>

# Check route
oc get routes -n <namespace>

# Check webhook URL
oc get route <eventlistener-name> -o jsonpath='{.spec.host}'

# Check trigger binding
oc describe triggerbinding <name>
```

### Issue: Workspace Issues
```bash
# Check workspace configuration
oc describe pipeline <name> | grep -A 10 workspaces

# Check workspace binding
oc describe pipelinerun <name> | grep -A 10 workspaces

# Check pod volume mounts
oc get pod <pod-name> -o yaml | grep -A 10 volumes
```

---

## 📚 Next Steps

After completing Day 06:
1. **Day 07**: Monitoring and Logging
2. **Day 08**: Security and Policies
3. **Day 09**: Operators and Helm
4. **Day 10**: Advanced Topics

---

## 🔗 Additional Resources

- [OpenShift Pipelines Documentation](https://docs.openshift.com/container-platform/4.10/pipelines/index.html)
- [Tekton Documentation](https://tekton.dev/docs/)
- [OpenShift Pipelines Triggers](https://docs.openshift.com/container-platform/4.10/pipelines/triggers/index.html)
- [Tekton Catalog](https://hub.tekton.dev/)

---

**💡 Pro Tip**: Use `oc get pipelineruns -o wide` to see detailed status information for all pipeline runs!

**💡 Pro Tip**: Use `oc logs -f pipelinerun/<name>` to follow pipeline execution in real-time! 