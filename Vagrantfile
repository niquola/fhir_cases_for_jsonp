# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "base"

  if `vagrant plugin list | grep 'lxc'` =~ /lxc/
    config.vm.box_url = "http://dl.dropbox.com/u/13510779/lxc-precise-amd64-2013-07-12.box"
  else
    config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"
  end

  config.vm.provision :shell, path: "provision.sh"
  config.vm.network "forwarded_port", guest: 5432, host: 5435
end
