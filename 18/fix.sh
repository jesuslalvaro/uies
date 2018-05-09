#!/bin/bash

## disponible en https://raw.githubusercontent.com/jesuslalvaro/uies/master/18/fix.sh

#########################
# update-python-modules -f
# update-software-center

apt-get --assume-yes  install -f
apt-get --assume-yes  autoremove


## apt-get --assume-yes  upgrade

## permite conexiones SSH mas largas
if [ -f "/etc/ssh/ssh_config" ] ; then
    if ! (grep "ServerAliveInterval" /etc/ssh/ssh_config ) ; then
      echo "    ServerAliveInterval    100"  >> /etc/ssh/ssh_config
    fi
fi
###########


###########
# Reparing installation in startup
# some packages do not configure properly in chroot...
# nfs-common  ca-certificates (for java)....
## tambien podría realizarse con /etc/rc.local ....

INITFILE=/etc/init.d/livefix
cat > $INITFILE << EOF

#!/bin/sh

# fix package installation if required
# nfs-common  ca-certificates....

apt-get --assume-yes  install -f

loadkeys es

# add ubuntu to audio group
#grep audio /etc/group
usermod -a -G audio ubuntu

exit 0

EOF

chmod +x $INITFILE
update-rc.d livefix defaults

###########

## permite a otros desmontar fuse, no solo root ??? confirmar
FILE=/etc/fuse.conf
if [ -f "$FILE" ] ; then
    if ! (grep " user_allow_other" $FILE ) ; then
      echo " user_allow_other"  >> $FILE
    fi
	chmod 644 $FILE
fi

