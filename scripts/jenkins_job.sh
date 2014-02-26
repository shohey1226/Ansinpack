#!/bin/bash

# This script is executed by Jenkins job

TODAY=`date +%Y%m%d%H%M%S`

cd /tmp
mkdir /tmp/$TODAY
cd $TODAY

/usr/bin/git clone $GIT_URL
cd Ansinpack
#GIT_BRANCH=origin/test
git pull origin test_tag


