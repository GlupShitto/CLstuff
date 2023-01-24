#!/bin/bash


ip=$(hostname -I)

echo -e $ip

sed -i '/BOOTPROTO=/ s/dhcp/none/' /etc/sysconfig/network-scripts/ifcfg-ens192

echo "IPADDR=$ip" >> /etc/sysconfig/network-scripts/ifcfg-ens192

echo "PREFIX=24" >> /etc/sysconfig/network-scripts/ifcfg-ens192

echo "GATEWAY=192.168.179.1" >> /etc/sysconfig/network-scripts/ifcfg-ens192

echo "DNS1=1.1.1.1" >> /etc/sysconfig/network-scripts/ifcfg-ens192

echo "DNS2=8.8.8.8" >> /etc/sysconfig/network-scripts/ifcfg-ens192
