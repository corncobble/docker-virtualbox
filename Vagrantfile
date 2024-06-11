# -*- mode: ruby -*-

options = {}

Vagrant.configure("2") do |config|
    config.vm.box = "debian/bullseye64"
    config.vm.hostname = "docker-vagrant"
    config.vm.provision "bootstrap", type: "shell", path: "vagrant/bootstrap.sh", privileged: true, name: "bootstrap VM", env:options
    config.vm.provision "portainer", type: "shell", path: "vagrant/portainer.sh", privileged: true, name: "install Portainer CE", env:options
    config.vm.network "public_network"
    # Forward port for docker
    config.vm.network "forwarded_port", guest: 2375, host: 2375
    # Forward port for portainer
    config.vm.network "forwarded_port", guest: 9443, host: 9443

    config.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.memory = 4096
        vb.cpus = 2
        vb.name = "docker-vagrant"
    end
end
