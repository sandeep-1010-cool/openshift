#!/bin/bash

# Day 02: OpenShift CLI & Projects - Lab Scripts
# This script provides automated exercises for mastering OpenShift CLI commands

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if user is logged in
check_login() {
    if ! oc whoami &>/dev/null; then
        print_error "You are not logged in to OpenShift. Please run 'oc login' first."
        exit 1
    fi
    print_success "Logged in as: $(oc whoami)"
}

# Function to create project if it doesn't exist
create_project() {
    local project_name=$1
    local description=$2
    
    if ! oc get project $project_name &>/dev/null; then
        print_status "Creating project: $project_name"
        oc new-project $project_name --description="$description"
        print_success "Project $project_name created successfully"
    else
        print_warning "Project $project_name already exists"
    fi
    
    oc project $project_name
    print_success "Switched to project: $project_name"
}

# Exercise 1: Basic CLI Commands
exercise_1() {
    echo -e "\n${BLUE}=== Exercise 1: Basic CLI Commands ===${NC}"
    
    check_login
    
    print_status "Checking current context..."
    echo "Current user: $(oc whoami)"
    echo "Current project: $(oc project -q)"
    echo "Cluster info: $(oc cluster-info | head -1)"
    
    print_status "Listing all projects..."
    oc get projects
    
    print_success "Exercise 1 completed!"
}

# Exercise 2: Project Management
exercise_2() {
    echo -e "\n${BLUE}=== Exercise 2: Project Management ===${NC}"
    
    check_login
    
    # Create test project
    create_project "day02-lab" "Day 02 learning project"
    
    print_status "Getting project details..."
    oc describe project day02-lab
    
    print_status "Listing all resources in project..."
    oc get all
    
    print_success "Exercise 2 completed!"
}

# Exercise 3: Advanced CLI Features
exercise_3() {
    echo -e "\n${BLUE}=== Exercise 3: Advanced CLI Features ===${NC}"
    
    check_login
    oc project day02-lab
    
    print_status "Creating a test deployment..."
    oc create deployment nginx --image=nginx:latest
    
    print_status "Waiting for deployment to be ready..."
    oc rollout status deployment/nginx --timeout=60s
    
    print_status "Demonstrating different output formats..."
    echo "Wide format:"
    oc get pods -o wide
    
    echo -e "\nYAML format (first few lines):"
    oc get pods -o yaml | head -20
    
    echo -e "\nCustom columns:"
    oc get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,AGE:.metadata.creationTimestamp
    
    print_status "Exposing the deployment as a service..."
    oc expose deployment nginx --port=80 --target-port=80
    
    print_status "Creating a route..."
    oc expose service nginx --name=nginx-route
    
    print_success "Exercise 3 completed!"
}

# Exercise 4: User and Group Management
exercise_4() {
    echo -e "\n${BLUE}=== Exercise 4: User and Group Management ===${NC}"
    
    check_login
    oc project day02-lab
    
    print_status "Listing current users in project..."
    oc get users
    
    print_status "Listing current groups..."
    oc get groups
    
    print_status "Listing roles in project..."
    oc get roles
    
    print_status "Listing role bindings..."
    oc get rolebindings
    
    print_status "Checking current user permissions..."
    echo "Can list pods: $(oc auth can-i list pods)"
    echo "Can create deployments: $(oc auth can-i create deployments)"
    echo "Can delete projects: $(oc auth can-i delete projects)"
    
    print_success "Exercise 4 completed!"
}

# Exercise 5: RBAC Operations
exercise_5() {
    echo -e "\n${BLUE}=== Exercise 5: RBAC Operations ===${NC}"
    
    check_login
    oc project day02-lab
    
    print_status "Creating a test group..."
    oc adm groups new test-developers 2>/dev/null || print_warning "Group might already exist"
    
    print_status "Adding current user to test group..."
    oc adm groups add-users test-developers $(oc whoami) 2>/dev/null || print_warning "User might already be in group"
    
    print_status "Assigning view role to test group..."
    oc adm policy add-role-to-group view test-developers -n day02-lab 2>/dev/null || print_warning "Role binding might already exist"
    
    print_status "Listing updated role bindings..."
    oc get rolebindings
    
    print_success "Exercise 5 completed!"
}

# Exercise 6: Resource Management
exercise_6() {
    echo -e "\n${BLUE}=== Exercise 6: Resource Management ===${NC}"
    
    check_login
    oc project day02-lab
    
    print_status "Scaling nginx deployment to 3 replicas..."
    oc scale deployment nginx --replicas=3
    
    print_status "Waiting for scaling to complete..."
    oc rollout status deployment/nginx --timeout=60s
    
    print_status "Checking pod status..."
    oc get pods
    
    print_status "Creating a resource quota..."
    oc create quota test-quota --hard=cpu=2,memory=4Gi,pods=10 2>/dev/null || print_warning "Quota might already exist"
    
    print_status "Creating a limit range..."
    oc create limitrange test-limits --min=cpu=100m,memory=128Mi --max=cpu=1,memory=1Gi --default=cpu=200m,memory=256Mi 2>/dev/null || print_warning "Limit range might already exist"
    
    print_status "Checking project quotas and limits..."
    oc describe project day02-lab
    
    print_success "Exercise 6 completed!"
}

# Exercise 7: Monitoring and Debugging
exercise_7() {
    echo -e "\n${BLUE}=== Exercise 7: Monitoring and Debugging ===${NC}"
    
    check_login
    oc project day02-lab
    
    print_status "Watching pods for 10 seconds..."
    timeout 10s oc get pods -w || true
    
    print_status "Checking recent events..."
    oc get events --sort-by='.lastTimestamp' | head -10
    
    print_status "Checking resource usage..."
    oc adm top pods 2>/dev/null || print_warning "Resource usage not available"
    
    print_status "Getting logs from nginx pod..."
    POD_NAME=$(oc get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
    if [ ! -z "$POD_NAME" ]; then
        echo "Logs from $POD_NAME:"
        oc logs $POD_NAME --tail=5
    else
        print_warning "No nginx pods found"
    fi
    
    print_success "Exercise 7 completed!"
}

# Exercise 8: Cleanup
exercise_8() {
    echo -e "\n${BLUE}=== Exercise 8: Cleanup ===${NC}"
    
    check_login
    
    print_status "Cleaning up resources in day02-lab project..."
    oc project day02-lab
    
    print_status "Deleting all resources..."
    oc delete all --all
    
    print_status "Deleting quota and limit range..."
    oc delete quota test-quota 2>/dev/null || true
    oc delete limitrange test-limits 2>/dev/null || true
    
    print_status "Removing role bindings..."
    oc adm policy remove-role-from-group view test-developers -n day02-lab 2>/dev/null || true
    
    print_status "Deleting test group..."
    oc adm groups remove-users test-developers $(oc whoami) 2>/dev/null || true
    oc delete group test-developers 2>/dev/null || true
    
    print_success "Exercise 8 completed!"
}

# Challenge Exercise: Multi-Project RBAC
challenge_exercise() {
    echo -e "\n${BLUE}=== Challenge Exercise: Multi-Project RBAC ===${NC}"
    
    check_login
    
    print_status "Creating multiple projects..."
    oc new-project frontend-team --description="Frontend team project" 2>/dev/null || print_warning "Project might already exist"
    oc new-project backend-team --description="Backend team project" 2>/dev/null || print_warning "Project might already exist"
    oc new-project devops-team --description="DevOps team project" 2>/dev/null || print_warning "Project might already exist"
    
    print_status "Creating user groups..."
    oc adm groups new frontend-developers 2>/dev/null || print_warning "Group might already exist"
    oc adm groups new backend-developers 2>/dev/null || print_warning "Group might already exist"
    oc adm groups new devops-engineers 2>/dev/null || print_warning "Group might already exist"
    
    print_status "Adding current user to all groups..."
    oc adm groups add-users frontend-developers $(oc whoami) 2>/dev/null || print_warning "User might already be in group"
    oc adm groups add-users backend-developers $(oc whoami) 2>/dev/null || print_warning "User might already be in group"
    oc adm groups add-users devops-engineers $(oc whoami) 2>/dev/null || print_warning "User might already be in group"
    
    print_status "Assigning roles to groups..."
    oc adm policy add-role-to-group edit frontend-developers -n frontend-team 2>/dev/null || print_warning "Role binding might already exist"
    oc adm policy add-role-to-group edit backend-developers -n backend-team 2>/dev/null || print_warning "Role binding might already exist"
    oc adm policy add-role-to-group admin devops-engineers -n frontend-team 2>/dev/null || print_warning "Role binding might already exist"
    oc adm policy add-role-to-group admin devops-engineers -n backend-team 2>/dev/null || print_warning "Role binding might already exist"
    oc adm policy add-role-to-group admin devops-engineers -n devops-team 2>/dev/null || print_warning "Role binding might already exist"
    
    print_status "Testing permissions..."
    echo "Frontend team permissions:"
    oc auth can-i list pods -n frontend-team --as=$(oc whoami)
    oc auth can-i create deployments -n frontend-team --as=$(oc whoami)
    
    echo "Backend team permissions:"
    oc auth can-i list pods -n backend-team --as=$(oc whoami)
    oc auth can-i create deployments -n backend-team --as=$(oc whoami)
    
    echo "DevOps team permissions:"
    oc auth can-i delete projects --as=$(oc whoami)
    
    print_status "Generating RBAC report..."
    echo "Role bindings across all projects:"
    oc get rolebindings --all-namespaces -o wide | grep -E "(frontend|backend|devops)"
    
    print_success "Challenge exercise completed!"
}

# Main menu
show_menu() {
    echo -e "\n${BLUE}=== Day 02: OpenShift CLI & Projects Lab ===${NC}"
    echo "1. Exercise 1: Basic CLI Commands"
    echo "2. Exercise 2: Project Management"
    echo "3. Exercise 3: Advanced CLI Features"
    echo "4. Exercise 4: User and Group Management"
    echo "5. Exercise 5: RBAC Operations"
    echo "6. Exercise 6: Resource Management"
    echo "7. Exercise 7: Monitoring and Debugging"
    echo "8. Exercise 8: Cleanup"
    echo "9. Challenge Exercise: Multi-Project RBAC"
    echo "10. Run All Exercises"
    echo "11. Exit"
    echo -e "\nEnter your choice (1-11): "
}

# Run all exercises
run_all() {
    exercise_1
    exercise_2
    exercise_3
    exercise_4
    exercise_5
    exercise_6
    exercise_7
    challenge_exercise
    print_success "All exercises completed! Don't forget to run cleanup (Exercise 8) when done."
}

# Main script
main() {
    if [ $# -eq 0 ]; then
        while true; do
            show_menu
            read -r choice
            case $choice in
                1) exercise_1 ;;
                2) exercise_2 ;;
                3) exercise_3 ;;
                4) exercise_4 ;;
                5) exercise_5 ;;
                6) exercise_6 ;;
                7) exercise_7 ;;
                8) exercise_8 ;;
                9) challenge_exercise ;;
                10) run_all ;;
                11) echo "Goodbye!"; exit 0 ;;
                *) echo "Invalid choice. Please enter 1-11." ;;
            esac
        done
    else
        # Run specific exercise if argument provided
        case $1 in
            1) exercise_1 ;;
            2) exercise_2 ;;
            3) exercise_3 ;;
            4) exercise_4 ;;
            5) exercise_5 ;;
            6) exercise_6 ;;
            7) exercise_7 ;;
            8) exercise_8 ;;
            9) challenge_exercise ;;
            all) run_all ;;
            *) echo "Usage: $0 [1-9|all] or run without arguments for interactive menu"; exit 1 ;;
        esac
    fi
}

# Check if oc command exists
if ! command -v oc &> /dev/null; then
    print_error "OpenShift CLI (oc) is not installed or not in PATH"
    print_status "Please install OpenShift CLI first"
    exit 1
fi

# Run main function
main "$@" 