# -*- mode: ruby -*-
# vi: set ft=ruby :

# default_network_interface=`ip addr show | awk '/inet.*brd/{print $NF}'`.split(/\n+/)
default_network_interface=`ifconfig | awk '/UP/ && !/LOOPBACK/ && !/POINTOPOINT/ && !/docker/' | awk '{print substr($1, 1, length($1)-1)}'`.split(/\n+/)

require_relative './bootstrap'

Vagrant.configure("2") do |config|
   config.vm.provider "virtualbox" do |v|
     v.customize ["modifyvm", :id, "--cpus", "4"]
   end

  $config['ip'].each do | host_name, host_ip |
    config.vm.define "#{host_name}" do |node|
      node.vm.box = "bento/ubuntu-18.04"
      node.vm.hostname = "#{host_name}"
      node.ssh.insert_key=false
      #node.vm.network :private_network, ip: host_ip
      node.vm.network "public_network", bridge: default_network_interface
      node.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/#{host_name}.sh"), :args => node.vm.hostname
      
      node.vm.provider :virtualbox do |vb|
         vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
         vb.customize ["modifyvm", :id, "--memory", "4096"]
      end
    end
  end

end

