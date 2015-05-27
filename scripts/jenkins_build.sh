#!/bin/bash
set -e

MACHINE=$1
JENKINS_PERSISTENT_WORKDIR=/mnt/btrfs_drive/yocto
JENKINS_DL_DIR=$JENKINS_PERSISTENT_WORKDIR/yocto-downloads
JENKINS_SSTATE_DIR=$JENKINS_PERSISTENT_WORKDIR/yocto-sstate-$MACHINE
JENKINS_DEPLOY_DIR=$JENKINS_PERSISTENT_WORKDIR/yocto-deploy-$MACHINE
SUPERVISOR_raspberrypi=rpi-supervisor
SUPERVISOR_raspberrypi2=armv7hf-supervisor
SUPERVISOR_beaglebone=armv7hf-supervisor
SUPERVISOR_nitrogen6x=armv7hf-supervisor
SUPERVISOR_parallella_hdmi_resin=armv7hf-supervisor
BARYS_ARGUMENTS_production=""
BARYS_ARGUMENTS_master="-s"

# Sanity checks
if [ "$#" -ne 1 ]; then
    echo "Usage: jenkins_build.sh <MACHINE> [JENKINS_PERSISTENT_WORKDIR]"
    exit 1
fi
if [ -z "$BUILD_NUMBER" ] || [ -z "$sourceBranch" ]; then
    echo "[ERROR] BUILD_NUMBER and sourceBranch variable undefined."
    exit 1
fi

# Get the absolute script location
pushd `dirname $0` > /dev/null 2>&1
SCRIPTPATH=`pwd`
popd > /dev/null 2>&1

# Make sure we are where we have to be
cd $SCRIPTPATH/..

# Custom JENKINS_PERSISTENT_WORKDIR?
if [ "$#" -eq 2 ]; then
    JENKINS_PERSISTENT_WORKDIR=$2
fi

# Get sources
git checkout $sourceBranch
./repo init -u .git -b $sourceBranch -m manifests/resin-board-$sourceBranch.xml
./repo sync

# Run build
BARYS_ARGUMENTS_VAR=BARYS_ARGUMENTS_$sourceBranch
./scripts/barys  -l -r -m $MACHINE ${!BARYS_ARGUMENTS_VAR} \
    --shared-downloads $JENKINS_DL_DIR \
    --shared-sstate $JENKINS_SSTATE_DIR

#echo 'INHERIT += "rm_work"' >> conf/local.conf # yocto says this will speed up a little

# Write deploy artifacts
mkdir -p $JENKINS_DEPLOY_DIR/$BUILD_NUMBER
rm -rf $JENKINS_DEPLOY_DIR/$BUILD_NUMBER/* # do we have anything there?
cp -rv build/tmp/deploy/images/$MACHINE/*.resin-sdcard $JENKINS_DEPLOY_DIR/$BUILD_NUMBER
cp build/tmp/deploy/images/$MACHINE/VERSION $JENKINS_DEPLOY_DIR/$BUILD_NUMBER
ln -sf $BUILD_NUMBER $JENKINS_DEPLOY_DIR/latest
