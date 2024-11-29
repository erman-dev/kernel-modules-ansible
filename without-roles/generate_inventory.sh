#!/bin/bash

# Define the output inventory file
INVENTORY_FILE="hosts.ini"

# Timeout settings (in seconds) for checking cluster and SSH availability
CLUSTER_CHECK_TIMEOUT=10
SSH_CHECK_TIMEOUT=5

# Function to check Kubernetes cluster availability
check_k8s_cluster() {
  echo "Checking Kubernetes cluster availability..."

  # Check if the 'kubectl' command is available
  if ! command -v kubectl &> /dev/null; then
    echo "Error: 'kubectl' command not found. Please ensure Kubernetes CLI is installed."
    exit 1
  fi

  # Check the cluster by running 'kubectl get nodes' with a timeout
  if ! timeout $CLUSTER_CHECK_TIMEOUT kubectl get nodes &> /dev/null; then
    echo "Error: Unable to reach the Kubernetes cluster or cluster is not available."
    exit 1
  fi

  echo "Kubernetes cluster is available."
}

# Function to retrieve worker nodes
get_worker_nodes() {
  echo "Retrieving worker nodes from Kubernetes cluster..."

  # Get the list of worker nodes (excluding master/control plane nodes)
  #WORKER_NODES=$(kubectl get nodes --selector='!node-role.kubernetes.io/control-plane' -o jsonpath='{range .items[*]}{.metadata.name} {.status.addresses[?(@.type=="InternalIP")].address}{"\n"}{end}')
  WORKER_NODES=$(kubectl get nodes -o json |jq -r '.items[] |select([.metadata.labels |keys[] | contains("worker")] | any == true) | "\(.metadata.name) \(.status.addresses[] | select(.type=="InternalIP").address)"')


  if [ -z "$WORKER_NODES" ]; then
    echo "Error: No worker nodes found in the Kubernetes cluster."
    exit 1
  fi

  echo "Found the following worker nodes:"
  echo "$WORKER_NODES"
}

# Function to verify SSH access to the worker node
check_ssh_access() {
  local WORKER_IP=$1
  local USERNAME=$2

  echo "Verifying SSH access to $WORKER_IP..."

  # Try SSH with a 5-second timeout for connection
  if ! timeout $SSH_CHECK_TIMEOUT ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=$SSH_CHECK_TIMEOUT "$WORKER_IP" "exit" &> /dev/null; then
    echo "Error: Unable to SSH into $WORKER_IP. Please ensure SSH access is set up properly for the user '$USERNAME'."
    exit 1
  fi

  echo "SSH access to $WORKER_IP verified."
}

# Function to generate the inventory file
generate_inventory() {
  echo "Generating Ansible inventory file..."

  # Begin writing to the inventory file
  echo "[workers]" > $INVENTORY_FILE

  # Loop through each worker node and gather the kernel version
  echo "$WORKER_NODES" | while read -r WORKER_NAME WORKER_IP; do
    # Verify SSH access to the worker node
    check_ssh_access "$WORKER_IP" "$USER"

    # Retrieve the kernel version from the worker node using SSH
    KERNEL_VERSION=$(ssh "$WORKER_IP" "uname -r")

    # If SSH fails, report the error and exit
    if [ $? -ne 0 ]; then
      echo "Error: Unable to SSH into $WORKER_NAME ($WORKER_IP). Please check the SSH connection."
      exit 1
    fi

    # Write the worker node information to the inventory file
    echo "$WORKER_NAME ansible_host=$WORKER_IP kernel_version=$KERNEL_VERSION" >> $INVENTORY_FILE
  done

  echo "Inventory file '$INVENTORY_FILE' generated successfully."
}

# Function to create host_vars directories for each worker node
create_host_vars_directories() {
  echo "Creating host_vars directories for each worker node..."

  # Loop through each worker node
  echo "$WORKER_NODES" | while read -r WORKER_NAME WORKER_IP; do
    # Create the host_vars directory if it does not exist
    if [ ! -d "host_vars" ]; then
      mkdir host_vars
    fi

    # Create the subdirectory for the worker node
    if [ ! -d "host_vars/$WORKER_NAME" ]; then
      mkdir "host_vars/$WORKER_NAME"
    fi

    echo "Created host_vars directory for $WORKER_NAME"
  done

  echo "host_vars directories created successfully."
}

# Ensure script is run by a user who can SSH into the worker nodes
USER=$(whoami)

# Step 1: Check Kubernetes cluster availability
check_k8s_cluster

# Step 2: Retrieve the list of worker nodes
get_worker_nodes

# Step 3: Generate the inventory file
generate_inventory

# Step 4: Create host_vars directories for each worker node
create_host_vars_directories
