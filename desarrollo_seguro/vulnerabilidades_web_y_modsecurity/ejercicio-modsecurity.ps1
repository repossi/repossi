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

####
####   MAIN
####

$URL_BASE="http://ccia.ei.uvigo.es/docencia/SSI-grado/1516/practicas"
$DIR_BASE="C:\SSI1516"


if(!(Test-Path -Path $DIR_BASE))  {
   New-Item $DIR_BASE -itemtype directory
}

Preparar-Imagen "swap2015" "$URL_BASE" "$DIR_BASE"
Preparar-Imagen "atacante" "$URL_BASE" "$DIR_BASE"
Preparar-Imagen "base"     "$URL_BASE" "$DIR_BASE"


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

$MV_ATACANTE2="ATACANTE2_$ID"
if(!(Test-Path -Path "$DIR_BASE\$MV_ATACANTE2"))  {
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_ATACANTE2 --basefolder `"$DIR_BASE`" --register" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storagectl $MV_ATACANTE2 --name STORAGE_$MV_ATACANTE2  --add sata" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storageattach $MV_ATACANTE2 --storagectl STORAGE_$MV_ATACANTE2 --port 0 --device 0 --type hdd --medium `"$DIR_BASE\atacante.vdi`" --mtype multiattach" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storageattach $MV_ATACANTE2 --storagectl STORAGE_$MV_ATACANTE2 --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap2015.vdi`" --mtype immutable" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_ATACANTE2 --memory 512 --pae on" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_ATACANTE2 --nic1 intnet --intnet1 vlan1 --macaddress1 080027111111" -NoNewWindow -Wait

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE2 /DSBOX/num_interfaces 1" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE2 /DSBOX/eth0/type static" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE2 /DSBOX/eth0/address 198.51.100.11" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE2 /DSBOX/eth0/netmask 24" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE2 /DSBOX/default_gateway 198.51.100.1" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE2 /DSBOX/default_nameserver 8.8.8.8" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE2 /DSBOX/host_name atacante2.ssi.net" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE2 /DSBOX/etc_hosts_dump `"atacante2.ssi.net:198.51.100.11,modsecurity.ssi.net:198.51.100.12`"  " -NoNewWindow -Wait
}

$MV_MODSECURITY="MODSECURITY_$ID"
if(!(Test-Path -Path "$DIR_BASE\$MV_MODSECURITY"))  {
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_MODSECURITY --basefolder `"$DIR_BASE`" --register" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storagectl $MV_MODSECURITY --name STORAGE_$MV_MODSECURITY  --add sata" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storageattach $MV_MODSECURITY --storagectl STORAGE_$MV_MODSECURITY --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base.vdi`"     --mtype multiattach" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storageattach $MV_MODSECURITY --storagectl STORAGE_$MV_MODSECURITY --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap2015.vdi`" --mtype immutable" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_MODSECURITY --memory 512 --pae on" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_MODSECURITY --nic1 intnet --intnet1 vlan1 --macaddress1 080027111112" -NoNewWindow -Wait

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/num_interfaces 1" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/eth0/type static" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/eth0/address 198.51.100.12" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/eth0/netmask 24" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/default_gateway 198.51.100.1" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/default_nameserver 8.8.8.8" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/host_name modsecurity.ssi.net" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/etc_hosts_dump `"modsecurity.ssi.net:198.51.100.12,atacante2.ssi.net:198.51.100.11`"  " -NoNewWindow -Wait
}


Start-Process $VBOX_MANAGE  "startvm $MV_ATACANTE2"
Start-Process $VBOX_MANAGE  "startvm $MV_MODSECURITY"
