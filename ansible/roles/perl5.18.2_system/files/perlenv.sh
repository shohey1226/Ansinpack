#!/bin/bash

export PLENV_ROOT=/opt/perl5

if [[ ! -e $PLENV_ROOT ]];then
   mkdir -p /opt/perl5
   git clone git://github.com/tokuhirom/plenv.git $PLENV_ROOT
   git clone git://github.com/tokuhirom/Perl-Build.git $PLENV_ROOT/plugins/perl-build/
   $PLENV_ROOT/bin/plenv install 5.18.2
   $PLENV_ROOT/bin/plenv rehash
   $PLENV_ROOT/bin/plenv global 5.18.2 
   $PLENV_ROOT/bin/plenv install-cpanm
   $PLENV_ROOT/bin/plenv rehash
   #echo 'export PATH="$HOME/.plenv/bin:$PATH"' >> $HOME/.bash_profile
   #echo 'eval "$(plenv init -)"' >> $HOME/.bash_profile
   #$HOME/.plenv/shims/cpanm Carton 
fi
