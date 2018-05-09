#!/bin/bash

# el siguiente script se llama como una
# porcion de codigo para incluir.


#~ #se deben pasar las siguientes variables
#~ FSRO=/rofs
#~ OUTCASPERFOLDER=$1
#~ FSRO=$2
#~ NUEVADISTRIB="uiesn" 
#~ ESCALA="escala" 
#~ US="ubuntu"   #nombre de usuario live   # de momento no se usa   
#~ CREARSISTEMA="no"
#~ CREARSISTEMA="si"
#~ NUEVAESCALA="mitest" 
#~ NUEVONIVEL="45"
#~ TMP=/tmp
#~ INTERACTIVE="si"
#~ RSCRIPTS=""
#~ image_directory


RW=$TMP/patch/rw
UN=$TMP/patch/un

mkdir -p $OUTCASPERFOLDER

############################
## FUNCIONES

ejecutachroot() {
	CHROOT=$1
	script=$2
	if [ -f "${script}" ] ; then
		echo -e "\nEjecutando script  ${script}..."
		cp "${script}" $CHROOT/tmp/script
		chmod +x $CHROOT/tmp/script
		chroot $CHROOT /tmp/script
		rm $CHROOT/root/tmp/script
	fi
}



asegurapermisos(){
	# a veces por alguna extrana razon se pierden algunos permisos
	# lista tomada con el comando: find /usr -perm 4755
	rt=$1
	scrpt="$1/tmp/scrpt"
	cat > $scrpt << EOF
#! /bin/sh

FILES="/usr/bin/newgrp
/usr/bin/passwd
/usr/bin/chsh
/usr/bin/kpac_dhcp_helper
/usr/bin/arping
/usr/bin/fileshareset
/usr/bin/pkexec
/usr/bin/kgrantpty
/usr/bin/lppasswd
/usr/bin/traceroute6.iputils
/usr/bin/sudo
/usr/bin/mtr
/usr/bin/chfn
/usr/bin/sudoedit
/usr/bin/start_kdeinit
/usr/bin/gpasswd
/usr/lib/openssh/ssh-keysign
/usr/lib/eject/dmcrypt-get-device
/usr/lib/policykit-1/polkit-agent-helper-1
/usr/lib/pt_chown
/usr/lib/chromium-browser/chromium-browser-sandbox
"

for f in $FILES; do chmod -fv 4755 $f; done


EOF
	chmod +x $scrpt
	chroot $rt "/tmp/scrpt"
}

limpiachroot() {
        rt=$1
        scrpt="$1/tmp/scrpt"
        cat > $scrpt << EOF
#! /bin/sh
#if [ -f "/etc/resolv.conf" ] ; then
        #~ apt-get --assume-yes  update
        apt-get --assume-yes  install -f
#        update-python-modules -f
        dpkg --configure -a
        apt-get --assume-yes  clean
        apt-get --assume-yes  autoremove
#        rm /etc/resolv.conf
#fi

#aseguramos sudo
chmod 4755 /usr/bin/sudo

rm -rf /tmp/*
rm -rf /boot/*.bak
rm -rf /root/.bash_history

umount /proc
umount /sys
if grep --quiet  volatile /etc/mtab; then
##if $(grep volatile /etc/mtab) ; then
    umount /lib/modules/*/volatile
fi

#aseguramos que no copiaremos nada de proc
umount /proc
rm -Rf /proc/*

EOF
        chmod +x $scrpt
        chroot $rt "/tmp/scrpt"
        
	asegurapermisos $rt
            
}

manifestchroot() {
        rt=$1
        echo " creando manifest..."
        # ¿Porque no hace correctamente el filesystem.manifest, y lo hace vacío? posiblemente por correr en chroot
        #~ chroot ${rt} dpkg-query -W --showformat='${Package} ${Version}\n' | tee ${rt}/filesystem.manifest
        chroot ${rt} dpkg-query -W --showformat='${Package} ${Version}\n' > ${rt}/filesystem.manifest
        
        # creando el manifest del desktop copiando el otro y eliminando las entradas en REMOVE
        cp -v ${rt}/filesystem.manifest{,-desktop}
        # incluir los de uies uies-casper uies-pendriveinstaller
        REMOVE='uies-casper uies-pendriveinstaller ubiquity casper live-initramfs user-setup discover1 xresprobe os-prober libdebian-installer4'
        for i in $REMOVE
        do
                        sed -i "/${i}/d" ${rt}/filesystem.manifest-desktop
        done
}

#############################


echo "Preparando ... "
fusermount -uz $UN

rm -Rfv $RW $UN
mkdir -pv $RW $UN


if [ "${rofsstring}" = "" ]; then
   rofsstring="${FSRO}=RO"
fi

echo "Montando union en $UN ... con RW: $RW y rofsstring: $rofsstring"
unionfs-fuse -o default_permissions,cow,max_files=32768,allow_other,use_ino,nonempty,dev ${RW}=RW:${rofsstring} ${UN} 

cp -v /etc/resolv.conf $UN/etc/resolv.conf

#~ mount --bind /dev  $UN/dev

#~ mount --bind /proc $UN/proc
#~ mount --bind /sys  $UN/sys

# prevencion de que no  esten creados
rm -Rfv $UN/proc
rm -Rfv $UN/sys

mkdir -p $UN/proc
mkdir -p $UN/sys

#~ chroot $UN mount /proc
chroot $UN mount /sys



## aqui ejecutar script local si la variable SCRIPT
if [ -f "$SCRIPT" ] ; then
	ejecutachroot $UN $SCRIPT
fi


## aqui descargar un script via wget y ejecutarlo si la variable REMOTESCRIPT

if ! [ "$REMOTESCRIPTURL" = "no" ] ; then
	REMSCRIPT=/tmp/rscript.sh
	rm -fv $REMSCRIPT
	echo "Checking $REMOTESCRIPT for KEY  $KEY ..."
	if  ( wget $REMOTESCRIPTURL -O $REMSCRIPT && grep $KEY $REMSCRIPT ) ; then
	 echo "VALID Script"
	 ejecutachroot $UN $REMSCRIPT
	else
	  echo "No fue posible descargar $REMOTESCRIPTURL o bien no contiene el KEY"
	fi
	rm -fv $REMSCRIPT
	echo "Remote Script Finalized"
fi

## aqui descargar una serie de scripts via wget y ejecutarlos si la variable RSCRIPTS
if ! [ "$RSCRIPTS" = "no" ] ; then
	REMSCRIPT=/tmp/rscript.sh
	for REMOTESCRIPTURL in $RSCRIPTS
	do
		rm -fv $REMSCRIPT
		echo ".........................................................................."
		echo "Checking $REMOTESCRIPT for KEY  $KEY ..."
		if  ( wget $REMOTESCRIPTURL -O $REMSCRIPT && grep $KEY $REMSCRIPT ) ; then
		 echo "VALID Script"
		 ejecutachroot $UN $REMSCRIPT
		else
		  echo "No fue posible descargar $REMOTESCRIPTURL o bien no contiene el KEY"
		fi
		rm -fv $REMSCRIPT
		echo "Remote Script $REMOTESCRIPTURL Finalized"
	done
fi



## abrir terminal si la variable TERMINAL
if [ "$ABRIRTERMINAL" = "si" ] ; then
	echo " "
	echo " "
	echo "**********************************************************"
	echo "** Abriendo un bash para control manual, salir con exit **"
	echo "**********************************************************"
	chroot $UN bash
fi


#clean
echo " Limpiando ... "
limpiachroot $UN

umount  $UN/proc
umount  $UN/dev
umount  $UN/sys

echo "########################### GENERANDO ARCHIVOS ############################"
# generar manifest
echo " Generando manifests....."
rm -rfv $UN/filesystem.manif*
manifestchroot $UN

# generar size
echo " Generando size....."
rm -rfv $UN/filesystem.siz*
FILESYSTEMSIZE=`du -sx --block-size=1 $UN | cut -f1`
printf $FILESYSTEMSIZE > $UN/filesystem.size
cat $UN/filesystem.size
echo "...."

# copiar initrd (y kernel y filesystem.* )
### TODO las nuevas isos live no llevan initrd ni kernel dentro, sino en casper....



echo " Instalando  KERNEL........ "
###OJO solo debe borrar y copiar un nuevo kernel si hay uno nuevo listo
if  [ `ls $UN/boot/vmlinu*` ] ; then 
  echo "extrayendo nuevo kernel..." 
	rm -rf $OUTCASPERFOLDER/vmlinu*
	#~ cp -v "$UN/boot/vmlinu"* $OUTCASPERFOLDER
	cp -v "$UN/boot/vmlinu"* $OUTCASPERFOLDER/vmlinuz
else
    echo "no se ha generado un nuevo kernel, se usará el anterior"
	if ! [  -f "$OUTCASPERFOLDER/vmlinuz" ] ; then 
	    echo "no se encuentra kernel anterior, se copiara del casper de la iso source "
		#~ cp -v "$SCD/casper/vmlinu"* $OUTCASPERFOLDER/vmlinuz
		cp -v "$image_directory/vmlinu"* $OUTCASPERFOLDER/vmlinuz
	fi
fi





echo " Instalando INITRD........... "
#EJEMPLO gzip -dc '/home/ubuntu/a/boot/initrd.img-3.5.0-23-generic' | lzma -7 > '/media/_home/tmp/remaster/out/cd/casper/initrd.lz'
if  [ `ls $UN/boot/initrd*` ] ; then
  echo "convirtiendo nueva initrd con compresion lzma..."
  rm -rf $OUTCASPERFOLDER/initrd*
  #cp -v "$UN/boot/initrd"* $OUTCASPERFOLDER
  gzip -dc "$UN/boot/initrd"* | lzma -7 > $OUTCASPERFOLDER/initrd.lz
fi

## filesystem
rm -rf $OUTCASPERFOLDER/filesyste*
cp -v $UN/filesyst* $OUTCASPERFOLDER
rm -rf $UN/filesyste*

echo "########################### GENERANDO SQUASH ############################"
DIA="$(date +%y%m%d%H%M)"

sistema="${NUEVADISTRIB}.00.a.${NUEVAESCALA}.${DIA}.squashfs"
patch="${NUEVADISTRIB}.${NUEVONIVEL}.${ESCALA}.${NUEVAESCALA}.${DIA}.squashfs"


echo "------------------------"
echo " ! Se va a crear el squashfs, aprovechar para realizar alguna edicion en $UN/"
echo "    se creara sistema completo --> $CREARSISTEMA"
if [ "$INTERACTIVE" = "si" ] ; then
    echo " pulsar una tecla para continuar " ; read
fi

if [ "${PRESQUASH}"  != ""  ] && [ -f "${PRESQUASH}" ] ; then
    echo "------------------------"
    echo " ! Including PRESQUASH $PRESQUASH"
    . $PRESQUASH
fi


if [ "$CREARSISTEMA" = "si" ] && [ "$SAMESQUASH" != "si" ] ; then
    rm -rf $OUTCASPERFOLDER/*.squashfs
    rm -rf $OUTCASPERFOLDER/$sistema
    mksquashfs $UN  $OUTCASPERFOLDER/$sistema -e $UN/.unionfs $UN/proc/* $UN/sys/*
else

    if [ "$SAMESQUASH" != "si" ] ; then
        rm -rf $OUTCASPERFOLDER/$patch
        mksquashfs $RW  $OUTCASPERFOLDER/$patch  -e $UN/.unionfs $UN/proc/*  $UN/sys/*
    fi
    # copiar los squashfs anteriores
    echo "Incorporando los squashfs anteriores del patch ...."
    echo "   contenido del casper de origen:"
    #~ ls $SCD/casper
    ls $image_directory
    echo " "
    #~ cp -vu "$SCD/casper/"*.squashfs $OUTCASPERFOLDER/
    cp -vu "$image_directory/"*.squashfs $OUTCASPERFOLDER/
    echo " "
fi


echo "Desmontando... "
fusermount -uz $UN


echo "Limpiando.... "
rm -Rf $RW $UN

