#!/bin/sh


### debemos llamar este script con sudo !!

##############
MYDIR=`pwd`
cd `dirname "$0"`
THISSCRIPTPATH=`pwd`
cd $MYDIR
##############

ISOOUT=/media/ubuntu-studio/Acer/tmp/isos
ISO=/isodevice/bionic.hd/bionic-desktop-amd64.iso

$THISSCRIPTPATH/../bin/remasteriso.sh $ISO $ISOOUT $THISSCRIPTPATH/myxubuntu.conf
