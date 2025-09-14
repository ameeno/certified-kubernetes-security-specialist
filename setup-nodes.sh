#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

set -e

# --- Step 1: Setup containerd ---
echo "--- Setting up containerd ---"

# Load kernel modules
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Configure sysctl parameters for Kubernetes networking. [2]
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl parameters without rebooting
sysctl --system

# Install containerd
apt-get update
apt-get install -y containerd

# Create containerd configuration
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# Set SystemdCgroup to true
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart and enable containerd
systemctl restart containerd
systemctl enable containerd

echo "--- containerd setup complete ---"

# --- Step 2: Configure Kubernetes Repo and Installation ---
echo "--- Configuring Kubernetes repository and installing components ---"

# Install dependencies
apt-get install -y apt-transport-https ca-certificates curl gpg

# Add Kubernetes GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

# Update package list and install Kubernetes components
apt-get update
apt-get install -y kubelet=1.32.0-1.1 kubeadm=1.32.0-1.1 kubectl=1.32.0-1.1 cri-tools=1.32.0-1.1

# Mark Kubernetes packages to hold their version
apt-mark hold kubelet kubeadm kubectl

# Enable and start kubelet
systemctl enable --now kubelet

echo "--- Kubernetes components installation complete - Joining cluster---"

kubeadm join 192.168.0.25:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

echo "--- Node setup is finished ---"
