#!/bin/sh


### debemos llamar este script con sudo !!

##############
MYDIR=`pwd`
cd `dirname "$0"`
THISSCRIPTPATH=`pwd`
cd $MYDIR
##############

ISOOUT=/media/ubuntu-studio/Acer/tmp/isos
## descargado de http://cdimage.ubuntu.com/xubuntu/bionic/daily-live/current/bionic-desktop-amd64.iso
ISO=/isodevice/bionic.hd/bionic-desktop-amd64.iso

$THISSCRIPTPATH/../bin/remasteriso.sh $ISO $ISOOUT $THISSCRIPTPATH/myxubuntu.conf
