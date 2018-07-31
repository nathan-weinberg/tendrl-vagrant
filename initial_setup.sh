#!/bin/bash

# ensure proper priviledges
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Script must be run with sudo privileges or as root."
    exit
fi

# ensure VMs not already created
if [[ $(vagrant status | grep -c "not created") -eq 0 ]]; then
	echo 'A vagrant setup already exists. Please run "destroy.sh" to teardown the existing setup before building a new one.'
	exit
fi

###

vagrant up
echo "VMs created"

###

node_1_ip=$(vagrant ssh-config tendrl-node-1 | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
echo $node_1_ip tendrl-node-1 tendrl-node-1.local >> /etc/hosts

node_2_ip=$(vagrant ssh-config tendrl-node-2 | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
echo $node_2_ip tendrl-node-2 tendrl-node-2.local >> /etc/hosts

server_ip=$(vagrant ssh-config tendrl-server | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
echo $server_ip tendrl-server tendrl-server.local >> /etc/hosts

echo "/etc/hosts populated"

###

mkdir volmount
echo "tendrl-node-1:/glustervol $PWD/volmount glusterfs  defaults 0 0" >> /etc/fstab
mount -a
echo "volmount mounted"

###

echo "Setup complete."
