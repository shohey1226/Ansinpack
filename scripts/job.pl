use strict;
use warnings;
use JSON::PP;
use FindBin qw($Bin);
use Data::Dumper;

my $docker = "/usr/bin/docker";
my $packer = "/usr/local/bin/packer";
my $rake = "/usr/bin/rake";
my $doman = "$Bin/doman.pl";

# first 7 digits of commit#
my $git_commit = substr ($ENV{GIT_COMMIT}, 0, 7);

#-----------------------------------------------
# Branch name - origin/{base,webapp,nginx,,,}
#-----------------------------------------------
my $branch = $ENV{GIT_BRANCH};
print "Working on $branch ...\n";


#-------------------------------------------
# Make sure that docker registry is running
#-------------------------------------------
my $registry_container_id = `$docker ps | grep registry | awk '{print \$1}'`;
if ($registry_container_id eq ''){
    print "Bring up docker registry..\n";
    system ("$docker run -d -p 5000:5000 -v /tmp/registry:/tmp/registry registry");
}

if ($branch eq "origin/master"){
    run_master_process();
}else{
    $branch=~ s/^origin\///;
    run_branch_process($branch, $git_commit);
}

exit 0;

#==============================================
# Master 
#==============================================
sub run_master_process{
    # do nothing for now
    # create do iamge do-webapp 
    # and run test which should be the same as docker test
    exit 0;
}


#==============================================
# Branch 
#==============================================
sub run_branch_process{
    my ($type, $git_commit) = @_; 

    my $base_image_repo = 'localhost:5000/base';
    my $base_image_id = `$docker images | grep $base_image_repo | grep latest | awk '{print \$3}'`;

    # 
    # # find the current base image 
    # 
    # system "$docker pull $base_image"; 

    my $epoch = time();
    my $image_name = $type . $epoch . '-' . $git_commit . '.img';
    my $cmd;

    if ($type eq 'base'){
        # Create image file using Packer 
        $cmd = "$packer build -var 'image_name=/tmp/$image_name' packer/docker-${type}.json";
        print "Execute: $cmd \n";
        system($cmd) == 0 or die "Failed to execute: $cmd\n"; 

        # if the latest exsits,  tag current localhost:5000/base:latest to localhost:5000/base:$epoch 
        if ($base_image_id ne ''){
            $cmd = "$docker tag $base_image_id localhost:5000/base:$epoch";
            print "Execute: $cmd\n";
            system($cmd) == 0 or die "Failed to execute: $cmd\n";  
        }

        # Create docker image
        $cmd = "$docker import - localhost:5000/base < /tmp/$image_name";
        $base_image_id = `$cmd`; 
        die "Failed to execute: $cmd" if ($base_image_id eq ''); 

        # Run the image 
        $cmd = "$docker run -d --name base${epoch}-${git_commit} -p 2222:22 localhost:5000/base:latest /usr/sbin/sshd -D";
        my $container_id = `$cmd`;
        die "Failed to execute : $cmd" if ($container_id eq '');

        # Run test
        $cmd = "tests/$type/run.sh";
        print "Execute: $cmd\n";
        if (system($cmd) == 0){
            # push to the private repo
            $cmd = "$docker pull localhost:5000/base:latest";
            system($cmd) == 0 or die "Failed to execute: $cmd\n";  
            # stop container 
            $cmd = "$docker stop $container_id";
            system($cmd) == 0 or die "Failed to execute: $cmd\n";  
            exit 0;
        }else{
            # destroy container and image 
            $cmd = "$docker rm $container_id";
            system($cmd) == 0 or die "Failed to execute: $cmd\n";  
            $cmd = "$docker rmi $base_image_id";
            system($cmd) == 0 or die "Failed to execute: $cmd\n";  
            exit 1;
        }
    }else{
        # find latest container
        # if exists, start the container 
        # if not, check whether we have image or not,
        # if exsits, start the image,
        # if not, error saying "base is not found"
        
        # assume here, we have container is running,
        # run ansible-playbook 
        # ansible-playbook -i 'localhost:2222,' $type.yml
        # if failed, error
        # if not, run test
    }
    # check if base image exits
}




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
    
        # Delete image if the same name exists
        my $line = `$doman --show_my_image | grep $server_type`;
        if ($line =~ /id:(\d+)/){
            system "$doman --destroy_image -image_id $1";
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

    print "Removing /var/lib/jenkins/.ssh/known_hosts\n";
    system "/bin/rm -f /var/lib/jenkins/.ssh/known_hosts";

    sleep(15);

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
    
    

