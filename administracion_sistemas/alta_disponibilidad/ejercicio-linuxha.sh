#!/bin/bash

# Descripcion
TITULO="Practica: alta disponibilidad con LinuxHA"
CURSO="Centros de Datos 2015/16"


URL_BASE=http://ccia.ei.uvigo.es/docencia/CDA/1516/practicas
#URL_ATACANTE2=$URL_BASE/$ATACANTE.zip
#URL_MODSECURITY=$URL_BASE/$MODSECURITY.zip
#URL_SWAP=$URL_BASE/$SWAP.zip

DIR_BASE=$HOME/CDA1516
IMAGEN_BASE=$DIR_BASE/base_cda.vdi
IMAGEN_SWAP=$DIR_BASE/swap1024.vdi

preparar_imagen() {
  local NOMBRE_IMAGEN=$1
  local URL_BASE_ORIGEN=$2
  local DIR_BASE_DESTINO=$3
  
  local URL_ORIGEN=$URL_BASE_ORIGEN/$NOMBRE_IMAGEN.vdi.zip  
  local IMAGEN_DESTINO=$DIR_BASE_DESTINO/$NOMBRE_IMAGEN.vdi
  
  if [ ! -e $IMAGEN_DESTINO ];
  then
     if [ ! -e $DIR_BASE_DESTINO/$NOMBRE_IMAGEN.vdi.zip ];
     then
        echo "Descargando imagen $URL_ORIGEN ... "
        cd $DIR_BASE_DESTINO
        wget --continue $URL_ORIGEN
     fi
     echo "Descomprimiendo imagen $IMAGEN_DESTINO ... "
     unzip $NOMBRE_IMAGEN.vdi.zip
     rm $NOMBRE_IMAGEN.vdi.zip
  fi
}

# Crear directorio base
if [ ! -e $DIR_BASE ];
then
  echo "Creando directorio $DIR_BASE ..."
  mkdir -p $DIR_BASE
fi


# Descargar imagenes base
preparar_imagen "swap1024"     $URL_BASE  $DIR_BASE
preparar_imagen "base_cda"     $URL_BASE  $DIR_BASE



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


# Crear/arrancar imagenes
MV_CLIENTE="CLIENTE_$ID"
if [ ! -e "$DIR_BASE/$MV_CLIENTE" ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_CLIENTE --basefolder "$DIR_BASE" --register    
VBoxManage storagectl $MV_CLIENTE --name ${MV_CLIENTE}_storage  --add sata     
VBoxManage storageattach $MV_CLIENTE --storagectl ${MV_CLIENTE}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE" --mtype multiattach 
VBoxManage storageattach $MV_CLIENTE --storagectl ${MV_CLIENTE}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_CLIENTE --memory 512 --pae on
VBoxManage modifyvm $MV_CLIENTE --nic1 intnet --intnet1 vlan1 --macaddress1 080027111111  

VBoxManage guestproperty set $MV_CLIENTE /ssi/num_interfaces 1
VBoxManage guestproperty set $MV_CLIENTE /ssi/eth0/type static
VBoxManage guestproperty set $MV_CLIENTE /ssi/eth0/address 193.147.87.33
VBoxManage guestproperty set $MV_CLIENTE /ssi/eth0/netmask 24
VBoxManage guestproperty set $MV_CLIENTE /ssi/default_gateway 193.147.87.47
VBoxManage guestproperty set $MV_CLIENTE /ssi/default_nameserver 8.8.8.8
VBoxManage guestproperty set $MV_CLIENTE /ssi/host_name cliente
VBoxManage guestproperty set $MV_CLIENTE /ssi/etc_hosts_dump "cliente:193.147.87.33,servidor.esei.net:193.147.87.47"
fi




MV_SERVIDOR1="SERVIDOR1_$ID"
if [ ! -e "$DIR_BASE/$MV_SERVIDOR1" ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_SERVIDOR1 --basefolder "$DIR_BASE" --register    
VBoxManage storagectl $MV_SERVIDOR1 --name ${MV_SERVIDOR1}_storage  --add sata     
VBoxManage storageattach $MV_SERVIDOR1 --storagectl ${MV_SERVIDOR1}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE" --mtype multiattach 
VBoxManage storageattach $MV_SERVIDOR1 --storagectl ${MV_SERVIDOR1}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_SERVIDOR1 --memory 128 --pae on
VBoxManage modifyvm $MV_SERVIDOR1 --nic1 intnet --intnet1 vlan1     --macaddress1 080027222222  
VBoxManage modifyvm $MV_SERVIDOR1 --nic2 intnet --intnet2 heartbeat --macaddress2 080027222233

VBoxManage guestproperty set $MV_SERVIDOR1 /ssi/num_interfaces 2
VBoxManage guestproperty set $MV_SERVIDOR1 /ssi/eth1/type static
VBoxManage guestproperty set $MV_SERVIDOR1 /ssi/eth1/address 10.10.10.11
VBoxManage guestproperty set $MV_SERVIDOR1 /ssi/eth1/netmask 24
VBoxManage guestproperty set $MV_SERVIDOR1 /ssi/default_gateway 10.10.10.1
VBoxManage guestproperty set $MV_SERVIDOR1 /ssi/default_nameserver 8.8.8.8
VBoxManage guestproperty set $MV_SERVIDOR1 /ssi/host_name servidor1
VBoxManage guestproperty set $MV_SERVIDOR1 /ssi/etc_hosts_dump "servidor1:10.10.10.11,servidor2:10.10.10.22"
fi


MV_SERVIDOR2="SERVIDOR2_$ID"
if [ ! -e "$DIR_BASE/$MV_SERVIDOR2" ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_SERVIDOR2 --basefolder "$DIR_BASE" --register    
VBoxManage storagectl $MV_SERVIDOR2 --name ${MV_SERVIDOR2}_storage  --add sata     
VBoxManage storageattach $MV_SERVIDOR2 --storagectl ${MV_SERVIDOR2}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE" --mtype multiattach 
VBoxManage storageattach $MV_SERVIDOR2 --storagectl ${MV_SERVIDOR2}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_SERVIDOR2 --memory 128 --pae on
VBoxManage modifyvm $MV_SERVIDOR2 --nic1 intnet --intnet1 vlan1     --macaddress1 080027222244
VBoxManage modifyvm $MV_SERVIDOR2 --nic2 intnet --intnet2 heartbeat --macaddress2 080027222255


VBoxManage guestproperty set $MV_SERVIDOR2 /ssi/num_interfaces 2
VBoxManage guestproperty set $MV_SERVIDOR2 /ssi/eth1/type static
VBoxManage guestproperty set $MV_SERVIDOR2 /ssi/eth1/address 10.10.10.22
VBoxManage guestproperty set $MV_SERVIDOR2 /ssi/eth1/netmask 24
VBoxManage guestproperty set $MV_SERVIDOR2 /ssi/default_gateway 10.10.10.1
VBoxManage guestproperty set $MV_SERVIDOR2 /ssi/default_nameserver 8.8.8.8
VBoxManage guestproperty set $MV_SERVIDOR2 /ssi/host_name servidor2
VBoxManage guestproperty set $MV_SERVIDOR2 /ssi/etc_hosts_dump "servidor1:10.10.10.11,servidor2:10.10.10.22"
fi



# Cada vez que se quiera arrancar (o directamente desde el interfaz grafico)
VBoxManage startvm $MV_CLIENTE
VBoxManage startvm $MV_SERVIDOR1
VBoxManage startvm $MV_SERVIDOR2
