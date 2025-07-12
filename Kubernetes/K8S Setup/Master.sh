#!/bin/bash

# -------------------------------------------
# Kubernetes Master Node Initialization Script
# Run this ONLY on the Master Node
# -------------------------------------------

# 🚀 Step 1: Initialize the Kubernetes Cluster
# The --ignore-preflight-errors=all option is used to bypass warnings (can be removed for stricter checks)
echo "🔧 Initializing Kubernetes Cluster..."
sudo kubeadm init --ignore-preflight-errors=all
sleep 2

# 🧰 Step 2: Configure kubectl for the current (non-root) user
# This allows you to run kubectl without sudo
echo "🔧 Setting up local kubeconfig..."
mkdir -p "$HOME/.kube"
sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"
sleep 2

# 🌐 Step 3: Install a Network Plugin (Calico)
# Required for pod-to-pod communication across nodes
echo "🌐 Installing Calico network plugin..."
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/calico.yaml
sleep 5

# 🔑 Step 4: Generate the Join Command for Worker Nodes
# You'll use this output on each worker node to join the cluster
echo "🔑 Generating join command for worker nodes..."
kubeadm token create --print-join-command
sleep 2

echo "✅ Kubernetes Master Node setup complete."
