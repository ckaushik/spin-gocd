# WARNING!

This code is intended as an example that you can copy and use, rather than a supported module that you should import. I reserve the right to completely change it in dangerous and destructive ways, with complete disregard for backwards compatibility.

Also, I make no guarantees that this code works as you find it. There's a pretty good chance that it's broken, because I'm in the middle of a change, because I'm using it in some way specific to myself, because I've neglected it, or for some other reason.


## What this is

The purpose of this project is to make it easy to spin up a GoCD cluster on AWS, using Terraform.


## Pre-requisites

You'll need a number of things, including:

- AWS account
- Terraform
- Ruby & Bundler
- GNU Make
- AWSCLI


### Using the infra-workbox

I run this inside a Vagrant VM running a box that I've built with the various pre-requisite tools. If you want to use this, you can refer to it as `kief/infra-workbox` in your Vagrantfile. See https://github.com/kief/infra-workbox, which is the (poorly documented and negligently maintained) project that uses Packer to build this box. It would be reasonable to fork or copy that project so you can tailor it for your own use.


## Setup

Aside from having the tools installed and working, there are some things you'll need to set up in order to run this.

- AWS User, policies, and credentials
- DNS Zone in Route53, name in a configuration file called CONFIG_DOMAIN
- Create a my.tfvars file


### AWS Credentials

You'll need access keys for an AWS user with certain permissions. I *strongly* recommend you create a separate IAM AWS user for this. It's good practice to isolate permissions.

The main permissions the IAM user will need are:

- EC2
- VPC
- Route53
- Certificate Request

I've got some policy files in the [../blob/master/iam](../blob/master/iam) folder of this project. I haven't implemented automation for applying these, I currently use the AWS console. These permissions are also more liberal than are probably needed, especially those for route53. I'd like to limit these appropriately, for example make sure that the user only has permission to mess with records in the one domain.

I usually only add the certificate request policy when I need to request a certificate, and remove it afterwards.

Generate access keys for this user, and put them into your aws_credentials file. I have my Vagrantfile grab this file from a .secrets directory and put it into place. The way I do this should be documented in my infra-workbox project mentioned above.


### DNS Zone in Route53

This project uses Terraform to assign a DNS name to the GoCD server using Route53. See the file [../blob/master/domain.tf](../blob/master/domain.tf) for this - it just needs to be able to create a record. I have a domain I use for this, whose name servers are pointed to the AWS name servers for the zone in Route53. I don't have anything else important under this domain.

The name of this domain goes into a file named `CONFIG_DOMAIN` in this directory. This is only used by the Makefile to generate an SSL certificate request to the AWS Certificate Management service. So if you're doing something different for the SSL certificate, you shouldn't need this file.

However, the domain does need to be added to the my.tfvars file (described below), so Terraform can refer to it.


### Create a my.tfvars file

Make a file called `my.tfvars`, as below:

```
aws_region = "eu-west-1"
gocd_ssl_certificate_arn = "arn:aws:acm:...."
parent_domain = "mydomain.com"
```

- This project currently assumes the region is *eu-west-1*. It will definitely break if you use a different one. But it shouldn't be too difficult to tweak it - add the relevant AMI (should be Ubuntu) to the `aws_amis` map in `variables.tf` for your region.
- The *gocd_ssl_certificate_arn* value will come after you've generated and approved the SSL certificate request. Or if you have a certificate you've put into AWS certificate manager yourself with the appropriate domain, then put the arn for that in here.
- The *parent_domain* is the base DNS domain you'll be using. It needs to be in Route53, and the AWS access keys you're using need to have permission to add records. Terraform will add a subdomain for each environment you create (this is `sandbox` by default), and a hostname alias for gocd, which it attaches to the load balancer.


### SSL Certificate

Run `make certificate`: Send a certificate request to AWS certificate management service for the GoCD DNS hostname. You'll need to approve it, and add the arn to the configuration as above.

Otherwise, create an SSL certificate for `gocd.ENVIRONMENT.PARENT_DOMAIN`, load it into AWS certificate manager, and put the arn into the `my.tfvars` file as described above.


## Running it

After configuring as above, you can use these commands:

- `make plan`: Run `terraform plan` and print out what would be done
- `make apply`: Build (or update) the VPC
- `make test`: Build (or update) the VPC and run tests against it
- `make destroy`: Destroy the VPC and everything in it

If you have everything in place and run `make test`, Terraform will build a VPC with an instance of GoCD, and then run rspec tests against it. Sometimes there is a lag in everything coming up which makes the tests fail first time.

The URL for GoCD will be: https://gocd.ENVIRONMENT.PARENT_DOMAIN:8154/go/home.

ENVIRONMENT defaults to *sandbox*. If you want a different environment name, pass it on the *make* command line. For example:

    make apply ENVIRONMENT=production


