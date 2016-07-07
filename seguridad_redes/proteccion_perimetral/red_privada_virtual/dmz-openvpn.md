Entorno de prácticas
====================

Software de virtualización <span>VirtualBOX</span>
--------------------------------------------------

En estas prácticas se empleará el software de virtualización
<span>VirtualBOX</span> para simular pequeñas redes formadas por equipos
GNU/Linux.

-   Página principal: <http://virtualbox.org>

-   Más información: <http://es.wikipedia.org/wiki/Virtualbox>

Imágenes a utilizar
-------------------

1.  Script de instalación

    -   para GNU/Linux:

        -   Ejecutar desde el directorio de descarga

                             alumno@pc:~$ bash ejercicio-dmz-openvpn.sh
                            

    -   para MS Windows :

        -   Ejecutar desde el directorio de descarga

                               Powershell.exe -executionpolicy bypass -file ejercicio-dmz-openvpn.ps1
                              

    **NOTAS:**

    1.  Se pedirá un identificador (sin espacios) para poder reutilizar
        las versiones personalizadas de las imágenes creadas (usar por
        ejemplo el nombre del grupo de prácticas)

    2.  En ambos scripts la variable `$DIR_BASE` especifica donde se
        descargarán las imágenes y se crearán las MVs.

        -   Por defecto en GNU/Linux será en `$HOME/CDA1516` y en
            Windows en `C:\\CDA1516`

        -   Puede modificarse antes de lanzar los scripts para hacer la
            instalación en otro directorio más conveniente (disco
            externo, etc)

    3.  Es posible descargar las imágenes comprimidas manualmente (o
        intercambiarlas con USB), basta descargar los archivos con
        extensión `.vdi.zip` de y copiarlos en el directorio anterior
        (`$DIR_BASE`) para que el script haga el resto.

2.  El script descargará las siguientes imágenes en el directorio
    `DIR_BASE` (`$HOME/CDA1516` ó `C:\\CDA1516`)

    -   `base_cda.vdi` (0,8 GB comprimida, 2,8 GB descomprimida): Imagen
        genérica (común a todas las MVs) que contiene las herramientas a
        utilizar

        -   Contiene un sistema Debian 7.1 con herramientas gráficas y
            un entorno gráfico ligero <span>LXDE</span> (*Lighweight X11
            Desktop Environment*) .

        -   Usuarios configurados.

              ****login****   ****password****
              --------------- ------------------
              `root`          `purple`
              `usuario1`      `usuario1`

    -   `swap1024.vdi`: Disco de 1 GB formateado como espacio de
        intercambio (SWAP)

3.  (Si no lo hacen desde el script anterior) se pueden arrancar las
    instancias <span>VirtualBOX</span> desde el interfaz gráfico de
    VirtualBOX o desde la línea de comandos.

        VBoxManage startvm DMZ_<id>
        VBoxManage startvm DENTRO_<id>
        VBoxManage startvm FUERA_<id>
        VBoxManage startvm FIREWALL3_<id>

Establecer el entorno virtualizado
----------------------------------

Una vez ejecutado el script se habrán definido las redes y los equipos
virtualizados donde se realizarán los ejercicios:

-   Red interna (10.10.10.0 ... 10.10.10.255): máquina **dentro** (eth0)
    + interfaz eth0 de **firewall3**

-   Red DMZ (10.20.20.0 ... 10.20.20.255): máquina **dmz** (eth0) +
    interfaz eth1 de **firewall3**

-   Red externa (193.147.87.0 ... 193.147.87.255): máquina **fuera**
    (eth0) + interfaz eth2 de **firewall3**

![image](dmz-vpn)

1.  PREVIO 1: Loguearse en las máquinas

    -   como administrador con `root/purple` para realizar directamente
        a las tareas de administración

    -   como usuario normal con `usuario1/usuario1` para realizar las
        tareas de administración mediante comandos `sudo`

    **Nota 1:** en los casos que sea necesario/conveniente, puede
    arrancarse el entorno gráfico con `startx`

                firewall3:~#  startx

                

    **Nota 2:** Para permitir ”copiar y pegar” desde entre anfitrión y
    máquina virtual, además de acceder al entorno gráfico del huésped,
    es preciso habilitar la opción
    `Dispositivos->Portapapeles Compartido->Bidireccional` desde el menú
    de la ventana de VirtualBOX.

2.  PREVIO 2: Habilitar la redirección de tráfico en la máquina
    **firewall3 [10.10.10.1, 10.20.20.1, 193.147.87.47]**

        firewall3:~#  echo 1 > /proc/sys/net/ipv4/ip_forward

3.  PREVIO 3: Arrancar los servicios a utilizar (el servidor ***ssh***
    está activado por defecto).

        dentro:~# /etc/init.d/mysql start
        dentro:~# /etc/init.d/openbsd-inetd start

        dmz:~# /etc/init.d/apache2 start   (servidor web  [80])
        dmz:~# /etc/init.d/postfix start   (servidor smtp [25]) 
        dmz:~# /etc/init.d/dovecot start   (servidor pop3 [110])

        fuera:~# /etc/init.d/apache2 start
        fuera:~# /etc/init.d/openbsd-inetd start
        fuera:~# /etc/init.d/postfix start   

    **Nota:** En la imagen común a todas las máquinas virtuales fue
    habilitado el acceso exterior al servidor MySQL (en principio sólo
    será relevante para la máquina `dentro(10.10.10.11)`)

        dentro~# nano /etc/mysql/my.cnf

             (comentar la linea donde aparece bind-address 127.0.0.1)
             ...
             # bind-address 127.0.0.1
             ...

4.  PREVIO 4: **(a incluir en la memoria entregable)** Escaneo de las
    máquinas del ejercicio para verificar los servicios accesibles
    inicialmente

    -   desde `fuera`:

            fuera:~# nmap -T4 193.147.87.47     [escaneo de firewall3 (unica máquina visible desde fuera)]
            fuera:~# nmap -T4 10.10.10.11       [escaneo de dentro  (fallará)]
            fuera:~# nmap -T4 10.20.20.22       [escaneo de dmz  (fallará)]

    -   desde `dentro`:

            dentro:~# nmap -T4 193.147.87.33     [escaneo de fuera]
            dentro:~# nmap -T4 10.20.20.22       [escaneo de dmz]
            dentro:~# nmap -T4 10.10.10.1        [escaneo de firewall3]

    -   desde `dmz`:

            dmz:~# nmap -T4 193.147.87.33     [escaneo de fuera]
            dmz:~# nmap -T4 10.10.10.11       [escaneo de dentro]
            dmz:~# nmap -T4 10.20.20.1        [escaneo de firewall3]

    -   desde `firewall3`:

            firewall3:~# nmap -T4 193.147.87.33     [escaneo de fuera]
            firewall3:~# nmap -T4 10.10.10.11       [escaneo de dentro]
            firewall3:~# nmap -T4 10.20.20.22       [escaneo de dmz]

Ejercicio 1: Configuración de una DMZ *(DeMilitarized Zone)* usando el generador de firewalls ip-tables Shoreline Firewall (ShoreWall)
======================================================================================================================================

Descripción
-----------

Se desarrollará un ejercicio de configuración básica de un firewall con
DMZ empleando el generador de reglas iptables Shorewall. Se usará un
equipo con tres interfaces para hacer el papel de firewall.

-   Web de Shoreline Firewall (Shorewall) :

-   Resumen

Restriciones de acceso a implementar
------------------------------------

 [sec:requisitos]

1.  Enmascaramiento (SNAT) de la red interna (10.10.10.0/24) y de la DMZ
    (10.20.20.0/24)

2.  Redireccionamiento (DNAT) de los servicios públicos que ofrecerá la
    red hacia la máquina **dentro (10.20.20.22)** de la DMZ

    1.  peticiones WEB (http y https)

    2.  tráfico de correo saliente (smtp) y entrante (pop3)

3.  Control de tráfico con política *”denegar por defecto”* (DROP)

    1.  desde la red externa sólo se permiten las conexiones hacia la
        DMZ contempladas en las redirecciones del punto anterior (http,
        https, smtp, pop3)

    2.  desde la red interna hacia la red externa sólo se permite
        tráfico de tipo WEB y SSH

    3.  desde la red interna hacia la DMZ sólo se permite tráfico WEB
        (http, https), e-mail (smtp, pop3), hacia los respectivos
        servidores, y tráfico SSH para tareas de administración en los
        equipos de la DMZ

    4.  desde el servidor SMTP de la red DMZ (máquina **dmz
        (10.20.20.22)**) hacia el exterior se permite la salida de
        conexiones SMTP (para el reenvío del e-mail saliente)

    5.  desde la máquina **dmz (10.20.20.22)** se permiten conexiones
        MySQL hacia la máquina **dentro (10.10.10.11)** de la red
        interna

    6.  se permite la salida a la red externa de las consultas DNS
        originadas en la red interna y en la DMZ

    7.  firewall sólo admite conexiones SSH desde la red interna para
        tareas de administración

4.  Registro (log) de intentos de acceso no contemplados desde red
    externa a **firewall3 (193.147.87.47)** y a los equipos internos

Pasos a seguir
--------------

Se usará el esquema *three-interfaces* incluido en la distribución
estándar de Shorewall y descrito en .

La plantilla para configurar el firewall está en el directorio
`/usr/share/doc/shorewall/examples/three-interfaces/`

Todas las tareas de configuración de Shorewall se realizarán en la
máquina **firewall3**.

1.  Copiamos y descomprimimos los ficheros de configuración en el
    directorio de configuración de Shorewall (`/etc/shorewall/`)

        firewall3:~#  cd /etc/shorewall
        firewall3:/etc/shorewall# cp /usr/share/doc/shorewall/examples/three-interfaces/* .
        firewall3:/etc/shorewall# gunzip *.gz

2.  Configurar las zonas (`/etc/shorewall/zones`) [lo dejaremos como
    está]

    Tendremos 4 zonas:

    -   el propio firewall (`fw`)

    -   la red externa (`net`)

    -   la red interna (`loc`)

    -   la dmz (`dmz`)

    <!-- -->

        firewall3:/etc/shorewall# leafpad zones &

        ###############################################################################
        #ZONE   TYPE    OPTIONS                 IN                      OUT
        #                                       OPTIONS                 OPTIONS
        fw      firewall
        net     ipv4
        loc     ipv4
        dmz     ipv4
        #LAST LINE - ADD YOUR ENTRIES ABOVE THIS ONE - DO NOT REMOVE 

3.  Configurar los interfaces (`/etc/shorewall/interfaces`)

    Ajustar los interfaces de red de cada zona para que se ajusten a
    nuestra configuración (en columna `INTERFACE`)

        firewall3:/etc/shorewall# leafpad interfaces &

        ###############################################################################
        FORMAT 2
        ###############################################################################
        #ZONE   INTERFACE       OPTIONS
        net     eth2            tcpflags,routefilter,norfc1918,nosmurfs,logmartians
        loc     eth0            tcpflags,detectnets,nosmurfs
        dmz     eth1            tcpflags,detectnets,nosmurfs
        #LAST LINE -- ADD YOUR ENTRIES BEFORE THIS ONE -- DO NOT REMOVE 

4.  Definir las políticas (`/etc/shorewall/policy`)

    El fichero por defecto incluye todas las combinaciones posibles
    entre nuestras 3 zonas (`loc`, `dmz`, `net`) indicando una política
    ACCEPT para el tráfico de la zona `loc` y una política por defecto
    de rechazar (REJECT) y generando un LOG de los ”rechazo” realizados.

    -   Esta política sólo tiene utilidad para depuración

    -   En nuestro caso fijaremos unas políticas restrictivas que
        descartarán por defecto todo el tráfico entre las zonas

    -   En el fichero `/etc/shorewall/rules` se ajustarán las
        excepciones pertinentes.

    <!-- -->

        firewall3:/etc/shorewall# leafpad policy &

        ###############################################################################
        #SOURCE         DEST            POLICY          LOG LEVEL       LIMIT:BURST
        loc             all             DROP            info
        net             all             DROP            info 
        dmz             all             DROP            info

        # THE FOLLOWING POLICY MUST BE LAST
        all             all             REJECT          info

        #LAST LINE -- ADD YOUR ENTRIES ABOVE THIS LINE -- DO NOT REMOVE

5.  Definir el enmascaramiento (`/etc/shorewall/masq`)

    En nuestro ejemplo enmascararemos (*SNAT: source NAT*) el tráfico
    saliente de nuestras 2 redes internas (`loc` y `dmz`).

        firewall3:/etc/shorewall# leafpad masq &

        ##############################################################################
        #INTERFACE              SOURCE          ADDRESS         PROTO   PORT(S) IPSEC   MARK
        eth2                    10.10.10.0/24
        eth2                    10.20.20.0/24
        #LAST LINE -- ADD YOUR ENTRIES ABOVE THIS LINE -- DO NOT REMOVE

    Indica que para el tráfico que pretenda salir de la red
    **10.10.10.0** y **10.20.20.0** a través del interface *eth2* (red
    externa) se ”reescribirá” su dirección origen con la dirección IP
    del interfaz *eth2* (IP publica de **firewall3 (193.147.87.47)**)

6.  Incluir las excepciones y redirecciones en `/etc/shorewall/rules`
    Mantendremos las excepciones (reglas) incluidas en el fichero
    `rules` de muestra.

    -   Definen el comportamiento de servicios básico como DNS, SSH
        hacia `dmz` y `firewall`, mensajes ICMP de PING, etc

        **Nota:** hace uso de macros como `Ping(DROP)`, `SSH(ACCEPT)`
        (abrevian la notación ahorrando el escribir los puertos
        concretos)

    Implementaremos parte de las restricciones de tráfico descrita en el
    ejercicio 1:

    -   Se redireccionan todos los servicio públicos
        (`http, https, smtp` y `pop3`) que ofrecerá nuestra red hacia la
        DMZ (en nuestro caso a la máquina **10.20.20.22**)

    -   Se permite acceso del servidor web de la DMZ (en
        **10.20.20.22**) al servidor MySQL de la red interna (en
        **10.10.10.11**)

    -   Se permite el acceso desde la red interna a los servidores
        públicos (web y correo) alojados en la DMZ

    Añadiremos al final del fichero (antes de la línea
    `#LAST LINE ....`) las reglas que las implementan.

        firewall3:/etc/shorewall# leafpad rules &

        ####################################################################################
        #ACTION         SOURCE           DEST              PROTO   DEST    SOURCE   ORIGINAL ...        
        #                                                        PORT    PORT(S)  DEST            

        #       Accept DNS connections from the firewall to the Internet
        ############### COMENTAR (no nos interesa) #################
        # DNS(ACCEPT)      $FW              net
        ############################################################

        #       Accept SSH connections from the local network to the firewall and DMZ
        SSH(ACCEPT)      loc              $FW    # Cubre parte de las restricciones 3c
        SSH(ACCEPT)      loc              dmz    # Cubre parte de las restricciones 3c
        ....
        ....
        ##
        ## ANADIDOS para implementar reglas de filtrado
        ##
        ## Anadidos para 2a, 2b: redirec. puertos (servicios publicos: http, https, smtp, pop3) a DMZ
        DNAT            net              dmz:10.20.20.22   tcp     80,443
        DNAT            net              dmz:10.20.20.22   tcp     25,110


        ## Anadidos para 3b: acceso desde local a red externa (solo WEB y SSH)
        ACCEPT          loc              net               tcp     80,443
        ACCEPT          loc              net               tcp     22


        ## Anadidos para 3c: acceso desde local a servidores web y correo de DMZ y ssh a equipos DMZ
        ACCEPT          loc              dmz:10.20.20.22   tcp     80,443
        ACCEPT          loc              dmz:10.20.20.22   tcp     25,110
        ACCEPT          loc              dmz               tcp     22  # No sería necesario, cubierto por una regla anterior

        ## Anadidos para 3d: acceso del servidor SMTP de DMZ a servidores SMTP externos para (re)envío de e-mails
        ACCEPT          dmz:10.20.20.22  net               tcp     25

        ## Anadidos para 3e: acceso del servidor web de DMZ al servidor mysql
        ACCEPT          dmz:10.20.20.22  loc:10.10.10.11   tcp     3306

        ## Anadidos para 3f: acceso al exterior para consultas DNS desde red interna y dmz
        DNS(ACCEPT)     loc              net
        DNS(ACCEPT)     dmz              net

        ######## NOTA: Reglas 3f equivalen a:
        #ACCEPT          loc              net               tcp     53
        #ACCEPT          loc              net               udp     53
        #ACCEPT          dmz              net               tcp     53
        #ACCEPT          dmz              net               udp     53
        #################################### 

        #LAST LINE -- ADD YOUR ENTRIES BEFORE THIS ONE -- DO NOT REMOVE

7.  Ajustar el fichero de configuración de Shorewall
    (`/etc/shorewall/shorewall.conf`)

    Como mínimo debe establecerse la variable `STARTUP_ENABLED` a `yes`,
    para que el compilador Shorewall procese los ficheros y genere las
    reglas iptables.

    También debe habilitarse el *forwarding* de paquetes: Asegurar que
    la variable `IP_FORWARDING` está a `on` (o `Keep` si se garantiza
    que se habilita *ip forwarding* antes de iniciar el firewall)

        firewall3:/etc/shorewall# leafpad shorewall.conf &

        ###############################################################################
        #                      S T A R T U P   E N A B L E D
        ###############################################################################
        STARTUP_ENABLED=Yes
        ...

        ###############################################################################
        #                       F I R E W A L L   O P T I O N S
        ###############################################################################
        IP_FORWARDING=Yes 

8.  Arrancar Shorewall

        firewall3:~# shorewall start

### Pruebas a realizar

 [sec:pruebas~s~horewall]

1.  Comprobar la configuración actual de ***firewall3***

        firewall3:~# iptables -L -v
        firewall3:~# iptables -t nat -L -v
        ó
        firewall3:~# iptables-save > /tmp/volcado.txt

2.  Revisar la estructura de las reglas generadas automáticamente por
    Shorewall.

    1.  Identificar y describir las reglas iptables generadas que dan
        soporte al tráfico redireccionado hacia la DMZ.

    2.  Identificar y describir las reglas iptables generadas que
        permiten el acceso al servidor MySQL desde la DMZ hacía la red
        interna.

3.  Comprobar que se verifican las redirecciones y restriciones de
    tráfico desde las distintas máquinas (`fuera`, `dentro`, `dmz`)

    -   Puede hacerse empleando el escaner de puertos `nmap`, el
        generador de paquetes `hping3`, conexiones directas con
        `telnet`, `nc` ó `socat`, o conexiones directas empleando
        clientes de los propios protocolos implicados.

                        fuera:~# nmap -T4 193.147.87.47  10.10.10.11   10.20.20.22 
                        
                        dentro:~# nmap -T4 193.147.87.33  10.20.20.22  10.10.10.1 
                        
                        dmz:~# nmap -T4 193.147.87.33  10.10.10.11  10.20.20.1
                        
                        firewall3:~# nmap -T4 193.147.87.33   10.10.10.11  10.20.20.22 
                        

    -   Para el caso del servidor WEB redireccionado a la DMZ, puede
        comprobarse el ”salto” adicional introducido por el firewall
        empleando la herramienta `tcptraceroute`.

    -   **Documentar las pruebas realizadas**, los resultados obtenidos
        y las posibles discrepancias con las políticas de filtrado
        previstas.

Ejercicio 2: Uso de enlaces cifrados OpenVPN
============================================

Se desarrollará un ejercicio de creación de enlaces OpenVPN, donde se
creará un enlace cifrado OpenVPN desde un equipo de la red externa y se
revisará su integración en el firewall con DMZ configurado con
Shorewall.

Parte 1: Creación de un enlace OpenVPN
--------------------------------------

Se creará un enlace cifrado OpenVPN desde la máquina externa **fuera
(193.147.87.33)** a la máquina **firewall3 (193.147.87.47)**. Se usará
un esquema SSL completo

Usaremos el modo de funcionamiento de OpenVPN *”roadwarrior”*, donde un
servidor OpenVPN crea enlaces cifrados para equipos autorizados situados
en redes externas.

-   La autenticación se realizará mediante **certificados digitales**
    (la otra posibilidad sería emplear cifrado simétrico con claves
    secretas estáticas preacordadas)

-   A las máquinas que se conecten por VPN se les asignarán direcciones
    IP del rango **10.30.30.0/24**, donde la máquina **firewall3** (el
    servidor OpenVPN) tendrá la IP **10.30.30.1**

Certificados y claves necesarias:

-   Para el servidor:

    -   certificado digital de la Autoridad Certificadora (CA)
        reconocida por ambos participantes: `cacert.crt`

    -   clave privada del servidor: `firewall3.key`

    -   certificado digital del servidos: `firewall3.crt` (emitido por
        la CA)

    -   parámetros para intercambio de clave Diffie-Hellam: `dh1024.pem`

-   Para cada uno de los clientes que se conecten con OpenVPN:

    -   certificado digital de la Autoridad Certificadora reconocida por
        ambos participantes: `cacert.crt`

    -   clave privada del cliente: `fuera.key`

    -   certificado digital del servidor: `fuera.crt` (emitido por la
        CA)

### Creación de la CA y de los certificados de servidor y clientes

La distribución de OpenVPN incluye un conjunto de scripts para implantar
una CA básica

1.  Crear la ”autoridad certificadora” (CA) en el firewall

    Crear un directorio `easy-rsa` donde residirán los scripts y las
    claves de la CA

        firewall3:~# cd /etc/openvpn
        firewall3:/etc/openvpn/# cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0 easy-rsa
        firewall3:/etc/openvpn/# cd easy-rsa

    Editar datos generales de nuestra red

        firewall3:/etc/openvpn/easy-rsa/#  nano vars
        ...
        export KEY_COUNTRY=es
        export KEY_PROVINCE=ourense
        export KEY_CITY=ourense
        export KEY_ORG=cda
        export KEY_EMAIL=cda@esei.net
        ...

    Inicializar la CA y generar su par de claves

        firewall3:/etc/openvpn/easy-rsa/# source vars
        firewall3:/etc/openvpn/easy-rsa/# ./clean-all
        firewall3:/etc/openvpn/easy-rsa/# ./build-ca

    Cuando se nos pregunte por ”COMMON\_NAME:” poner en nombre de
    dominio completo del equipo (firewall3.esei.net)

2.  Crear el certificado del equipo ”servidor” OpenVPN

        firewall3:/etc/openvpn/easy-rsa/# ./build-key-server firewall3

    Cuando se nos pregunte por ”COMMON\_NAME:” poner el nombre de
    dominio completo del servidor OpenVPN (en este caso,
    `firewall3.esei.net`)

    Se solicitará una contraseña para proteger el fichero con la clave
    privada. Dado que OpenVPN se iniciará como un script de arranque en
    `/etc/init.d/` se dejará en blanco para que no se bloquee el inicio
    del servidor.

    Crear parámetros de intercambio de clave (Diffie-Hellmann)

        firewall3:/etc/openvpn/easy-rsa/# ./build-dh

    Las claves generadas (fichero con el certificado digital firmado por
    la CA [extensión `.crt`] + fichero con la respectiva clave privada
    [extensión `.key`]) se crean en el directorio
    `/etc/openvpn/easy-rsa/keys/`

3.  Crear el certificado del equipo ”cliente” OpenVPN

        firewall3:/etc/openvpn/easy-rsa/# ./build-key fuera

    Cuando se nos pregunte por ”COMMON\_NAME:” poner el nombre de
    dominio completo del cliente OpenVPN (en este caso, `fuera`)

    Se solicitará una contraseña para proteger el fichero con la clave
    privada. Dado que OpenVPN se iniciará como un script de arranque en
    `/etc/init.d/` se dejará en blanco para que no se bloquee el inicio
    del cliente.

Otra alternativa a los scripts `easy-rsa` es usar la herramienta gráfica
`TinyCA` que ofrece un interfaz gráfico sobre openSSL para la gestion de
autoridades de certificación y la generación de certificados digitales.

    firewall3:~# tinyca2 &

### Configuración y creación del enlace OpenVPN

1.  Configuración del servidor: en la máquina **firewall3**

    -   Copiar las claves/certificados necesarios al directorio
        `/etc/openvpn` :

            firewall3:~# cd /etc/openvpn
            firewall3:/etc/openvpn# cp easy-rsa/keys/ca.crt         .
            firewall3:/etc/openvpn# cp easy-rsa/keys/firewall3.crt  .
            firewall3:/etc/openvpn# cp easy-rsa/keys/firewall3.key  .
            firewall3:/etc/openvpn# cp easy-rsa/keys/dh1024.pem     .

    -   Crear el fichero de configuración del servidor:

        Se usará como base el ejemplo disponible en
        `/usr/share/doc/openvpn/examples/sample-config-files/`

            firewall3:/etc/openvpn# cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz  .
            firewall3:/etc/openvpn# gunzip server.conf.gz

        Editar los parámetros concretos para nuestros túneles VPN:

            firewall3:/etc/openvpn# leafpad server.conf &

        Parámetros destacados (con ”$\to$” se señalan los cambios
        efectuados para nuestro ejemplo):

          ------- -----------------------------------------------------------------------------------------------
                  `port 1194      /* puerto por defecto del servidor OpenVPN */`
                  `proto udp      /* protocolo por defecto del servidor OpenVPN */`
                  `dev tun        /* tipo de dispositivo de red virtual (= tarjeta de red "software") a través`
                  `                  del cual se accederá al tunel cifrado establecido */`
                  `...`
          $\to$   `ca   /etc/openvpn/ca.crt          /* parametros de cifrado */ `
          $\to$   `cert /etc/openvpn/firewall3.crt `
          $\to$   `key  /etc/openvpn/firewall3.key `
                  `...`
          $\to$   `dh   /etc/openvpn/dh1024.pem`
                  `...`
          $\to$   `server 10.30.30.0 255.255.255.0 /* rango de direcciones a asignar a los clientes`
                  `                                   OpenVPN que se vayan conectando*/ `
                  `    `
          $\to$   `push "route 10.10.10.0 255.255.255.0"    `
          $\to$   `push "route 10.20.20.0 255.255.255.0"    `
                  `              /* configuración de las rutas a establecer ("empujar") en los `
                  `                 clientes para las conexiones cifradas que se vayan creando */`
                  `              /* en nuestro caso son las rutas hacia las 2 redes (interna `
                  `                 y dmz) gestionadas por firewall3 */`
          ------- -----------------------------------------------------------------------------------------------

2.  Configuración de los clientes: en la máquina **fuera
    (193.147.87.33)**

    -   Copiar (mediante copia segura sobre SSH con `scp`) las
        claves/certificados necesarios al directorio `/etc/openvpn` :

            fuera:~# cd /etc/openvpn
            fuera:/etc/openvpn# scp root@firewall3.esei.net:/etc/openvpn/easy-rsa/keys/ca.crt  .
            fuera:/etc/openvpn# scp root@firewall3.esei.net:/etc/openvpn/easy-rsa/keys/fuera.crt  .
            fuera:/etc/openvpn# scp root@firewall3.esei.net:/etc/openvpn/easy-rsa/keys/fuera.key  .

    -   Crear el fichero de configuración del cliente

        Se usará como base el ejemplo disponible en
        `/usr/share/doc/openvpn/examples/sample-config-files/`

            fuera:/etc/openvpn# cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf  .

        Editar los parámetros concretos para nuestros túneles VPN

            fuera:/etc/openvpn# nano client.conf

        Parámetros destacados (con ”$\to$” se señalan los cambios
        efectuados para nuestro ejemplo):

          ------- -----------------------------------------------------------------------------------------------
                  `client          /* indica que es la configuración para un cliente */`
                  `   `
                  `dev tun        /* tipo de dispositivo de red virtual (= tarjeta de red "software") a traves`
                  `                  del cual se accederá al tunel cifrado establecido con el servidor */`
          $\to$   `remote 193.147.87.47 1194   /* dirección IP y puerto de escucha del servidor OpenVPN `
                  `                               con el que se establecera el tunel cifrado */`
                  `    `
          $\to$   `ca   /etc/openvpn/ca.crt          /* parametros de cifrado */ `
          $\to$   `cert /etc/openvpn/fuera.crt `
          $\to$   `key  /etc/openvpn/fuera.key `
                  `...`
          ------- -----------------------------------------------------------------------------------------------

3.  Crear el túnel OpenVPN

    **Importante:** antes de iniciar el tunel asegurar que en
    **firewall3** está activado el *IP forwading* y desactivadas las
    reglas `iptables` de Shorewall.

    Si es necesario:

        firewall3:~#  echo 1 > /proc/sys/net/ipv4/ip_forward

        OPCION 1: deshabilitar el firewall shorewall 
        firewall3:~# shorewall stop
        firewall3:~# shorewall clear

        ó 

        OPCION 2: reestablecer la configuración por defecto de NETFILTER/iptables (politica ACCEPT)
        firewall3:~#  iptables -F
        firewall3:~#  iptables -X
        firewall3:~#  iptables -Z
        firewall3:~#  iptables -t nat -F

        firewall3:~#  iptables -P INPUT ACCEPT
        firewall3:~#  iptables -P OUTPUT ACCEPT  
        firewall3:~#  iptables -P FORWARD ACCEPT 

    -   Inciar OpenVPN en servidor (**firewall3**), ejecutar
        `/etc/init.d/openvpn start`

    -   Inicar OpenVPN en cliente (**fuera**), ejecutar
        `/etc/init.d/openvpn start`

    En ambos extremos del túnel cifrado se crea un interfaz de red
    ”virtual” `/dev/tun0` por el que se accede al enlace cifrado que
    conforma la red privada virtual.

    -   Un interfaz *tun* (también los interfaces *tap*) simula un
        dispositivo de red ethernet, pero en lugar de enviar los
        datagramas Ethernet sobre un cable de red, los encapsula dentro
        de los paquetes de una conexión TCP/IP establecida.

        -   En nuestro caso se trata de una conexión SSL al puerto 1194
            UDP de la máquina **firewall3**

    -   El enlace OpenVPN definirá la red **10.30.30.0/24**

        -   El servidor tendrá la dir. IP **10.30.30.1**

        -   A los clientes se les asignarán direcciones a partir de
            **10.30.30.6**

        -   El *gateway* (puerta de enlace) de los clientes conectado
            por VPN será **10.30.30.5**, que reenvía a **10.30.30.1**

        Se puede comprobar la configura en ambos extremos con
        `ifconfig -a`

    -   En este caso las rutas hacia las dos ”redes internas” (red dmz y
        red interna) se ”inyectan” en el cliente VPN al crear el tunel

        -   La ruta por defecto de los equipos internos usa como
            *gateway* a **firewall3** que a su vez conoce la ruta hacia
            las máquinas clientes VPN

        -   Por ello, en este caso concreto no es necesario indicar
            rutas adicionales para que los equipos **dentro** y **dmz**
            respondan y se comuniquen con los clientes OpenVPN

    -   Para el equipo firewall3 tendremos 4 redes

        -   10.10.10.0/24: red interna en el interfaz *eth0*

        -   10.20.20.0/24: red dmz en el interfaz *eth1*

        -   10.30.30.0/24: equipos externos conectados sobre VPN en el
            interfaz ”virtual” *tun0*

        -   red externa en el interfaz *eth2*

4.  Comprobar el tunel creado

    Comprobar el acceso desde la máquina cliente (**fuera**) a las 2
    redes internas detrás de **firewall3**, que inicialmente no eran
    accesibles.

    -   Desde fuera:

            fuera:~# nmap -T4 10.10.10.11     [escaneo de dentro]
            fuera:~# nmap -T4 10.20.20.22     [escaneo de dmz]

    -   Otra opción: hacer conexión ssh + comprobar con comando who
        quien está conectado

            fuera:~# ssh  usuario1@10.10.10.11     
            fuera:~# ssh  usuario1@10.20.20.22
            {\footnotesize
            \begin{verbatim}

Parte 2: Integración del enlace OpenVPN con Shorewall
-----------------------------------------------------

Shorewall prevee la posibilidad de dar soporte a conexiones VPN. Veremos
como integrar nuestro túnel openVPN en Shorewall

### Pasos a seguir

 [sec:pruebas~o~penvpn]

1.  Crear una nueva zona (`road`) para los clientes conectado con
    OpenVPN en el fichero `/etc/shorewall/zones`

        firewall3:/etc/shorewall# leafpad zones &

        ###############################################################################
        #ZONE   TYPE    OPTIONS                 IN                      OUT
        #                                       OPTIONS                 OPTIONS
        fw      firewall
        net     ipv4
        loc     ipv4
        dmz     ipv4
        road    ipv4            

    **Nota:** otra opción más directa sería habilitar una excepción para
    el tráfico openVPN (`puerto 1194 UDP`) en el fichero
    `/etc/shorewall/rules` y anadir el interfaz *tun0* a la zona `loc`

    -   De ese modo, todo el tráfico que llegará al forewall mediante
        los túneles OpenVPN se concideraría como perteneciente a la zona
        `loc` (red interna).

2.  Asociar el interfaz *tun0* a la zona `road` en el fichero
    `/etc/shorewall/interfaces`

         firewall3:/etc/shorewall# leafpad interfaces &

        ###############################################################################
        FORMAT 2
        ###############################################################################
        #ZONE   INTERFACE         OPTIONS
        net     eth2              tcpflags,dhcp,routefilter,nosmurfs,logmartians
        loc     eth0              tcpflags,nosmurfs
        dmz     eth1           
        road    tun+

3.  Definir las políticas y reglas que afectan a los clientes OpenVPN

    Haremos que los equipos conectados por openVPN (zona `road`) tengas
    las mismas restricciones/privilegios que los de la red interna (zona
    `loc`).

    -   Fichero `/etc/shorewall/policy`

        Habilitar el acceso a la zona interna (`loc`) desde los equipos
        que lleguen a través del túnel OpenVPN (zona `road`)

            firewall3:/etc/shorewall# leafpad policy &

            ###############################################################################
            #SOURCE         DEST            POLICY          LOG LEVEL       LIMIT:BURST
            loc             all             DROP
            net             all             DROP
            dmz             all             DROP

            road            loc             ACCEPT

            # THE FOLLOWING POLICY MUST BE LAST
            all             all             REJECT          info 
                 

    -   Fichero `/etc/shorewall/rules`

        Replicar las entradas correspondientes a la zona `loc`,
        cambiando su campo zona de `loc` a `road`.

        **Nota:** esto es una simplificación para acelerar el desarrollo
        del ejemplo. En un entorno real, puede no ser
        necesario/razonable que los equipos de los usuarios
        ”itinerantes” se equiparen en cuanto a restricciones de acceso
        con los equipos internos (especialmente si el único mecanismo de
        autenticación es el uso exclusivo de certificados digitales de
        clientes).

            firewall3:/etc/shorewall# leafpad rules &

            ...
            SSH(ACCEPT)      road             $FW
            SSH(ACCEPT)      road             dmz
            ...
            ACCEPT           road             dmz            tcp     80,443 
            ACCEPT           road             dmz            tcp     25,110

            DNS(ACCEPT)      road             net

                 

4.  Dar de alta el tunel OpenVPN `/etc/shorewall/tunnels`

        firewall3:/etc/shorewall# leafpad tunnels &

        #TYPE                   ZONE    GATEWAY         GATEWAY-ZONE
        openvpnserver:1194      net     0.0.0.0/0

5.  Comprobar la configuración del firewall y el funcionamiento del
    tunel OpenVPN

    -   Recompilar y arrancar el cortafuegos generado por Shorewall con
        las nuevas configuraciones

            firewall3~# shorewall start
                  

    -   Reiniciar el servidor OpenVPN en `firewall3`

            firewall3~# /etc/init.d/openvpn restart
                  

    -   Arrancar el cliente OpenVPN en `fuera`

            fuera~# /etc/init.d/openvpn restart
                  

    -   Repetir las comprobaciones realizadas en el punto *(3)* del
        apartado [sec:pruebas~s~horewall] y documentar los resultados
        obtenidos.

        -   En concreto, con NMAP se puede comprobar que desde el equipo
            `fuera` se tiene acceso a los mismos servicios de las redes
            interna y DMZ que en el caso de equipos de la red interna.

                fuera~# nmap -T4 10.10.10.11
                fuera~# nmap -T4 10.20.20.22
                      

Documentación a entregar
========================

**Esquema propuesto** (hasta un máximo de 5-6 páginas)

-   Descripción **breve** del ejercicio realizado

-   Detallar la situación inicial del la red del ejemplo (escaneos del
    punto `PREVIO 4`)

-   Detallar las comprobaciones realizadas en el
    apartado [sec:pruebas~s~horewall] y documentar los resultados
    obtenidos (comentando, si es necesario, las discrepancias con el
    comportamiento deseado descrito en la sección [sec:requisitos])

-   Detallar las comprobaciones realizadas en el punto *(5)* del
    apartado [sec:pruebas~o~penvpn] y documentar los resultados
    obtenidos después de configurar OpenVPN e integrar el enlace con
    Shorewall

-   Conclusiones: detallar los problemas encontrados, posibles mejoras o
    alternativas, impresiones sobre la idoneidad de las herramientas,
    etc

**Entrega:** FAITIC

**Fecha límite:** `<pendiente>`

