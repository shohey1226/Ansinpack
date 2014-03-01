#!/bin/bash

export PATH="$HOME/.plenv/bin:$PATH"
eval "$(plenv init -)"

cd /tmp
if [[ -e 'cpanfile' ]]
then
    cpanm --installdeps .
fi
