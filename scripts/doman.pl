#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;
use DigitalOcean;

my $client_id = $ENV{DIGITALOCEAN_CLIENT_ID};
my $api_key = $ENV{DIGITALOCEAN_API_KEY};
my $verbose = undef;
my $help = undef;
my $create_droplet=undef;
my $show_droplet=undef;
my $show_my_image=undef;
my $show_size=undef;
my $show_region=undef;
my $destroy_image=undef;
my $destroy_droplet=undef;
my $image_id=undef;
my $size_id=undef;
my $region_id=undef;
my $droplet_id=undef;
my $droplet_name=undef;
my $show_ssh_key=undef;
my $ssh_key_ids=undef;

my $options_okay = GetOptions (
    'client_id=s'       => \$client_id,  
    'api_key=s'         => \$api_key,  
    'create_droplet'    => \$create_droplet,
    'show_droplet'    => \$show_droplet,
    'show_size'    => \$show_size,
    'show_region'    => \$show_region,
    'show_my_image'    => \$show_my_image,
    'show_ssh_key'    => \$show_ssh_key,
    'destroy_image' => \$destroy_image,
    'destroy_droplet' => \$destroy_droplet,
    'image_id=s' => \$image_id, 
    'region_id=s' => \$region_id, 
    'ssh_key_ids=s' => \$ssh_key_ids,
    'size_id=s' => \$size_id, 
    'droplet_id=s' => \$droplet_id, 
    'droplet_name=s' => \$droplet_name, 
    'verbose'           => \$verbose,  
    'help'              => \$help,  
);


if (defined $help || (! defined $client_id || ! defined $api_key) ){
    show_help();
}

my $do = DigitalOcean->new(
    client_id=> $client_id, 
    api_key => $api_key, 
    wait_on_events => 1
);

if (defined $show_droplet) {
    my $droplets = $do->droplets;
    print "no droplet found\n" if (scalar @{$droplets} == 0);
    for my $droplet (@{$droplets}) {
        print "name:" . $droplet->name . "\tid:" . $droplet->id . "\tip:" . $droplet->ip_address, "\n";
    }
}
elsif (defined $show_my_image) {
    my $images = $do->images;
    for my $image (@{$images}) {
        #print Dumper $image;
        next if($image->{public} == 1);
        print "name:" . $image->name . "\tid:" . $image->id . "\n";
    }
}
elsif (defined $show_region){
    my $regions = $do->regions;
    for my $region (@{$regions}) {
        print "name:" . $region->name . "\tid:" . $region->id . "\n";
    }
}
elsif (defined $show_size){
    my $sizes = $do->sizes;
    for my $size (@{$sizes}) {
        print "name:" . $size->name . "\tid:" . $size->id . "\n";
    }
}
elsif (defined $show_ssh_key){
    my $ssh_keys = $do->ssh_keys;
    for my $ssh_key (@{$ssh_keys}) {
        print "name:" . $ssh_key->name . "\tid:" . $ssh_key->id . "\n";
    }
}
elsif (defined $destroy_image && defined $image_id ) {
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
    my @param = (
        name => $droplet_name, 
        size_id => $size_id,
        image_id => $image_id,
        region_id => $region_id,
    );
    push @param, (ssh_key_ids => $ssh_key_ids) if(defined $ssh_key_ids);
    my $new_droplet = $do->create_droplet(@param);
    print $new_droplet->name . "is just created\n";
}
else {
    show_help();
}

sub show_help {
    pod2usage();
    exit;
}


__END__

=head1 NAME

doman.pl - DigitalOcean Manipulator

=head1 SYNOPSIS

doman.pl [options] 

 Options:
   -help             brief help message
   --show_droplet    show all droplets
   --show_my_image   show none public image 
   --show_size       show all image size
   --show_region     show all region
   --show_ssh_key    show ssh key that you have 
   --destroy_droplet destroy droplet
   --destroy_image   destroy image
   --create_droplet  create_droplet

   # the below parameter is used to specify image or etc.
   # plese take a look at the below example
   -droplet_id       
   -size_id
   -image_id
   -ssh_key_ids

 Example:
   # show droplet that you have
   $ doman.pl --show_droplet 

   # show images that you have 
   $ doman.pl --show_my_image 

   # show size ids and region
   $ doman.pl --show_size 
   $ doman.pl --show_region 

   # create droplet. -ssh_key_ids is optional
   $ doman.pl --create_droplet -size_id 66 -region_id 6 -image_id 111 -droplet_name mydroplet1 -ssh_key_ids 12345

   # destroy droplet and image 
   $ doman.pl --destroy_droplet -droplet_id 11111
   $ doman.pl --destroy_image -image_id 2474933

=head1 OPTIONS

=over 8 

=item B<-help>

=back

=head1 DESCRIPTION

doman.pl manipulates DigitalOcean with DigitalOcean module.

=cut
