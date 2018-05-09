#!/bin/sh

apt-get install --force-yes --assume-yes uies-remaster 

UIES=/home/uies
ISO=$UIES/isos/ubuntu-14.04.1-desktop-i386.iso

# desde ubuntu oficial daily live
#~ ISO=$UIES/isos/trusty-desktop-i386.iso




# coge la última version de Ufe*
ISO=$(ls -t $UIES/isos/uiest.Ufe*.*.iso | head -n 1 )

remasteriso.sh $ISO $UIES/isos $UIES/14.scripts/ufelam.conf
