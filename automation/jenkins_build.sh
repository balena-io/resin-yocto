#!/bin/bash
set -e

MACHINE=$1
JENKINS_PERSISTENT_WORKDIR=$2
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
if [ "$#" -ne 2 ]; then
    echo "Usage: jenkins_build.sh <MACHINE> <JENKINS_PERSISTENT_WORKDIR>"
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

# Get sources
git checkout $sourceBranch
./repo init -u .git -b $sourceBranch -m manifests/resin-board-$sourceBranch.xml
./repo sync

# Run build
BARYS_ARGUMENTS_VAR=BARYS_ARGUMENTS_$sourceBranch
./scripts/barys  -l -r -m $MACHINE ${!BARYS_ARGUMENTS_VAR} \
    --shared-downloads $JENKINS_DL_DIR \
    --shared-sstate $JENKINS_SSTATE_DIR \
    --rm-work

# Write deploy artifacts
BUILD_NAME=$sourceBranch-$BUILD_NUMBER
BUILD_DEPLOY_DIR=$JENKINS_DEPLOY_DIR/$BUILD_NAME
mkdir -p $BUILD_DEPLOY_DIR
rm -rf $BUILD_DEPLOY_DIR/* # do we have anything there?
cp -rv build/tmp/deploy/images/$MACHINE/*.resin-sdcard $BUILD_DEPLOY_DIR
cp -v build/tmp/deploy/images/$MACHINE/VERSION $BUILD_DEPLOY_DIR
ln -snf $BUILD_NAME $JENKINS_DEPLOY_DIR/$sourceBranch-latest
