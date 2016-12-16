
if [ ! -d /home/vagrant ] ; then
  echo "ERROR: I don't appear to be running in the Vagrant box"
  exit 1
fi

mkdir -p -m 0700 /home/vagrant/.ssh

if [ ! -f ~/.ssh/spin-gocd-key ] ; then
  ssh-keygen -N '' -C 'infra-workshop' -f ~/.ssh/spin-gocd-key
fi

cat > /home/vagrant/.ssh/config <<ENDSSHCONFIG
Host *
  User ubuntu
  StrictHostKeyChecking=no
  IdentityFile ~/.ssh/spin-gocd-key

Host bastion
  Hostname <<BASTION_PUBLIC_IP>>
  ForwardAgent yes
  IdentityFile ~/.ssh/spin-gocd-key
  User ubuntu
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null

Host goserver
  Hostname <<TARGET_HOST_PRIVATE_IP>>
  IdentityFile ~/.ssh/spin-gocd-key
  User ubuntu
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
  ProxyCommand ssh -q bastion nc %h %p

ENDSSHCONFIG


