#!/bin/bash

# ensure proper priviledges
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Script must be run with sudo privileges or as root."
    exit
fi

###

vagrant reload
mount -a

echo "Vagrant VM Setup resumed"