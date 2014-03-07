use strict;
use warnings;
use JSON::PP;
use FindBin qw($Bin);
use Data::Dumper;

my $packer = "/usr/local/bin/packer";
my $rake = "/usr/bin/rake";
my $doman = "$Bin/doman.pl";

#-----------------------------------------------
# Branch name - origin/webapp-0.0.0/nginx-0.0.0 
#-----------------------------------------------
my $branch = $ENV{GIT_BRANCH};
print "Working on $branch ...\n";
exit 0 if ($branch eq "origin/master"); #ignore master for now

#--------------------------------------------------
# Get all sshkeys that are loaded on DisgitalOcean
# These keys is to be used for VM's root
#--------------------------------------------------
my @ssh_key_ids;
for my $line (split /\n/, `$doman --show_ssh_key`) {
    if ($line =~ /id:(\d+)/) {
        push @ssh_key_ids, $1;
    }
}
my $ssh_key_id = join ',', @ssh_key_ids; 
print "SSH Key IDs: $ssh_key_id \n";

$branch =~ s/^origin\///;
my @server_types = split /\//, $branch;

for my $server_type (@server_types){
    my ($type, $version) = split /-/, $server_type;
    print "$type : $version\n";

    my $region_id = 6;
    my $size_id = 66;
    my $packer_json_file = "$Bin/../packer/do-${type}.json";
    if ( -e $packer_json_file ){

        #------------------------------------------------------
        # Load do-packer.json fie to get region_id and size_id 
        # Note that this value is not actually used for deployment
        # but it's used for building and its test
        #------------------------------------------------------
        local $/;
        open( my $fh, "<", $packer_json_file) or die "can't open $packer_json_file: $!";
        my $json_text = <$fh>;
        my $ref = decode_json $json_text;
        $size_id = $ref->{builders}[0]->{size_id};
        $region_id = $ref->{builders}[0]->{region_id};

        # Validate packer.json
        my $cmd = "$packer validate -var 'snapshot_name=${server_type}' packer/do-${type}.json";
        print "Execute: $cmd\n";
        my $result = system $cmd;
        if ($result != 0 ){
            print "Failed to validate pcaker/do-${type}.json\n";
            exit 1;
        }

        # OK, now it's time to create image by packer
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

    my $line = `$doman --show_my_image | grep $server_type`;
    $line =~ /id:(\S+)/;
    my $image_id = $1;
    unless (defined $image_id){
        print "ERROR: image ID is not found\n";
        exit 1;
    }
    my $cmd = "$doman --create_droplet -size_id $size_id -region_id $region_id -image_id $image_id -droplet_name $server_type -ssh_key_ids $ssh_key_id";
    print "Execute: $cmd\n";
    my $result = system $cmd; 
    if ($result != 0 ){
        print "doman.pl --create_droplet is failed\n";
        exit 1;
    }
    $line = `$doman --show_droplet | grep $server_type`;
    $line =~ /ip:(\S+)/;
    my $ip = $1;
    unless (defined $ip){
        print "ERROR: droplet IP is not found\n";
        exit 1;
    }
    $line =~ /id:(\d+)/;
    my $droplet_id = $1;

    print "cd tests\n";
    chdir "tests";
    $cmd = "SERVER_TYPE=$type TARGET_HOST=$ip $rake SPEC_OPTS=\"--require junit.rb --format JUnit --out results.xml\" spec";
    print "Execute: $cmd\n";
    $result  = system $cmd;  
    if ($result != 0 ){
        print "Error: Failed to execute rake for serverspec\n";
        print "Destroying droplet(id=$droplet_id)..\n";
        system "$doman --destroy_droplet -droplet_id $droplet_id"; 
        exit 1;
    }
}
    
    

