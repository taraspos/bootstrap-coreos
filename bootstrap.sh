#!/bin/bash
# Script to download cloud-config file according to CLIENT_ID value
# Install CoreOS and download all containers that declared in the cloud-config file
# Druing first boot
#
#
# If you testing the script, use 3333 as CLIENT_ID parameter
# cloud-config-3333 are existing in the testing AWS S3  bucket

DOCKER_DATA_DIR=/var/lib/docker        ######## Directory whhere docker store containers
MOUNT_DIR=~/rootfs                     ######## Directory to mount CoreOS file system
CORE_OS_PARTITION=/dev/sda9            ######## Partition with CoreOS file system
CLOUD_INIT_REPOSITORY=https://raw.githubusercontent.com/Trane9991/bootstrap-coreos/master/templates
DOCKER_PRIVARE_REPOSITORY=quay.io

function check_if_root {
  if [[ $EUID -ne 0 ]]; then
     echo "This script must be run as root" 1>&2
     exit 1
  fi
}

#### Function to provide CLIENT_ID valut from input, if it wasn't provided as parameter
function read_CLIENT_ID_from_input {
  echo "Please provide CLIENT_ID value:"
  read CLIENT_ID
}

### Function to get CLIENT_ID value from user
function check_CLIENT_ID {
  CLIENT_ID=$1
  #### Asking for CLIENT_ID value until user provieds it
  while [[ ! $CLIENT_ID ]]
    do

      if [ "$#" -eq "1" ]; then          #### Accecpt parameter as CLIENT_ID
        echo "Provided CLIENT_ID value: $CLIENT_ID"
      elif [ $# -eq 0 ]; then            #### Ask for input if no parameters are supplied
        echo "No arguments provided"
        read_CLIENT_ID_from_input
      else                               #### Actualym only the first parameter will be accepted as CLIENT_ID even if more then on parameter are suppplied
        echo "Illegal number of parameters"
        read_CLIENT_ID_from_input
      fi
    done
}

#### Not in use, becouse we are uploading cloud-inti file during coreos-install command
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

###### Download cloud-config file from repository(now there is testing S3)
function get_cloud_init {
  CLOUD_INIT_URL=cloud-config-$CLIENT_ID
  wget $CLOUD_INIT_REPOSITORY/$CLOUD_INIT_URL -O ~/cloud-config
  #### Setting hostname "core-$CLIENT-ID"
  sed -i "s/client_id/core-$CLIENT_ID/" ~/cloud-config
}

##### Installing CoreOS with downloaded cloud-config file
function  install_coreos {
  coreos-install -d /dev/sda -C stable -c ~/cloud-config
}

##### Function to mount CoreOS partition and link current docker data directory(LiveCD partition) to the CoreOS partition,
##### so in the next step we will be able to download containers right into CoreOS file system
function mount_root_disk {
  mkdir -p $MOUNT_DIR
  IS_MOUNT=`df -h | grep "/dev/sda9 .* $MOUNT_DIR"`
  if [[ ! $IS_MOUNT ]]; then
    echo "Mounting CoreOS root partition to the $MOUNT_DIR"
    mount $CORE_OS_PARTITION $MOUNT_DIR
  fi

  if [ ! -L $DOCKER_DATA_DIR ]; then
    systemctl stop docker.service
    # Removing existning docker's data directory(on the LiveCD filesystem) and linking it to the CoreOS filesystem docker's data directory
    rm -rf $DOCKER_DATA_DIR
    ln -s $MOUNT_DIR/$DOCKER_DATA_DIR $DOCKER_DATA_DIR
    systemctl start docker.service
  else
    echo "$DOCKER_DATA_DIR already linked to $MOUNT_DIR/$DOCKER_DATA_DIRr"
  fi
}

#### Running cloud-config file, to download containers
function download_containers {
  mount_root_disk
  if [ "$(pidof docker)" ]; then
    clear
  else
    systemctl start docker.service
  fi
  echo "======================================="
  echo "Please Log In into your $DOCKER_PRIVARE_REPOSITORY account"
  echo "======================================="
  docker login $DOCKER_PRIVARE_REPOSITORY
  sed "s/ExecStartPre=/ /" /root/cloud-config | grep pull | bash
}

check_if_root
check_CLIENT_ID $1
#check_cloud_init_path
get_cloud_init
install_coreos
download_containers
