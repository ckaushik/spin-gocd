#!/bin/bash

echo "deb https://download.gocd.io /" | sudo tee /etc/apt/sources.list.d/gocd.list
curl -s https://download.gocd.io/GOCD-GPG-KEY.asc | sudo apt-key add -
apt-get update
apt-get install go-agent -y
apt-get install git-core -y

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

