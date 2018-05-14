#!/bin/sh


###   instala las dos versiones de grub (clasica y EFI) 
###   y escribe un menu inicial
###
###   correr como sudo
### ejemplo
### sudo uies/bin/grubFolderDevice.sh /media/ubuntu-studio/LLINUX /dev/sde


## pendrive formateado como vfat fat32
#FOLDER=/media/ubuntu-studio/LLINUX
#DEVICE=/dev/sdd

FOLDER=$1  

### OJO pendrives con nombres con espacios fallan -> crear un alias en /tmp
ln -s $FOLDER /tmp/fold
FOLDER=/tmp/fold

DEVICE=$2  

apt-get install grub-efi-amd64

##grub-install --target=x86_64-efi --efi-directory=/media/ubuntu-studio/LLINUX/ --bootloader-id=GRUB --root-directory=/media/ubuntu-studio/LLINUX/  /dev/sdd
## grub-install  --root-directory=/media/ubuntu-studio/LLINUX/  /dev/sdd


## doble instalacion de grub: clasica y EFI
grub-install --target=x86_64-efi --efi-directory=$FOLDER --bootloader-id=GRUB --root-directory=$FOLDER --force $DEVICE
grub-install --root-directory=$FOLDER  $DEVICE


### prepara menu grub.cfg con autodeteccion de menus
CFG=$FOLDER/boot/grub/grub.cfg
rm $CFG

cat > $CFG << EOF
     
insmod chain
insmod png
insmod part_msdos
insmod fat
insmod ntfs
insmod syslinuxcfg
insmod cpuid
insmod ext2
insmod all_video
insmod configfile
insmod normal
insmod linux
insmod echo
insmod search
insmod regexp

insmod font
if loadfont /boot/grub/fonts/unicode.pf2 ; then
#if loadfont unicode ; then
	# Use shift key to avoid loading gfxterm
	if keystatus --shift ; then true ; else
        if [ "\${grub_platform}" == "efi" ]; then
            insmod efi_gop
            insmod efi_uga
        else
            insmod vbe
            insmod vga
            set gfxmode=auto
            set gfxpayload=auto
            terminal_output gfxterm 
            if terminal_output gfxterm ; then true ; else
                terminal gfxterm
            fi
        fi
        insmod gfxterm
	fi
fi

set color_normal=white/black
set color_highlight=white/light-blue
export color_normal
export color_highlight

set default=0
set timeout=15

### intentando menus automaticos:
for menufile in /*/menu.cfg; do
    source "\$menufile"
# menuentry "\${menufile}" {
#	configfile "\$menufile"
#	}
done

EOF

## para escribir en el sistema,
## para actualizar, para parches
## usar 
## sudo mount  -o remount,rw /cdrom
