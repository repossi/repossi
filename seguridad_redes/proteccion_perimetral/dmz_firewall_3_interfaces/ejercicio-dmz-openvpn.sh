#!/bin/bash

# Descripcion
TITULO="Practica DMZ y VPN"
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


# Crear imagenes

MV_DENTRO="DENTRO_$ID"
if [ ! -e "$DIR_BASE/$MV_DENTRO" ]; then
# Solo 1 vez
VBoxManage createvm  --name ${MV_DENTRO} --basefolder "$DIR_BASE" --register    
VBoxManage storagectl ${MV_DENTRO} --name ${MV_DENTRO}_storage  --add sata     
VBoxManage storageattach ${MV_DENTRO} --storagectl ${MV_DENTRO}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE" --mtype multiattach 
VBoxManage storageattach ${MV_DENTRO} --storagectl ${MV_DENTRO}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm ${MV_DENTRO} --memory 128 --pae on
VBoxManage modifyvm ${MV_DENTRO} --nic1 intnet --intnet1 vlan1 --macaddress1 080027111111  

VBoxManage guestproperty set ${MV_DENTRO} /ssi/num_interfaces 1
VBoxManage guestproperty set ${MV_DENTRO} /ssi/eth0/type static
VBoxManage guestproperty set ${MV_DENTRO} /ssi/eth0/address 10.10.10.11
VBoxManage guestproperty set ${MV_DENTRO} /ssi/eth0/netmask 24
VBoxManage guestproperty set ${MV_DENTRO} /ssi/default_gateway 10.10.10.1
# VBoxManage guestproperty set ${MV_DENTRO} /ssi/default_nameserver 193.147.87.2
VBoxManage guestproperty set ${MV_DENTRO} /ssi/host_name dentro.esei.net
VBoxManage guestproperty set ${MV_DENTRO} /ssi/etc_hosts_dump "dentro.esei.net:10.10.10.11,dmz.esei.net:10.20.20.22,firewall3.esei.net:10.10.10.1,fuera:193.147.87.33"
fi

MV_DMZ="DMZ_$ID"
if [ ! -e "$DIR_BASE/$MV_DMZ" ]; then
# Solo 1 vez
VBoxManage createvm  --name ${MV_DMZ} --basefolder "$DIR_BASE" --register    
VBoxManage storagectl ${MV_DMZ} --name ${MV_DMZ}_storage  --add sata     
VBoxManage storageattach ${MV_DMZ} --storagectl ${MV_DMZ}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE" --mtype multiattach 
VBoxManage storageattach ${MV_DMZ} --storagectl ${MV_DMZ}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm ${MV_DMZ} --memory 128 --pae on
VBoxManage modifyvm ${MV_DMZ} --nic1 intnet --intnet1 vlan2 --macaddress1 080027222222  

VBoxManage guestproperty set ${MV_DMZ} /ssi/num_interfaces 1
VBoxManage guestproperty set ${MV_DMZ} /ssi/eth0/type static
VBoxManage guestproperty set ${MV_DMZ} /ssi/eth0/address 10.20.20.22
VBoxManage guestproperty set ${MV_DMZ} /ssi/eth0/netmask 24
VBoxManage guestproperty set ${MV_DMZ} /ssi/default_gateway 10.20.20.1
# VBoxManage guestproperty set ${MV_DMZ} /ssi/default_nameserver 193.147.87.2
VBoxManage guestproperty set ${MV_DMZ} /ssi/host_name dmz.esei.net
VBoxManage guestproperty set ${MV_DMZ} /ssi/etc_hosts_dump "dmz.esei.net:10.20.20.22,dentro.esei.net:10.10.10.11,firewall3.esei.net:10.20.20.1,fuera:193.147.87.33"
fi

MV_FUERA="FUERA_$ID"
if [ ! -e "$DIR_BASE/$MV_FUERA" ]; then
# Solo 1 vez
VBoxManage createvm  --name ${MV_FUERA} --basefolder "$DIR_BASE" --register    
VBoxManage storagectl ${MV_FUERA} --name ${MV_FUERA}_storage  --add sata     
VBoxManage storageattach ${MV_FUERA} --storagectl ${MV_FUERA}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE" --mtype multiattach 
VBoxManage storageattach ${MV_FUERA} --storagectl ${MV_FUERA}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm ${MV_FUERA} --memory 128 --pae on
VBoxManage modifyvm ${MV_FUERA} --nic1 intnet --intnet1 vlan3 --macaddress1 080027333333 

VBoxManage guestproperty set ${MV_FUERA} /ssi/num_interfaces 1
VBoxManage guestproperty set ${MV_FUERA} /ssi/eth0/type static
VBoxManage guestproperty set ${MV_FUERA} /ssi/eth0/address 193.147.87.33
VBoxManage guestproperty set ${MV_FUERA} /ssi/eth0/netmask 24
VBoxManage guestproperty set ${MV_FUERA} /ssi/default_gateway 193.147.87.1
# VBoxManage guestproperty set ${MV_FUERA} /ssi/default_nameserver 193.147.87.2
VBoxManage guestproperty set ${MV_FUERA} /ssi/host_name fuera
VBoxManage guestproperty set ${MV_FUERA} /ssi/etc_hosts_dump "fuera:193.147.87.33,firewall3.esei.net:193.147.87.47"
fi

MV_FIREWALL3="FIREWALL3_$ID"
if [ ! -e "$DIR_BASE/$MV_FIREWALL3" ]; then
# Solo 1 vez
VBoxManage createvm  --name ${MV_FIREWALL3} --basefolder "$DIR_BASE" --register    
VBoxManage storagectl ${MV_FIREWALL3} --name ${MV_FIREWALL3}_storage  --add sata     
VBoxManage storageattach ${MV_FIREWALL3} --storagectl ${MV_FIREWALL3}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE" --mtype multiattach 
VBoxManage storageattach ${MV_FIREWALL3} --storagectl ${MV_FIREWALL3}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm ${MV_FIREWALL3} --memory 512 --pae on
VBoxManage modifyvm ${MV_FIREWALL3} --nic1 intnet --intnet1 vlan1 --macaddress1 080027444444
VBoxManage modifyvm ${MV_FIREWALL3} --nic2 intnet --intnet2 vlan2 --macaddress2 080027555555
VBoxManage modifyvm ${MV_FIREWALL3} --nic3 intnet --intnet3 vlan3 --macaddress3 080027666666

VBoxManage guestproperty set ${MV_FIREWALL3} /ssi/num_interfaces 3
VBoxManage guestproperty set ${MV_FIREWALL3} /ssi/eth0/type static
VBoxManage guestproperty set ${MV_FIREWALL3} /ssi/eth0/address 10.10.10.1
VBoxManage guestproperty set ${MV_FIREWALL3} /ssi/eth0/netmask 24
VBoxManage guestproperty set ${MV_FIREWALL3} /ssi/eth1/type static
VBoxManage guestproperty set ${MV_FIREWALL3} /ssi/eth1/address 10.20.20.1
VBoxManage guestproperty set ${MV_FIREWALL3} /ssi/eth1/netmask 24
VBoxManage guestproperty set ${MV_FIREWALL3} /ssi/eth2/type static
VBoxManage guestproperty set ${MV_FIREWALL3} /ssi/eth2/address 193.147.87.47
VBoxManage guestproperty set ${MV_FIREWALL3} /ssi/eth2/netmask 24
VBoxManage guestproperty set ${MV_FIREWALL3} /ssi/default_gateway 193.147.87.1
# VBoxManage guestproperty set ${MV_FIREWALL3} /ssi/default_nameserver 193.147.87.2
VBoxManage guestproperty set ${MV_FIREWALL3} /ssi/host_name firewall3.esei.net
VBoxManage guestproperty set ${MV_FIREWALL3} /ssi/etc_hosts_dump "firewall3.esei.net:193.147.87.47,dmz.esei.net:10.20.20.22,dentro.esei.net:10.10.10.11,fuera:193.147.87.33"
fi

# Cada vez que se quiera arrancar (o directamente desde el interfaz grafico)
VBoxManage startvm ${MV_DENTRO}
VBoxManage startvm ${MV_DMZ}
VBoxManage startvm ${MV_FUERA}
VBoxManage startvm ${MV_FIREWALL3}