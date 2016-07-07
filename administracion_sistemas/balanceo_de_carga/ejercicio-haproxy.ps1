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
  Start-Process $VBOX_MANAGE  "modifyvm $MV_CLIENTE --nic2 nat --macaddress2 080027111112   " -NoNewWindow -Wait    

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/num_interfaces 2" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/eth0/type static" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/eth0/address 193.147.87.33" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/eth0/netmask 24" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/eth1/type static" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/eth1/address 10.0.3.15" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/eth1/netmask 24" -NoNewWindow -Wait    
  
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/default_gateway 10.0.3.2" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/host_name cliente" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_CLIENTE /ssi/etc_hosts_dump `"cliente:193.147.87.33,balanceador.esei.net:193.147.87.47`" " -NoNewWindow -Wait    
}

$MV_APACHE1="APACHE1_$ID"
if (!(Test-Path -Path "$DIR_BASE\$MV_APACHE1"))  {
# Solo 1 vez
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_APACHE1 --basefolder `"$DIR_BASE`"  --register " -NoNewWindow -Wait       
  Start-Process $VBOX_MANAGE  "storagectl $MV_APACHE1 --name STORAGE_$MV_APACHE1  --add sata     " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_APACHE1 --storagectl STORAGE_$MV_APACHE1 --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_cda.vdi`"  --mtype multiattach " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_APACHE1 --storagectl STORAGE_$MV_APACHE1 --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap1024.vdi`"  --mtype immutable " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_APACHE1 --memory 128 --pae on --cpuexecutioncap  30 " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_APACHE1 --nic1 intnet --intnet1 vlan2 --macaddress1 080027222222 " -NoNewWindow -Wait    

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_APACHE1 /ssi/num_interfaces 1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_APACHE1 /ssi/eth0/type static" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_APACHE1 /ssi/eth0/address 10.10.10.11" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_APACHE1 /ssi/eth0/netmask 24" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_APACHE1 /ssi/default_gateway 10.10.10.1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_APACHE1 /ssi/host_name apache1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_APACHE1 /ssi/etc_hosts_dump `"balanceador:10.10.10.1,apache2:10.10.10.22`" " -NoNewWindow -Wait    
}

$MV_APACHE2="APACHE2_$ID"
if (!(Test-Path -Path "$DIR_BASE\$MV_APACHE2"))  {
# Solo 1 vez
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_APACHE2 --basefolder `"$DIR_BASE`"  --register " -NoNewWindow -Wait       
  Start-Process $VBOX_MANAGE  "storagectl $MV_APACHE2 --name STORAGE_$MV_APACHE2  --add sata     " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_APACHE2 --storagectl STORAGE_$MV_APACHE2 --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_cda.vdi`"  --mtype multiattach " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_APACHE2 --storagectl STORAGE_$MV_APACHE2 --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap1024.vdi`"  --mtype immutable " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_APACHE2 --memory 128 --pae on --cpuexecutioncap  30 " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_APACHE2 --nic1 intnet --intnet1 vlan2 --macaddress1 080027222223 " -NoNewWindow -Wait    

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_APACHE2 /ssi/num_interfaces 1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_APACHE2 /ssi/eth0/type static" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_APACHE2 /ssi/eth0/address 10.10.10.22" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_APACHE2 /ssi/eth0/netmask 24" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_APACHE2 /ssi/default_gateway 10.10.10.1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_APACHE2 /ssi/host_name apache2" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_APACHE2 /ssi/etc_hosts_dump `"balanceador:10.10.10.1,apache1:10.10.10.11`" " -NoNewWindow -Wait    
}




$MV_BALANCEADOR="BALANCEADOR_$ID"
if (!(Test-Path -Path "$DIR_BASE\$MV_BALANCEADOR"))  {
# Solo 1 vez
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_BALANCEADOR --basefolder `"$DIR_BASE`"  --register    " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storagectl $MV_BALANCEADOR --name STORAGE_$MV_BALANCEADOR  --add sata     " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_BALANCEADOR --storagectl STORAGE_$MV_BALANCEADOR --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_cda.vdi`"  --mtype multiattach " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storageattach $MV_BALANCEADOR --storagectl STORAGE_$MV_BALANCEADOR --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap1024.vdi`"  --mtype immutable " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_BALANCEADOR --memory 128 --pae on" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_BALANCEADOR --nic1 intnet --intnet1 vlan1 --macaddress1 080027444444 " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_BALANCEADOR --nic2 intnet --intnet2 vlan2 --macaddress2 080027555555 " -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "modifyvm $MV_BALANCEADOR --nic3 nat --macaddress3 080027666666" -NoNewWindow -Wait    
  

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BALANCEADOR /ssi/num_interfaces 3" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BALANCEADOR /ssi/eth0/type static" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BALANCEADOR /ssi/eth0/address 193.147.87.47" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BALANCEADOR /ssi/eth0/netmask 24" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BALANCEADOR /ssi/eth1/type static" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BALANCEADOR /ssi/eth1/address 10.10.10.1" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BALANCEADOR /ssi/eth1/netmask 24" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BALANCEADOR /ssi/eth2/type static" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BALANCEADOR /ssi/eth2/address 10.0.4.15" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BALANCEADOR /ssi/eth2/netmask 24" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BALANCEADOR /ssi/default_gateway 10.0.4.2" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BALANCEADOR /ssi/host_name balanceador.esei.net" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_BALANCEADOR /ssi/etc_hosts_dump `"cliente:193.147.87.33,apache1:10.10.10.11,apache2:10.10.10.22`" " -NoNewWindow -Wait    
}

Write-Host "Arrancando maquinas virtuales ..."
Start-Process $VBOX_MANAGE  "startvm $MV_CLIENTE" -NoNewWindow -Wait    
Start-Process $VBOX_MANAGE  "startvm $MV_APACHE1" -NoNewWindow -Wait    
Start-Process $VBOX_MANAGE  "startvm $MV_APACHE2" -NoNewWindow -Wait    
Start-Process $VBOX_MANAGE  "startvm $MV_BALANCEADOR" -NoNewWindow -Wait    

Write-Host "Maquinas virtuales arrancadas"
