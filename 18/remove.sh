#!/bin/bash

## disponible en https://raw.githubusercontent.com/jesuslalvaro/uies/master/18/prepare.sh
## iso de partida UBUNTU TRUSTY OFICIAL
# wget -c http://cdimage.ubuntu.com/daily-live/current/trusty-desktop-i386.iso
# KEY="20130331scriptvalido"

############# REMOVE ####################
## remove

RPKGS=""
# international
RPKGS="$RPKGS language-pack-zh* language-pack-de-base language-pack-pt-base language-pack-de"
RPKGS="$RPKGS language-pack-gnome-zh* language-pack-gnome-de-base language-pack-gnome-pt-base "

RPKGS="$RPKGS ttf-indic-fonts-core ttf-punjabi-fonts fonts-kacst fonts-khmeros-core fonts-nanum fonts-kacst-one fonts-lklug-sinhala fonts-lao "
RPKGS="$RPKGS firefox-locale-de  firefox-locale-fr firefox-locale-pt firefox-locale-zh-hans     "


## unused services
RPKGS="$RPKGS example-content"  # no lo elimina del todo, queda el archivo .desktop :( 
#~ RPKGS="$RPKGS ubuntuone-client ubuntuone-installer  deja-dup "
#~ RPKGS="$RPKGS  accountsservice  account-plugi* account-plugin-facebook account-plugin-aim"


## some applications
#~ RPKGS="$RPKGS thunderbird"


## grub
##RPKGS="$RPKGS grub* "


apt-get --assume-yes  remove $RPKGS
#~ apt-get --assume-yes  purge $RPKGS
apt-get  --assume-yes  autoremove
