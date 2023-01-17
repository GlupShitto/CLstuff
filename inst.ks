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
@^server-product-environment
%end
