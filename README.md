# ** Resin.io Yocto manifests with repo tool.** #

##** Environment setup** ##

* After you download this repository, execute the following in the repository to initialize the workspace.
```
#!bash

    ./repo init -u .git -m manifests/resin-board.xml
    ./repo sync
```
* At this point you should have all the dependent layers for building an image for a resin supported board.

* Initialise the Yocto environment by running the following.
```
#!bash

    export TEMPLATECONF=../meta-resin/meta-resin-common/conf/
    source ./poky/oe-init-build-env
    vim conf/local.conf
```

##** Production vs Master builds** ##
**NOTE:** Production and Master builds use different manifests.

** Steps to promote a build to production: **

* Update the production manifest with any changes to revisions of dependencies and commit to master.
* Merge till the above commit into the production branch.
* The above guarantees that production manifests of different devices are stable.
* Use repo to initialise the production manifest as follows:
```
#!bash

    ./repo init -u .git -m manifests/resin-board-production.xml
```

##** Additional Notes** ##
* Edison manifests are not unified yet so, for this specific board, use the edison.xml and edison-production.xml manifests.
* The <board>.xml and <board>-production.xml manifests were kept only for compatifily or for further needs on having different code base per device.
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
