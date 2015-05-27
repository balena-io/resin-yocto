#!/bin/bash

set -e

MACHINE=$1
YOCTO_TARGETS=$2
SUPERVISOR=$3

# Don't cleanup workspace to keep repositories and save some time
rm -rf build/

# Checkout proper branch
git checkout $sourceBranch

# Init repo
./repo init -u .git -b $sourceBranch -m manifests/resin-board-$sourceBranch.xml

# Pull in sources
./repo sync

# Configure build
export TEMPLATECONF=../meta-resin/meta-resin-common/conf/
source poky/oe-init-build-env build

# Custom build variables
echo 'DL_DIR="/mnt/btrfs_drive/yocto/yocto-downloads"' >> conf/local.conf
echo "SSTATE_DIR='/mnt/btrfs_drive/yocto/yocto-sstate-${MACHINE}'" >> conf/local.conf
echo "TMPDIR='/mnt/btrfs_drive/yocto/yocto-resin-${MACHINE}/$sourceBranch'" >> conf/local.conf
if [ "$sourceBranch" == "master" ]; then
    echo 'RESIN_STAGING_BUILD = "yes"' >> conf/local.conf
    echo 'INHERIT += "rm_work"' >> conf/local.conf # yocto says this will speed up a little
fi

# Start build
MACHINE=${MACHINE} bitbake ${YOCTO_TARGETS}

# Write VERSION
echo -n `docker inspect resin/${SUPERVISOR}:$sourceBranch | \
    grep '"VERSION=' | head -n 1 | tr -d " " | tr -d "\"" | \
    tr -d "VERSION="` \
    > /mnt/btrfs_drive/yocto/yocto-resin-${MACHINE}/$sourceBranch/deploy/images/${MACHINE}/VERSION
