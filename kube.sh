#bin/bash

wget -P /etc/yum.repos.d/ https://download.docker.com/linux/centos/docker-ce.repo
wget -P /etc/yum.repos.d/ https://raw.githubusercontent.com/GlupShitto/kubernetes/main/kubernetes.repo

sleep 5

sed -i '22s/enforcing/disabled/' /etc/selinux/config
systemctl disable firewalld

sleep 5

cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sleep 5

modprobe overlay
modprobe br_netfilter

sleep 5

cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sleep 5

sysctl --system

sleep 5
dnf install -y  yum-utils device-mapper-persistent-data lvm2

dnf update -y && dnf install -y containerd.io

sleep 5
mkdir -p /etc/containerd

containerd config default > /etc/containerd/config.toml
sed -i '125s/false/true/' /etc/containerd/config.toml

systemctl restart containerd

systemctl enable containerd

sleep 5

dnf install -y kubeadm kubelet kubectl

sleep 5

systemctl enable kubelet
echo 'KUBELET_EXTRA_ARGS="--fail-swap-on=false"' > /etc/sysconfig/kubelet

systemctl start kubelet

reboot
