function Extraer-ZIP($file, $destination) {
  $shell = new-object -com shell.application
  $zip = $shell.NameSpace($file)
  $shell.NameSpace($destination).copyhere($zip.items())
}


function Preparar-Imagen($nombre_imagen, $url_base_origen, $dir_base_destino) {
  if(!(Test-Path -Path "$dir_base_destino\$nombre_imagen.vdi"))  {
      if(!(Test-Path -Path "$dir_base_destino\$nombre_imagen.vdi.zip"))  {
           Write-Host "Iniciando descarga de $url_base_origen\$nombre_imagen.vdi.zip ..."
           # Invoke-WebRequest "$url_base_origen\$nombre_imagen.vdi.zip"-OutFile "$dir_base_destino\$nombre_imagen.vdi.zip"
           $web_client = New-Object System.Net.WebClient
           $web_client.DownloadFile("$url_base_origen\$nombre_imagen.vdi.zip", "$dir_base_destino\$nombre_imagen.vdi.zip")
      }
      Write-Host "Descomprimiendo $dir_base_destino\$nombre_imagen.vdi.zip ..."
      Extraer-Zip "$dir_base_destino\$nombre_imagen.vdi.zip" "$dir_base_destino"
      Remove-Item "$dir_base_destino\$nombre_imagen.vdi.zip"
  }
}

####
####   MAIN
####

$URL_BASE="http://ccia.ei.uvigo.es/docencia/SSI-grado/1516/practicas"
$DIR_BASE="C:\SSI1516"


if(!(Test-Path -Path $DIR_BASE))  {
   New-Item $DIR_BASE -itemtype directory
}

Preparar-Imagen "swap2015"   "$URL_BASE" "$DIR_BASE"
Preparar-Imagen "base_snort" "$URL_BASE" "$DIR_BASE"


$ID = Read-Host "Introducir identificador de las MVs"


$BASE_VBOX = $env:VBOX_MSI_INSTALL_PATH
if ([string]::IsNullOrEmpty($BASE_VBOX)) {
   $BASE_VBOX = $env:VBOX_INSTALL_PATH
}
if ([string]::IsNullOrEmpty($BASE_VBOX)) {
   $BASE_VBOX = Read-Host "Introducir directorio de instalacion de VirtualBox (habitualente `"C:\\Archivos de Programa\Oracle\VirtualBox`") :"
}

$VBOX_MANAGE = "$BASE_VBOX\VBoxManage.exe"

echo $VBOX_MANAGE

Write-Host "Configurando maquinas virtuales ..."

$MV_OPENVAS="OPENVAS_$ID"
if (!(Test-Path -Path "$DIR_BASE\$MV_OPENVAS"))  {
# Solo 1 vez
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_OPENVAS --basefolder `"$DIR_BASE`" --register " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storagectl $MV_OPENVAS --name STORAGE_$MV_OPENVAS  --add sata   " -NoNewWindow -Wait   
  Start-Process $VBOX_MANAGE  "storageattach $MV_OPENVAS --storagectl STORAGE_$MV_OPENVAS --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_snort.vdi`" --mtype multiattach " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storageattach $MV_OPENVAS --storagectl STORAGE_$MV_OPENVAS --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap2015.vdi`" --mtype immutable  " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_OPENVAS --memory 1024 --pae on " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_OPENVAS --nic1 intnet --intnet1 vlan2 --macaddress1 080027111111  " -NoNewWindow -Wait 

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_OPENVAS /ssi/num_interfaces 1 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_OPENVAS /ssi/eth0/type static " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_OPENVAS /ssi/eth0/address 193.147.87.47 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_OPENVAS /ssi/eth0/netmask 24 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_OPENVAS /ssi/default_gateway 193.147.87.1 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_OPENVAS /ssi/default_nameserver 8.8.8.8 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_OPENVAS /ssi/host_name openvas.ssi.net " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_OPENVAS /ssi/etc_hosts_dump `"openvas.ssi.net:193.147.87.47,borde.ssi.net:193.147.87.1,snort.ssi.net:10.10.10.11`" " -NoNewWindow -Wait
}

$MV_SNORT="SNORT_$ID"
if (!(Test-Path -Path "$DIR_BASE\$MV_SNORT"))  {
# Solo 1 vez
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_SNORT --basefolder `"$DIR_BASE`" --register  " -NoNewWindow -Wait  
  Start-Process $VBOX_MANAGE  "storagectl $MV_SNORT --name STORAGE_$MV_SNORT  --add sata   " -NoNewWindow -Wait   
  Start-Process $VBOX_MANAGE  "storageattach $MV_SNORT --storagectl STORAGE_$MV_SNORT --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_snort.vdi`" --mtype multiattach " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storageattach $MV_SNORT --storagectl STORAGE_$MV_SNORT --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap2015.vdi`" --mtype immutable  " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_SNORT --memory 512 --pae on " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_SNORT --nic1 intnet --intnet1 vlan1 --macaddress1 080027111133   " -NoNewWindow -Wait

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SNORT /ssi/num_interfaces 1 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SNORT /ssi/eth0/type static " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SNORT /ssi/eth0/address 10.10.10.11 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SNORT /ssi/eth0/netmask 24 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SNORT /ssi/default_gateway 10.10.10.1 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SNORT /ssi/default_nameserver 8.8.8.8 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SNORT /ssi/host_name snort.ssi.net " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SNORT /ssi/etc_hosts_dump `"openvas.ssi.net:193.147.87.47,borde.ssi.net:10.10.10.1,snort.ssi.net:10.10.10.11`" " -NoNewWindow -Wait
}

$MV_BORDE="BORDE_$ID"
if (!(Test-Path -Path "$DIR_BASE\$MV_BORDE"))  {
# Solo 1 vez
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_BORDE --basefolder `"$DIR_BASE`" --register  " -NoNewWindow -Wait   
  Start-Process $VBOX_MANAGE  "storagectl $MV_BORDE --name STORAGE_$MV_BORDE  --add sata     " -NoNewWindow -Wait 
  Start-Process $VBOX_MANAGE  "storageattach $MV_BORDE --storagectl STORAGE_$MV_BORDE --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_snort.vdi`" --mtype multiattach " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storageattach $MV_BORDE --storagectl STORAGE_$MV_BORDE --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap2015.vdi`" --mtype immutable  " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_BORDE --memory 128 --pae on " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_BORDE --nic1 intnet --intnet1 vlan1 --macaddress1 080027111133   " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_BORDE --nic2 intnet --intnet2 vlan2 --macaddress3 080027111434  " -NoNewWindow -Wait 
  Start-Process $VBOX_MANAGE  "modifyvm $MV_BORDE --nic3 nat --macaddress3 080027111222 " -NoNewWindow -Wait


  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BORDE /ssi/num_interfaces 3 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BORDE /ssi/eth0/type static " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BORDE /ssi/eth0/address 10.10.10.1 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BORDE /ssi/eth0/netmask 24 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BORDE /ssi/eth1/type static " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BORDE /ssi/eth1/address 193.147.87.1 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BORDE /ssi/eth1/netmask 24 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BORDE /ssi/eth2/type static " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BORDE /ssi/eth2/address 10.0.4.15 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BORDE /ssi/eth2/netmask 24 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BORDE /ssi/default_gateway 10.0.4.2 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BORDE /ssi/default_nameserver 8.8.8.8 " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BORDE /ssi/host_name borde.ssi.net " -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BORDE /ssi/etc_hosts_dump `"openvas.ssi.net:193.147.87.47,snort.ssi.net:10.10.10.11`" " -NoNewWindow -Wait
}


echo "Arrancando máquinas ...."
  Start-Process $VBOX_MANAGE  "startvm $MV_SNORT" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "startvm $MV_OPENVAS" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "startvm $MV_BORDE" -NoNewWindow -Wait
echo "Máquinas arrancadas."


