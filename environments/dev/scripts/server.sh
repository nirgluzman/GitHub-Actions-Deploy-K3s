#! /bin/bash

# update os
apt-get update -y
apt-get upgrade -y

# install AWS CLI
apt-get install unzip -y
curl -SL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip
cd /tmp
unzip awscliv2.zip
rm -rf awscliv2.zip
sudo ./aws/install

# set server hostname
hostnamectl set-hostname k3s-server

# placeholder for K3s Server config.yaml
mkdir -p /etc/rancher/k3s && sudo touch $_/config.yaml

# customize bash prompt
echo 'export PS1="\[$(tput setaf 226)\]\u\[$(tput setaf 220)\]@\[$(tput setaf 214)\]\h \[$(tput setaf 33)\]\w \[$(tput sgr0)\]$ "' >> /home/ubuntu/.bashrc

# create custom aliases
cat > /etc/profile.d/custom_config.sh << EOF
alias c='clear'
alias d='docker'
alias k='kubectl'
EOF
chmod a+x /etc/profile.d/custom_config.sh
