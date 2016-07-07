function Extraer-ZIP($file, $destination) {
  $shell = new-object -com shell.application
  $zip = $shell.NameSpace($file)
  $shell.NameSpace($destination).copyhere($zip.items())
}


function Preparar-Imagen($nombre_imagen, $url_base_origen, $dir_base_destino) {
  if(!(Test-Path -Path "$dir_base_destino\$nombre_imagen.vdi"))  {
      if(!(Test-Path -Path "$dir_base_destino\$nombre_imagen.vdi.zip"))  {
           Write-Host "Iniciando descarga de $url_base_origen\$nombre_imagen.vdi.zip ..."
           # Invoke-WebRequest "$url_base_origen\$nombre_imagen.vdi.zip" -OutFile "$dir_base_destino\$nombre_imagen.vdi.zip"
           $web_client = New-Object System.Net.WebClient
           $web_client.DownloadFile("$url_base_origen\$nombre_imagen.vdi.zip", "$dir_base_destino\$nombre_imagen.vdi.zip")
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


$ID = Read-Host "Introducir identificador de las MVs"


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
$MV_DENTRO="DENTRO_$ID"
if (!(Test-Path -Path "$DIR_BASE\$MV_DENTRO"))  {
# Solo 1 vez
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_DENTRO --basefolder `"$DIR_BASE`"  --register" -NoNewWindow -Wait        
  Start-Process $VBOX_MANAGE  "storagectl $MV_DENTRO --name STORAGE_$MV_DENTRO  --add sata" -NoNewWindow -Wait         
  Start-Process $VBOX_MANAGE  "storageattach $MV_DENTRO --storagectl STORAGE_$MV_DENTRO --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_cda.vdi`"  --mtype multiattach " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_DENTRO --storagectl STORAGE_$MV_DENTRO --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap1024.vdi`"  --mtype immutable " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_DENTRO --memory 128 --pae on" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_DENTRO --nic1 intnet --intnet1 vlan1 --macaddress1 080027111111  " -NoNewWindow -Wait    

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_DENTRO /ssi/num_interfaces 1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_DENTRO /ssi/eth0/type static" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_DENTRO /ssi/eth0/address 10.10.10.11" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_DENTRO /ssi/eth0/netmask 24" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_DENTRO /ssi/default_gateway 10.10.10.1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_DENTRO /ssi/host_name dentro.esei.net" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_DENTRO /ssi/etc_hosts_dump `"dentro.esei.net:10.10.10.11,dmz.esei.net:10.20.20.22,firewall3.esei.net:10.10.10.1,fuera:193.147.87.33`" " -NoNewWindow -Wait    
}

$MV_DMZ="DMZ_$ID"
if (!(Test-Path -Path "$DIR_BASE\$MV_DMZ"))  {
# Solo 1 vez
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_DMZ --basefolder `"$DIR_BASE`"  --register " -NoNewWindow -Wait       
  Start-Process $VBOX_MANAGE  "storagectl $MV_DMZ --name STORAGE_$MV_DMZ  --add sata     " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_DMZ --storagectl STORAGE_$MV_DMZ --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_cda.vdi`"  --mtype multiattach " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_DMZ --storagectl STORAGE_$MV_DMZ --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap1024.vdi`"  --mtype immutable " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_DMZ --memory 128 --pae on" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_DMZ --nic1 intnet --intnet1 vlan2 --macaddress1 080027222222  " -NoNewWindow -Wait    

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_DMZ /ssi/num_interfaces 1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_DMZ /ssi/eth0/type static" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_DMZ /ssi/eth0/address 10.20.20.22" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_DMZ /ssi/eth0/netmask 24" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_DMZ /ssi/default_gateway 10.20.20.1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_DMZ /ssi/host_name dmz.esei.net" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_DMZ /ssi/etc_hosts_dump `"dmz.esei.net:10.20.20.22,dentro.esei.net:10.10.10.11,firewall3.esei.net:10.20.20.1,fuera:193.147.87.33`" " -NoNewWindow -Wait    
}

$MV_FUERA="FUERA_$ID"
if (!(Test-Path -Path "$DIR_BASE\$MV_FUERA"))  {
# Solo 1 vez
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_FUERA --basefolder `"$DIR_BASE`"  --register    " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storagectl $MV_FUERA --name STORAGE_$MV_FUERA  --add sata     " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_FUERA --storagectl STORAGE_$MV_FUERA --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_cda.vdi`"  --mtype multiattach " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_FUERA --storagectl STORAGE_$MV_FUERA --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap1024.vdi`"  --mtype immutable " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_FUERA --memory 128 --pae on" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_FUERA --nic1 intnet --intnet1 vlan3 --macaddress1 080027333333 " -NoNewWindow -Wait    

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FUERA /ssi/num_interfaces 1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FUERA /ssi/eth0/type static" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FUERA /ssi/eth0/address 193.147.87.33" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FUERA /ssi/eth0/netmask 24" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FUERA /ssi/default_gateway 193.147.87.1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FUERA /ssi/host_name fuera" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FUERA /ssi/etc_hosts_dump `"fuera:193.147.87.33,firewall3.esei.net:193.147.87.47`" " -NoNewWindow -Wait    
}

$MV_FIREWALL3="FIREWALL3_$ID"
if (!(Test-Path -Path "$DIR_BASE\$MV_FIREWALL3"))  {
# Solo 1 vez
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_FIREWALL3 --basefolder `"$DIR_BASE`"  --register    " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storagectl $MV_FIREWALL3 --name STORAGE_$MV_FIREWALL3  --add sata     " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_FIREWALL3 --storagectl STORAGE_$MV_FIREWALL3 --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_cda.vdi`"  --mtype multiattach " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_FIREWALL3 --storagectl STORAGE_$MV_FIREWALL3 --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap1024.vdi`"  --mtype immutable " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_FIREWALL3 --memory 512 --pae on" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_FIREWALL3 --nic1 intnet --intnet1 vlan1 --macaddress1 080027444444" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_FIREWALL3 --nic2 intnet --intnet2 vlan2 --macaddress2 080027555555" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_FIREWALL3 --nic3 intnet --intnet3 vlan3 --macaddress3 080027666666" -NoNewWindow -Wait    

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FIREWALL3 /ssi/num_interfaces 3" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FIREWALL3 /ssi/eth0/type static" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FIREWALL3 /ssi/eth0/address 10.10.10.1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FIREWALL3 /ssi/eth0/netmask 24" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FIREWALL3 /ssi/eth1/type static" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FIREWALL3 /ssi/eth1/address 10.20.20.1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FIREWALL3 /ssi/eth1/netmask 24" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FIREWALL3 /ssi/eth2/type static" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FIREWALL3 /ssi/eth2/address 193.147.87.47" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FIREWALL3 /ssi/eth2/netmask 24" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FIREWALL3 /ssi/default_gateway 193.147.87.1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FIREWALL3 /ssi/host_name firewall3.esei.net" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_FIREWALL3 /ssi/etc_hosts_dump `"firewall3.esei.net:193.147.87.47,dmz.esei.net:10.20.20.22,dentro.esei.net:10.10.10.11,fuera:193.147.87.33`" " -NoNewWindow -Wait    
}

Write-Host "Arrancando maquinas virtuales ..."
Start-Process $VBOX_MANAGE  "startvm $MV_DENTRO" -NoNewWindow -Wait    
Start-Process $VBOX_MANAGE  "startvm $MV_DMZ" -NoNewWindow -Wait    
Start-Process $VBOX_MANAGE  "startvm $MV_FUERA" -NoNewWindow -Wait    
Start-Process $VBOX_MANAGE  "startvm $MV_FIREWALL3" -NoNewWindow -Wait    

Write-Host "Maquinas virtuales arrancadas"
