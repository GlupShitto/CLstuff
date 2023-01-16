lang en_US
keyboard us
timezone America/New_York --utc
rootpw $2b$10$nZgTyqOl.CwJjQF94qqwS.Abk2AMDVKpqztC8iKxYatem49OigtuO --iscrypted
reboot
cdrom
bootloader --append="rhgb quiet crashkernel=auto"
zerombr
clearpart --all --initlabel
autopart
firstboot --disable
selinux --disabled
%packages
@^server-product-environment
%end
%post
wget -P /etc/yum.repos.d/ https://download.docker.com/linux/centos/docker-ce.repo
wget -P /etc/yum.repos.d/ https://raw.githubusercontent.com/GlupShitto/kubernetes/main/kubernetes.repo



sed -i '22s/enforcing/disabled/' /etc/selinux/config
systemctl disable firewalld



cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF



modprobe overlay
modprobe br_netfilter



cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF



sysctl --system


dnf install -y  yum-utils device-mapper-persistent-data lvm2

dnf update -y && dnf install -y containerd.io


mkdir -p /etc/containerd

containerd config default > /etc/containerd/config.toml
sed -i '125s/false/true/' /etc/containerd/config.toml

systemctl restart containerd

systemctl enable containerd



dnf install -y kubeadm kubelet kubectl



systemctl enable kubelet
echo 'KUBELET_EXTRA_ARGS="--fail-swap-on=false"' > /etc/sysconfig/kubelet

systemctl start kubelet

reboot
%end
