#!/bin/bash -x

echo $GIT_URL
echo $GIT_BRANCH
echo 'test'

## This script is executed by Jenkins job
#
#use strict;
#use warnings;
#use DigitalOcean;
#
#my $repo_url = $ENV{GIT_URL};
#my $branch = $ENV{GIT_BRANCH};
#$repo_url =~ /\/(\S+)\.git$/;
#my $repo_name= $1;
#
## Create working directory and go to there
#my $today =`date +%Y%m%d%H%M%S`;
#chomp $today;
#mkdir "/tmp/$today";
#cddir "/tmp/$today";
#
#print "Currently I'm in " . `pwd`;
#print  "Execute: /usr/bin/git clone -b $branch $repo_url\n";
#system "/usr/bin/git clone -b $branch $repo_url";
#
#print "Move to packer directory\n";
#cddir  "$repo_name/packer";
#
## NOTE: GIT_BRANCH name convention
## /image_name1/image_name2/..3/explanation
## $GIT_BRANCH=webapp/nginx/database/=update-perl
## This means we are going to create webapp, nginx and database image.
#
## Create image with packer command
#my @images = split /\//, $branch;
#for my $image (@images){
#    last if ($image =~ /^=/);
#    print "Execute : packer $image.json\n";
#    system "packer vb-$image.json" if ( -e "vb-$image.json");
#    system "packer do-$image.json" if ( -e "do-$image.json");
#}
#
## Move on to test
#
## If the test is failed, report Jenkins it's failed and delete image and snapshot.
#my $do = DigitalOcean->new(client_id=> $client_id, api_key => $api_key, wait_on_events => 1);
#

