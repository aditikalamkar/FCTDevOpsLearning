#!/bin/bash

# -------------------------------------------
# Kubernetes Node Preparation Script (Master & Worker)
# Compatible with Ubuntu 18.04+ systems
# -------------------------------------------

# 🔧 Step 1: Disable Swap (Kubernetes requires swap to be disabled)
echo "Disabling swap..."
sudo swapoff -a
sleep 2

# 🔧 Step 2: Load Required Kernel Modules
# These modules are needed for container networking
echo "Loading necessary kernel modules for Kubernetes networking..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# Apply the modules immediately
sudo modprobe overlay
sudo modprobe br_netfilter
sleep 2

# 🔧 Step 3: Set Sysctl Parameters for Networking
# Ensures proper packet forwarding and bridge traffic handling
echo "Setting sysctl parameters for networking..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl settings
sudo sysctl --system
# Optional: Verify loaded modules
lsmod | grep br_netfilter
lsmod | grep overlay
sleep 2

# 🔧 Step 4: Install Container Runtime (containerd)
echo "Installing containerd..."

# Update packages and install dependencies
sudo apt-get update
sleep 2

sudo apt-get install -y ca-certificates curl
sleep 2

# Add Docker’s official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sleep 2

# Set up Docker's stable repository for containerd
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sleep 2

# Install containerd
sudo apt-get install -y containerd.io
sleep 2

# Configure containerd with systemd as the cgroup driver (recommended for Kubernetes)
containerd config default | sed -e 's/SystemdCgroup = false/SystemdCgroup = true/' -e 's/sandbox_image = "registry.k8s.io\/pause:3.6"/sandbox_image = "registry.k8s.io\/pause:3.9"/' | sudo tee /etc/containerd/config.toml

# Restart containerd to apply configuration
sudo systemctl restart containerd
sleep 2

# Verify containerd is active
sudo systemctl is-active containerd
sleep 2

# 🔧 Step 5: Install Kubernetes Components
echo "Installing Kubernetes components (kubelet, kubeadm, kubectl)..."

# Update package list and install transport tools
sudo apt-get update
sleep 2

sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sleep 2

# Add Kubernetes signing key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sleep 2

# Add Kubernetes repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package list again
sudo apt-get update
sleep 2

# Install kubelet, kubeadm, and kubectl
sudo apt-get install -y kubelet kubeadm kubectl
sleep 2

# Prevent automatic upgrades to ensure version consistency
sudo apt-mark hold kubelet kubeadm kubectl
sleep 2

echo "✅ Kubernetes setup completed on this node."
