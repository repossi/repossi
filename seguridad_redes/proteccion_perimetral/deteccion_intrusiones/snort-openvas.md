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

1.  Scripts de instalación

    -   para GNU/Linux:

        -   Ejecutar desde el directorio de descarga

                              alumno@pc:~$ bash ejercicio-snort.sh
                              

    -   para MS Windows (Vista o superior):

        -   Ejecutar desde el directorio de descarga

                              Powershell.exe -executionpolicy bypass -file ejercicio-snort.ps1
                              

    **NOTAS:**

    1.  En ambos scripts la variable `$DIR_BASE` especifica donde se
        descargarán las imágenes y se crearán las MVs.

        -   Por defecto en GNU/Linux será en `$HOME/SSI1516` y en
            Windows en `C:\\SSI1516`

        -   Puede modificarse antes de lanzar los scripts para hacer la
            instalación en otro directorio más conveniente (disco
            externo, etc)

    2.  Es posible descargar las imágenes comprimidas manualmente (o
        intercambiarlas con USB), basta descargar los archivos con
        extensión `.vdi.zip` de y copiarlos en el directorio anterior
        (`$DIR_BASE`) para que el script haga el resto.

2.  El script descargará las siguientes imágenes en el directorio
    `DIR_BASE` (`$HOME/SSI1516` ó `C:\\SSI1516`)

    -   `base_snort.vdi` (1,6 GB comprimida, 4,5 GB descomprimida):
        Imagen VirtualBox común

        Usuarios configurados.

          ****login****   ****password****
          --------------- ------------------
          `root`          `purple`
          `usuario1`      `usuario1`

        Administrador MySQL: `root` con contraseña `purple`

    -   `swap2015.vdi`: Imagen VirtualBox de una unidad de disco
        formateada como SWAP

3.  Se pedirá un identificador (sin espacios) para poder reutilizar las
    versiones personalizadas de las imágenes creadas

4.  Arrancar las instancias <span>VirtualBOX</span> (si no lo hacen
    desde el script anterior) desde el interfaz gráfico o desde la línea
    de comandos.

              VBoxManage startvm OPENVAS-<id>
              VBoxManage startvm SNORT-<id>

    **Importante:** Después de finalizar cada ejercicio terminar la
    ejecución de la máquina virtual desde línea de comandos con
    `poweroff` o `sudo poweroff` o desde el interfaz gráfico LXDE.

Máquinas virtuales y redes creadas
----------------------------------

-   Red donde se realizarán los ejercicios:

    -   Red interna 10.10.10.0/24: máquina **snort** (10.10.10.11),
        interfaz *eth1* de máquina **borde** (10.10.10.1)

    -   Red externa 193.147.87.0/24: máquina **openvas**
        (193.147.87.47), interfaz *eth1* de máquina **borde**
        (193.147.87.1)

    -   En caso de que funcionen correctamente se pueden configurar las
        direcciones IP de cada máquina manualmente

            snort:~/# ifconfig eth0 10.10.10.11 netmask 255.255.255.0

            openvas:~/# ifconfig eth0 193.147.87.47 netmask 255.255.255.0

            borde:~/# ifconfig eth0 10.10.10.1 netmask 255.255.255.0
            borde:~/# ifconfig eth1 193.147.87.1 netmask 255.255.255.0
            borde:~/# dhclient eth2
            borde:~/# route add default gw 10.0.4.2   # Puede cambiar

-   Habilitar el tráfico entre las redes interna y externa en la máquina
    **borde**

        borde:~/# echo 1 > /proc/sys/net/ipv4/ip_forward

-   Permitir el acceso a la ”red real” del anfitrión desde las máquinas
    del ejercicio a través de la máquina **borde**

        borde:~/# iptables -t nat -A POSTROUTING -o eth2 -j MASQUERADE

-   Arrancar servicios en la máquina **snort** (10.10.10.11)

        snort:~/# /etc/init.d/apache2 start
        snort:~/# /etc/init.d/postfix start
        snort:~/# /etc/init.d/dovecot start
        snort:~/# /etc/init.d/openbsd-inetd start
        snort:~/# /etc/init.d/mysql start

Ejemplo 1: Configuración de la consola web SNORBY con un NIDS Snort y un HIDS Sagan {#sec:configuracion}
===================================================================================

Descripción
-----------

Se desarrollará un ejercicio de configuración de una consola de análisis
de logs SNORBY y su enlace con un detector de intrusiones de red (NIDS)
SNORT y un detector de intrusiones en host (HIDS) SAGAN.

-   Web de SNORBY :

-   Web de SNORT :

-   Web de SAGAN :

Pasos a seguir: SNORBY
----------------------

### Pasos previos (ya realizado)

1.  Instalación de paquetes DEB requeridos (ya hecho)

        snort:~# apt-get install git  
        snort:~# apt-get install ruby ruby-dev
        snort:~# apt-get install mysql-server libmysqlclient-dev libmysql++-dev 
        snort:~# apt-get install imagemagick libmagickwand-dev wkhtmltopdf 
        snort:~# apt-get install gcc g++ build-essential linux-headers 
        snort:~# apt-get install libssl-dev libreadline-gplv2-dev zlib1g-dev  
        snort:~# apt-get install libsqlite3-dev libxslt1-dev libxml2-dev 

2.  Descarga de la última versión

        snort:~# git clone http://github.com/Snorby/snorby.git

3.  Descarga e instalación de dependencias

        snort:~# cd snorby
        snort:~/snorby# gem install bundler
        snort:~/snorby# bundle install

### Puesta en marcha

1.  Editar configuración de BD (`config/database.yml`)

        snort:~/snorby# cp config/database.yml.example config/database.yml  
        snort:~/snorby# nano config/database.yml  

        snorby: &snorby
          adapter: mysql      # <--
          username: root      # <--
          password: purple    # <--
          host: localhost     # <--

        development:
          database: snorby
          <<: *snorby

        test:
          database: snorby
          <<: *snorby

        production:
          database: snorby
          <<: *snorby

          
        snort:~/snorby# cp config/snorby_config.yml.example config/snorby_config.yml
        snort:~/snorby# nano config/snorby_config.yml

        # 
        # Production
        #
        # Change the production configuration for your environment.
        # 
        # USE THIS! 
        #
        production:
          domain: localhost:3000                    # <--
          wkhtmltopdf: /usr/bin/wkhtmltopdf         # <--
          ssl: false
          mailer_sender: 'snorby@snorby.org'
          geoip_uri: "http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz"
          rules:
            - "/etc/snort/rules/"                   # <--    
            - "/etc/sagan-rules/"                   # <--      
          authentication_mode: database
          # If timezone_search is undefined or false, searching based on time will
          # use UTC times (historical behavior). If timezone_search is true
          # searching will use local time.
          timezone_search: true
          # uncomment to set time zone to time zone of box from /usr/share/zoneinfo, e.g. "America/Cancun"
          # time_zone: 'UTC'

        #
        # Only Use For Development
        #
        development:
          domain: localhost:3000
          wkhtmltopdf: /usr/bin/wkhtmltopdf       # <--
          ssl: false
          mailer_sender: 'snorby@snorby.org'
          geoip_uri: "http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz"
          rules: 
            - "/etc/snort/rules/"                 # <--
            - "/etc/sagan-rules/"                 # <--      
          authentication_mode: database
          # uncomment to set time zone to time zone of box from /usr/share/zoneinfo, e.g. "America/Cancun"
          # time_zone: 'UTC'
        #  authentication_mode: cas
        #  cas_config:
        #    base_url: https://auth.server.com.br/
        #    login_url: https://auth.server.com.br/login?domain=server
        #    logout_url: https://auth.server.com.br/logout?domain=server

        #
        # Only Use For Testing
        #
        test:
          domain: localhost:3000
          wkhtmltopdf: /usr/bin/wkhtmltopdf       # <--
          mailer_sender: 'snorby@snorby.org'
          geoip_uri: "http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz"
          authentication_mode: database
          

2.  Inicializar y crear la BD `snorby`

        snort:~/snorby# bundle exec rake snorby:setup

        snort:~/snorby# mysql --user=root --password=purple -D snorby
        mysql> show tables;

3.  Desplegar la aplicación en modo producción

        snort:~/snorby# bundle exec rails server -e production

4.  Acceder a la URL `http://localhost:3000` con el usuario
    `snorby@snorby.org` y la contraseña `snorby`

Pasos a seguir: SNORT
---------------------

### Pasos previos (ya realizado)

1.  Instalar paquetes DEB (ya hecho)

        snort:~# apt-get install snort-mysql snort-rules  

### Puesta en marcha

1.  Reconfigurar paquete `snort-mysql` usando la información de la BD de
    *snorby*

        snort:~# dpkg-reconfigure --force snort-mysql

          Modo de arranque: arranque
          Interfaz de escucha: eth0
          Red local: 10.10.10.0/24
          Deshabilitar modo promiscuo: no
          Resumenes por mail: no
          Configurar base de datos: si
            Nombre servidor:      localhost
            Nombre base de datos: snorby
            Usuario:              root
            Contrasena:           purple

    Por defecto la instalación del paquete Debian deja la BD de `snort`
    sin configurar. Debe crearse una BD y eliminar el fichero
    `/etc/snort/db-pending-config` para que el demonio `snort` pueda ser
    arrancado.

    -   Puede crearse la estructura de tablas siguiendo las
        instrucciones en
        `/usr/share/doc/snort-mysql/README-database.Debian.gz` y el
        esquema de BD disponible en
        `/usr/share/doc/snort-mysql/create_mysql.gz`

    -   En este caso no es necesario y se usará directamente la BD
        creada por *snorby* que es compatible con el esquema de DB de
        `snort`

2.  Habilitar el arranque de `snort` y arrancar el demonio

        snort:~# rm /etc/snort/db-pending-config
        snort:~# /etc/init.d/snort start

3.  Lanzar un escaneo de puertos con `nmap` en la máquina `openvas`

        openvas:~# nmap -O -sV 10.10.10.11

    Se generarán algunos eventos en la BD de `snorby` y en su interfaz
    gráfico.

        snort:~# mysql --user=root --password=purple -D snorby

        mysql> select * from event;
        mysql> select * from events_with_join;

Pasos a seguir: SAGAN
---------------------

### Pasos previos (ya realizado)

1.  Instalar paquetes DEB (ya hecho)

        snort:~# apt-get install sagan sagan-rules

### Puesta en marcha

1.  Configurar `sagan` para escribir sus alertas en BD *snorby* y
    especificar el fichero FIFO donde recibirá los logs (las líneas
    relevantes están marcadas con `<--`)

        snort:~# nano /etc/sagan.conf

        ...
        ##############################################################################
        # Standard _required_ Sagan options!
        ##############################################################################

        # Sagan reads log entries via a FIFO (First in/First Out).  This variable
        # lets Sagan know where that FIFO is located. 
        #
        # [Required]

        var FIFO /var/run/sagan/sagan.fifo          # <--

        # This variable contains the path of the Sagan rule sets.  It is required.
        #
        # [Required]

        var RULE_PATH /etc/sagan-rules              # <--
        ...

        # This is the IP address _of_ the Sagan system.   These options are used
        # if Sagan is unable to determine a TCP/IP network address and/or port.
        #
        # [Required]
        sagan_host 10.10.10.11                   # <--
        sagan_port 514
        ...

        ##############################################################################
        # Snort database specific configurations [Direct SQL access]                                     
        ##############################################################################

        # Sagan "sensor" configuration.  If you plan on running Sagan and storing data
        # into a Snort database,  these options are required.   This information gets 
        # logged to the Snort database's "sensor" table to differentiate between Snort
        # IDS/IPS data and log data.   We don't really have an "interface", so we create
        # one known as "syslog",  or what ever you'd like to call it.
        #
        # [Required if logging directly to a Snort database.  Not to be confused with
        # Unified2 output]]

        sagan_hostname sagan            # <--
        sagan_interface syslog          # <--
        sagan_filter none               # <--
        sagan_detail 1                  # <--

        # If you plan on logging to a Snort database,  this is where you tell Sagan 
        # where to log to.   The options should be pretty clear.  Currently Sagan 
        # supports MySQL and PostgreSQL.  
        #
        # [Required if logging directly to a Snort database]

        output database: log, mysql, user=root password=purple dbname=snorby host=localhost      # <--

        ; output database: log, postgresql, user=sagan password=secret dbname=snort_db host=192.168.0.1

        ...

        # ERRATA: Al final del fichero, comentar el include de "linux-kernel.rules" (no existe) 
        ; include $RULE_PATH/linux-kernel.rules

2.  Crear el fichero FIFO `/var/run/sagan/sagan.fifo`

        snort:~# mkdir /var/run/sagan
        snort:~# mkfifo /var/run/sagan/sagan.fifo
        snort:~# chown sagan:adm /var/run/sagan/sagan.fifo 

3.  Configurar el motor de logs del sistema (`rsyslog`) para que envíe
    los logs al fichero FIFO de donde los extraerá `sagan`

    Crear un fichero en `/etc/rsyslog.d/` que envíe todos los eventos en
    el formato de `sagan` [**Importante:** todo en la misma línea]

        snort:~# nano /etc/rsyslog.d/sagan_rsyslog.conf

        # The standard "input" template Sagan uses.  Basically the message 'format' Sagan understands.  The template is _one_ line.
        $template sagan,"%fromhost-ip%|%syslogfacility-text%|%syslogpriority-text%|%syslogseverity-text%|%syslogtag%|%timegenerated:1:10:date-rfc3339%|%timegenerated:12:19:date-rfc3339%|%programname%|%msg%\n"

        # The FIFO/named pipe location.  This is what Sagan will read.
        *.*     |/var/run/sagan/sagan.fifo;sagan

    Rearrancar `sagan` y `rsyslog`

        snort:~# /etc/init.d/sagan restart
        snort:~# /etc/init.d/rsyslog restart

4.  Verificar que se anotan los eventos (en la BD y en el interfaz
    *snorby*) realizando una conexión SSH para el usuario `root` con una
    conteseña incorrecta

        snort:~# ssh root@localhost

        snort:~# mysql --user=root --password=purple -D snorby

        mysql> select * from event;
        mysql> select * from events_with_join;

Ejemplo 2: Definición de reglas SNORT y testeo con SCAPY
========================================================

Descripción
-----------

Se verá una ejemplo de regla SNORT ”a medida” y cómo generar un paquete
TCP/IP que la active usando la librería Python

-   Web de SCAPY :

Pasos a seguir
--------------

1.  Añadir una regla en el fichero de reglas ”locales” de snort.

        snort:~# nano /etc/snort/rules/local.rules

        alert tcp any any -> $HOME_NET 7789 (
                               msg: "Prueba SSI 2014"; 
                               reference: url,http://ccia.ei.uvigo.es/docencia/SSI-grado/; 
                               content: "el perro de san roque"; 
                               flow:to_server; 
                               nocase; 
                               sid:9000999; 
                               rev:1)     

    **Importante:** todos lo campos de la regla deben incluirse en la
    misma línea

2.  Reiniciar SNORT

        snort:~# /etc/init.d/snort restart

3.  Desde la máquina `openvas` abrir el shell de *scapy*, crear un
    paquete TCP/IP que incluya una carga útil que active la regla
    anterior y enviarlo a la máquina `snort`

        openvas:~#  scapy

        >>> ip=IP()
        >>> ip.src="193.147.87.47"
        >>> ip.dst="10.10.10.11"

        >>> tcp=TCP()
        >>> tcp.dport=7789
        >>> tcp.sport=11111

        >>> payload="el perro de san roque"

        >>> paquete = ip/tcp/payload
        >>> paquete.show()

        >>> send(paquete)

        >>> exit()

4.  Comprobar en la BD y en el interfaz de *snorby* que se ha generado
    la alertas

        snort:~# mysql --user=root --password=purple -D snorby

        mysql> select * from event;
        mysql> select * from events_with_join;

Tareas a realizar {#sec:scapy}
-----------------

1.  Seleccionar tres reglas SNORT (ver `/etc/snort/rules/`) y generar
    con SCAPY una serie de paquetes que fuercen su activación

2.  Comprobar la detección de ese tipo de tráfico en la consola de
    SNORBY y en la base de datos

3.  **Importante:** al menos una de las reglas seleccionadas debe
    requerir tráfico en binario

**NOTA :** Muchas de las reglas de SNORT para tŕafico TCP requieren que
la conexión se encuentre establecida.

En esos casos hay varias alternativas:

-   Implementar con SCAPY la negociación de 3 pasos
    (`SYN, SYN_ACK, ACK`) generando los paquetes con los números de
    secuencia y ACK correctos (ver la función `sr1()` de SCAPY) (más
    info. en
    <http://stackoverflow.com/questions/26480854/3-way-handshake-in-scapy>)

-   Utilizar directamente una herramienta como `netcat` / `nc` para
    establecer la conexión y desde esa misma herramienta enviar los
    datos que generen la alerta en Snort.

    En este caso también se puede utilizar `netcat` en modo escucha
    (opción `-l`) para simular un servidor en el puerto que sea
    necesario.

<span>|l|</span>\
**IMPORTANTE (17/12/2015)**\
\

[t]<span>0.85</span>

-   Aparentemente las dos opciones propuestas (negociación TCP con
    `scapy` y uso de `nc`) no consiguen generar paquetes que provoquen
    alertas en SNORT con reglas para tráfico TCP marcadas con
    `flow:established`.

-   Una alternativa sería trabajar sólo con reglas UDP simples, dado que
    no requerirán conexión, pero no abundan demasiado y es difícil
    encontrarlas.

-   En cualquier caso, de cara a confeccionar la **documentación
    entregable** bastará con incluir:

    1.  **Identificar las reglas** para las cuales que se ha intentado
        forzar alertas

    2.  Describir el **procedimiento empleado** para intentar generar
        esa alerta (usando `scapy` ó usando `netcat`)

    3.  Señalar los resultados obtenidos: eventos registrados en la BD
        de SNORT o señalar la ausencia de eventos si no ha funcionado.

 \

\

Ejemplo 3: Instalación y uso de OpenVAS [no entregable]
=======================================================

**Importante:** tarea opcional no entregable (la descarga de plugins y
el escaneo pueden llevar mucho tiempo, por encima de 30-45 min)

Web OpenVAS;

Instalación de OpenVAS versión 7 desde código fuente
----------------------------------------------------

Código fuente:

1.  Paquetes necesarios (ya instalados)

        apt-get install cmake doxygen
        apt-get install pkg-config libssh-dev libgnutls-dev libglib2.0-dev
        apt-get install libpcap-dev libgpgme11-dev uuid-dev bison libksba-dev
        apt-get install xmltoman libmicrohttpd10 libmicrohttpd-dev libxslt-dev xsltproc

        [pueden ser necesarios otros paquetes ya instalados en las MVs de prácticas]

2.  Descarga del código fuente desde la web de OpenVAS (ya realizado)

        mkdir /home/root/openvas
        cd /home/root/openvas
        wget http://wald.intevation.org/frs/download.php/1833/openvas-libraries-7.0.6.tar.gz
        wget http://wald.intevation.org/frs/download.php/1844/openvas-scanner-4.0.5.tar.gz
        wget http://wald.intevation.org/frs/download.php/1849/openvas-manager-5.0.7.tar.gz
        wget http://wald.intevation.org/frs/download.php/1799/greenbone-security-assistant-5.0.4.tar.gz
        wget http://wald.intevation.org/frs/download.php/1803/openvas-cli-1.3.1.tar.gz

3.  Compilación e instalación de los binarios (ya realizado)

        cd /home/root/openvas
        tar xvf openvas-libraries-7.0.4.tar 

        cd openvas-libraries-7.0.4
        mkdir build
        cd build/
        cmake -DCMAKE_INSTALL_PREFIX=/usr/ ..
        make
        make install
        cd ../..

        tar xzvf openvas-scanner-4.0.3.tar.gz 
        cd openvas-scanner-4.0.3
        mkdir build
        cd build/
        cmake -DCMAKE_INSTALL_PREFIX=/usr/ ..
        make
        make doc
        make install
        cd ../..

        tar xzvf openvas-manager-5.0.4.tar.gz 
        cd openvas-manager-5.0.4
        mkdir build
        cd build/
        cmake -DCMAKE_INSTALL_PREFIX=/usr/ ..
        make
        make doc
        make install
        cd ../..

        tar xzvf openvas-cli-1.3.0.tar.gz 
        cd openvas-cli-1.3.0
        mkdir build
        cd build/
        cmake -DCMAKE_INSTALL_PREFIX=/usr/ ..
        make
        make doc
        make install
        cd ../..

        tar xzvf greenbone-security-assistant-5.0.3.tar.gz 
        cd greenbone-security-assistant-5.0.3
        mkdir build
        cd build/
        cmake -DCMAKE_INSTALL_PREFIX=/usr/ ..
        make
        make doc
        make install
        cd ../..

Puesta en marcha
----------------

Pasos a seguir (incluye descarga de plugings y datos de vulnerabilidades
y arranque ”manual” de los demonios)

    apt-get install sqlite3

    openvas-mkcert    # Crear certificado de servidor
    openvas-nvt-sync  # Descarga de plugins

    openvas-mkcert-client -n -i  # Crear certificado de cliente

    openvassd            # Arranque demonio OpenVAS Scanner 
    openvasmd --rebuild  # OpenVAS Manager, creación de BD de plugins (> 10-15 min.)

    openvas-scapdata-sync  # Descarga y parseo de XML de vulnerabilidades (> 15 min.)
    openvas-certdata-sync  # Descarga y parseo de XML de vulnerabilidades 

    openvasmd  # Arranque 'real' demonio OpenVAS Manager
    gsad       # Arranque del interfaz web

    openvasmd --create-user=admin --role=Admin # Crear un usuario 'admin' con rol administrador 
                                               # (imprimira su password)

Comprobación de la configuración

    wget --no-check-certificate https://svn.wald.intevation.org/svn/openvas/trunk/tools/openvas-check-setup
    bash openvas-check-setup

Puertos en uso:

-   OpenVas Scanner: 9391

-   OpenVas Manager: 9390

-   Interfaz web (`gsad`): 443

Acceso a la consola web

-   URL: `https://localhost:443`

-   Usuario `admin` con el password generado

    (es recomendable cambiar el password en `Administration->Users`)

Lanzar un scaneo:

-   En `Configuration->Target`: crear un nuevo objetivo `snort` con la
    IP 10.10.10.11)

-   En `Configuration->Scan Config`: crear una nueva política de escaneo
    `politica snort`, seleccionando los plugins que correspondan

-   En `Scan Management->Task`: definir un escaneo sobre el objetivo
    `snort` con la política `politica snort` y lanzarlo

-   Cuando termine, revisar el informe generado y comprobar en la
    consola SNORBY de la máquina `snort` (10.10.10.11) las nuevas
    alertas generadas

Documentación y entrega
=======================

1.  Documentar las pruebas realizadas con la librería SCAPY en la
    sección [sec:scapy].

    1.  Indicar y describir las reglas SNORT seleccionadas

    2.  Señalar los comando SCAPY necesarios para generar los paquetes
        que provoquen las alertas SNORT

        -   en caso de utilizar otras herramientas (`nc`, `socat`)
            indicar los comandos empleados

    3.  Documentar las alertas capturadas por el IDS SNORT y su
        visualización en la consola de SNORBY

<span>|l|</span>\
**IMPORTANTE (17/12/2015)**\
\

[t]<span>0.85</span>

-   Ante problemas para conseguir que SNORT reconozca las alerta, de
    cara a confeccionar la **documentación entregable** bastará con
    incluir:

    1.  **Identificar las reglas** para las cuales que se ha intentado
        forzar alertas

    2.  Describir el **procedimiento empleado** para intentar generar
        esa alerta (usando `scapy` ó usando `netcat`)

    3.  Señalar los resultados obtenidos: eventos registrados en la BD
        de SNORT o señalar la ausencia de eventos si no ha funcionado.

 \

\

