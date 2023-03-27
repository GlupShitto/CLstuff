#!/bin/bash
source variables.sh
verzeichnis="/etc/terraform/$vm_name"
tf_verzeichnis="/etc/tf/oracle8"
reachable=false
set -x 

####################################################
ping -c 1 $esxi_ip >/dev/null 2>&1
if [ $? -ne 0 ]
then 
  echo "$esxi_ip ist nicht erreichbar"
  exit 1
fi 

ping -c 1 $ansible_ip >/dev/null 2>&1
if [ $? -ne 0 ]
then 
  echo "$ansible_ip ist nicht erreichbar"
  exit 1
fi 

ping -c 1 $terraform_ip >/dev/null 2>&1
if [ $? -ne 0 ]
then 
  echo "$terraform_ip ist nicht erreichbar"
  exit 1
fi 
####################################################
if [ "$1" = "destroy" ]
then 
  ssh $terraform_user@$terraform_ip "cd $verzeichnis && terraform destroy"
  ssh $terraform_user@$terraform_ip "rm -r $verzeichnis"
  exit 1
fi

if [ $((ram % 4)) -ne 0 ]; then
  echo "Ram ist kein Mehrfaches von 4"
  exit 1
fi


if ssh $terraform_user@$terraform_ip "[ -d /etc/terraform/$vm_name ]"; then
    echo "Maschine existiert bereits"
    exit 1
else    
    ssh $terraform_user@$terraform_ip "mkdir -p /etc/terraform/$vm_name"
    echo "Verzeichnis erstellt"
fi


####################################################
ssh $terraform_user@$terraform_ip "cp $tf_verzeichnis/main.tf $verzeichnis/main.tf"
ssh $terraform_user@$terraform_ip "cp $tf_verzeichnis/vm.tf $verzeichnis/vm.tf"

ssh $terraform_user@$terraform_ip "touch $verzeichnis/variables.tf"

ssh $terraform_user@$terraform_ip "cat <<EOF >> $verzeichnis/variables.tf
variable \"esxi_hostport\" {
  default = \"22\"
}

EOF"

ssh $terraform_user@$terraform_ip "cat <<EOF >> $verzeichnis/variables.tf
variable \"esxi_hostssl\" {
  default = \"443\"
}

EOF"

ssh $terraform_user@$terraform_ip "cat <<EOF >> $verzeichnis/variables.tf
variable \"esxi_username\" {
  default = \"$esxi_username\"
}

EOF"

ssh $terraform_user@$terraform_ip "cat <<EOF >> $verzeichnis/variables.tf
variable \"esxi_password\" {
  default = \"$esxi_passwort\"
}

EOF"

ssh $terraform_user@$terraform_ip "cat <<EOF >> $verzeichnis/variables.tf
variable \"esxi_hostname\" {
  default = \"$esxi_ip\"
}

EOF"

ssh $terraform_user@$terraform_ip "cat <<EOF >> $verzeichnis/variables.tf
variable \"guest_name\" {
  default = \"$vm_name\"
}

EOF"

ssh $terraform_user@$terraform_ip "cat <<EOF >> $verzeichnis/variables.tf
variable \"disk_store\" {
  default = \"$disk_store\"
}

EOF"

ssh $terraform_user@$terraform_ip "cat <<EOF >> $verzeichnis/variables.tf
variable \"memsize\" {
  default = $ram
}

EOF"

ssh $terraform_user@$terraform_ip "cat <<EOF >> $verzeichnis/variables.tf
variable \"numvcpu\" {
  default = $cores
}

EOF"

ssh $terraform_user@$terraform_ip "cat <<EOF >> $verzeichnis/variables.tf
variable \"virtual_disk\" {
  default = \"$virtual_disk\"
}

EOF"

ssh $terraform_user@$terraform_ip "cat <<EOF >> $verzeichnis/variables.tf
variable \"virtual_disk_size\" {
  default = $virtual_disk_size
}

EOF"

ssh $terraform_user@$terraform_ip "cat <<EOF >> $verzeichnis/variables.tf
variable \"virtual_disk_type\" {
  default = \"$virtual_disk_type\"
}

EOF"


ssh $terraform_user@$terraform_ip "cat <<EOF >> $verzeichnis/variables.tf
variable \"boot_disk_type\" {
  default = \"$bootdisk_type\"
}

EOF"

####################################################

ssh $terraform_user@$terraform_ip "cd $verzeichnis && terraform init"
ssh $terraform_user@$terraform_ip "cd $verzeichnis && terraform apply --auto-approve"

if [ $? -ne 0 ]
then
    echo "Terraform war nicht erfolgreich"
    ssh $terraform_user@$terraform_ip "rm -r $verzeichnis"
    exit 1
else
  echo "Terraform war erfolgreich"
fi

expect /root/scripts/ssh-key.exp
ssh root@$vm_ip_alt "reboot"
while ! ssh root@$vm_ip_alt "echo 'Server is back online!'"; do
  sleep 5
done
ssh root@$vm_ip_alt "mkdir -p /mnt/platte02"
ssh root@$vm_ip_alt "parted -s /dev/sdb mklabel gpt"
ssh root@$vm_ip_alt "parted -s /dev/sdb mkpart primary ext4 0% 100%"
ssh root@$vm_ip_alt "mkfs.ext4 /dev/sdb1"
ssh root@$vm_ip_alt "mount /dev/sdb1 /mnt/platte02"

ssh root@$vm_ip_alt "sed -i 's/$vm_ip_alt/$vm_ip_neu/' /etc/sysconfig/network-scripts/ifcfg-$interface_name"
ssh root@$vm_ip_alt "reboot"
while [ $reachable == false ]
do
    ping -c 1 $vm_ip_neu > /dev/null  # Ping the machine once and discard the output
    if [ $? -eq 0 ]; then  # Check the return code of the ping command
        echo "Machine is now reachable"
        reachable=true
    else
        echo "Machine is not reachable yet, retrying in 5 seconds..."
        sleep 3
    fi
done
expect /root/scripts/fingerprint.exp
sed -i "/\[Terraform\]/a\\$vm_ip_neu" /etc/ansible/hosts