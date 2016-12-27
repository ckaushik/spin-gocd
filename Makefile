
MY_IP=$(shell curl -s icanhazip.com)

all: plan

plan: *.tf ssh_keys get
	terraform plan -var allowed_ip=$(MY_IP) -var-file=my.tfvars

apply: terraform.tfstate

destroy: ssh_keys
	terraform destroy -force -var allowed_ip=$(MY_IP) -var-file=my.tfvars
	rm -f terraform.tfstate terraform.tfstate.backup
	rm -f .tmp/*_HOST

get:
	terraform get

test: apply .tmp/BASTION_HOST .tmp/GO_SERVER .tmp/GO_PUBLIC_HOST quick-test

quick-test: export BASTION_HOST = $(shell cat .tmp/BASTION_HOST)
quick-test: export GO_SERVER = $(shell cat .tmp/GO_SERVER)
quick-test: export GO_PUBLIC_HOST = $(shell cat .tmp/GO_PUBLIC_HOST)

quick-test: Gemfile.lock
	./run-specs.sh

terraform.tfstate: *.tf ssh_keys get
	terraform apply -var allowed_ip=$(MY_IP) -var-file=my.tfvars

.tmp/BASTION_HOST: terraform.tfstate
	mkdir -p .tmp
	terraform output | awk -F' *= *' '$$1 == "bastion_host_ip" { print $$2 }' > .tmp/BASTION_HOST

.tmp/GO_SERVER: terraform.tfstate
	mkdir -p .tmp
	terraform output | awk -F' *= *' '$$1 == "goserver_ip" { print $$2 }' > .tmp/GO_SERVER

.tmp/GO_PUBLIC_HOST: terraform.tfstate
	mkdir -p .tmp
	terraform output | awk -F' *= *' '$$1 == "go_server_lb_dns" { print $$2 }' > .tmp/GO_PUBLIC_HOST

Gemfile.lock: Gemfile
	bundle install

ssh_keys: ~/.ssh/spin-gocd-key ~/.ssh/spin-bastion-key

~/.ssh/spin-gocd-key:
	ssh-keygen -N '' -C 'spin-gocd-key' -f ~/.ssh/spin-gocd-key

~/.ssh/spin-bastion-key:
	ssh-keygen -N '' -C 'spin-bastion-key' -f ~/.ssh/spin-bastion-key

ssh_config: ~/.ssh/spin_config

define SSHCONFIG_BASTION
  ForwardAgent yes
  IdentityFile ~/.ssh/spin-bastion-key
  User ubuntu
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null

endef

define SSHCONFIG_GOSERVER
  IdentityFile ~/.ssh/spin-gocd-key
  User ubuntu
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
  ProxyCommand ssh -q bastion nc %h %p

endef

export SSHCONFIG_BASTION
export SSHCONFIG_GOSERVER

~/.ssh/spin_config: export BASTION_HOST = $(shell cat .tmp/BASTION_HOST)

~/.ssh/spin_config: export GO_SERVER = $(shell cat .tmp/GO_SERVER)

~/.ssh/spin_config: .tmp/GO_SERVER .tmp/BASTION_HOST ssh_keys terraform.tfstate
	echo "Host bastion" > $@
	echo "  Hostname $(BASTION_HOST)" >> $@
	echo "$$SSHCONFIG_BASTION" >> $@
	echo "" >> $@
	echo "Host goserver" >> $@
	echo "  Hostname $(GO_SERVER)" >> $@
	echo "$$SSHCONFIG_GOSERVER" >> $@
	echo "" >> $@

check-env:
ifndef GOCD_DNS_NAME
	$(error GOCD_DNS_NAME is undefined)
endif

.certificate-arn: check-env
	aws acm request-certificate \
		--domain-name ${GOCD_DNS_NAME} \
		--idempotency-token 12345 > .certificate-arn
