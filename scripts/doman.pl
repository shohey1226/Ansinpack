#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use DigitalOcean;

my $client_id = $ENV{DIGITALOCEAN_CLIENT_ID};
my $api_key = $ENV{DIGITALOCEAN_API_KEY};
my $verbose = undef;
my $help = undef;
my $create_droplet=undef;


my $options_okay = GetOptions (
    'client_id=s'       => \$client_id,  
    'api_key=s'         => \$api_key,  
    'create_droplet'    => \$create_droplet,
    'verbose'           => \$verbose,  
    'help'              => \$help,  
);

if (defined $help ){
    show_help();
}

if ( undef $client_id && undef $api_key ) {
    show_help();
}

my $do = DigitalOcean->new(
    client_id=> $client_id, 
    api_key => $api_key, 
    wait_on_events => 1
);

my $droplets = $do->droplets;
for my $droplet (@{$droplets}) {
    print Dumper $droplet->name;
}

#if ( defined $create_droplet && 
#
#
#
#if ($verbose == 1){
#    print "hello\n";
#}
#
#sub show_help {
#    print "doman -create_droplet -img_id\n";
#}

