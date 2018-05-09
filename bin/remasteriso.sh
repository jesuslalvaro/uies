#!/bin/bash

#~ #######################
#~ uso:
#~ ajustar TMP con un path no FAT32,
#~ ajustar ESCALA, NUEVAESCALA,CREARSISTEMA
#~ 
#~ un ejemplo
#~ ubuntu@ubuntu:~$ sudo /media/MisDatos/uiesdev/remaster/remasteriso.sh /media/LGExternalHDD/tmp/isosuies/uiesl.gnome.1109152209.iso /media/LGExternalHDD/tmp/isosuies  master.auto.conf
#~ #######################

### DONE ONLYISO TODO incorporar preferencia para no tocar el squash (copiarlo y editar solo la iso): es necesario retocar inc
### TODO incorporar script de iso 


## Argumentos Obligatorios
SISO=$1  # iso de partida (SourceISO)
OUT=$2   # carpeta de salida para la iso
#RPREF=$3

## Argumentos Opcionales
RPREF=/etc/remasteriso/remasteriso.conf   #archivo con la configuracion 
if [ "$3"  != ""  ] ; then                # se ajusta inmediatamente
		RPREF=$3
fi

ABRIRTERMINAL="si"  # decide si abre terminal para hacer ajustes/comprobaciones
                    # debe ser "no" para script desatendido
INPUTCASPER=""   # permite utilizar una carpeta como entrada,
                 # evitando la carpeta casper del CD
TMP=/tmp    # espacio temporal de trabajo
            # debe estar en una particion con permisos, no vale FAT32
            # tampoco es recomendable espacio live (nos quedamos sin RAM)
            





# Variables a pasar a remastersquash
#~ #se deben pasar las siguientes variables
#~ para el codigo como incluido

FSRO=/rofs
OUTCASPERFOLDER=""   # se ajustara en función del OCD
US=ubuntu    #nombre de usuario live   # de momento no se usa
NUEVADISTRIB="uiesp" 
ESCALA="ubuntu"       # escala de partida para control de carga alfabetica de patchs

## decidir si se crea un nuevo squashfs con los cambios o simplemente un patch de escala...
#~ CREARSISTEMA="no"
CREARSISTEMA="si"
NUEVAESCALA="base" 
NUEVONIVEL="20"


# uso de script a correr en chroot
SCRIPT="/tmp/noscript.sh"
REMOTESCRIPTURL="no"
KEY="20130331scriptvalido" # clave para validar un script remoto seguridad mínima
RSCRIPTS=""  # lista de URLs de scripts a ejecutar en orden


USAR_PLANTILLA_ISO="no"
PLANTILLA_ISO="/etc/remasteriso/uies.min.isolinux.iso"
ISOLINUX="/etc/remasteriso/isolinux"
MENUISOLINUX=""    # txt.cfg menu para CD (ISOLINUX)
MENUGRUBLOOPBACK=""  # menu para arranque  frugal con grub

KERNELOPTIONS="console-setup/layoutcode=es locale=es_ES  debian-installer/language=es keyboard-configuration/layoutcode=es"
XSESSION="fluxbox"
INTERACTIVE="si" 
ONLYISO = "no"
CREAMENUGRUBLOOPBACK="no"
PRESQUASH=""
PREISO=""
SAMESQUASH="no"   #fuerza el mismo squash anterior


##########################
echo "...............Cargando archivo de preferencias $RPREF ............"
cat $RPREF
 . $RPREF
echo "..................................................................."
##############
MYDIR=`pwd`
cd `dirname "$0"`
THISSCRIPTPATH=`pwd`
cd $MYDIR
##############

# nombre para la distro
NOMBRE=$NUEVADISTRIB.$NUEVAESCALA
echo $NOMBRE
SCRIPT="$THISSCRIPTPATH/gnome.sh"

## ajusta variables a los argumentos
if [ "$3"  != ""  ] ; then
		RPREF=$3
		if [ "$4"  != ""  ] ; then
				ABRIRTERMINAL=$4
			if [ "$5"  != ""  ] ; then
					INPUTCASPER=$5
				if [ "$6"  != ""  ] ; then
						TMP=$6
				fi
			fi
		fi
fi






#~ crea un nuevo sistema live iso a partir de una iso fuente

apt-get install unionfs-fuse squashfs-tools mkisofs

SISO=$1  # iso de partida
SCD=$TMP/remaster/source/cd
RWCD=$TMP/remaster/source/rwcd
OCD=$TMP/remaster/out/cd

SMNT=$TMP/remaster/mnt  #montaje de fuentes
SFS=$TMP/remaster/source/sfs  # source filesystem

OUT=$2   # carpeta de salida para la iso


rm -Rf $SCD $RWCD $OCD $SFS $SMNT
mkdir -p $SCD $RWCD $OCD $SFS $OUT $SMNT

echo "---------------------------- CD -------------------------------"

#~ si se da un directorio montarlo bind no como iso
if [ -d "${SISO}" ]; then
 echo "la entrada $SISO es un directorio, se monta como bind"
 mount -o bind $SISO $SCD
else 
 echo "la entrada $SISO es un archivo, se monta como loop"
 mount -o loop $SISO $SCD
fi

echo "  ! $SCD montado"
if [ "$INTERACTIVE" = "si" ] ; then
    read
fi

BASE_CD=$SCD

#posible uso de una plantilla de CD 
if [ "$USAR_PLANTILLA_ISO" = "si" ] && [ -f "${PLANTILLA_ISO}" ]; then
  BASE_CD=$TMP/remaster/source/templatecd
  rm -Rf $BASE_CD
  mkdir -p $BASE_CD
  mount -o loop $PLANTILLA_ISO $BASE_CD
fi


echo "Montando CD union con RW en ${RWCD}...para hacer cambios a la iso "
unionfs-fuse -o default_permissions,cow,max_files=32768,allow_other,use_ino,nonempty ${RWCD}=RW:${BASE_CD}=RO ${OCD} 
ls -l $OCD/*

echo "   ! la carpeta CD de salida esta montada como union. Pulsar para Continuar"
if [ "$INTERACTIVE" = "si" ] ; then
    read
fi
    

OUTCASPERFOLDER=$OCD/casper

echo "---------------------------SQUASH------------------------------"
# mount source filesystem


####### HAY QUE MONTAR TODAS LAS CAPAS SQUASHFS

image_directory=$SCD/casper

if [ -d "${INPUTCASPER}" ]; then
 echo "Se utilizara como carpeta casper de entrada $INPUTCASPER"
 image_directory=$INPUTCASPER
fi

if [ "${ONLYISO}" = "si" ]; then
    mkdir -p $OUTCASPERFOLDER
echo "--------------------- ONLYISO -----------------------------------"
    ls -l  $OUTCASPERFOLDER/
    echo "Copiando archivos del casper:"
    cp -v "$image_directory/"* $OUTCASPERFOLDER/
    ls -l  $OUTCASPERFOLDER/
echo "-----------------------------------------------------------------"
else

    
    croot=$SMNT
    
    #~ ver /usr/share/initramfs-tools/scripts/casper
    #~ :
    
        #~ # Let's just mount the read-only file systems first
        rofsstring=""
        rofslist=""
        #~ if [ "${UNIONFS}" = "aufs" ]; then
            #~ roopt="rr"
        #~ elif [ "${UNIONFS}" = "unionfs-fuse" ]; then
            roopt="RO"
        #~ else
            #~ roopt="ro"
        #~ fi
    
        #~ mkdir -p "${croot}"
        for image_type in "squashfs" "dir" ; do
            for image in "${image_directory}"/*."${image_type}"; do
                imagename=$(basename "${image}")
                if [ -d "${image}" ]; then
                    # it is a plain directory: do nothing
                    rofsstring="${image}=${roopt}:${rofsstring}"
                    rofslist="${image} ${rofslist}"
                elif [ -f "${image}" ]; then
                    #~ backdev=$(get_backing_device "$image")
                    #~ fstype=$(get_fstype "${backdev}")
                    #~ if [ "${fstype}" = "unknown" ]; then
                        #~ panic "Unknown file system type on ${backdev} (${image})"
                    #~ fi
                    mkdir -p "${croot}/${imagename}"
                    #~ mount -t "${fstype}" -o ro,noatime "${backdev}" "${croot}/${imagename}" || panic "Can not mount $backdev ($image) on ${croot}/${imagename}" && rofsstring="${croot}/${imagename}=${roopt}:${rofsstring}" && rofslist="${croot}/${imagename} ${rofslist}"
                    echo "mounting  ($image) on ${croot}/${imagename}"
                    mount -o loop -t squashfs -o ro,noatime "${image}" "${croot}/${imagename}" || echo "Can not mount ($image) on ${croot}/${imagename}" && rofsstring="${croot}/${imagename}=${roopt}:${rofsstring}" && rofslist="${croot}/${imagename} ${rofslist}"
                fi
             done
        done
        rofsstring=${rofsstring%:}
    #~ 
    
    
    ###########mount -o loop -t squashfs $SCD/casper/*.squashfs $SFS
    
    
    
    ####################################################################################################
     . $THISSCRIPTPATH/remastersquash.inc.sh
    ####################################################################################################
    
    #desmontando filesystem de entrada
    #~ umount $SFS
    for mpoint in $rofslist ; do
      echo "unmounting $mpoint"
      umount $mpoint
    done
      
    
    echo "------------------------ end SQUASH ---------------------------"
    
    
fi


#~ # es necesario editar menu.lst con las nuevas versiones de kernel e init.d
#~ 
#~ OLD=`basename $(ls $SCD/casper/vmlinu*)`
#~ NEW=`basename $(ls $OCD/casper/vmlinu*)`
#~ FILE=$OCD/boot/grub/menu.lst
#~ sed "s/$OLD/$NEW/" $FILE > /tmp/buff ; mv /tmp/buff $FILE
#~ 
#~ OLD=`basename $(ls $SCD/casper/initr*)`
#~ NEW=`basename $(ls $OCD/casper/initr*)`
#~ FILE=$OCD/boot/grub/menu.lst
#~ sed "s/$OLD/$NEW/" $FILE > /tmp/buff ; mv /tmp/buff $FILE

## hay que convertir a initrd.lz
#EJEMPLO gzip -dc '/home/ubuntu/a/boot/initrd.img-3.5.0-23-generic' | lzma -7 > '/media/_home/tmp/remaster/out/cd/casper/initrd.lz'

# crear nueva iso
# limpieza de posibles contenidos de ubuntu
rm -Rf $OCD/wubi.exe $OCD/autorun.inf $OCD/md5sum.txt $OCD/ubuntu  $OCD/preseed $OCD/pool $OCD/pics $OCD/dists


## ajustes de menu isolinux
if [ -d "${ISOLINUX}" ]; then
    echo "Copiando nuevos menus en isolinux..."
    #~ cp -v /etc/remasteriso/isolinux/*  $OCD/isolinux/
    cp -v $ISOLINUX/*  $OCD/isolinux/
fi



cd $OUT
isoname="$NOMBRE.$(date +%y%m%d%H%M).iso"

###################### MENUS #################################################



if [ "${MENUISOLINUX}"  != ""  ] && [ -f "${MENUISOLINUX}" ] ; then
    cp -v $MENUISOLINUX $OCD/isolinux/txt.cfg
else
        cat > $OCD/isolinux/txt.cfg << EOF
     
default live
label live
  menu label Launch ${NOMBRE}
  kernel /casper/vmlinuz
  append  ${KERNELOPTIONS} boot=casper initrd=/casper/initrd.lz quiet splash xsession=${XSESSION} --

EOF
fi

## crear $OCD/boot/grub/loopback.cfg con menu para despues instalarse frugal
## con una preferencia, si no está usar la de la iso de partida $SCD, y si tampoco, usar/crear una por defecto


mkdir -p $OCD/boot/grub
## no es necesario    iso_path="$isoname" se pondra al instalar

if [ "${CREAMENUGRUBLOOPBACK}"  = "si" ]  ; then
        cat > $OCD/boot/grub/loopback.cfg << EOF
     
menuentry "Launch ${isoname} " {
search --set -f "\${iso_path}"
loopback loop "\${iso_path}"
linux (loop)/casper/vmlinuz ${KERNELOPTIONS} iso-scan/filename=\${iso_path} boot=casper noprompt quiet splash  --
initrd (loop)/casper/initrd.lz
}

EOF
else
    if [ "${MENUGRUBLOOPBACK}"  != ""  ] && [ -f "${MENUGRUBLOOPBACK}" ] ; then
       cp -v  $MENUGRUBLOOPBACK  $OCD/boot/grub/loopback.cfg
    else 
        if [ -f "${SCD}/boot/grub/loopback.cfg" ]   ; then
            cp -v ${SCD}/boot/grub/loopback.cfg $OCD/boot/grub/loopback.cfg
        fi
    fi
fi



echo "Creating new iso image: $isoname from directory $OCD/ desde el directorio $OUT"
echo "------------------------"
echo " ! Se va a crear la ISO, aprovechar para realizar alguna edicion en $OCD/"
echo '    como lineas del menu.lst ( "vga=791"  i8042.reset i8042.nomux  ...)'
echo '    o editar para CD, no PenDrive...)'
    
if [ "$INTERACTIVE" = "si" ] ; then
    echo " pulsar una tecla para continuar " ; read
fi

if [ "${PREISO}"  != ""  ] && [ -f "${PREISO}" ] ; then
    echo "------------------------"
    echo " ! Including PREISO $PREISO"
    . $PREISO
fi





echo "------------------------"
ls -l $OUT
ls -l $OCD
echo "-------------------------"
#~ mkisofs -R -posix-L -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table -o  $OUT/$isoname $OCD/
#mkisofs -R -posix-L -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table -o  $OUT/$isoname -x .unionfs $OCD

## iso bootable para isolinux
mkisofs -D -r -V "$NOMBRE" -cache-inodes -J -l  -o $OUT/$isoname  -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -x .unionfs  $OCD


# crea suma md5
md5sum $OUT/$isoname > $OUT/$isoname.md5sum.txt

echo " ! ISO creada "
if [ "$INTERACTIVE" = "si" ] ; then
    echo " Pulsar una tecla para continuar" ; read
fi

# desmontando union CD
fusermount -uz $OCD
# demontando ISO fuente
umount $SCD
if [ "$USAR_PLANTILLA_ISO" = "si" ] && [ -f "${PLANTILLA_ISO}" ]; then
    umount $BASE_CD
fi

# limpiezals
rm -Rf $SCD $RWCD $OCD $SFS

exit 0






