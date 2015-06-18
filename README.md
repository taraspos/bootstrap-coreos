
## HOW-TO Use bootstarp.sh script ##
To use this script you need to inject it into CoreOS installation ISO(**isomaster** tool on Ubuntu) and write it to the flesh drive(**unetbootin**) or use customized ISO in the VirtualBox or VMware

When you loaded Installation ISO(on the bare-metal on VM) you need to do next steps:
* Mount flesh drive or virtual CD partition:
```
sudo mount /dev/sdb1 /mnt/ ## if you installing from Flash Drive
```  
or
```
sudo mount /dev/sr0 /mnt/ ## if you installing from virtual CD in VirtualBox
```

* Run script with **SUDO** replacing "<CLIENT_ID>" with real value.
```
sudo bash /mnt/bootstrap.sh <CLIENT_ID>
```
**NOTE:** if you didn't specify CLIENT_ID as script parameter you will be asked for input during script runtime


To use your own clod-config files replace ```CLOUD_INIT_REPOSITORY``` variable. All cloud-config files should be named like ```cloud-config-<CLIENT_ID>```, where <CLIENT_ID> is real value.

* During script runtime you will be asked for Login into your QUAY.io account. To change Docker private repository supplier change ```DOCKER_PRIVARE_REPOSITORY``` value
