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
Preparar-Imagen "Metasploitable2" "$URL_BASE" "$DIR_BASE"


$ID = Read-Host "Introducir identificador de las MVs"


$VBOX_MANAGE = "$env:VBOX_MSI_INSTALL_PATH\VBoxManage.exe"

echo $VBOX_MANAGE

$MV_ATACANTE="ATACANTE_$ID"
if(!(Test-Path -Path "$DIR_BASE\$MV_ATACANTE"))  {
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_ATACANTE --basefolder `"$DIR_BASE`" --register" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storagectl $MV_ATACANTE --name STORAGE_$MV_ATACANTE  --add sata" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storageattach $MV_ATACANTE --storagectl STORAGE_$MV_ATACANTE --port 0 --device 0 --type hdd --medium `"$DIR_BASE\atacante.vdi`" --mtype multiattach" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storageattach $MV_ATACANTE --storagectl STORAGE_$MV_ATACANTE --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap2015.vdi`" --mtype immutable" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_ATACANTE --memory 2048 --pae on" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_ATACANTE --nic1 intnet --intnet1 vlan1 --macaddress1 080027111111" -NoNewWindow -Wait

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/num_interfaces 1" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/eth0/type static" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/eth0/address 198.51.100.111" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/eth0/netmask 24" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/default_gateway 198.51.100.1" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/default_nameserver 8.8.8.8" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/host_name atacante.ssi.net" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/etc_hosts_dump `"atacante.ssi.net:198.51.100.111,metasploitable2.ssi.net:198.51.100.222`"  " -NoNewWindow -Wait
}

$MV_METASPLOITABLE="METASPLOITABLE_$ID"
if(!(Test-Path -Path "$DIR_BASE\$MV_METASPLOITABLE"))  {
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_METASPLOITABLE --basefolder `"$DIR_BASE`" --register" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storagectl $MV_METASPLOITABLE --name STORAGE_$MV_METASPLOITABLE --add sata" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storageattach $MV_METASPLOITABLE --storagectl STORAGE_$MV_METASPLOITABLE --port 0 --device 0 --type hdd --medium `"$DIR_BASE\Metasploitable2.vdi`" --mtype multiattach" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_METASPLOITABLE --memory 256 --pae on" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_METASPLOITABLE --nic1 intnet --intnet1 vlan1 --macaddress1 080027222222" -NoNewWindow -Wait
}


Start-Process $VBOX_MANAGE  "startvm $MV_ATACANTE"
Start-Process $VBOX_MANAGE  "startvm $MV_METASPLOITABLE"
