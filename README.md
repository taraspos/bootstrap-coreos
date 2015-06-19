
## HOW-TO Use bootstarp.sh script ##
To use this script you need to inject it into CoreOS installation ISO(**isomaster** tool on Ubuntu) and write it to the flesh drive(**unetbootin**) or use customized ISO as virtual CD in the VirtualBox or VMware

When you booted form Installation ISO(on the bare-metal on VM) you need to do next steps:
* Mount flesh drive or virtual CD partition:
```
sudo mount /dev/sdb1 /mnt/ ## if you installing from Flash Drive
```  
or
```
sudo mount /dev/sr0 /mnt/ ## if you installing from virtual CD in VirtualBox
```

* Run script with **SUDO** replacing *CLIENT_ID* with real value.
```
sudo bash /mnt/bootstrap.sh CLIENT_ID
```
**NOTE:** if you didn't specify *CLIENT_ID* as script parameter you will be asked for input during script runtime


To use your own cloud-config files replace ```CLOUD_INIT_REPOSITORY``` variable. All cloud-config files should be named like ```cloud-config-CLIENT_ID```, where *CLIENT_ID* is real value.

* During script runtime you will be asked for Login into your QUAY.io account. To change Docker private repository supplier change ```DOCKER_PRIVARE_REPOSITORY``` value
**NOTE**: sometime during login step CoreOS can prompt some unexpected output, just ignore it and keep typing username.

* Reboot when everything is done and login with credentials which are specified in choosen cloud-config file


## USE EXAMPLE ##
```
sudo mount /dev/sr0 /mnt                    #### Installing on VirtualBox
sudo bash /mnt/bootstrap.sh proxy-DHCP      #### cloud-config-proxy-DHCP from templates directory
##### aking for input to login in quay.io
username
password
email
#####
sudo reboot
```

This script will do next things:
* Install CoreOS
* Add downloaded cloud-config file in the */var/lib/coreos-install* directory, so it will be executed after reboot
* LogIn into quay.io account  (just example of login, in the cloud-config templates all docker containers pulling from public repositories)
* Set hostname equal *core-CLIENT_ID*
* Create user **adminaccount** with **qwer1234** password and SUDO access
* Configure such proxy address: http_proxy=http://10.128.225.206:8080
* Configure DHCP networking
* Pull all containers specified in the cloud-config file(*nginx* and *cAdvisor* in this case) so they will be available after reboot

**NOTE:** username, password, proxy, networking, containers - all this values are in the cloud-config file and can be changed in case of need


## Templates ##
* *cloud-config-proxy-DHCP, cloud-config-proxy-static and cloud-config-moproxy-static* require to set proper **network interface**, **ip address**, **default gateway** , **proxy_url**
* Login step is just example, all docker containers pulling from public repositories
