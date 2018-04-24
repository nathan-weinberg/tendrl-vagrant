# Tendrl/api development with Vagrant

A Vagrant setup for development of tendrl-api.

This will setup as many gluster storage nodes as you want with a number of bricks that you can define!
It works with your local tendrl-api server and tendrl-ui setup.
It uses vagrant's ansible plugin, so you will need ansible (>=2.4) on your host machine.

## Requirements
* macOS with [Virtualbox](https://www.virtualbox.org/wiki/Downloads) (starting 5.1.30) **or**
* RHEL 7.4/Fedora 27 with KVM/libvirt
* [Ansible](https://ansible.com) (starting 2.4.0.0)
* [Vagrant](https://www.vagrantup.com) (starting 1.9.1)
* git

## Installation instructions for Vagrant / Ansible

#### On RHEL 7.4

* make sure you are logged in as a user with `sudo` privileges
* make sure your system has the following repositories enabled (`yum repolist`)
  * rhel-7-server-rpms
  * rhel-7-server-extras-rpms
* install the requirements
  * `sudo yum groupinstall "Virtualization Host"`
  * `sudo yum install ansible git gcc libvirt-devel`
  * `sudo yum install https://releases.hashicorp.com/vagrant/2.0.1/vagrant_2.0.1_x86_64.rpm`
* start `libvirtd`
  * `sudo systemctl enable libvirtd`
  * `sudo systemctl start libvirtd`
* enable libvirt access for your current user
  * `sudo gpasswd -a $USER libvirt`
* as your normal user, install the libvirt plugin for vagrant
  * `vagrant plugin install vagrant-libvirt`

#### On Fedora 27

* make sure you are logged in as a user with `sudo` privileges
* make sure your system has the following repositories enabled (`dnf repolist`)
  * fedora
  * fedora-updates
* install the requirements
  * `sudo dnf install ansible git gcc libvirt-devel libvirt qemu-kvm`
  * `sudo dnf install vagrant vagrant-libvirt`
* start `libvirtd`
  * `sudo systemctl enable libvirtd`
  * `sudo systemctl start libvirtd`
* enable libvirt access for your current user
  * `sudo gpasswd -a $USER libvirt`
* as your normal user, install the libvirt plugin for vagrant
  * `vagrant plugin install vagrant-libvirt`

#### On macOS High Sierra

* install the requirements
  * install [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
  * install [Vagrant](https://www.vagrantup.com)
  * install [homebrew](https://brew.sh/)
  * install git
    * `brew install git`
  * install ansible
    * `brew install ansible`

## Get started
* Clone this repository
  * `git clone https://github.com/shirshendu/tendrl-vagrant.git`
* Goto the folder in which you cloned this repo
  * `cd tendrl-vagrant`
* if you are a returning user run `git pull` to ensure you have the latest updates
* if you are on RHEL/Fedora and your don't want your libvirt storage domain `default` to be used, override the storage domain like this
  * `export LIBVIRT_STORAGE_POOL=images`
* `cp tendrl.conf.yml.sample tendrl.conf.yml`
  * Decide how many storage nodes and how many bricks you need
  * Decide if you want vagrant to initialize the cluster (`gdeploy`) for you
  * If you opted to initialize the cluster, decide whether you want to deploy tendrl
  * edit options in this file
* Run `vagrant up`
  * Wait a while

## Usage
* *Always make sure you are in the git repo - vagrant only works in there!*
* After `vagrant up` you can connect to each VM with `vagrant ssh` and the name of the VM you want to connect to
* The single central server VM is called `tendrl-server`
* Each storage node VM is called `tendrl-node-x` where x starts with 1
  - tendrl-node-1 is your first VM and it counts up depending on the amount of VMs you spawn
* If you get the following error:

`Error while activating network: Call to virNetworkCreate failed: error creating bridge interface virbr0: File exists.`

Please try restarting `libvirtd` with `sudo systemctl restart libvirtd`

* There are also other vagrant commands you should check out!
  * if you want to throw away everything: `vagrant destroy -f`
  * if you want to freeze the VMs and continue later: `vagrant suspend`
  * Try `vagrant -h` to find out about them
  * if you run `vagrant up` again you without running `vagrant destroy` before you will overwrite your configuration and vagrant may loose track of some VMs (it's safe to remove them manually)
* modify the `VMMEM` and `VMCPU` variables in the Vagrant file to change the VM resources, adjust `VMDISK` to change brick device sizes

## What happens under the covers
* After starting the storage node VMs:
  * the hosts file is prepopulated
  * all glusters packages are pre-installed (allows you to continue offline)
  * the centos images are subscribed to epel, copr repositories 
* If you decided to have vagrant initialize the cluster
  * a gdeploy.conf is generated
  * gdeploy was executed with the gdeploy.conf file
  * cluster is peered
  * all block devices have been set up of VGs, LVs, formatted and mounted (`gdeploy`'s standard backend-setup)
  * brick directories have been created
* If you decided to deploy tendrl
  * tendrl-ansible roles are downloaded
  * an additional VM will run tendrl server components
  * the Ansible inventory and tendrl install playbook have been generated
  * the installation playbook has been executed on the Tendrl server and storage nodes
  * the Tendrl UI is reachable on the IP address of the eth1 adapter of the Tendrl VM (the URL also displayed after the installer finished)

## Clean up / Refresh images

If you like to clean up disk space or there are updates to the images do the following:

* on VirtualBox - remove the VM instances named `packer-tendrl-server-...` and `packer-tendrl-node-...` (these are base images for the clones)
* on libvirt
  * run `virsh vol-list default` to list all images in your `default` storage pool (adjust the name if you are using a different one)
  * run `virsh vol-delete tendrl-node-... default` and  `virsh vol-delete tendrl-server-... default` to delete the images starting with `tendrl-node-...` and `tendrl-server-...` (replace with full name) from the default pool
* run `vagrant box update`

Next time you do `vagrant up` it will automatically pull new images.

## Known issues
* `vagrant up` overrides your state - if there are still VMs running and you do `vagrant up` it will override the `vagrant_env.conf` and vagrant will loose track of your existing VMs
  * try to remember to run `vagrant destroy -f` before you do another `vagrant up`
  * delete left-over VMs manually in case you forgot

## Creating your own vagrant box
If you - for whatever reason - do not want to use my prebuilt box, you can create your own box very easy!  

**BEWARE** this is for advanced users only!

* Get [packer](https://www.packer.io/)
* `git checkout` the "packer" branch of this repository, follow the README

## Author
[Shirshendu Mukherjee](https://github.com/shirshendu)

## Original Authors
[Christopher Blum](https://github.com/zeichenanonym)

[Daniel Messer](mailto:dmesser@redhat.com) - [dmesser@redhat.com](mailto:dmesser@redhat.com) -
Technical Marketing Manager @ Red Hat
