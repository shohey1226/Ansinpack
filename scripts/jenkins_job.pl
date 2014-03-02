use strict;
use warnings;

my $packer = "/usr/local/bin/packer";
my $rake = "/usr/bin/rake";
my $region_id = 6;
my $size_id = 66;
my $ssh_key_id = 87532;

# Branch name - origin/webapp-0.0.0/nginx-0.0.0 
my $branch = $ENV{GIT_BRANCH};
exit 0 if ($branch eq "origin/master"); #ignore master for now

$branch =~ s/^origin\///;
my @server_types = split /\//, $branch;

for my $server_type (@server_types){
    my ($type, $version) = split /-/, $server_type;
    print "$type : $version\n";
    if ( -e "packer/do-${type}.json"){
        my $result = system "$packer packer/do-${type}.json -var 'snapshot_name=${server_type}' ";
        if ($result == -1){
            print "Failed to execute packer\n";
            exit 1;
        }
    }
    else{
        print  "packer/do-${type}.json doesn't exist\n";
        exit 1;
    }
    my $line = `scripts/doman.pl --show_my_image | grep $server_type`;
    $line =~ /id:(\S+)/;
    my $image_id = $1;
    unless (defined $image_id){
        print "image ID is not found\n";
        exit 1;
    }
    my $result = system "scripts/doman.pl --create_droplet -size_id $size_id -region_id $region_id -image_id $image_id -droplet_name $server_type -ssh_key_ids $ssh_key_id";
    if ($result == -1){
        print "doman.pl --create_droplet is failed\n";
        exit 1;
    }
    $line = `scripts/doman.pl --show_droplet | grep $server_type`;
    $line =~ /ip:(\S+)/;
    my $ip = $1;
    unless (defined $ip){
        print "droplet IP is not found\n";
        exit 1;
    }
    system "SERVER_TYPE=$type TARGET_HOST=$ip $rake SPEC_OPTS=\"--require ./tests/junit.rb --format JUnit --out results.xml\" tests/spec";
}
    
    

