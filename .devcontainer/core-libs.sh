#!/usr/bin/env bash
## set -euo pipefail
## 
## ARG USERNAME=vscode
## ARG USER_UID=1000
## ARG USER_GID=$USER_UID
## 
## # Create the user
## RUN groupadd --gid $USER_GID $USERNAME \
##     && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
##     #
##     # [Optional] Add sudo support. Omit if you don't need to install sofware after connecting.
##     && apt-get update \
##     && apt-get install -y sudo \
##     && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
##     && chmod 0440 /etc/sudoers.d/$USERNAME
##     
## USER $USERNAME

# install apt-add-repository
sudo apt update 
sudo apt install software-properties-common -y
sudo apt update

# add proxy if you are in china, of cause you need to setup your proxy server!
# echo 'Acquire::http::Proxy "http://127.0.0.1:1086";' | sudo tee -a /etc/apt/apt.conf
# echo 'Acquire::https::Proxy "https://127.0.0.1:1086";' | sudo tee -a /etc/apt/apt.conf
export HTTP_PROXY=http://198.18.0.1:1086
export HTTPS_PROXY=http://198.18.0.1:1086
sudo apt install iputils-ping
echo "Adding HashiCorp GPG key and repo..."
sudo sh -c 'curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -'
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update

# install cni plugins https://www.nomadproject.io/docs/integrations/consul-connect#cni-plugins
echo "Installing cni plugins..."
sudo sh -c 'curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.1.1.tgz'
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz
sudo rm ./cni-plugins.tgz

echo "Installing Consul..."
sudo apt-get install consul -y

echo "Installing Nomad..."
sudo apt-get install nomad -y

echo "Installing Vault..."
sudo apt-get install vault -y

# # configuring environment
# sudo -H -u root nomad -autocomplete-install
# sudo -H -u root consul -autocomplete-install
# sudo -H -u root vault -autocomplete-install
# sudo tee -a /etc/environment <<EOF
# export VAULT_ADDR=http://localhost:8200
# export VAULT_TOKEN=root
# EOF
sudo apt-get clean -y 
sudo rm -rf /var/lib/apt/lists/* /tmp/core-libs.sh

# Install Buf
sudo sh -c 'curl -sSL "https://github.com/bufbuild/buf/releases/download/v1.8.0/buf-$(uname -s)-$(uname -m)" -o "/usr/local/bin/buf"'
sudo chmod +x "/usr/local/bin/buf"

# Install migrate CLI
sudo sh -c 'curl -L "https://github.com/golang-migrate/migrate/releases/download/v4.15.2/migrate.linux-amd64.tar.gz" | tar xvz'
sudo mv migrate "/usr/local/bin/migrate"
sudo chmod +x "/usr/local/bin/migrate"


source /etc/environment

# WSL2-hack - Nomad cannot run on wsl2 image, then we need to work-around
sudo mkdir -p /lib/modules/$(uname -r)/
echo '_/bridge.ko' | sudo tee -a /lib/modules/$(uname -r)/modules.builtin

exec "$@"
