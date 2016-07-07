#!/bin/bash

# Descripcion
TITULO="Ejercicio IDS Snort"
CURSO="Seguridad en Sistemas de Información 2015/16"


URL_BASE=http://ccia.ei.uvigo.es/docencia/SSI-grado/1516/practicas

DIR_BASE=$HOME/SSI1516
IMAGEN_BASE_SNORT=$DIR_BASE/base_snort.vdi
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
preparar_imagen "swap2015"   $URL_BASE  $DIR_BASE
preparar_imagen "base_snort" $URL_BASE  $DIR_BASE



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

MV_OPENVAS="OPENVAS_$ID"
if [ ! -e "$BASE_DIR/$MV_OPENVAS" ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_OPENVAS --basefolder "$BASE_DIR" --register    
VBoxManage storagectl $MV_OPENVAS --name ${MV_OPENVAS}_storage  --add sata     
VBoxManage storageattach $MV_OPENVAS --storagectl ${MV_OPENVAS}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE_SNORT" --mtype multiattach
VBoxManage storageattach $MV_OPENVAS --storagectl ${MV_OPENVAS}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_OPENVAS --memory 1024 --pae on
VBoxManage modifyvm $MV_OPENVAS --nic1 intnet --intnet1 vlan2 --macaddress1 080027111111  

VBoxManage guestproperty set $MV_OPENVAS /ssi/num_interfaces 1
VBoxManage guestproperty set $MV_OPENVAS /ssi/eth0/type static
VBoxManage guestproperty set $MV_OPENVAS /ssi/eth0/address 193.147.87.47
VBoxManage guestproperty set $MV_OPENVAS /ssi/eth0/netmask 24
VBoxManage guestproperty set $MV_OPENVAS /ssi/default_gateway 193.147.87.1
VBoxManage guestproperty set $MV_OPENVAS /ssi/default_nameserver 8.8.8.8
VBoxManage guestproperty set $MV_OPENVAS /ssi/host_name openvas.ssi.net
VBoxManage guestproperty set $MV_OPENVAS /ssi/etc_hosts_dump "openvas.ssi.net:193.147.87.47,borde.ssi.net:193.147.87.1,snort.ssi.net:10.10.10.11"
fi

MV_SNORT="SNORT_$ID"
if [ ! -e $PWD/$MV_SNORT ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_SNORT --basefolder "$BASE_DIR" --register    
VBoxManage storagectl $MV_SNORT --name ${MV_SNORT}_storage  --add sata     
VBoxManage storageattach $MV_SNORT --storagectl ${MV_SNORT}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE_SNORT" --mtype multiattach
VBoxManage storageattach $MV_SNORT --storagectl ${MV_SNORT}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_SNORT --memory 512 --pae on
VBoxManage modifyvm $MV_SNORT --nic1 intnet --intnet1 vlan1 --macaddress1 080027111133  

VBoxManage guestproperty set $MV_SNORT /ssi/num_interfaces 1
VBoxManage guestproperty set $MV_SNORT /ssi/eth0/type static
VBoxManage guestproperty set $MV_SNORT /ssi/eth0/address 10.10.10.11
VBoxManage guestproperty set $MV_SNORT /ssi/eth0/netmask 24
VBoxManage guestproperty set $MV_SNORT /ssi/default_gateway 10.10.10.1
VBoxManage guestproperty set $MV_SNORT /ssi/default_nameserver 8.8.8.8
VBoxManage guestproperty set $MV_SNORT /ssi/host_name snort.ssi.net
VBoxManage guestproperty set $MV_SNORT /ssi/etc_hosts_dump "openvas.ssi.net:193.147.87.47,borde.ssi.net:10.10.10.1,snort.ssi.net:10.10.10.11"
fi

MV_BORDE="BORDE_$ID"
if [ ! -e $PWD/$MV_BORDE ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_BORDE --basefolder "$BASE_DIR" --register    
VBoxManage storagectl $MV_BORDE --name ${MV_BORDE}_storage  --add sata     
VBoxManage storageattach $MV_BORDE --storagectl ${MV_BORDE}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE_SNORT" --mtype multiattach
VBoxManage storageattach $MV_BORDE --storagectl ${MV_BORDE}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_BORDE --memory 128 --pae on
VBoxManage modifyvm $MV_BORDE --nic1 intnet --intnet1 vlan1 --macaddress1 080027111133  
VBoxManage modifyvm $MV_BORDE --nic2 intnet --intnet2 vlan2 --macaddress3 080027111434  
VBoxManage modifyvm $MV_BORDE --nic3 nat --macaddress3 080027111222


VBoxManage guestproperty set $MV_BORDE /ssi/num_interfaces 3
VBoxManage guestproperty set $MV_BORDE /ssi/eth0/type static
VBoxManage guestproperty set $MV_BORDE /ssi/eth0/address 10.10.10.1
VBoxManage guestproperty set $MV_BORDE /ssi/eth0/netmask 24
VBoxManage guestproperty set $MV_BORDE /ssi/eth1/type static
VBoxManage guestproperty set $MV_BORDE /ssi/eth1/address 193.147.87.1
VBoxManage guestproperty set $MV_BORDE /ssi/eth1/netmask 24
VBoxManage guestproperty set $MV_BORDE /ssi/eth2/type static
VBoxManage guestproperty set $MV_BORDE /ssi/eth2/address 10.0.4.15
VBoxManage guestproperty set $MV_BORDE /ssi/eth2/netmask 24
VBoxManage guestproperty set $MV_BORDE /ssi/default_gateway 10.0.4.2
VBoxManage guestproperty set $MV_BORDE /ssi/default_nameserver 8.8.8.8
VBoxManage guestproperty set $MV_BORDE /ssi/host_name borde.ssi.net
VBoxManage guestproperty set $MV_BORDE /ssi/etc_hosts_dump "openvas.ssi.net:193.147.87.47,snort.ssi.net:10.10.10.11"
fi


# Cada vez que se quiera arrancar (o directamente desde el interfaz grafico)
VBoxManage startvm $MV_SNORT
VBoxManage startvm $MV_OPENVAS
VBoxManage startvm $MV_BORDE

