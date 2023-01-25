text
lang en_US
keyboard de
timezone Europe/Berlin --utc
rootpw $2b$10$StMiLqdtiBlUdzLsSJsnOO9bXrVxBbzpRT5vpSO551pz2DSY5CFqy --iscrypted
reboot
cdrom
bootloader --append="rhgb quiet crashkernel=auto ipv6.disabled=1"
zerombr
clearpart --all --initlabel
autopart
firstboot --disable
selinux --disabled
%packages

perl
@^server-product-environment
%end
%post
echo "GRUB_CMDLINE_LINUX='ipv6.disable=1'" >> /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
dnf install -y expect

wget -P /etc/yum.repos.d/ https://download.docker.com/linux/centos/docker-ce.repo
wget -P /etc/yum.repos.d/ https://raw.githubusercontent.com/GlupShitto/kubernetes/main/kubernetes.repo


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



%end
