#!/bin/bash

export PLENV_ROOT=/opt/perl5
export PATH="$PLENV_ROOT/bin:$PATH"
eval "$(plenv init -)"

cd /tmp
if [[ -e 'cpanfile' ]]
then
    cpanm --installdeps .
fi
