## directory structure

- http://docs.ansible.com/playbooks_best_practices.html

* site.yml - include all infrastructure of this project
* production - inventory file which includes servers
* stage.yml - the setup for our landed host or CI hosts 
* roles - direcory includes the role for each server
  * common - common setup for server
    * tasks/main.yml - tasks such as adding user to the host 
    * handler/main.yml - notify calls this entry
    * templates/ -- tempalte module uses this
    * files/foo.sh -- files to copy over to the host or script to run on the host
    * vars/main.yml - variable for this role
  * ci - setup for continuous integration
