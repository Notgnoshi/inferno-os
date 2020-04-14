#!/bin/bash

# Update shit
apt-get update
apt-get dist-upgrade -y

# Install basic necessities
apt-get install -y \
	build-essential \
	htop \
	iperf \
	locales-all \
	locate \
	net-tools \
	nmap \
	rsync \
	screen \
	traceroute \
	tree \
	vim 

# Install git
apt-get install git bash-completion -y
git config --global core.editor vim

# Install docker
# https://docs.docker.com/install/linux/docker-ce/ubuntu/
apt-get install -y \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg-agent \
	software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

apt-key fingerprint 0EBFCD88

add-apt-repository \
	"deb [arch=armhf] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) \
	stable"

apt-get install -y docker-ce docker-ce-cli containerd.io

# Get the inferno project
#mkdir -p /srv/inferno
#git clone https://github.com/Notgnoshi/inferno-os.git /srv/inferno --branch dev/native-arm

cd /srv/inferno

# Build the ARM image
docker build -t inferno/arm:latest .
