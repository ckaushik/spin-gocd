
MY_IP=$(shell curl -s icanhazip.com)

plan: *.tf get
	terraform plan -var allowed_ip=$(MY_IP)

apply: terraform.tfstate get

get:
	terraform get

test : export TARGET_HOST = $(shell cat .tmp/TARGET_HOST)

test: apply .tmp/TARGET_HOST Gemfile.lock
	rspec spec/gocd_server/ssh_spec.rb

clean:
	rm -rf .tmp

distclean: clean
	terraform destroy -force -var allowed_ip=$(MY_IP)
	rm -f terraform.tfstate terraform.tfstate.backup

update:
	bundle clean --force

terraform.tfstate: *.tf modules/*/*.tf
	terraform apply -var allowed_ip=$(MY_IP)

.tmp/TARGET_HOST: terraform.tfstate
	mkdir -p .tmp
	terraform output | awk -F' *= *' '$$1 == "gocd_server_ip" { print $$2 }' > .tmp/TARGET_HOST

Gemfile.lock: Gemfile
	bundle install

