#!/bin/bash

# ensure proper priviledges
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Script must be run with sudo privileges or as root."
    exit
fi

# ensure VMs are already created
if [[ $(vagrant status | grep -c "not created") -ne 0 ]]; then
	echo 'No VM setup detected. To build a new one run "initial_setup.sh".'
	exit
fi

###

sed -i '/volmount/d' /etc/fstab
fusermount -uz $PWD/volmount
rm -rf volmount
echo "volmount unmounted"

###

sed -i '/tendrl/d' /etc/hosts
echo "depopulated /etc/hosts"

###

vagrant destroy -f
echo 'Vagrant VM Setup Destroyed. Run "initial_setup.sh" for new build.'
