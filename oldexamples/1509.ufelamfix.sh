#!/bin/bash

### Ojo GoogleCode ya no deja modificar y estará listo para acceder por svn hasta enero de 2016... Es hora de pensar alternativas. De momento puedo incorporar scripts alojados en otro sitio (pe dropbox) a RSCRIPTS, pero debo buscar otra solución al generador de paquetes.... -> GIT
## Script con ajustes que no puedo realizar en el SVN

DS="https://dl.dropboxusercontent.com/u/10562198/prj15/uies"
ESTESCRIPT="$DS/1509.ufelamfix.sh"


echo "#################### #################### #################### "
echo "# nuevos paquetes"
echo "####################"
PKGS="$PKGS  openscad freecad winff libjpeg62 "
echo "# paquetes a actualizar"
echo "####################"

PKGS="$PKGS  wine "
PKGS="$PKGS  firefox adobe-flashplugin google-chrome-stable"
PKGS="$PKGS  libreoffice-sdbc-hsqldb "  # drivers bases de datos

apt-get --assume-yes --force-yes install $PKGS


echo "#################### #################### #################### "
echo "# qtodotxt"
echo "####################"


#http://dl.bintray.com/mnantern/deb/qtodotxt_1.4.0_all.deb
DEBFILE="qtodotxt_1.4.0_all.deb"

if ! [ -f /var/cache/apt/archives/${DEBFILE} ] ; then
	cd /var/cache/apt/archives
	wget -c http://dl.bintray.com/mnantern/deb/qtodotxt_1.4.0_all.deb
fi
dpkg -i /var/cache/apt/archives/$DEBFILE
apt-get --assume-yes --force-yes install -f 
## Sera necesario -f para que busque el resto de paquetes?

echo "#################### #################### #################### "
echo "# arduino"
echo "####################"

set -e

#http://arduino.googlecode.com/files/arduino-1.0.4-linux32.tgz
#http://arduino.googlecode.com/files/arduino-1.0.5-linux32.tgz
#http://downloads.arduino.cc/arduino-1.6.5-r5-linux32.tar.xz
VER="1.6.5-r5-linux32" 
VERF="1.6.5-r5"
VER="1.6.7-linux32" 
VERF="1.6.7"

## if ! [ -f /var/cache/apt/archives/${DEBFILE} ] ; then
if ! grep "ARDUINO 1.6.7"  "/usr/share/arduino/revisions.txt"  ; then
	cd /usr/share/pixmaps
	wget -c http://arduino.cc/en/pub/skins/arduinoUno/img/logo.png -O arduino.png


	if ! [ -f /var/cache/apt/archives/arduino-${VER}.tar.xz ] ; then
		cd /var/cache/apt/archives
		wget -c http://downloads.arduino.cc/arduino-${VER}.tar.xz
	fi

cd /usr/share
#tar -xf /var/cache/apt/archives/arduino-${VER}.tgz
echo "..descomprimiendo /var/cache/apt/archives/arduino-${VER}.tar.xz"
tar -xf /var/cache/apt/archives/arduino-${VER}.tar.xz
rm -Rf arduino
mv arduino-${VERF} arduino
#~ rm /var/cache/apt/archives/arduino-${VER}.tgz



cat > /usr/share/applications/arduino.desktop << EOF
[Desktop Entry]
Type=Application
Name=arduino
Name[xx]=arduino
GenericName=Program Atmegas the easy way
Exec=/usr/share/arduino/arduino
Icon=arduino
Terminal=false
Categories=Development;Education;Electronics;

EOF
else echo " Arduino ${VER} ya parece instalado "
fi

echo "#################### #################### #################### "
echo "# web2board para tarjetas de bq"
echo "# utilidad para bitbloq2 para que pueda detectar tarjeta"
echo "####################"




CACHE="/var/cache/apt/archives"
ARCHIVE=web2board32bit.tar.gz

## Comprueba si ya esta instalada esta version
if ! grep "2015"  "/usr/share/web2board32bit/src/web2board.py"  ; then



cd /usr/share/pixmaps
### wget -c http://diwo.bq.com/wp-content/uploads/2015/03/bitbloq_first.png -O bitbloq.png
wget -c https://raw.githubusercontent.com/bq/web2board/master/res/common/Web2board.ico


#apt-get --assume-yes --force-yes install gcc-avr avr-libc avrdude python-wxgtk2.8 

cd /var/cache/apt/archives
if ! [ -f ${CACHE}/${ARCHIVE} ] ; then
	cd $CACHE
	wget -c http://bitbloq.com.s3.amazonaws.com/dev/qa/linux/32bit/${ARCHIVE}
fi

cd /usr/share
tar -xf ${CACHE}/${ARCHIVE}

cat > /usr/share/applications/web2board.desktop << EOF
[Desktop Entry]
Type=Application
Name=Web2Board
Name[xx]=Web2Board
GenericName=Electronic Robotics
##Exec=bash -c 'sudo python /usr/share/web2board32bit/src/web2board.py'
##Exec=xterm -bg black -fg wheat -e "sudo python /usr/share/web2board32bit/src/web2board.py;printf '______\nMantener esta ventana abierta. Para terminar  pulsa para cerrar  ';read"
Exec=xterm -bg black -fg wheat -e "sudo python /usr/share/web2board32bit/src/web2board.py"
Icon=Web2board
Terminal=true
Categories=Development;Engineering;Electronics

EOF

else echo " Web2board  ya parece instalado "
fi




echo "#################### #################### #################### "
echo "# fritzing"
echo "####################"



#http://fritzing.org/download/0.9.2b/linux-32bit/fritzing-0.9.2b.linux.i386.tar.bz2


CACHE="/var/cache/apt/archives"
VER="0.9.2b.linux.i386"
ARCHIVE=fritzing-${VER}.tar.bz2

## Comprueba si ya esta instalada esta version
if ! grep "0.9.2b"  "/usr/share/fritzing/fritzing.rc"  ; then



cd /usr/share/pixmaps
#~ wget -c https://upload.wikimedia.org/wikipedia/commons/e/ed/Fritzing_icon.png -O fritzing.png
wget -c http://upload.wikimedia.org/wikipedia/commons/thumb/e/ed/Fritzing_icon.png/300px-Fritzing_icon.png -O fritzing.png



if ! [ -f ${CACHE}/${ARCHIVE} ] ; then
	cd $CACHE
	#~ wget -c http://fritzing.org/download/0.7.11b/linux-32bit/${ARCHIVE}
	wget -c http://fritzing.org/download/0.9.2b/linux-32bit/fritzing-0.9.2b.linux.i386.tar.bz2
fi

cd /usr/share
tar -xvjf ${CACHE}/${ARCHIVE}
rm -Rf fritzing
mv fritzing-${VER} fritzing


cat > /usr/share/applications/fritzing.desktop << EOF
[Desktop Entry]
Type=Application
Name=fritzing
Name[xx]=fritzing
GenericName=Electronic Design
Exec=/usr/share/fritzing/Fritzing
Icon=fritzing
Terminal=false
Categories=Development;Engineering;Electronics

EOF

else echo " Fritzing ${VER} ya parece instalado "
fi


echo "#################### #################### #################### "
echo "# Dropbox"
echo "####################"

# https://dl.dropboxusercontent.com/u/17/dropbox-lnx.x86-3.10.6.tar.gz
# https://dl-web.dropbox.com/u/17/dropbox-lnx.x86-1.6.17.tar.gz
# http://www.dropbox.com/download/?plat=lnx.x86

CACHE="/var/cache/apt/archives"
VER="x86-3.10.6"
VER="x86-3.12.5"
ARCHIVE=dropbox-lnx.${VER}.tar.gz
APP=".dropbox-dist"


## Comprueba si ya esta instalada esta version
if ! grep "$VER"  "/usr/share/.dropbox-dist/dropboxd"  ; then


if ! [ -f ${CACHE}/${ARCHIVE} ] ; then
	cd $CACHE
   echo "... downloading daemon..........."
	wget -c http://dl.dropboxusercontent.com/u/17/${ARCHIVE}
   echo "... download dropbox.py.............."
    wget -c  -O dropbox.py https://linux.dropbox.com/packages/dropbox.py

fi

echo "... borra instalacion anterior  ............."
cd /usr/share
rm -Rfv $APP
tar -xzvf ${CACHE}/${ARCHIVE}

cd /usr/bin
echo "... borra ejecutables anteriores de dropbox............."
# mejor deberia guardarlo.. para postremove

rm -Rfv dropbox dropboxd dropbox.py

echo "...  Crea enlaces simbolicos................"
ln -svf /usr/share/$APP/dropbox-lnx.${VER}/dropbox 
ln -svf /usr/share/$APP/dropbox-lnx.${VER}/dropboxd 
cp -fv $CACHE/dropbox.py ./ ; chmod +x dropbox.py


echo "... Descarga icono.........................."
cd /usr/share/pixmaps
wget -c https://cf.dropboxstatic.com/static/images/icons/blue_dropbox_glyph-vflJ8-C5d.png -O dropbox.png


#OLD="Exec=dropbox start -i"
#NEW="Exec=sudo dropbox start"
#FILE=/usr/share/applications/dropbox.desktop
#sed "s/$OLD/$NEW/" $FILE > /tmp/buff ; mv /tmp/buff $FILE


echo "... Escribe desktop........................."
cat > /usr/share/applications/dropbox.desktop << EOF
[Desktop Entry]
Type=Application
Name=dropbox
GenericName=Simplifica tu vida
Exec=/usr/bin/dropbox
Icon=dropbox
Terminal=false
Categories=Network;Utility;

EOF


else echo " Dropbox ${VER} ya parece instalado "
fi




echo "#################### #################### #################### "
echo "# Ajustar menus"
echo "####################"


# Automatically added by dh_installmenu
if [ "$1" = "configure" ] && [ -x "`which update-menus 2>/dev/null`" ]; then
	update-menus
fi
# End automatically added section



echo "#################### #################### #################### "
echo "# Fondo de Escritorio "
echo "####################"

wget  $DS/uies-fondo.png -O /usr/share/pixmaps/uies-fondo.png



echo "#################### #################### #################### "
echo "# create_ap"
echo "# utilidad para crear puntos de acceso. muy util para clase"
echo "####################"

cd /var/cache/apt/archives
ARCHIVE=create_ap/create_ap
if ! [ -f ${CACHE}/${ARCHIVE} ] ; then
	cd $CACHE
	git clone https://github.com/oblique/create_ap
else
	cd $CACHE/create_ap
	git pull
fi
cd $CACHE/create_ap
make install




##echo "#################### #################### #################### "
##echo "# teamviewer: remote desktop including mobile remote"
##echo "####################"

## apt-get install libjpeg62


##ARCHIVE=teamviewer_i386.deb
##if ! [ -f ${CACHE}/${ARCHIVE} ] ; then
##	cd $CACHE
	##wget -c http://download.teamviewer.com/download/teamviewer_i386.deb
	##dpkg -i teamviewer_i386
##fi


echo "#################### #################### #################### "
echo "# Some fix, rc.local"
echo "####################"

echo "## allow ubuntu to use serial ports (arduino....)"
## hay que escribirlo en un script no basta con correrlo ahora
gpasswd --add ubuntu dialout


# de momento lo hago en rc.local pero lo mejor sería dejarlo todo en /etc/init.d/livefix
## pero  luego lo modifica fix.sh 
cat > /etc/rc.local << EOF
#!/bin/sh -e
#
# rc.local
gpasswd --add ubuntu dialout

exit 0

EOF



echo "# Script finalizado"
echo "#################### #################### #################### "





