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
my $show_droplet=undef;
my $show_snapshot=undef;
my $show_size=undef;
my $show_region=undef;
my $destroy_snapshot=undef;
my $destroy_droplet=undef;
my $image_id=undef;
my $size_id=undef;
my $region_id=undef;
my $droplet_id=undef;
my $droplet_name=undef;

my $options_okay = GetOptions (
    'client_id=s'       => \$client_id,  
    'api_key=s'         => \$api_key,  
    'create_droplet'    => \$create_droplet,
    'show_droplet'    => \$show_droplet,
    'show_size'    => \$show_size,
    'show_region'    => \$show_region,
    'show_snapshot'    => \$show_snapshot,
    'destroy_snapshot' => \$destroy_snapshot,
    'destroy_snapshot' => \$destroy_snapshot,
    'destroy_snapshot' => \$destroy_snapshot,
    'destroy_droplet' => \$destroy_droplet,
    'image_id=s' => \$image_id, 
    'region_id=s' => \$region_id, 
    'size_id=s' => \$size_id, 
    'droplet_id=s' => \$droplet_id, 
    'droplet_name=s' => \$droplet_name, 
    'verbose'           => \$verbose,  
    'help'              => \$help,  
);


if (defined $help ){
    show_help();
}

if ( ! defined $client_id || ! defined $api_key ) {
    show_help();
}

my $do = DigitalOcean->new(
    client_id=> $client_id, 
    api_key => $api_key, 
    wait_on_events => 1
);

if (defined $show_droplet) {
    my $droplets = $do->droplets;
    for my $droplet (@{$droplets}) {
        print $droplet->name . " " . $droplet->id . " " . $droplet->ip_address, "\n";
    }
}
elsif (defined $show_snapshot) {
    my $images = $do->images;
    for my $image (@{$images}) {
        print $image->name . " " . $image->id . "\n";
    }
}
elsif (defined $show_region){
    my $regions = $do->regions;
    for my $region (@{$regions}) {
        print $region->name . " " . $region->id . "\n";
    }
}
elsif (defined $show_size){
    my $sizes = $do->sizes;
    for my $size (@{$sizes}) {
        print $size->name . " " . $size->id . "\n";
    }
}
elsif (defined $destroy_snapshot && defined $image_id ) {
    my $image = $do->image($image_id);
    $image->destroy;
    print "image(id=$image_id) has been destroyed\n";
}
elsif (defined $destroy_droplet && defined $droplet_id ) {
    my $droplet = $do->droplet($droplet_id);
    $droplet->destroy;
    print "droplet(id=$droplet_id) has been destroyed\n";
}
elsif ( defined $create_droplet && defined $image_id && defined $droplet_name && defined $size_id && defined $region_id){
    my $new_droplet = $do->create_droplet(
        name => $droplet_name, 
        size_id => $size_id,
        image_id => $image_id,
        region_id => $region_id,
    );
    print $new_droplet->name . "is just created\n";
}
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

