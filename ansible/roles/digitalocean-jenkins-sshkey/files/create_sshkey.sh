#!/bin/bash

if [[ ! -e /var/lib/jenkins/.ssh ]]
then
    /usr/bin/su -s /bin/bash jenkins
    /usr/bin/ssh-keygen -t rsa -N "" -f /var/lib/jenkins/.ssh/id_rsa
    ../scripts/doman.pl --create_sshkey -sshkey_name jenkins -pub_sshkey /var/lib/jenkins/.ssh/id_rsa.pub
fi

