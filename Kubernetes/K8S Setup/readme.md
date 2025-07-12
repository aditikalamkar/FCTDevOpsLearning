# 🛠️ Kubeadm Kubernetes Cluster Setup Guide (AWS EC2 - Ubuntu)

This guide explains how to set up a Kubernetes cluster using kubeadm on AWS EC2 Ubuntu instances.

---

# 🌐 Step 1: Launch EC2 Instances & Configure Security Group

### ✅ 1. Launch EC2 Instances

- Go to **AWS EC2 Dashboard**
- Click **Launch Instance**
- Choose:
  - **AMI**: Ubuntu 18.04+
  - **Instance Type**: `t2.medium` or higher
- **VPC**: Use default VPC or create a new one
- Proceed to configure **Security Group**

---

### 🔒 2. Create or Use a Security Group

- Choose an existing Security Group or click **“Create new Security Group”**
- Add the following **Inbound Rules**:

| Rule Name        | Type        | Protocol | Port | Source             | Purpose                         |
|------------------|-------------|----------|------|--------------------|----------------------------------|
| SSH              | SSH         | TCP      | 22   | `0.0.0.0/0`        | Access via SSH                  |
| Kubernetes API   | Custom TCP  | TCP      | 6443 | `0.0.0.0/0` or VPC CIDR | Worker nodes join master |

> 🔐 **Tip**: Replace `0.0.0.0/0` with your own IP or VPC CIDR for better security.

---

### ✅ 3. Launch & Tag

- Launch the instances
- Tag instances clearly (e.g., `master`, `worker`)
- Attach the configured Security Group to **all master and worker nodes**

---
# ✅ 📦 Step 2: Install Kubernetes Components on All Nodes

To install Kubernetes tools on your **master** and **worker** nodes, follow these steps:

---

## 📥 1. Download the Script from GitHub

Go to your GitHub repo and download the setup script:

**🔗 [`setup.sh`](https://github.com/aditikalamkar/FCTDevOpsLearning/tree/main/Kubernetes/K8S%20Setup) – GitHub Repository**

### You can either:

#### 🔹 Manually Download
Navigate to the `setup.sh` file in the `K8S Setup` folder and click **"Download raw"** to save it to your local machine or server.

#### 🔹 Or Clone the Repo
```bash
git clone https://github.com/aditikalamkar/FCTDevOpsLearning.git
cd FCTDevOpsLearning/Kubernetes/K8S\ Setup
```

---

## ⚙️ 2. Run the Script on Each Node

After downloading the script, run the following commands:

```bash
chmod +x setup.sh
sudo ./setup.sh
```

Or:

```bash
sudo sh setup.sh
```

> 💡 **Note:** Run this script on both **master** and **worker** nodes to install `kubeadm`, `kubelet`, and `kubectl`.

---

## 🧪 Optional: Verify Installation

To confirm that the tools are installed correctly, run:

```bash
kubeadm version
kubectl version --client
kubelet --version
```

You should see proper version outputs (e.g., `v1.xx.x`).  
If any command is missing or fails, recheck the script and installation steps.

---
# ✅ 🖥️ Step 3: Set Up Kubernetes Control Plane (Master)

To set up the control plane (**master node**), run the script provided in your GitHub repository.

---

## 📥 1. Download the `master.sh` Script from GitHub

Go to your GitHub repo and download the script:

**🔗 [`master.sh`](https://github.com/aditikalamkar/FCTDevOpsLearning/tree/main/Kubernetes/K8S%20Setup) – GitHub Repository**

### You can either:

#### 🔹 Manually Download
Navigate to the `master.sh` file inside the `K8S Setup` folder and click **"Download raw"** to save it to your **master node**.

#### 🔹 Or Clone the Repo
```bash
git clone https://github.com/aditikalamkar/FCTDevOpsLearning.git
cd FCTDevOpsLearning/Kubernetes/K8S\ Setup
```

---

## ⚙️ 2. Run the Script on the Master Node
> ⚠️ **Important:** This step should be run **only on the master node**.

After downloading or cloning the repo, run the following:

```bash
chmod +x master.sh
sudo ./master.sh
```

🛠️ This initializes the Kubernetes control plane and sets up the master node using `kubeadm init`.

---


# ✅ 🔗 Step 4: Join Worker Nodes to the Master and Verify Connection

After installing Kubernetes using `setup.sh` and running `worker.sh`, it's time to connect your **worker nodes** to the **master** and confirm everything is working.

---

## ⚙️ 1. Join Worker Nodes to the Cluster

On each **worker node**, execute the join command that was output by the master node during `kubeadm init`.

Make sure to:
- Add `sudo` at the beginning
- Add `--v=5` at the end for verbose logging

### 🔹 Example With Placeholders:

```bash
sudo <paste-join-command-here> --v=5
```

### 🧩 Example Full Command:

```bash
sudo kubeadm join <private-ip-of-master>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash> --cri-socket "unix:///run/containerd/containerd.sock" --v=5
```

📝 This command securely connects the worker node to the master.

---

## ✅ 2. Verify Connection from Master Node

On the **master node**, run the following command to check the status of all nodes:

```bash
kubectl get nodes
```

You should see all your nodes (**master + workers**) listed with `STATUS = Ready`.

---
---

# 🎉 Conclusion

You have now successfully set up a Kubernetes cluster using **kubeadm** on **AWS EC2 Ubuntu instances**!

✅ You should have:
- Launched and configured EC2 instances for master and worker nodes
- Installed all required Kubernetes components
- Initialized the control plane on the master node
- Joined the worker nodes to the cluster
- Verified the setup with `kubectl get nodes`

---


## 🙌 Happy Kubernetes-ing!
