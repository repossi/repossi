function Extraer-ZIP($file, $destination) {
  $shell = new-object -com shell.application
  $zip = $shell.NameSpace($file)
  $shell.NameSpace($destination).copyhere($zip.items())
}


function Preparar-Imagen($nombre_imagen, $url_base_origen, $dir_base_destino) {
  if(!(Test-Path -Path "$dir_base_destino\$nombre_imagen.vdi"))  {
      if(!(Test-Path -Path "$dir_base_destino\$nombre_imagen.vdi.zip"))  {
           Write-Host "Iniciando descarga de $url_base_origen/$nombre_imagen.vdi.zip ..."
           $web_client = New-Object System.Net.WebClient
           $web_client.DownloadFile("$url_base_origen/$nombre_imagen.vdi.zip", "$dir_base_destino\$nombre_imagen.vdi.zip")
      }
      Write-Host "Descomprimiendo $dir_base_destino\$nombre_imagen.vdi.zip ..."
      Extraer-Zip "$dir_base_destino\$nombre_imagen.vdi.zip" "$dir_base_destino"
      Remove-Item "$dir_base_destino\$nombre_imagen.vdi.zip"
  }
}


$URL_BASE="http://ccia.ei.uvigo.es/docencia/CDA/1516/practicas"
$DIR_BASE="C:\CDA1516"


if(!(Test-Path -Path $DIR_BASE))  {
   New-Item $DIR_BASE -itemtype directory
}

Preparar-Imagen "swap1024" "$URL_BASE" "$DIR_BASE"
Preparar-Imagen "base_cda" "$URL_BASE" "$DIR_BASE"


$ID = Read-Host "Introducir identificador de las MVs: "


$BASE_VBOX = $env:VBOX_MSI_INSTALL_PATH
if ([string]::IsNullOrEmpty($BASE_VBOX)) {
   $BASE_VBOX = $env:VBOX_INSTALL_PATH
}
if ([string]::IsNullOrEmpty($BASE_VBOX)) {
   $BASE_VBOX = Read-Host "Introducir directorio de instalacion de VirtualBox (habitualmente `"C:\\Archivos de Programa\Oracle\VirtualBox`") :"
}

$VBOX_MANAGE = "$BASE_VBOX\VBoxManage.exe"

echo $VBOX_MANAGE

Write-Host "Configurando maquinas virtuales ..."

# Crear imagenes
$MV_CLIENTE="CLIENTE_$ID"
if (!(Test-Path -Path "$DIR_BASE\$MV_CLIENTE"))  {
# Solo 1 vez
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_CLIENTE --basefolder `"$DIR_BASE`"  --register" -NoNewWindow -Wait        
  Start-Process $VBOX_MANAGE  "storagectl $MV_CLIENTE --name STORAGE_$MV_CLIENTE  --add sata" -NoNewWindow -Wait         
  Start-Process $VBOX_MANAGE  "storageattach $MV_CLIENTE --storagectl STORAGE_$MV_CLIENTE --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_cda.vdi`"  --mtype multiattach " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_CLIENTE --storagectl STORAGE_$MV_CLIENTE --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap1024.vdi`"  --mtype immutable " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_CLIENTE --memory 512 --pae on" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_CLIENTE --nic1 intnet --intnet1 vlan1 --macaddress1 080027111111  " -NoNewWindow -Wait    

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/num_interfaces 1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/eth0/type static" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/eth0/address 193.147.87.33" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/eth0/netmask 24" -NoNewWindow -Wait    
  
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/default_gateway 193.147.87.47" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/host_name cliente" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/etc_hosts_dump `"cliente:193.147.87.33,servidor.esei.net:193.147.87.47`" " -NoNewWindow -Wait    
}

$MV_SERVIDOR1="SERVIDOR1_$ID"
if (!(Test-Path -Path "$DIR_BASE\$MV_SERVIDOR1"))  {
# Solo 1 vez
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_SERVIDOR1 --basefolder `"$DIR_BASE`"  --register " -NoNewWindow -Wait       
  Start-Process $VBOX_MANAGE  "storagectl $MV_SERVIDOR1 --name STORAGE_$MV_SERVIDOR1  --add sata     " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_SERVIDOR1 --storagectl STORAGE_$MV_SERVIDOR1 --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_cda.vdi`"  --mtype multiattach " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_SERVIDOR1 --storagectl STORAGE_$MV_SERVIDOR1 --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap1024.vdi`"  --mtype immutable " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_SERVIDOR1 --nic1 intnet --intnet1 vlan1     --macaddress1 080027222222  " -NoNewWindow -Wait 
  Start-Process $VBOX_MANAGE  "modifyvm $MV_SERVIDOR1 --nic2 intnet --intnet2 heartbeat --macaddress2 080027222233 " -NoNewWindow -Wait    

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SERVIDOR1 /ssi/num_interfaces 1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SERVIDOR1 /ssi/eth1/type static" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SERVIDOR1 /ssi/eth1/address 10.10.10.11" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SERVIDOR1 /ssi/eth1/netmask 24" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SERVIDOR1 /ssi/default_gateway 10.10.10.1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SERVIDOR1 /ssi/host_name servidor1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SERVIDOR1 /ssi/etc_hosts_dump `"servidor1:10.10.10.11,servidor2:10.10.10.22`" " -NoNewWindow -Wait    
}

$MV_SERVIDOR2="SERVIDOR2_$ID"
if (!(Test-Path -Path "$DIR_BASE\$MV_SERVIDOR2"))  {
# Solo 1 vez
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_SERVIDOR2 --basefolder `"$DIR_BASE`"  --register " -NoNewWindow -Wait       
  Start-Process $VBOX_MANAGE  "storagectl $MV_SERVIDOR2 --name STORAGE_$MV_SERVIDOR2  --add sata     " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_SERVIDOR2 --storagectl STORAGE_$MV_SERVIDOR2 --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_cda.vdi`"  --mtype multiattach " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_SERVIDOR2 --storagectl STORAGE_$MV_SERVIDOR2 --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap1024.vdi`"  --mtype immutable " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_SERVIDOR2 --nic1 intnet --intnet1 vlan1     --macaddress1 080027222322  " -NoNewWindow -Wait 
  Start-Process $VBOX_MANAGE  "modifyvm $MV_SERVIDOR2 --nic2 intnet --intnet2 heartbeat --macaddress2 080027222333 " -NoNewWindow -Wait    

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SERVIDOR2 /ssi/num_interfaces 1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SERVIDOR2 /ssi/eth1/type static" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SERVIDOR2 /ssi/eth1/address 10.10.10.22" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SERVIDOR2 /ssi/eth1/netmask 24" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SERVIDOR2 /ssi/default_gateway 10.10.10.1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SERVIDOR2 /ssi/host_name servidor2" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_SERVIDOR2 /ssi/etc_hosts_dump `"servidor1:10.10.10.11,servidor2:10.10.10.22`" " -NoNewWindow -Wait    
}



Write-Host "Arrancando maquinas virtuales ..."
 Start-Process $VBOX_MANAGE  "startvm $MV_CLIENTE" -NoNewWindow -Wait    
 Start-Process $VBOX_MANAGE  "startvm $MV_SERVIDOR1" -NoNewWindow -Wait    
 Start-Process $VBOX_MANAGE  "startvm $MV_SERVIDOR2" -NoNewWindow -Wait    
Write-Host "Maquinas virtuales arrancadas"
