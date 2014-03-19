Ansinpack : An image creation framework for Immutable Infrastructure with Ansible and Packer
=========

## What is Ansinpack? 

[Immutable infrastructure/servers or disposable infrastructure/servers](http://chadfowler.com/blog/2013/06/23/immutable-deployments/) is the recent topic in cloud era.
To realize immutable infra, we need two things.

1. Create images for cloud service
2. Deploy the images (or instantiate the images) on the cloud

Ansinpack handles "1. Create images" using Anible and Packer. 

_Note: The name comes from ANSIble aNd PACKer. Also Ansin(安心) means 'feel safe' in Japanese. 
Hope that this flow provides a package for infrastructure engineer to feel safe:)_

One more important thing is that we need to know the state of the image. For example, we should know what's inside in the image without logging to host(instance). -- "Infrastructure as Code" is the key concept of this. Ansible is used to make this happen.  Ansible is easy to use, comparing to Chef/Puppet.


## How is Ansinpack implemented? 

There are the mixture of systems/tools as following:

   * Github : Repo to have all Github flow 
   * Jenkins : CI and hook for github
   * Ansible : provisioner 
   * Packer : Image creator
   * Docker : Instance for branch : quick test
   * Serverspec : testing instance

#### Brief flow explanation

 1. Push to Github
 2. Jenkins runs a job with Github hook
 3. When branch is not master, then create docker image and test its instance
  1. Success - keep the image
  2. Fail - destory image
 4. When branch is master, then create vendor image(like DigitalOcean) and test its instance
  1. Success - keep the image
  2. Fail - destory image

### Diagram



### Flow chart to see the details


1.	User git push 
2.	Jenkins hook notices the branch change, and run batch
3.	The batach create docker image by packer and ansible
4.	The docker image is instantiated and tested by Serverspec
5.	If fail, delete the image
6.	If success, it’s ready to merge to master branch
7.	If master branch is merged, create vendor image with packer and ansible
8.	Instantiate isamge and serverspec test it.
9.	If failed, delelte image
10.	If sucesss, you have the image
 

### Naming convention of image

TYPE + Epoch Time + '-' + GIT_COMMIT(first 7 digits) 

e.g. webapp1394493444-e7c9e38, db13944933244-ac8038a

As epoch time is inside of the name, you can see when the image is created. Also easy to sort or get the latest one.
```
$ date -d @1394493444 +'%Y/%m/%d/%H:%M'
```
As commit# is inside, you can see the file contents at the revision.
```
$ git show e7c9e38:ansible/webapp.yml
```

### Directory structure

TYPE needs to be the same string.

```
 / 
   ansible/ # ansible root
      production # inventory file
      roles/
        perl-5_18_2-system/ # include version and brief explanation
          tasks/main.yml # this is followed ansible best practice
          handlers/
          ...
        adduser/
        ...
      landing.yml # Landing host which Jenkins runs to create image - required
      base.yml  # base image that is used for TYPE image - required
      TYPE.yml  # e.g. webapp.yml, database.yml or others. this is created on base image.
      webapp.yml # 
      ...
    packer/
      # do:DigitalOcean docker:Docker
      do-TYPE.json # create image from base.yml and TYPE.yml 
      docker-base.json # docker image creation using base.yml
      ...
    scripts/
      doman.pl # DigitalOcean MANipulator 
      jenkins_job.pl # jenkins job to run
    tests/
      TYPE/  # see below webapp for an example
      webapp/
        run.sh # executed by jenkins_job.pl for the Serverspec test
        Rakefile
        spec/
          roles/*_spec.rb  # test is here
. 
```

## How to install

### 1 Fork Ansinpack from Github 

This is to set up your infrastructure as Code(controlled by Github)

### 2 Build a landing host

Jenkins, Packer, Docker, Ansible and other packages needs to be installed on the landing host in order to create image on the host. Run the following command agaist the landing host.

```
 $ cd Ansinpack/ansible
 # assume the landing host is Centos. You may need to change ansible roles
 $ ansible-playbook -i 'LANDING_HOST,' landing.xml  
```

### 3 Set up Jenkins hook and job

See here.

### 4 Create Docker base image

The base image makes us install and test faster becuase Docker container can start really quickly.
As we are using github hook, create the branch named 'base/description'. 'base' is required.

```
$ git checkout –b base/first_test  # you can use '/' to put comment
```

Then, edit base.xml to have necessary packages.

```
 # some updates like below
 $ vi base.xml
 # Create role if you need
 $ vi roles/new_role/tasks/main.xml
 $ git add . 
 $ git commit 
 $ git push origin base/first_test
```

`github push orign base/first_test` kicks scritps/jenkins_job.pl by Jenkins Github hook.
The job crate base image for you. Once the image created proplery, you see the image 

```
 (landing_host)$ docker images | grep base
```

### 5 Create TYPE image on the base image

Type can be webapp, database or others that you want to build the server.
If you want to create webapp,  ansible/weapp.xml, tests/webapp/* and packer/do-webapp.json are needed.

As the same as creating base, 

```
$ git checkout –b webapp/now_first_test  # you can use '/' to put comment
# work on the provisioner config and tests
$ git push origin webapp/now_first_test
```

This creates Docker container from Docker base image. And run ansible_play to the docker container and it's tested by Serverspec. Once it's succeeded, you should see the below

```
 (landing_host) $ docker ps -a | grep webapp
```

### 6 Create vendor (AWS, DistalOcean or others) image 

Ok, webapp on docker is ok now. let's create the image on vendor, like on digitalocean.
This is done by simply merge the pull request of the above branches.

```
 $ git checkout webapp/now_fist_test
 $ git rebase -i # compress comit
 $ git push webapp/now_fist_test
```

Go to Github, then pull request of the branch. After merge this, it push to origin/master, which initiated jenkins_job.pl for master to create vendor image

If you are working on DigitalOcean, you can see the new image created on the web gui or run the below commands.

```
 (landing_host)$ scripts/doman.pl --show_my_image
```
      
