#!/bin/bash


### OJO
## está en desuso habria que revisarlo, sobre todo el paso de variables
## se usa más remasteriso.sh


#~ crea los componentes de una carpeta casper que se pasa como primer parámetro
#~ a partir de una carpeta con el sistema fuente, que por defecto es el montado en 
#~ /rofs, ya que suponemos corre desde un modo live.


#~ #se deben pasar las siguientes variables
#~ para el codigo como incluido

FSRO=/rofs
rofsstring=""
OUTCASPERFOLDER=/tmp/out
US=ubuntu
NUEVADISTRIB="uiesl" 
ESCALA="gnome" 
#~ CREARSISTEMA="no"
CREARSISTEMA="si"
NUEVAESCALA="big" 
NUEVONIVEL="75"


ABRIRTERMINAL="si"
SCRIPT="/tmp/noscript.sh"
REMOTESCRIPTURL="no"
RSCRIPTS=""  # lista de URLs de scripts a ejecutar en orden
TMP=/tmp

FSRO=$1
OUTCASPERFOLDER=$2
TMP=$3


image_directory=""

##############
MYDIR=`pwd` ; cd `dirname "$0"` ; THISSCRIPTPATH=`pwd` ; cd $MYDIR
##############

 . $THISSCRIPTPATH/remastersquash.inc.sh
