#!/bin/bash

# Temporary hack due to DNS issues with go.cd (2016/12/24)
cat >> /etc/hosts <<ENDHOSTS
52.85.142.215   go.cd www.go.cd docs.go.cd
52.85.142.115   download.go.cd
52.85.142.251   api.go.cd
65.49.44.137    build.go.cd
ENDHOSTS

echo "deb https://download.go.cd /" | sudo tee /etc/apt/sources.list.d/gocd.list
curl -s https://download.go.cd/GOCD-GPG-KEY.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install go-server -y
