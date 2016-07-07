#!/bin/bash

# Descripcion
TITULO="Ejemplo Metasploit"
CURSO="Seguridad en Sistemas de Información 2014/15"

## Imagenes
#ATACANTE=atacante.vdi
#METASPLOITABLE=Metasploitable2.vdi
#SWAP=swap2015.vdi

URL_BASE=http://ccia.ei.uvigo.es/docencia/SSI-grado/1516/practicas
#URL_ATACANTE=$URL_BASE/$ATACANTE.zip
#URL_METASPLOTABLE=$URL_BASE/$METASPLOITABLE.zip
#URL_SWAP=$URL_BASE/$SWAP.zip

DIR_BASE=$HOME/SSI1516
IMAGEN_ATACANTE=$DIR_BASE/atacante.vdi
IMAGEN_METASPLOITABLE=$DIR_BASE/Metasploitable2.vdi
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
preparar_imagen "atacante"         $URL_BASE  $DIR_BASE
preparar_imagen "swap2015"         $URL_BASE  $DIR_BASE
preparar_imagen "Metasploitable2"  $URL_BASE  $DIR_BASE



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



MV_ATACANTE="ATACANTE_$ID"
if [ ! -e "$DIR_BASE/$MV_ATACANTE" ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_ATACANTE --basefolder "$DIR_BASE" --register    
VBoxManage storagectl $MV_ATACANTE --name ${MV_ATACANTE}_storage  --add sata     
VBoxManage storageattach $MV_ATACANTE --storagectl ${MV_ATACANTE}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_ATACANTE" --mtype multiattach
VBoxManage storageattach $MV_ATACANTE --storagectl ${MV_ATACANTE}_storage --port 1 --device 0 --type hdd --medium "$IMAGEN_SWAP" --mtype immutable 
VBoxManage modifyvm $MV_ATACANTE --memory 2048 --pae on
VBoxManage modifyvm $MV_ATACANTE --nic1 intnet --intnet1 vlan1 --macaddress1 080027111111  

VBoxManage guestproperty set $MV_ATACANTE /DSBOX/num_interfaces 1
VBoxManage guestproperty set $MV_ATACANTE /DSBOX/eth0/type static
VBoxManage guestproperty set $MV_ATACANTE /DSBOX/eth0/address 198.51.100.111
VBoxManage guestproperty set $MV_ATACANTE /DSBOX/eth0/netmask 24
VBoxManage guestproperty set $MV_ATACANTE /DSBOX/default_gateway 198.51.100.1
VBoxManage guestproperty set $MV_ATACANTE /DSBOX/default_nameserver 8.8.8.8
VBoxManage guestproperty set $MV_ATACANTE /DSBOX/host_name atacante.ssi.net
VBoxManage guestproperty set $MV_ATACANTE /DSBOX/etc_hosts_dump "atacante.ssi.net:198.51.100.111,metasploitable2.ssi.net:198.51.100.222"
fi

MV_METASPLOITABLE="METASPLOITABLE_$ID"
if [ ! -e "$DIR_BASE/$MV_METASPLOITABLE" ]; then
# Solo 1 vez
VBoxManage createvm  --name $MV_METASPLOITABLE --basefolder "$DIR_BASE" --register    
VBoxManage storagectl $MV_METASPLOITABLE --name ${MV_METASPLOITABLE}_storage  --add ide     
VBoxManage storageattach $MV_METASPLOITABLE --storagectl ${MV_METASPLOITABLE}_storage --port 0 --device 0 --type hdd --medium "$IMAGEN_METASPLOITABLE"  --mtype multiattach
VBoxManage modifyvm $MV_METASPLOITABLE --memory 256 --pae on
VBoxManage modifyvm $MV_METASPLOITABLE --nic1 intnet --intnet1 vlan1 --macaddress1 080027222222  

VBoxManage guestproperty set $MV_METASPLOITABLE /DSBOX/num_interfaces 1
VBoxManage guestproperty set $MV_METASPLOITABLE /DSBOX/eth0/type static
VBoxManage guestproperty set $MV_METASPLOITABLE /DSBOX/eth0/address 198.51.100.222
VBoxManage guestproperty set $MV_METASPLOITABLE /DSBOX/eth0/netmask 24
VBoxManage guestproperty set $MV_METASPLOITABLE /DSBOX/default_gateway 198.51.100.1
VBoxManage guestproperty set $MV_METASPLOITABLE /DSBOX/default_nameserver 8.8.8.8
VBoxManage guestproperty set $MV_METASPLOITABLE /DSBOX/host_name metasploitable2.ssi.net
VBoxManage guestproperty set $MV_METASPLOITABLE /DSBOX/etc_hosts_dump "atacante.ssi.net:198.51.100.111,metasploitable2.ssi.net:198.51.100.222"
fi



# Cada vez que se quiera arrancar (o directamente desde el interfaz grafico)
VBoxManage startvm $MV_ATACANTE
VBoxManage startvm $MV_METASPLOITABLE
