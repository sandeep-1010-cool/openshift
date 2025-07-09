#!/bin/bash

# Day 01: OpenShift Introduction - Lab Scripts
# This script contains all the commands needed for Day 01 exercises

echo "🚀 Starting Day 01 OpenShift Lab"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Exercise 1: Accessing Your OpenShift Cluster
print_header "Exercise 1: Accessing Your OpenShift Cluster"

print_status "Checking if you're logged in to OpenShift..."
if oc whoami &>/dev/null; then
    print_status "You are logged in as: $(oc whoami)"
else
    print_warning "You are not logged in. Please run: oc login -u <username> -p <password> <cluster-url>"
    exit 1
fi

print_status "Getting cluster information..."
oc cluster-info

print_status "Checking node status..."
oc get nodes

print_status "Checking cluster operators..."
oc get clusteroperators

print_status "Getting console URL..."
oc whoami --show-console

# Exercise 2: Project Management
print_header "Exercise 2: Project Management"

print_status "Listing all projects you have access to..."
oc get projects

print_status "Creating a new project for Day 01 lab..."
oc new-project day01-lab --description="Day 01 OpenShift Learning Lab"

print_status "Switching to the new project..."
oc project day01-lab

print_status "Checking project status..."
oc status

print_status "Describing the project to see quotas and limits..."
oc describe project day01-lab

# Exercise 3: Resource Investigation
print_header "Exercise 3: Resource Investigation"

print_status "Listing all resources in the project..."
oc get all

print_status "Checking project events..."
oc get events

print_status "Checking project quotas..."
oc get resourcequota

print_status "Checking project limits..."
oc get limitrange

# Exercise 4: Basic CLI Commands
print_header "Exercise 4: Basic CLI Commands"

print_status "Getting current context information..."
echo "Current user: $(oc whoami)"
echo "Current project: $(oc project -q)"

print_status "Listing different resource types..."
echo "Pods:"
oc get pods
echo ""
echo "Services:"
oc get services
echo ""
echo "Routes:"
oc get routes
echo ""
echo "Deployments:"
oc get deployments

# Challenge Exercise: Cluster Analysis
print_header "Challenge Exercise: Cluster Analysis"

print_status "Gathering cluster details..."
echo "Cluster Info:"
oc cluster-info
echo ""
echo "OpenShift Version:"
oc version
echo ""
echo "Node Details:"
oc get nodes -o wide

print_status "Analyzing cluster capacity..."
echo "Node Capacity Analysis:"
oc get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.capacity.cpu}{"\t"}{.status.capacity.memory}{"\n"}{end}'

print_status "Checking operator status..."
echo "Cluster Operators Status:"
oc get clusteroperators -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.conditions[?(@.type=="Available")].status}{"\n"}{end}'

# Additional useful commands
print_header "Additional Useful Commands"

print_status "Getting help with oc commands..."
echo "Available oc commands:"
oc --help | head -20

print_status "Checking your permissions..."
echo "Can you list projects: $(oc auth can-i list projects)"
echo "Can you create projects: $(oc auth can-i create projects)"
echo "Can you list pods: $(oc auth can-i list pods)"

print_status "Getting cluster metrics..."
echo "Cluster resource usage:"
oc get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.allocatable.cpu}{"\t"}{.status.allocatable.memory}{"\n"}{end}'

# Cleanup (optional)
print_header "Cleanup"

read -p "Do you want to delete the day01-lab project? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Deleting day01-lab project..."
    oc delete project day01-lab
    print_status "Project deleted successfully!"
else
    print_status "Project 'day01-lab' will remain for further exploration"
fi

print_header "Lab Complete!"
echo "🎉 Congratulations! You've completed Day 01 lab exercises."
echo ""
echo "Next steps:"
echo "1. Review the web console at: $(oc whoami --show-console)"
echo "2. Explore the project you created"
echo "3. Try the challenge exercise manually"
echo "4. Move on to Day 02: OpenShift CLI Mastery"
echo ""
echo "Happy Learning! 🚀" 