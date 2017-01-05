#!/bin/bash

echo "deb https://download.gocd.io /" | sudo tee /etc/apt/sources.list.d/gocd.list
curl -s https://download.gocd.io/GOCD-GPG-KEY.asc | sudo apt-key add -
apt-get update
apt-get install go-server -y
service go-server stop

cat > /etc/go/cruise-config.xml <<ENDCONFIG
<?xml version="1.0" encoding="utf-8"?>
<cruise xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="cruise-config.xsd" schemaVersion="87">
<server artifactsdir="artifacts"
    agentAutoRegisterKey="${gocd_agent_key}" 
    commandRepositoryLocation="default"
    serverId="" />
  <config-repos>
    <config-repo plugin="yaml.config.plugin">
      <git url="${git_repo_url}" />
    </config-repo>
  </config-repos>
</cruise>
ENDCONFIG
cp /etc/go/cruise-config.xml /etc/go/cruise-config.xml.debug
chown go:go /etc/go/cruise-config.xml*

( 
  cd /var/lib/go-server/plugins/external
  curl -sLO https://github.com/tomzo/gocd-yaml-config-plugin/releases/download/0.4.0/yaml-config-plugin-0.4.0.jar
)
chown go:go /var/lib/go-server/plugins/external/yaml-config-plugin-*.jar

service go-server start

apt-get install git-core
