#!/bin/bash

# Descripcion
TITULO="Ejemplo Wireshark y NMAP"
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
#!/bin/bash




MV_INTERNO1="INTERNO1_$ID"
if [ ! -e "$DIR_BASE/$MV_INTERNO1" ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_INTERNO1 --basefolder "$DIR_BASE" --register    
VBoxManage storagectl $MV_INTERNO1 --name ${MV_INTERNO1}_storage  --add sata     
VBoxManage storageattach $MV_INTERNO1 --storagectl ${MV_INTERNO1}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE" --mtype multiattach 
VBoxManage storageattach $MV_INTERNO1 --storagectl ${MV_INTERNO1}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_INTERNO1 --memory 256 --pae on
VBoxManage modifyvm $MV_INTERNO1 --nic1 intnet --intnet1 vlan1 --macaddress1 080027111111  

VBoxManage guestproperty set $MV_INTERNO1 /DSBOX/num_interfaces 1
VBoxManage guestproperty set $MV_INTERNO1 /DSBOX/eth0/type static
VBoxManage guestproperty set $MV_INTERNO1 /DSBOX/eth0/address 192.168.100.11
VBoxManage guestproperty set $MV_INTERNO1 /DSBOX/eth0/netmask 24
VBoxManage guestproperty set $MV_INTERNO1 /DSBOX/default_gateway 192.168.100.1
# VBoxManage guestproperty set $MV_INTERNO1 /DSBOX/default_nameserver 193.147.87.2
VBoxManage guestproperty set $MV_INTERNO1 /DSBOX/host_name interno1.ssi.net
VBoxManage guestproperty set $MV_INTERNO1 /DSBOX/etc_hosts_dump "interno1.ssi.net:192.168.100.11,interno2.ssi.net:192.168.100.22,observador.ssi.net:192.168.100.33"
fi

MV_INTERNO2="INTERNO2_$ID"
if [ ! -e "$DIR_BASE/$MV_INTERNO2" ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_INTERNO2 --basefolder "$DIR_BASE" --register    
VBoxManage storagectl $MV_INTERNO2 --name ${MV_INTERNO2}_storage  --add sata     
VBoxManage storageattach $MV_INTERNO2 --storagectl ${MV_INTERNO2}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE" --mtype multiattach 
VBoxManage storageattach $MV_INTERNO2 --storagectl ${MV_INTERNO2}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_INTERNO2 --memory 256 --pae on
VBoxManage modifyvm $MV_INTERNO2 --nic1 intnet --intnet1 vlan1 --macaddress1 080027222222  

VBoxManage guestproperty set $MV_INTERNO2 /DSBOX/num_interfaces 1
VBoxManage guestproperty set $MV_INTERNO2 /DSBOX/eth0/type static
VBoxManage guestproperty set $MV_INTERNO2 /DSBOX/eth0/address 192.168.100.22
VBoxManage guestproperty set $MV_INTERNO2 /DSBOX/eth0/netmask 24
VBoxManage guestproperty set $MV_INTERNO2 /DSBOX/default_gateway 192.168.100.1
# VBoxManage guestproperty set $MV_INTERNO2 /DSBOX/default_nameserver 193.147.87.2
VBoxManage guestproperty set $MV_INTERNO2 /DSBOX/host_name interno2.ssi.net
VBoxManage guestproperty set $MV_INTERNO2 /DSBOX/etc_hosts_dump "interno1.ssi.net:192.168.100.11,interno2.ssi.net:192.168.100.22,observador.ssi.net:192.168.100.33"
fi

MV_OBSERVADOR="OBSERVADOR_$ID"
if [ ! -e "$DIR_BASE/$MV_OBSERVADOR" ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_OBSERVADOR --basefolder "$DIR_BASE" --register    
VBoxManage storagectl $MV_OBSERVADOR --name ${MV_OBSERVADOR}_storage  --add sata     
VBoxManage storageattach $MV_OBSERVADOR --storagectl ${MV_OBSERVADOR}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_BASE" --mtype multiattach 
VBoxManage storageattach $MV_OBSERVADOR --storagectl ${MV_OBSERVADOR}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_OBSERVADOR --memory 512 --pae on
VBoxManage modifyvm $MV_OBSERVADOR --nic1 intnet --intnet1 vlan1 --macaddress1 080027333333 --nicpromisc1 allow-all 

VBoxManage guestproperty set $MV_OBSERVADOR /DSBOX/num_interfaces 1
VBoxManage guestproperty set $MV_OBSERVADOR /DSBOX/eth0/type static
VBoxManage guestproperty set $MV_OBSERVADOR /DSBOX/eth0/address 192.168.100.33
VBoxManage guestproperty set $MV_OBSERVADOR /DSBOX/eth0/netmask 24
VBoxManage guestproperty set $MV_OBSERVADOR /DSBOX/default_gateway 192.168.100.1
# VBoxManage guestproperty set $MV_OBSERVADOR /DSBOX/default_nameserver 193.147.87.2
VBoxManage guestproperty set $MV_OBSERVADOR /DSBOX/host_name observador.ssi.net
VBoxManage guestproperty set $MV_OBSERVADOR /DSBOX/etc_hosts_dump "interno1.ssi.net:192.168.100.11,interno2.ssi.net:192.168.100.22,observador.ssi.net:192.168.100.33"
fi

# Cada vez que se quiera arrancar (o directamente desde el interfaz grafico)
VBoxManage startvm $MV_INTERNO1
VBoxManage startvm $MV_INTERNO2
VBoxManage startvm $MV_OBSERVADOR
