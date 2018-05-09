#! /bin/bash

## https://edu.fauno.org/f/prj/llinux/p/wrun.sh
##
mkdir -p /tmp/wscript
chmod 777 /tmp/wscript
SCRIPT=/tmp/wscript/$(date +%y%m%d%H%M).sh

rm -Rf $SCRIPT
wget -c $1 -O $SCRIPT
chmod +x $SCRIPT
$SCRIPT $2 $3 $4 $5

