#!/bin/bash

if [[ ! -e /var/lib/jenkins/.ssh ]]
then
    sudo -u jenkins /usr/bin/ssh-keygen -t rsa -N "" -f /var/lib/jenkins/.ssh/id_rsa
fi

if [[ -e /var/lib/jenkins/.ssh/known_hosts ]]
then
    /bin/rm -f /var/lib/jenkins/.ssh/known_hosts
fi
