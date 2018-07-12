# UCSM Docker Image

This docker image is provides contains all required packages to run UCS Manager Ansible playbooks against remote nodes.
The container was originally created to overcome managing dependencies within environments without internet access.

####Using the container

The container entrypoint is the ansible-playbook command, allowing additional Ansible arguments to be passed at run time.

I have not found a need to persist the container after running a playbook, as such I always run it with the --rm flag.

If you're using paths within ansible.cfg for settings such as library, remember that the path is local within the context of the running container.
On run the below command on a docker host


```docker pull sdbrett\ucsm-ansible ```

Example commands

Running from within an Ansible playbook directory

``` docker run --rm \
    -v $(pwd):/ansible/playbooks \
    -it sdbrett\ucsm-ansible 
    -i inventory site.yml 
```

Running when external to Ansible playbook directory

``` docker run --rm \
    -v /usr/share/my-ucsm-playbook:/ansible/playbooks \
    -it sdbrett\ucsm-ansible \
    -i inventory site.yml \
    --check 
```

Run with custom hosts file

``` docker run --rm \
    -v $(pwd):/ansible/playbooks \
    -v $(pwd)/hosts:/etc/hosts \
    -it sdbrett\ucsm-ansible \
    -i inventory site.yml 
```

Using external library path

``` docker run --rm \
    -v $(pwd):/ansible/playbooks \
    -v $(pwd)/library:/usr/share/ansible/library \
    -it sdbrett\ucsm-ansible \
    -i inventory site.yml 
```

# UCS Projects

[ucsm-ansible](https://github.com/CiscoUcs/ucsm-ansible)

[ucsm_apis](https://github.com/CiscoUcs/ucsm_apis)
