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

vagrant reload
mount -a

echo "Vagrant VM Setup resumed"