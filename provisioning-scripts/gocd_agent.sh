#!/bin/bash

echo "deb https://download.gocd.io /" | sudo tee /etc/apt/sources.list.d/gocd.list
curl -s https://download.gocd.io/GOCD-GPG-KEY.asc | sudo apt-key add -

apt-get install -y software-properties-common apt-transport-https

add-apt-repository -y ppa:webupd8team/java
apt-add-repository -y ppa:brightbox/ruby-ng
apt-get update

echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

apt-get install -y oracle-java8-installer \
  oracle-java8-set-default \
  go-agent \
  git-core \
  make \
  unzip

service go-agent stop

sed -i 's/^GO_SERVER_URL.*/GO_SERVER_URL=https:\/\/${go_server_url}:${go_server_actual_https_port}\/go/' /etc/default/go-agent

mkdir -m 0755 -p /var/lib/go-agent/config

cat > /var/lib/go-agent/config/autoregister.properties <<ENDCONFIG
agent.auto.register.key=${gocd_agent_key}
# agent.auto.register.resources=
agent.auto.register.environments=${environment}
# agent.auto.register.hostname=
ENDCONFIG
chown -R go:go /var/lib/go-agent

service go-agent start


# Install Terraform. And think about building our own AMI.
mkdir /tmp/terraform
cd /tmp/terraform
curl -Os https://releases.hashicorp.com/terraform/0.8.2/terraform_0.8.2_linux_amd64.zip
unzip -q terraform_0.8.2_linux_amd64.zip
rm terraform_0.8.2_linux_amd64.zip
cd /tmp
mv terraform /usr/local/
ln -s /usr/local/terraform/terraform /usr/local/bin/

# Install Ruby. And think some more about building an AMI.
apt-get install -y ruby2.3 ruby2.3-dev liblzma-dev zlib1g-dev
update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby2.3 10
update-alternatives --install /usr/bin/gem gem /usr/bin/gem2.3 10
echo "gem: --no-document" > /etc/gemrc
gem install bundler
