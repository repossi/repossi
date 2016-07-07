#!/bin/bash

#!/bin/bash

# Descripcion
TITULO="Ejeercicio doble firewall con Shorewall"
CURSO="Seguridad en Sistemas de Información 2015/16"


URL_BASE=http://ccia.ei.uvigo.es/docencia/SSI-grado/1516/practicas

DIR_BASE=$HOME/SSI1516
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



# Crear/arrancar imagenes
MV_DENTRO="DENTRO_$ID"
if [ ! -e "$DIR_BASE/$MV_DENTRO" ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_DENTRO --basefolder "$DIR_BASE" --register    
VBoxManage storagectl $MV_DENTRO --name ${MV_DENTRO}_storage  --add sata     
VBoxManage storageattach $MV_DENTRO --storagectl ${MV_DENTRO}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE" --mtype multiattach 
VBoxManage storageattach $MV_DENTRO --storagectl ${MV_DENTRO}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_DENTRO --memory 128 --pae on
VBoxManage modifyvm $MV_DENTRO --nic1 intnet --intnet1 vlan1 --macaddress1 080027111111  

VBoxManage guestproperty set $MV_DENTRO /DSBOX/num_interfaces 1
VBoxManage guestproperty set $MV_DENTRO /DSBOX/eth0/type static
VBoxManage guestproperty set $MV_DENTRO /DSBOX/eth0/address 10.10.10.11
VBoxManage guestproperty set $MV_DENTRO /DSBOX/eth0/netmask 24
VBoxManage guestproperty set $MV_DENTRO /DSBOX/default_gateway 10.10.10.1
VBoxManage guestproperty set $MV_DENTRO /DSBOX/host_name dentro.esei.net
VBoxManage guestproperty set $MV_DENTRO /DSBOX/etc_hosts_dump "dentro.esei.net:10.10.10.11,dmz.esei.net:10.20.20.22,contencion.esei.net:10.10.10.1,acceso.esei.net:10.20.20.1,fuera:193.147.87.33"
fi

MV_DMZ="DMZ_$ID"
if [ ! -e "$DIR_BASE/$MV_DMZ" ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_DMZ --basefolder "$DIR_BASE" --register    
VBoxManage storagectl $MV_DMZ --name ${MV_DMZ}_storage  --add sata     
VBoxManage storageattach $MV_DMZ --storagectl ${MV_DMZ}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE" --mtype multiattach 
VBoxManage storageattach $MV_DMZ --storagectl ${MV_DMZ}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_DMZ --memory 128 --pae on
VBoxManage modifyvm $MV_DMZ --nic1 intnet --intnet1 vlan2 --macaddress1 080027222222  

VBoxManage guestproperty set $MV_DMZ /DSBOX/num_interfaces 1
VBoxManage guestproperty set $MV_DMZ /DSBOX/eth0/type static
VBoxManage guestproperty set $MV_DMZ /DSBOX/eth0/address 10.20.20.22
VBoxManage guestproperty set $MV_DMZ /DSBOX/eth0/netmask 24
VBoxManage guestproperty set $MV_DMZ /DSBOX/default_gateway 10.20.20.1
VBoxManage guestproperty set $MV_DMZ /DSBOX/host_name dmz.esei.net
VBoxManage guestproperty set $MV_DMZ /DSBOX/etc_hosts_dump "dmz.esei.net:10.20.20.22,dentro.esei.net:10.10.10.11,contencion.esei.net:10.20.20.2,acceso.esei.net:10.20.20.1,fuera:193.147.87.33"
fi

MV_FUERA="FUERA_$ID"
if [ ! -e "$DIR_BASE/$MV_FUERA" ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_FUERA --basefolder "$DIR_BASE" --register    
VBoxManage storagectl $MV_FUERA --name ${MV_FUERA}_storage  --add sata     
VBoxManage storageattach $MV_FUERA --storagectl ${MV_FUERA}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE" --mtype multiattach 
VBoxManage storageattach $MV_FUERA --storagectl ${MV_FUERA}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_FUERA --memory 128 --pae on
VBoxManage modifyvm $MV_FUERA --nic1 intnet --intnet1 vlan3 --macaddress1 080027333333 

VBoxManage guestproperty set $MV_FUERA /DSBOX/num_interfaces 1
VBoxManage guestproperty set $MV_FUERA /DSBOX/eth0/type static
VBoxManage guestproperty set $MV_FUERA /DSBOX/eth0/address 193.147.87.33
VBoxManage guestproperty set $MV_FUERA /DSBOX/eth0/netmask 24
VBoxManage guestproperty set $MV_FUERA /DSBOX/default_gateway 193.147.87.1
VBoxManage guestproperty set $MV_FUERA /DSBOX/host_name fuera
VBoxManage guestproperty set $MV_FUERA /DSBOX/etc_hosts_dump "fuera:193.147.87.33,acceso.esei.net:193.147.87.47"
fi

MV_ACCESO="ACCESO_$ID"
if [ ! -e "$DIR_BASE/$MV_ACCESO" ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_ACCESO --basefolder "$DIR_BASE" --register    
VBoxManage storagectl $MV_ACCESO --name ${MV_ACCESO}_storage  --add sata     
VBoxManage storageattach $MV_ACCESO --storagectl ${MV_ACCESO}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE" --mtype multiattach 
VBoxManage storageattach $MV_ACCESO --storagectl ${MV_ACCESO}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_ACCESO --memory 512 --pae on
VBoxManage modifyvm $MV_ACCESO --nic1 intnet --intnet1 vlan2 --macaddress1 080027444444
VBoxManage modifyvm $MV_ACCESO --nic2 intnet --intnet2 vlan3 --macaddress2 080027555555

VBoxManage guestproperty set $MV_ACCESO /DSBOX/num_interfaces 2
VBoxManage guestproperty set $MV_ACCESO /DSBOX/eth0/type static
VBoxManage guestproperty set $MV_ACCESO /DSBOX/eth0/address 10.20.20.1
VBoxManage guestproperty set $MV_ACCESO /DSBOX/eth0/netmask 24
VBoxManage guestproperty set $MV_ACCESO /DSBOX/eth1/type static
VBoxManage guestproperty set $MV_ACCESO /DSBOX/eth1/address 193.147.87.47
VBoxManage guestproperty set $MV_ACCESO /DSBOX/eth1/netmask 24
VBoxManage guestproperty set $MV_ACCESO /DSBOX/default_gateway 193.147.87.1
VBoxManage guestproperty set $MV_ACCESO /DSBOX/host_name acceso.esei.net
VBoxManage guestproperty set $MV_ACCESO /DSBOX/etc_hosts_dump "contencion.esei.net:10.20.20.2,acceso.esei.net:10.20.20.1,dmz.esei.net:10.20.20.22,dentro.esei.net:10.10.10.11,fuera:193.147.87.33"
fi

MV_CONTENCION="CONTENCION_$ID"
if [ ! -e "$DIR_BASE/$MV_CONTENCION" ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_CONTENCION --basefolder "$DIR_BASE" --register    
VBoxManage storagectl $MV_CONTENCION --name ${MV_CONTENCION}_storage  --add sata     
VBoxManage storageattach $MV_CONTENCION --storagectl ${MV_CONTENCION}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE" --mtype multiattach 
VBoxManage storageattach $MV_CONTENCION --storagectl ${MV_CONTENCION}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_CONTENCION --memory 512 --pae on
VBoxManage modifyvm $MV_CONTENCION --nic1 intnet --intnet1 vlan1 --macaddress1 080027555555
VBoxManage modifyvm $MV_CONTENCION --nic2 intnet --intnet2 vlan2 --macaddress2 080027666666

VBoxManage guestproperty set $MV_CONTENCION /DSBOX/num_interfaces 2
VBoxManage guestproperty set $MV_CONTENCION /DSBOX/eth0/type static
VBoxManage guestproperty set $MV_CONTENCION /DSBOX/eth0/address 10.10.10.1
VBoxManage guestproperty set $MV_CONTENCION /DSBOX/eth0/netmask 24
VBoxManage guestproperty set $MV_CONTENCION /DSBOX/eth1/type static
VBoxManage guestproperty set $MV_CONTENCION /DSBOX/eth1/address 10.20.20.2
VBoxManage guestproperty set $MV_CONTENCION /DSBOX/eth1/netmask 24
VBoxManage guestproperty set $MV_CONTENCION /DSBOX/default_gateway 10.20.20.1
VBoxManage guestproperty set $MV_CONTENCION /DSBOX/host_name contencion.esei.net
VBoxManage guestproperty set $MV_CONTENCION /DSBOX/etc_hosts_dump "contencion.esei.net:10.10.10.1,acceso.esei.net:10.20.20.1,dmz.esei.net:10.20.20.22,dentro.esei.net:10.10.10.11,fuera:193.147.87.33"
fi


echo "Arrancando máquinas ...."
# Cada vez que se quiera arrancar (o directamente desde el interfaz grafico)
VBoxManage startvm $MV_DENTRO
VBoxManage startvm $MV_DMZ
VBoxManage startvm $MV_FUERA
VBoxManage startvm $MV_ACCESO
VBoxManage startvm $MV_CONTENCION
echo "Máquinas arrancadas."
