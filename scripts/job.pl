use strict;
use warnings;
use JSON::PP;
use FindBin qw($Bin);
use Data::Dumper;

my $docker = "/usr/bin/docker";
my $packer = "/usr/local/bin/packer";
my $rake = "/usr/bin/rake";
my $doman = "$Bin/doman.pl";
my $ansible = "/usr/bin/ansible-playbook";

if ($ENV{GIT_COMMIT} eq '' || $ENV{GIT_BRANCH} eq '' ){
    die "Both GIT_COMMIT and GIT_BRANCH should exist\n";
}

# first 7 digits of commit#
my $git_commit = substr ($ENV{GIT_COMMIT}, 0, 7);

#-----------------------------------------------
# Branch name - origin/{base,webapp,nginx,,,}
#-----------------------------------------------
my $branch = $ENV{GIT_BRANCH};
print "Working on $branch ...\n";


###-------------------------------------------
### Make sure that docker registry is running
###-------------------------------------------
##my $registry_container_id = `$docker ps | grep registry | awk '{print \$1}'`;
##if ($registry_container_id eq ''){
##    print "Bring up docker registry..\n";
##    system ("$docker run -d -p 5000:5000 -v /tmp/registry:/tmp/registry registry");
##}

if ($branch eq "origin/master"){
    run_master_process();
}else{
    $branch =~ s/^origin\///;
    $branch =~ s/\/(\S+)$//;
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

    my $user = $ENV{USER};

    my $base_image_repo = "$user/base";
    my $base_image_id = `$docker images | grep $base_image_repo | grep latest | awk '{print \$3}'`;
    chomp $base_image_id;

    my $epoch = time();
    my $image_name = $type . $epoch . '-' . $git_commit . '.img';
    my $cmd;

    if ($type eq 'base'){
        # Create image file using Packer 
        $cmd = "$packer build -var 'image_name=/tmp/$image_name' packer/docker-${type}.json";
        print "Execute: $cmd \n";
        system($cmd) == 0 or die "Failed to execute: $cmd\n"; 

        # if the latest exsits,  tag current $user/base:latest to $user/base:$epoch 
        if ($base_image_id ne ''){
            $cmd = "$docker tag $base_image_id ${base_image_repo}:${epoch}";
            print "Execute: $cmd\n";
            system($cmd) == 0 or die "Failed to execute: $cmd\n";  
        }

        # Create docker image
        $cmd = "$docker import - ${base_image_repo} < /tmp/$image_name";
        $base_image_id = `$cmd`; 
        die "Failed to execute: $cmd" if ($base_image_id eq ''); 

        # Run the image 
        $cmd = "$docker run -d --name base${epoch}-${git_commit} -p 2222:22 ${base_image_repo}:latest /usr/sbin/sshd -D";
        my $container_id = `$cmd`;
        die "Failed to execute : $cmd" if ($container_id eq '');

        # Run test
        chdir "tests/$type";
        $cmd = "./run.sh";
        print "chdir to tests/$type and execute: $cmd\n";
        if (system($cmd) == 0){

            $cmd = "$docker stop $container_id";
            print $cmd , "\n";
            system($cmd) == 0 or die "Failed to execute: $cmd\n";  

            # destroy container and image 
            $cmd = "$docker rm $container_id";
            print $cmd , "\n";
            system($cmd) == 0 or die "Failed to execute: $cmd\n";  

            exit 0; # exit successfully 

        }else{
            # stop container
            $cmd = "$docker stop $container_id";
            print $cmd , "\n";
            system($cmd) == 0 or die "Failed to execute: $cmd\n";  

            # destroy container and image 
            $cmd = "$docker rm $container_id";
            print $cmd , "\n";
            system($cmd) == 0 or die "Failed to execute: $cmd\n";  

            $cmd = "$docker rmi $base_image_id";
            print $cmd , "\n";
            system($cmd) == 0 or die "Failed to execute: $cmd\n";  
            exit 1;
        }
    }else{
        # find latest container
        $cmd = "$docker run -d --name ${type}${epoch}-${git_commit} -p 2222:22 ${base_image_repo}:latest /usr/sbin/sshd -D";
        print $cmd, "\n";
        my $container_id = `$cmd`;
        if ($container_id eq ''){
            print "Please create base image first\n";
            exit 1;
        }

        # executing Ansible
        $cmd = "ANSIBLE_CONFIG=ansible/ansible.cfg $ansible -i 'localhost:2222,' ansible/${type}.yml";
        print $cmd, "\n";
        system($cmd) == 0 or die "Failed to execute: $cmd\n";  

       chdir "tests/$type" or die "Can't cd to tests/${type}: $!\n";
       $cmd = "./run.sh";
       print "chdir to tests/$type and execute: $cmd\n";
       if (system($cmd) == 0){
            # stop container
            $cmd = "$docker stop $container_id";
            print $cmd , "\n";
            system($cmd) == 0 or die "Failed to execute: $cmd\n";  
            exit 0;
       }else{
            # stop container
            $cmd = "$docker stop $container_id";
            print $cmd , "\n";
            system($cmd) == 0 or die "Failed to execute: $cmd\n";  

            # destroy container and image 
            $cmd = "$docker rm $container_id";
            print $cmd , "\n";
            system($cmd) == 0 or die "Failed to execute: $cmd\n";  
       }
        
    }
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
    
    

