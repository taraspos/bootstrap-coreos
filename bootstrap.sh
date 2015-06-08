#!/bin/bash

function check_if_root {
  if [[ $EUID -ne 0 ]]; then
     echo "This script must be run as root" 1>&2
     exit 1
  fi
}

function read_CLIENT_ID_from_input {
  echo "Please provide CLIENT_ID value:"
  read CLIENT_ID
}

function check_CLIENT_ID {
  CLIENT_ID=$1
  while [[ ! $CLIENT_ID ]]
    do
      if [ "$#" -eq "1" ]; then
        echo "Provided CLIENT_ID value: $CLIENT_ID"
      elif [ $# -eq 0 ]; then
        echo "No arguments provided"vi
        read_CLIENT_ID_from_input
      else
        echo "Illegal number of parameters"
        read_CLIENT_ID_from_input
      fi
    done
}

# function check_cloud_init_path {
#   if [ -d "/var/lib/coreos-vagrant/" ]; then
#     CLOUD_INIT_PATH=/var/lib/coreos-vagrant/vagrantfile-user-data
#     echo "Thank you for using Vagrant"
#     echo "Cloud init file are located $CLOUD_INIT_PATH"
#   elif [-d "/var/lib/coreos-install/"]; then
#     CLOUD_INIT_DIR=/var/lib/coreos-install/user_data
#     echo "Thank you for using CoreOS "
#     echo "Cloud init file are located $CLOUD_INIT_PATH"
#   else
#     echo "Directory for cloud-init file not found"
#     exit 1
#   fi
# }


function get_cloud_init {
  CLOUD_INIT_URL=https://s3-us-west-2.amazonaws.com/cloud-config-test-bucket/cloud-config-$CLIENT_ID
  wget $CLOUD_INIT_URL -O ~/cloud-config
}

function  install_coreos {
  coreos-install -d /dev/sda -C stable -c ~/cloud-config
}

function download_containers {
  mkdir /mnt/rootfs
  mount /dev/sda9 /mnt/rootfs
  systemctl stop docker.service
  rm -rf /var/lib/docker
  ln -s /mnt/rootfs/var/lib/docker /var/lib/docker
  systemctl start docker.service
  coreos-cloudinit --from-file ~/cloud-config
}

check_if_root
check_CLIENT_ID $1
#check_cloud_init_path
get_cloud_init
install_coreos
download_containers
