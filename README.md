##  Resin.io Yocto manifests with repo tool. #

* After you download this repository, execute the following in the repository to initialize the workspace for a device type [Example: raspberrypi].	
```
#!bash
    
    ./repo init -u .git -m manifests/raspberrypi.xml
```
* At this point you should have all the dependent layers for building an image for the specific board selected above. 

* Initialise the Yocto environment by running the following.
```
#!bash
    
    source ./poky/oe-init-build-env
```
* repo tool would have also sym-linked the local.conf and bblayers.conf from the machine specific meta-resin-<device> library.

## Additional Notes: ##
* While developing with meta-resin or any other layer - be sure to start a new branch for development as follows.
```
#!bash

./repo start new_branch_name meta-resin
```
* Prune already merged repos using the following
```
#!bash

./repo prune
```
# **Statutory warning:** #
Failure to keep manifests updated will result in outdated builds and can lead to cancer or other harmful conditions.