#!/bin/bash

/usr/bin/docker ps | grep registry
if [[ $? -ne 0 ]]
then
    docker run -d -p 5000:5000 -v /tmp/registry:/tmp/registry registry
if
