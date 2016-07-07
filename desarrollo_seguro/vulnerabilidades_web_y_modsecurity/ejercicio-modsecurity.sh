#!/bin/bash

# Descripcion
TITULO="Ejemplo Mod-Security"
CURSO="Seguridad en Sistemas de Información 2015/16"

## Imagenes
#ATACANTE2=atacante.vdi
#MODSECURITY=Metasploitable2.vdi
#SWAP=swap2015.vdi

URL_BASE=http://ccia.ei.uvigo.es/docencia/SSI-grado/1516/practicas
#URL_ATACANTE2=$URL_BASE/$ATACANTE.zip
#URL_MODSECURITY=$URL_BASE/$MODSECURITY.zip
#URL_SWAP=$URL_BASE/$SWAP.zip

DIR_BASE=$HOME/SSI1516
IMAGEN_ATACANTE2=$DIR_BASE/atacante.vdi
IMAGEN_BASE=$DIR_BASE/base.vdi
IMAGEN_SWAP=$DIR_BASE/swap2015.vdi



preparar_imagen() {
  local NOMBRE_IMAGEN=$1
  local URL_BASE_ORIGEN=$2
  local DIR_BASE_DESTINO=$3
  
  local URL_ORIGEN=$URL_BASE_ORIGEN/$1.vdi.zip  
  local IMAGEN_DESTINO=$DIR_BASE_DESTINO/$1.vdi
  
  if [ ! -e $IMAGEN_DESTINO ];
  then
     if [ ! -e $DIR_BASE_DESTINO/$1.vdi.zip ];
     then
        echo "Descargando imagen $URL_ORIGEN ... "
        cd $DIR_BASE_DESTINO
        wget --continue $URL_ORIGEN
     fi
     echo "Descomprimiendo imagen $IMAGEN_DESTINO ... "
     unzip $1.vdi.zip
     rm $1.vdi.zip
  fi
}

# Crear directorio base
if [ ! -e $DIR_BASE ];
then
  echo "Creando directorio $DIR_BASE ..."
  mkdir -p $DIR_BASE
fi


# Descargar imagenes base
preparar_imagen "atacante" $URL_BASE  $DIR_BASE
preparar_imagen "swap2015" $URL_BASE  $DIR_BASE
preparar_imagen "base"     $URL_BASE  $DIR_BASE



# Leer ID
DIALOG=`which dialog`

if [ ! $DIALOG ]; 
then
   echo "$TITULO -- $CURSO"
   echo -n "Introducir un identificador único (sin espacios) [+ ENTER]: "
   read ID;
else
  $DIALOG --title "$TITULO" --backtitle "$CURSO" \
          --inputbox "Introducir un identificador único (sin espacios): " 8 50  2> /tmp/ID.txt
  ID=`head -1 /tmp/ID.txt`
fi
#!/bin/bash



MV_ATACANTE2="ATACANTE2_$ID"
if [ ! -e "$DIR_BASE/$MV_ATACANTE2" ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_ATACANTE2 --basefolder "$DIR_BASE" --register    
VBoxManage storagectl $MV_ATACANTE2 --name ${MV_ATACANTE2}_storage  --add sata     
VBoxManage storageattach $MV_ATACANTE2 --storagectl ${MV_ATACANTE2}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_ATACANTE2" --mtype multiattach
VBoxManage storageattach $MV_ATACANTE2 --storagectl ${MV_ATACANTE2}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_ATACANTE2 --memory 512 --pae on
VBoxManage modifyvm $MV_ATACANTE2 --nic1 intnet --intnet1 vlan1 --macaddress1 080027111111  

VBoxManage guestproperty set $MV_ATACANTE2 /DSBOX/num_interfaces 1
VBoxManage guestproperty set $MV_ATACANTE2 /DSBOX/eth0/type static
VBoxManage guestproperty set $MV_ATACANTE2 /DSBOX/eth0/address 198.51.100.11
VBoxManage guestproperty set $MV_ATACANTE2 /DSBOX/eth0/netmask 24
VBoxManage guestproperty set $MV_ATACANTE2 /DSBOX/default_gateway 198.51.100.1
VBoxManage guestproperty set $MV_ATACANTE2 /DSBOX/default_nameserver 8.8.8.8
VBoxManage guestproperty set $MV_ATACANTE2 /DSBOX/host_name atacante2.ssi.net
VBoxManage guestproperty set $MV_ATACANTE2 /DSBOX/etc_hosts_dump "atacante2.ssi.net:198.51.100.11,modsecurity.ssi.net:198.51.100.12"
fi


MV_MODSECURITY="MODSECURITY_$ID"
if [ ! -e "$DIR_BASE/$MV_MODSECURITY" ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_MODSECURITY --basefolder "$DIR_BASE" --register    
VBoxManage storagectl $MV_MODSECURITY --name ${MV_MODSECURITY}_storage  --add sata     
VBoxManage storageattach $MV_MODSECURITY --storagectl ${MV_MODSECURITY}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE" --mtype multiattach
VBoxManage storageattach $MV_MODSECURITY --storagectl ${MV_MODSECURITY}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_MODSECURITY --memory 512 --pae on
VBoxManage modifyvm $MV_MODSECURITY --nic1 intnet --intnet1 vlan1 --macaddress1 080027111112

VBoxManage guestproperty set $MV_MODSECURITY /DSBOX/num_interfaces 1
VBoxManage guestproperty set $MV_MODSECURITY /DSBOX/eth0/type static
VBoxManage guestproperty set $MV_MODSECURITY /DSBOX/eth0/address 198.51.100.12
VBoxManage guestproperty set $MV_MODSECURITY /DSBOX/eth0/netmask 24
VBoxManage guestproperty set $MV_MODSECURITY /DSBOX/default_gateway 198.51.100.1
VBoxManage guestproperty set $MV_MODSECURITY /DSBOX/default_nameserver 8.8.8.8
VBoxManage guestproperty set $MV_MODSECURITY /DSBOX/host_name modsecurity.ssi.net
VBoxManage guestproperty set $MV_MODSECURITY /DSBOX/etc_hosts_dump "modsecurity.ssi.net:198.51.100.12,atacante2.ssi.net:198.51.100.11"
fi


# Cada vez que se quiera arrancar (o directamente desde el interfaz grafico)
VBoxManage startvm $MV_ATACANTE2
VBoxManage startvm $MV_MODSECURITY
