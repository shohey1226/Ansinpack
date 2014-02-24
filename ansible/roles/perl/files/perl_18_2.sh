#!/bin/sh

cd /tmp/
wget http://www.cpan.org/src/5.0/perl-5.18.2.tar.gz
tar zxvf perl-5.18.2.tar.gz
cd perl-5.18.2
./Configure
make 
make test
make install
