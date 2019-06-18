# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Author     : Gaston Gonzalez
# Date       : 17 May 2019
# Updated    : 13 June 2019
# Description: Vagrantfile for Kubernetes 
#
KUBERNETES_WORKERS=2

Vagrant.configure("2") do |config|
  
  config.vm.box = "bento/ubuntu-18.04"

  config.vm.provider "virtualbox" do |vb, override|
    vb.gui = false
    vb.memory = 2048
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"] 
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.define "k8smaster" do |k8smaster|
    k8smaster.vm.hostname = 'k8smaster'
    k8smaster.vm.network :private_network, ip: "192.168.9.10"
  end

  (1..KUBERNETES_WORKERS).each do |i|
    config.vm.define "k8sworker#{i}" do |k8sworker|
      k8sworker.vm.hostname = "k8sworker#{i}"
      k8sworker.vm.network :private_network, ip: "192.168.9.#{i + 10}"

      k8sworker.vm.provider "virtualbox" do |vb, override|
        vb.memory = 2048
      end
    end
  end

end
