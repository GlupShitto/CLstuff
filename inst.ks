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
expect
perl
@^server-product-environment
%end
%post
echo "GRUB_CMDLINE_LINUX='ipv6.disable=1'" >> /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
%end
