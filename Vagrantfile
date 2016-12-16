# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.define "gocd" do |gocd|

    gocd.vm.box = 'kief/infra-workbox'
    gocd.vm.hostname = 'gocd'

    gocd.ssh.username = "vagrant"
    gocd.ssh.password = "vagrant"
    gocd.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    gocd.vm.synced_folder ".", "/vagrant", disabled: false
    gocd.vm.synced_folder '.', '/home/vagrant/projects', disabled: false

    gocd.vm.provision 'shell', path: 'vagrant-provisioning-scripts/setup-aws.sh',
      privileged: false
    gocd.vm.provision 'shell', path: 'vagrant-provisioning-scripts/setup-ssh-key.sh',
      privileged: false

    gocd.vm.provider "virtualbox" do |vb|
      vb.name = 'gocd'
      vb.cpus = 1
      vb.memory = 1024
      # vb.gui = true
    end

  end

end
