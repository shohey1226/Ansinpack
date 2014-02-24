Ansipack 
=========

## Discription

Ansipack is a system design for immutable infrastructure with Packer and Ansible.

## Flow 

 1. Push Github
 2. Jenkins job runs by Github hook
 3. git clone this repo
 4. Execute scripts/jenkins.pl by the Jinkins's job
 5. In the job, run packer to create images provisioning by Ansible
 6. In the job, bring up the image
 7. severspec to test
 8. With result, leave the image or destroy the image

## Directory structure

```
 / 
   provision/ # ansible root
      production # inventory file
      roles/
        perl-5_18_2-system/ # include version and brief explanation
          tasks/main.yml # this is followed ansible best practice
          handlers/
          ...
      src/ 
        webapp-VERSON.yml # playbook with version - e.g. webapp-0.1.yml
        ...
      webapp.yml # symlink to src/webapp-VERSION.yml t point to the latest
      stage.yml # to provision staging sever, which is not done by packer
      ...
    packer/
      # do:DigitalOcean vb:Virtualbox
      do-webapp.json # symlink from src/webapp-VERSION.json 
      vb-webapp.json # 
      src/
        webapp-VERSION.json
    scripts/
      doman # DigitalOcean MANipulator 
      jenkins.pl # jenkins job to run
      packer_wrapper.pl # we may need this.. 
```


      
