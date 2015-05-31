#!/bin/bash

#
# conf-notes.txt generator
# ------------------------
#
# Signed-off-by: Theodor Gherzan <theodor@resin.io>
#

CONF=$1 # CONFNAME file directory location
JSON=$2 # JSON file full path
CONFNAME="conf-notes.txt"

# Checks
if [ $# -ne 2 ] || ! `which jq > /dev/null 2>&1` || [ ! -f $JSON ] || [ -z $CONF ] || [ ! -d $CONF ]; then
    exit 1
fi

echo -e "
  _____           _         _       
 |  __ \         (_)       (_)      
 | |__) |___  ___ _ _ __    _  ___  
 |  _  // _ \/ __| | '_ \  | |/ _ \ 
 | | \ \  __/\__ \ | | | |_| | (_) |
 |_|  \_\___||___/_|_| |_(_)_|\___/ 
                                    
 ---------------------------------- \n" > $CONF/$CONFNAME

echo "Resin specific targets are:" >> $CONF/$CONFNAME
for target in `cat $JSON | jq  -r '[.supported[].image] | unique | .[]'`; do
    echo "    $target" >> $CONF/$CONFNAME
done
echo >> $CONF/$CONFNAME

for machine in `cat $JSON | jq  -r '.supported[].machine'`; do
    NAME=`cat $JSON | jq  -r '.supported[] | select(.machine == '\"${machine}\"').name'`
    MACHINE=`cat $JSON | jq  -r '.supported[] | select(.machine == '\"${machine}\"').machine'`
    IMAGE=`cat $JSON | jq  -r '.supported[] | select(.machine == '\"${machine}\"').image'`
    printf "%-25s : %s\n" "$NAME" "\$ MACHINE=$MACHINE bitbake $IMAGE" >> $CONF/$CONFNAME
done
echo >> $CONF/$CONFNAME
