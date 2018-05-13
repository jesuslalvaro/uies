#!/bin/sh

### instala entorno live desde una carpeta casper con squashfs



### ejemplo
### uies/bin/installSKINF.sh '/home/ubuntu-studio/ll/casper' '/home/ubuntu-studio/ll/casper/vmlinuz' '/home/ubuntu-studio/ll/casper/initrd.lz' llinux '/media/ubuntu-studio/LLINUX' 

SQUASHFOLD=$1  # carpeta con squash
KERNEL=$2   
INIT=$3    
NAME=$4  ##NAME=bionicstudio
FOLDER=$5  # carpeta donde instalar 

#####

USER=me
HOST=$NAME

####
mkdir -p $FOLDER/$NAME/livemedia

### COPIAS

cp -uv $KERNEL $FOLDER/$NAME/
cp -uv $INIT $FOLDER/$NAME/
cp -uv $SQUASHFOLD/*.squashfs $FOLDER/$NAME/livemedia/


#### MENU ###
MENU=$FOLDER/$NAME/menu.cfg
rm $MENU

cat > $MENU << EOF

set default=0
set timeout=30

language="console-setup/layoutcode=es locale=es_ES debian-installer/language=es keyboard-configuration/layoutcode=es "
customization="username=$USER hostname=$HOST"

menuentry "$NAME" {
	set gfxpayload=keep
	linux	/$NAME/$(basename "${KERNEL}")  live-media-path=/$NAME/livemedia  \${language} \${customization} file=/cdrom/preseed/xubuntu.seed boot=casper  quiet splash ignore_bootid cdrom-detect/try-usb=true floppy.allowed_drive_mask=0 ignore_uuid root=UUID=DA22-6A73 ---
	initrd	/$NAME/$(basename "${INIT}")
}

EOF

## para escribir en el sistema,
