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
############# REPO ####################
## min repo
##rm -f /etc/apt/sources.list.d/uies.list
##wget -c -O /etc/apt/sources.list.d/uies.list http://ubuntuies.googlecode.com/svn/trunk/trusty/packages/uies-aptsources/files/etc/apt/sources.list.d/uies.list
##apt-get update
##apt-get --assume-yes  install uies-aptsources
##apt-get update

## debería ir como condicion si no esta instalado
##apt-get  --assume-yes  install grub-pc=2.02~beta2-9 grub2-common=2.02~beta2-9 grub-pc-bin=2.02~beta2-9 grub-common=2.02~beta2-9 grub2


# Spanish language

locale-gen es_ES.utf8
update-locale


## install
PKGS=""
## incluye lu-init en esta instalacion
##PKGS="$PKGS lu-init "
PKGS="$PKGS nano git sshfs unionfs-fuse rsync"
##PKGS="$PKGS uies-remaster uies-pendriveinstaller"

###TODO falta incluir el tema plymouth cuando este listo 
###TODO instalar wrun , mega mount tools, pcloud mounter

wget -c https://raw.githubusercontent.com/jesuslalvaro/uies/master/bin/wrun.sh -O /usr/bin/wrun
chmod +x /usr/bin/wrun

## pcloud
wget -c https://p-ams1.pcloud.com/D4Z6yURLJZAxYUbJZZZqBxRU7Z2ZZqK0ZkZOpNXZN7ZCXZrkZv1aQ7ZaOjeuujH9ljYk1d3Wiw3XHuQGdtk/pcloudcc_2.0.1-1_amd64.debian.8.10.deb -O /tmp/pcloudcc.deb
dpkg -i /tmp/pclou*


PKGS="$PKGS language-pack-es language-pack-gnome-es myspell-es aspell-es firefox-locale-es " 
# PKGS="$PKGS grub2"
############# SOME BASIC PACKAGES  ####################
#~ PKGS="$PKGS geany nano wrun sshfs" 
#~ PKGS="$PKGS  gparted partimage "
## PKGS="$PKGS   flashplugin-nonfree  adobe-flashplugin connectaddin"
## PKGS="$PKGS   adobe-flashplugin "


apt-get --assume-yes  install $PKGS
apt-get --assume-yes  install -f
apt-get --assume-yes  autoremove

# update-python-modules -f
# update-software-center

## apt-get --assume-yes  upgrade
if [ -f "/etc/ssh/ssh_config" ] ; then
    if ! (grep "ServerAliveInterval" /etc/ssh/ssh_config ) ; then
      echo "    ServerAliveInterval    100"  >> /etc/ssh/ssh_config
    fi
fi
###########
