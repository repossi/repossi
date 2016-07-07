
# Entorno de prácticas {#entorno}

## Imágenes a utilizar {#imagenes}

1. Scripts de instalación
  * para GNU/Linux:
    * Ejecutar desde el directorio de descarga

      ```alumno@pc:~$ bash ejercicio-doble-firewall.sh```

  * para MS Windows (Vista o superior):
    * Ejecutar desde el directorio de descarga

      ```Powershell.exe -executionpolicy bypass -file ejercicio-doble-firewall.ps1 ```

    **NOTAS:**

    *  En ambos scripts la variable ```$DIR_BASE``` especifica donde se   descargarán las imágenes y se crearán las MVs.
        * Por defecto en GNU/Linux será en `$HOME/SSI1516` y en  Windows en `C:\\SSI1516`

        * Puede modificarse antes de lanzar los scripts para hacer la instalación en otro directorio más conveniente (disco externo, etc)

    * Es posible descargar las imágenes comprimidas manualmente (o intercambiarlas con USB), basta descargar los archivos con
    extensión `.vdi.zip` de y copiarlos en el directorio anterior (`$DIR_BASE`) para que el script haga el resto.

2.  El script descargará las siguientes imágenes en el directorio `DIR_BASE` (`$HOME/SSI1516` ó `C:\\SSI1516`)

  * `base.vdi` (1,6 GB comprimida, 4,4 GB descomprimida): Imagen VirtualBox común

     Usuarios configurados.

  **login**  | **password**
  -----------|-----------------:
  `root`     | `purple`
  `usuario1` | `usuario1`

    * `swap2015.vdi`: Imagen VirtualBox de una unidad de disco formateada como SWAP

3.  Se pedirá un identificador (sin espacios) para poder reutilizar las versiones personalizadas de las imágenes creadas

4.  Arrancar las instancias VirtualBOX (si no lo hacen desde el script anterior) desde el interfaz gráfico o desde la línea de comandos.

      VBoxManage startvm ACCESO-<id>
      VBoxManage startvm CONTENCION-<id>
      VBoxManage startvm DENTRO-<id>
      VBoxManage startvm DMZ-<id>
      VBoxManage startvm FUERA-<id>

 **Importante:** Después de finalizar cada  ejercicio terminar la ejecución de la máquina virtual desde línea de comandos con `poweroff` o `sudo poweroff` o desde el interfaz gráfico LXDE.

## Máquinas virtuales y redes creadas

![doble-firewall.png](doble-firewall)

* Redes donde se realizarán los ejercicios:

  * Red interna (10.10.10.0 ... 10.10.10.255): máquina **dentro**
  (_eth0_) [10.10.10.11] + interfaz _eth0_ de **contencion** [10.10.10.1]

  * Red DMZ (10.20.20.0 ... 10.20.20.255): máquina **dmz** (_eth0_) [10.20.20.22] + interfaz _eth1_ de **contencion** [10.20.20.2] + interfaz _eth0_ de **acceso** [10.10.10.1]

  * Red externa (193.147.87.0 ... 193.147.87.255): máquina **fuera** (_eth0_) [193.147.87.33] + interfaz _eth1_ de **acceso**  [193.147.87.47]

* Máquinas virtuales

  * Máquina **dentro**: equipo de la red interna
     * IP: 10.10.10.11
     * Puerta de enlace por defecto: 10.10.10.1
  * Máquina **contención**: cortafuegos de contención, separa la red interna de la DMZ
     * IP en la red interna: 10.10.10.11
     * IP en la DMZ: 10.20.20.2
     * Puerta de enlace por defecto: 10.20.20.1

  * Máquina **dmz**: equipo de la DMZ (con servidores públicos HTTP,HTTPS, SMTP, POP3)
      * IP: 10.20.20.22
      * Puerta de enlace por defecto: 10.20.20.1

  * Máquina **acceso**: cortafuegos de acceso, separa la DMZ de la red externa
      * IP en la DMZ: 10.20.20.1
      * IP en la red externa (pública): 193.147.87.47
    * Máquina **fuera**: equipo de la red externa
      * IP en la red externa (pública): 193.147.87.33

# Preparación previa  {#preparacion}

1.  Servicios arrancados por defecto en todas las máquinas (no es necesario iniciarlos manualmente)
   * servidor web (Apache 2) [**Nota:** puede ser necesario reiniciarlo manualmente con ```service apache2 restart ```]
   * servidor telnet (arrancado por `openbsd-inetd`)
   * servidor ssh (openSSH)
   * servidor ftp (arrancado por `openbsd-inetd`)
   * servidor finger (arrancado por `openbsd-inetd`)
   * servidor MySQL
   * servidor SMTP (postfix)
   * servidores POP3 e IMAP (dovecot)

2.  Habilitar la redirección de tráfico en los dos cortafuegos: **acceso** [10.20.20.1, 193.147.87.47] y **contencion** [10.10.10.1, 10.20.20.2]

        acceso:~#  echo 1 > /proc/sys/net/ipv4/ip_forward

        contencion:~#  echo 1 > /proc/sys/net/ipv4/ip_forward

3.  Ajustar las tablas de enrutado
    * La ruta por defecto (*default gateway*) de la máquina **contención** [10.10.10.1, 10.20.20.2] está establecida hacia la máquina **acceso** [10.20.20.1] para que el tráfico de la red interna pueda salir al exterior.
        *   **Justificación:** Es necesario hacerlo así ya que en el cortafuegos **contención**[10.10.10.1, 10.20.20.2] no hacemos enmascaramiento (SNAT) de la red interna (10.10.10.0/24)

    * En el cortafuegos **acceso**: añadir una ruta que encamine el tráfico hacia las IPs de la red interna (10.10.10.0/24) a través de la IP del cortafuegos **contención** en la DMZ [10.20.20.2]

            acceso:~# route add -net 10.10.10.0/24 gw 10.20.20.2
            acceso:~# route -n

        *   **Justificación:** Es necesario hacerlo así para proporcionar al cortafuegos **acceso** una ruta para encaminar hacia la red interna (10.10.10.0/24) los paquetes de respuesta al tráfico saliente generado por los equipos de la propia red interna (10.10.10.0/24)

    * En los equipos de la DMZ (**dmz** en el ejemplo): añadir una ruta que encamine el tráfico hacia las IPs de la red interna (10.10.10.0/24) a través de la IP del cortafuegos **contención** en la DMZ [10.20.20.2]

            dmz:~# route add -net 10.10.10.0/24 gw 10.20.20.2
            dmz:~# route -n

        **Nota:** Sin restricciones adicionales, esta ruta no sería estrictamente necesaria.

         *  La ruta por defecto (*default gateway*) de
            **dmz** [10.20.20.22] encaminará el tráfico hacia la red 10.10.10.0/24 a la máquina 10.20.20.1 que a su vez, empleando la regla anterior, acabará por enviar esos paquetes a la máquina **contención** [10.20.20.2]

         *  No obstante, puesto que en el cortaguegos **acceso**, *Shorewall* decidirá la aceptación o denegación de tráfico en el momento del inicio de conexión, y dado que dichos paquetes de inicio no llegarán a pasar por **acceso**, sino sólo por **contencion**, sí es _necesario establecer esta regla de enrutado_ en las máquinas del DMZ.

# Tarea 1: DMZ con doble firewall usando Shorewall {#tarea1}

El ejercicio consiste en la configuración de los dos cortafuegos **acceso** y **contención** empleando el generador de reglas `iptables` Shorewall.

Material de partida:
* Web de Shoreline Firewall (Shorewall):
* Resumen
* Práctica de CDA 2015/16:

Se pretende conseguir un comportamiento que cumpla las restricciones de filtrado descritas en la sección [sec:requisitos].

Una vez configurados los dos cortafuegos, se deberá comprobar su funcionamiento con escaneos `nmap` o con la herramienta `hping3` desde las máquinas **fuera**, **dmz** y **dentro**.

Restricciones de filtrado a soportar {#sec:requisitos}
------------------------------------

1.  Enmascaramiento (SNAT) de la red interna (10.10.10.0/24) y de la DMZ (10.20.20.0/24) al salir hacia la red externa
2.  Redireccionamiento (DNAT) de los servicios públicos que ofrecerá la red hacia la máquina **dmz** [10.20.20.22] de la DMZ
    1.  peticiones WEB (http y https)
    2.  tráfico de correo saliente (smtp) y entrante (pop3)
3.  Control de tráfico con política *”denegar por defecto”* (DROP)
    1.  desde la red externa sólo se permiten las conexiones hacia la DMZ contempladas en las redirecciones del punto anterior (http,https, smtp, pop3)
    2.  desde la red interna hacia la red externa sólo se permite tráfico de tipo WEB y SSH
    3.  desde la red interna hacia la DMZ sólo se permite tráfico WEB (http, https), e-mail (smtp, pop3) y SSH
    4.  desde el servidor SMTP de la red DMZ (máquina **dmz** [10.20.20.22] hacia el exterior se permite la salida de conexiones SMTP (para el reenvío del e-mail saliente)

    5.  desde la máquina **dmz** [10.20.20.22] se permiten conexiones MySQL hacia la máquina **dentro**  [10.10.10.11] de la red interna

    6.  se permite la salida a la red externa de las consultas DNS originadas en la red interna y en la DMZ

    7.  los dos firewalls sólo admiten conexiones SSH desde la red interna

4.  Registro (log) de los intentos de acceso no contemplados.

## Configuración del cortafuegos de acceso {#configuracion_acceso}

El cortafuegos de acceso regula el tráfico entre la red externa y los equipos de la DMZ y de la red interna.

En nuestro caso, además de las responsabilidades de filtrado del tráfico entrante y/o saliente se debe de encargar de la traducción de direcciones.

  * Enmascaramiento (SNAT) de las direcciones de la DMZ (10.20.20.0/24) y de la red interna (10.10.10.0/24) en el tráfico saliente hacia la red externa.

  * Redirección del tráfico procedente de la red externa hacia los servicios públicos de la DMZ (en este caso HTTP, HTTPS, SMTP y POP3 en la máquina **dmz**)

Existen varias alternativas para implementar este cortafuegos, pero la más sencilla es emplear un esquema con **tres zonas** basado en el esquema *”Parallel Zones”* del documento de Shorewall

   *  Dado que varias zonas (`dmz` y `loc`) ”comparten” un interfaz (_eth0_), se declarará ese interfaz en el fichero `interfaces`, pero sin vincularlo a ninguna zona. Por lo que será necesario hacer uso del fichero `/etc/hosts` para distinguirlas en base a los rangos de direcciones IP empleados en cada caso.

   *  Más información: , ,

![image](zonas_acceso)

## Configuración del cortafuegos de contención {#cortafuegos_contencion}

El cortafuegos de contención regula el tráfico entre la red interna y los equipo de la DMZ y de la red externa.

En nuestro caso no se contempla traducción de direcciones: el enmascaramiento (SNAT) de la red interna se delega en el cortafuegos de acceso y el acceso a la DMZ se realiza con las propias direcciones de la red interna [10.10.10.0/24] (requiere fijar adecuadamente las tablas de enrutado, como se hizo al incio).

Existen varias alternativas para implementar este cortafuegos, pero la más sencilla es emplear un esquema con **tres zonas** basado en el esquema *”Nested Zones”* del documento de Shorewall

   * Dado que varias zonas (`dmz` y `net`) ”comparten” un interfaz (_eth1_) será necesario hacer uso del fichero `/etc/hosts` para distinguirlas en base a los rangos de direcciones IP empleados en cada caso.

   * No obstante, en este caso no es posible separar las zonas `dmz` y `net` en base a rangos de direcciones IP (la zona `net` puede tener cualquier dirección IP pública).

   La estrategia a seguir consitirá a vincular el interfaz _eth1_ a la zona `net` y especificar en el fichero `zones` qye `dmz:net` es una subzona dentro de `net`, empleando el fichero `/etc/hosts` para caracterizarla en base a sus direcciones.

   * Más información: , , ,

![image](zonas_contencion)

# Documentación y entrega {#documentacion}

El material entregable de este ejercicio constará de una pequeña memoria (máximo 3-4 páginas) cubriendo los siguientes puntos

1.  Tarea 1: DMZ con doble firewall
    * Descripción del filtrado realizado por cada cortafuegos
    * Detallar la configuración Shorewall empleada en cada uno de los  dos cortafuegos (**acceso** y **contención**) explicando las   decisiones tomadas.
    * Descripción de las pruebas de funcionamiento realizadas para    verificar el cumplimiento de los requisitos indicados en la  sección [sec:requisitos] y los resultados obtenidos.

**Nota:** en las comprobaciones realizadas con `nmap` incluir la  opción `-Pn`

* Esta opción omite la verificación de accesibilidad de los hosts escaneados empleando mensajes Ping
* Con la configuración por defecto, en caso de que los cortafuegos bloquearan el tráfico ICMP, `nmap! omitiría el escaneo
