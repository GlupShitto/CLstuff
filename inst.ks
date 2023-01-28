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
%pre
swapoff -a
%end
%packages

perl
@^server-product-environment
%end
%post
echo "swapoff -a" >> /etc/rc.local
echo "GRUB_CMDLINE_LINUX='ipv6.disable=1'" >> /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
dnf install -y expect
%end
