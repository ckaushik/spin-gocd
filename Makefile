
MY_IP=$(shell curl -s icanhazip.com)
ENVIRONMENT?=sandbox
BASE_DOMAIN=$(shell cat CONFIG_DOMAIN)

all: plan

validate: *.tf
	terraform validate

plan: *.tf ssh_keys init-terraform
	terraform plan -var allowed_ip=$(MY_IP) -var environment=$(ENVIRONMENT) -var-file=my.tfvars

apply: terraform.tfstate

terraform.tfstate: *.tf ssh_keys init-terraform
	terraform apply -var allowed_ip=$(MY_IP) -var environment=$(ENVIRONMENT) -var-file=my.tfvars

destroy: ssh_keys init-terraform
	@echo "Destroying the remote environment"
	terraform destroy -force -var allowed_ip=$(MY_IP) -var environment=$(ENVIRONMENT) -var-file=my.tfvars
	rm -rf .terraform
	rm -f terraform.tfstate terraform.tfstate.backup
	rm -rf .tmp

clean:
	@echo "Cleaning local state, not touching the remote environment"
	rm -rf .terraform
	rm -f terraform.tfstate terraform.tfstate.backup
	rm -rf .tmp

init-terraform: get-module get-state

get-module:
	terraform get

get-state: check-env
	terraform init \
    -backend-config="bucket=$(BASE_DOMAIN).tfstate" \
    -backend-config="key=$(ENVIRONMENT)/gocd/terraform.tfstate" \
	-backend-config="region=ap-south-1" \
	-backend=true \
	-force-copy

test: apply .tmp/BASTION_HOST .tmp/GO_SERVER .tmp/GO_PUBLIC_HOST quick-test

quick-test: export BASTION_HOST = $(shell cat .tmp/BASTION_HOST)
quick-test: export GO_SERVER = $(shell cat .tmp/GO_SERVER)
quick-test: export GO_PUBLIC_HOST = $(shell cat .tmp/GO_PUBLIC_HOST)

quick-test: Gemfile.lock
	./run-specs.sh

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
	echo "Host 10.0.*" >> $@
	echo "$$SSHCONFIG_GOSERVER" >> $@
	echo "" >> $@

check-env:
ifeq ($(BASE_DOMAIN),)
	$(error BASE_DOMAIN is undefined, should be in file CONFIG_DOMAIN)
endif

certificate: .certificate-arn

.certificate-arn: check-env
	@echo "Generating certificate request for ${ENVIRONMENT}.${BASE_DOMAIN}"
	aws acm request-certificate \
		--domain-name "${ENVIRONMENT}.${BASE_DOMAIN}" \
		--subject-alternative-names "gocd.${ENVIRONMENT}.${BASE_DOMAIN}" \
		--idempotency-token 12345 > .certificate-arn
	@echo "Verification email should be sent to whois owner of ${BASE_DOMAIN}"
