use strict;
use warnings;

my $packer = "/usr/local/bin/packer";
my $rake = "/usr/bin/rake";
my $region_id = 6;
my $size_id = 66;
my $ssh_key_id = "87532,90025";

# Branch name - origin/webapp-0.0.0/nginx-0.0.0 
my $branch = $ENV{GIT_BRANCH};
print "Working on $branch ...\n";
exit 0 if ($branch eq "origin/master"); #ignore master for now

$branch =~ s/^origin\///;
my @server_types = split /\//, $branch;

for my $server_type (@server_types){
    my ($type, $version) = split /-/, $server_type;
    print "$type : $version\n";
    if ( -e "packer/do-${type}.json"){
        my $cmd = "$packer validate -var 'snapshot_name=${server_type}' packer/do-${type}.json";
        print "Execute: $cmd\n";
        my $result = system $cmd;
        if ($result != 0 ){
            print "Failed to validate pcaker/do-${type}.json\n";
            exit 1;
        }
        $cmd = "$packer build -var 'snapshot_name=${server_type}' packer/do-${type}.json";
        print "Execute: $cmd\n";
        $result = system $cmd; 
        if ($result != 0){
            print "Failed to execute packer\n";
            exit 1;
        }
    }
    else{
        print  "ERROR: packer/do-${type}.json doesn't exist\n";
        exit 1;
    }
    my $line = `scripts/doman.pl --show_my_image | grep $server_type`;
    $line =~ /id:(\S+)/;
    my $image_id = $1;
    unless (defined $image_id){
        print "ERROR: image ID is not found\n";
        exit 1;
    }
    my $cmd = "scripts/doman.pl --create_droplet -size_id $size_id -region_id $region_id -image_id $image_id -droplet_name $server_type -ssh_key_ids $ssh_key_id";
    print "Execute: $cmd\n";
    my $result = system $cmd; 
    if ($result != 0 ){
        print "doman.pl --create_droplet is failed\n";
        exit 1;
    }
    $line = `scripts/doman.pl --show_droplet | grep $server_type`;
    $line =~ /ip:(\S+)/;
    my $ip = $1;
    unless (defined $ip){
        print "ERROR: droplet IP is not found\n";
        exit 1;
    }
    print "cd tests\n";
    chdir "tests";
    $cmd = "SERVER_TYPE=$type TARGET_HOST=$ip $rake SPEC_OPTS=\"--require junit.rb --format JUnit --out results.xml\" spec";
    print "Execute: $cmd\n";
    $result  = system $cmd;  
    if ($result != 0 ){
        print "Error: Failed to execute rake for serverspec\n";
        exit 1;
    }
}
    
    

