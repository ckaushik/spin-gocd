
MY_IP=$(shell curl -s icanhazip.com)

specs := $(wildcard *.k)

plan: *.tf get
	terraform plan -var allowed_ip=$(MY_IP)

apply: terraform.tfstate get

get:
	terraform get

test : export BASTION_HOST = $(shell cat .tmp/BASTION_HOST)

test: hosts Gemfile.lock
	./run-specs.sh

destroy: distclean

distclean:
	terraform destroy -force -var allowed_ip=$(MY_IP)
	rm -f terraform.tfstate terraform.tfstate.backup
	rm -f .tmp/*_HOST

update:
	bundle clean --force

terraform.tfstate: *.tf modules/*/*.tf
	terraform apply -var allowed_ip=$(MY_IP)

hosts: .tmp/BASTION_HOST

.tmp/BASTION_HOST: terraform.tfstate
	mkdir -p .tmp
	terraform output | awk -F' *= *' '$$1 == "bastion_host_ip" { print $$2 }' > .tmp/BASTION_HOST

Gemfile.lock: Gemfile
	bundle install

