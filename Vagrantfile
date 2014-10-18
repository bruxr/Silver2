# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Shell provisioning script which installs the stuff we
# need (e.g. postgres, redis, ruby) to run Silver.
$setup = <<SCRIPT
sudo -s
apt-get update -y
apt-get upgrade -y
apt-get install -y locales
locale-gen --purge en_US.UTF-8
echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale
apt-get install -y postgresql postgresql-client redis-server git libpqdev libsqlite3-dev curl
pg_createcluster 9.1 main
service postgresql restart
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/$bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
rbenv install 2.1.3
rbenv global 2.1.3
gem install bundler
rbenv rehash
curl -sL https://deb.nodesource.com/setup | bash -
apt-get install -y nodejs
cd /vagrant
git clone https://$USER:$PASSWORD@bitbucket.org/imoz32/silver2.git .
bundle
rbenv rehash
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  
  # Use Debian 7.4 "Wheezy"
  config.vm.box = "chef/debian-7.4"

  # Expose WEBrick's default port 3000
  config.vm.network "forwarded_port", guest: 3000, host: 3000

  # SSH connections made will enable agent forwarding.
  config.ssh.forward_agent = true

  # Limit the VM to 1 GB memory
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end
  
  # Run our setup script when provisioning
  config.vm.provision "shell", inline: $setup
  
end
