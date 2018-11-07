#!/bin/bash

## disponible en https://raw.githubusercontent.com/jesuslalvaro/uies/master/18/
## iso de partida UBUNTU  OFICIAL
# wget -c http://cdimage.ubuntu.com/daily-live/current/
# KEY="20130331scriptvalido"


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

#basic
PKGS="$PKGS nano git sshfs unionfs-fuse rsync"
PKGS="$PKGS  gparted partimage "
PKGS="$PKGS fuseiso squashfuse"


#?
##PKGS="$PKGS uies-remaster uies-pendriveinstaller"
###TODO falta incluir el tema plymouth cuando este listo 
###TODO instalar mega mount tools,

#wrun
wget -c https://raw.githubusercontent.com/jesuslalvaro/uies/master/bin/wrun.sh -O /usr/bin/wrun
chmod +x /usr/bin/wrun


## Spanish
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

### Set ssh time
## apt-get --assume-yes  upgrade
if [ -f "/etc/ssh/ssh_config" ] ; then
    if ! (grep "ServerAliveInterval" /etc/ssh/ssh_config ) ; then
      echo "    ServerAliveInterval    100"  >> /etc/ssh/ssh_config
    fi
fi
###########
