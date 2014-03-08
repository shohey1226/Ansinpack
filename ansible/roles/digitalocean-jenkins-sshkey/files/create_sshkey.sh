#!/bin/bash

if [[ ! -e /var/lib/jenkins/.ssh ]]
then
    sudo -u jenkins /usr/bin/ssh-keygen -t rsa -N "" -f /var/lib/jenkins/.ssh/id_rsa
fi

