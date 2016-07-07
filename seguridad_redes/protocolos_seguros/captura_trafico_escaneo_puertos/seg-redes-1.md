# Captura de tráfico y escaneo de puertos

## Entorno de prácticas

## Software de virtualización VirtualBOX

En estas prácticas se empleará el software de virtualización VirtualBOX para simular pequeñas redes formadas por equipos GNU/Linux.

* Página principal: <http://virtualbox.org>
* Más información: <http://es.wikipedia.org/wiki/Virtualbox>

## Imágenes a utilizar

Imágenes de partida

1.  Scripts de instalación

   * para GNU/Linux:
     * Ejecutar desde el directorio de descarga

                alumno@pc:~$ bash ejercicio-nmap.sh

   * para MS Windows (Vista o superior):
     * Ejecutar desde el directorio de descarga

                Powershell.exe -executionpolicy bypass -file ejercicio-nmap.ps1


    **NOTAS:**
    1.  En ambos scripts la variable `$DIR_BASE` especifica donde se descargarán las imágenes y se crearán las MVs.

        * Por defecto en GNU/Linux será en `$HOME/SSI1516` y en Windows en `C:\\SSI1516`

        * Puede modificarse antes de lanzar los scripts para hacer la  instalación en otro directorio más conveniente (disco externo, etc)

    2.  Es posible descargar las imágenes comprimidas manualmente (o
        intercambiarlas con USB), basta descargar los archivos con
        extensión `.vdi.zip` de y copiarlos en el directorio anterior
        (`$DIR_BASE`) para que el script haga el resto.

2.  El script descargará las siguientes imágenes en el directorio
    `DIR_BASE` (`$HOME/SSI1516` ó `C:\\SSI1516`)

    *   `base.vdi` (1,6 GB comprimida, 4,4 GB descomprimida): Imagen VirtualBox de la máquina ”víctima”

        Usuarios configurados.

          ****login****   ****password****
          --------------- ------------------
          `root`          `purple`
          `usuario1`      `usuario1`

    *   `swap2015.vdi`: Imagen VirtualBox de una unidad de disco
        formateada como SWAP

3.  Se pedirá un identificador (sin espacios) para poder reutilizar las
    versiones personalizadas de las imágenes creadas

4.  Arrancar las instancias <span>VirtualBOX</span> (si no lo hacen
    desde el script anterior) desde el interfaz gráfico o desde la línea
    de comandos.

        VBoxManage startvm INTERNO1-<id>
        VBoxManage startvm INTERNO2-<id>
        VBoxManage startvm OBSERVADOR-<id>

    **Importante:** Después de finalizar cada ejercicio terminar la
    ejecución de la máquina virtual desde línea de comandos con
    `poweroff` o `sudo poweroff` o desde el interfaz gráfico LXDE.

# Intercepción de mensajes y escaneo de puertos

## Descripción

El ejercicio consta de dos partes.

*   Realizar una sesión de intercepción de mensajes utilizando el     *sniffer*/analizador de redes y comprobar la vulnerabilidad de los servicios que no usan cifrado.

*   Realizar una sesión de recopilación de información empleando el escáner de puertos .

## Desarrollo

Red donde se realizarán los ejercicios:

![image](scanner)

Servicios arrancados por defecto en todas las máquinas

*   servidor web (Apache 2) [**Nota:** puede ser necesario reiniciarlo manualmente con `service apache2 restart`]
*   servidor telnet (arrancado por `openbsd-inetd`)
*   servidor ssh (openSSH)
*   servidor ftp (arrancado por `openbsd-inetd`)
*   servidor finger (arrancado por `openbsd-inetd`)
*   servidor MySQL
*   servidor SMTP (postfix)
*   servidores POP3 e IMAP (dovecot)

## Ejercicio 1

El primer ejercicio consistirá en el uso de la herramienta
_Wireshark_ desde el equipo ***observador*** para interceptar
el tráfico _telnet_, _http_ y _ssh_
entre los equipos ***interno1*** e ***interno2***.

_Wireshark_ es un *sniffer* de red y un analizador de protocolos que
recopila los paquetes que fluyen por la red, los analiza, extrae el
contenido de los campos de diferentes protocolos y los presenta al
usuario.

*  Página de <span>wireshark</span>:
*  Más información:

### Pasos:

1.  En **observador** (192.168.100.33): iniciar _Wireshark_

    *   Iniciar el entorno gráfico:

                  # startx    

    *   Arrancar <span>wireshark</span>:
        `[Inicio] > Internet > Wireshark`

2.  En **observador** (192.168.100.33): iniciar la escucha de la red.

    *   Menú `''Capture'' -> ''Interfaces''`
    *   Pulsar botón `[Start]` del interfaz _eth0_

3.  En ***interno2 (192.168.100.22)***: iniciar una conexión
    _telnet_ con **interno1** (192.168.100.11)

        interno2:~# telnet 192.168.100.11
        Trying 192.168.100.11...
        Connected to interno1.
        Escape character is '^]'.

        Linux 2.6.26-1-686 (192.168.100.22) (pts/18)

        alqueidon login: usuario1
        Password: usuario1
        ...
        interno1:~$ ls -l
        ...
        interno1:~$ exit

4.  En **observador** (192.168.100.33): analizar el tráfico recopilado

    *   Detener captura con el botón `[Stop]`
    *   Filtrar el tráfico _telnet_ capturado
        *   Poner `telnet` en el campo `''Filter''`
        *   Recorrer los paquetes capturados y comprobar los datos
            intercambiados
            *   Seleccionar `Telnet` en la lista de plantillas a aplicar
                sobre los paquetes
            *   Moverse entre los paquetes con `control` + $\uparrow$ /
                $\downarrow$
        *   Otra opción: seleccionar el primer paquete de la conexión y
            seleccionar `[botón derecho] -> Follow TCP stream`

### Tareas:

#### Tarea 1.
    Repetir el ejercicio de captura de tráfico, realizando una conexión
    SSH desde el equipo **interno2** (192.168.100.22) al equipo
    **interno1** (192.168.100.11).

        interno2:~# ssh usuario1@192.168.100.11
        usuario@192.168.100.11's password: usuario1
        ...
        interno1:~$ ls -l
        ...
        interno1:~$ exit

#### Tarea 2.
    Repetir el ejercicio de captura de tráfico, realizando una conexión
    WEB desde el equipo **interno2** (192.168.100.22) al equipo
    **interno1** (192.168.100.11).

    *   Poner de nuevo _Wireshark_ a escuchar en el interfaz _eth0_
        (puede ser recomendable salir de Wireshark y volver a iniciarlo)

    *   **Opción 1:** usar el navegador web en modo texto _Lynx_

            interno2:~# lynx 192.168.100.11
            ...

    *   **Opción 2:** usar _Mozilla Firefox_ desde el interfaz gráfico.

            interno2:~# startx
            ...

        Arrancar _icewaesel_:
        `[Inicio] > Internet > Navegador Web Iceweasel`

#### Tarea 3.
   Habilitar el soporte SSL en el servidor Apache2 y comprobar que
    sucede cuando se ”escucha” una conexión SSL/TLS.

    En el equipo **interno1** (192.168.100.11):

    1.  Crear un certificado autofirmado para el servidor web.

            interno1:~# mkdir /etc/apache2/ssl/
            interno1:~# make-ssl-cert /usr/share/ssl-cert/ssleay.cnf /etc/apache2/ssl/apache.pem

        *   Cuando se solicite el nombre del servidor HTTP, indicar
            **interno1.ssi.net**
        *   Cuando se solicite los *”nombres alternativos*, dejar el
            campo en blanco

        El fichero generado (`/etc/apache2/ssl/apache.pem`) contiene
        tanto el certificado del servidor como la clave privada asociada
        al mismo.

            interno1:~# cat /etc/apache2/ssl/apache.pem
            interno1:~# openssl x509 -text -in /etc/apache2/ssl/apache.pem
            interno1:~# openssl rsa -text -in /etc/apache2/ssl/apache.pem

        **Nota:** `make-ssl-cert` es una utilidad de Debian (incluida en
        el paquete DEB *ssl-cert*) para generar certificados
        autofirmados para pruebas (los datos de configuración del
        certificado a generar se indican en
        `/usr/share/ssl-cert/ssleay.cnf`). Internamente hace uso de las
        utilidades de la librería `openssl`.

        **Nota:** En un servidor real se suele utilizar un certificado
        emitido por una autoridad de certificación (CA) reconocida (o
        bien una CA pública o una CA propia de la organización). No es
        recomendable utilizar certificados autofirmados en sistemas en
        producción ya que son fácilmente falsificables.

    2.  Editar la configuración SSL por defecto para indicar el
        certificado del servidor y su respectiva clave privada.

            interno1:~# nano /etc/apache2/sites-available/default-ssl

        Asignar los siguientes valores a los parámetros (en caso de que
        estén comentados descomentarlos)

            ...
            SSLEngine on
            ...
            SSLCertificateFile /etc/apache2/ssl/apache.pem
            SSLCertificateKeyFile /etc/apache2/ssl/apache.pem
            ...

        Asegurar que el fichero `/etc/apache2/ports.conf` incluya el
        valor `Listen 443`

    3.  Habilitar soporte SSL en Apache2 y habilitar la configuracion
        SSL por defecto

            interno1:~# a2enmod ssl
            interno1:~# a2ensite default-ssl
            interno1:~# service apache2 restart

        **Nota**:

        *   **a2enmod** es un comando (en Debian y derivados) para
            habilitar módulos de Apache2

            Los ficheros de configuración de los módulos disponibles
            están en `/etc/apache2/mods-available/` y al habilitarlos se
            crea un enlace simbólico desde `/etc/apache2/mods-enabled/`

        *   **a2ensite** es un comando (en Debian y derivados) para
            habilitar configuraciones de ”sitios web” en Apache2

            Los ficheros de configuración de los ”sitios web”
            disponibles (normalmente son configuraciones de servidores
            virtuales Apache) están en `/etc/apache2/sitess-available/`
            y al habilitarlos se crea un enlace simbólico desde
            `/etc/apache2/sites-enabled/`

    En el equipo **observador** (192.168.100.33): Iniciar una sesión
    de escucha en _WireShark_.

    En el equipo **interno2** (192.168.100.22):

    1.  Iniciar el entorno gráfico (con `startx`) y abrir un navegador
        web Iceweasel

    2.  Indicar `https://interno1.ssi.net` en la barra de direcciones.

    3.  Dará un aviso de que la CA que firma el certificado del servidor
        no está reconocida. Añadir la correspondiente excepción de
        seguridad y permitir la descarga y aceptación del certificado
        (antes de aceptarlo se puede ver el contenido del certificado)

    Comprobar en **observador** (192.168.100.33) el resultado de la
    escucha.

## Ejercicio 2

El segundo ejercicio consistirá en el uso de la herramienta de escaneo
de puertos _nmap_ para obtener información de los equipos y
servicios de la red.

La herramienta _nmap_ implementa diversas técnicas para extraer información
de los equipos que forman parte de una red y para identificar los
puertos y servicios que están disponibles en distintas máquinas. Algunos
de los métodos disponibles realizan el escaneo sin dejar rastro,
mientras que otros dejarán un rastro en los ficheros de log de las
máquinas analizadas.

*   Página de <span>nmap</span>: <http://www.nmap.org>
*   Más información: <http://es.wikipedia.org/wiki/Nmap>
*   Manual en español: <http://nmap.org/man/es/>
*   Tutorial en inglés: <http://www.nmap-tutorial.com>

### Pasos:

1.  Enumerar equipos de la red y sus servicios

    Desde la máquina **observador** (192.168.100.33):

    1.  Lanzar un escaneado **Ping Sweeping** [opción `-sP`] para
        identificar, mediante Ping, las máquinas que componen la red

              observador:~# nmap -sP 192.168.100.0/24


    2.  Sobre cada uno de los equipos que aparezcan como activos
        (exluido **observador**) realizar un escaneo de tipo **TCP
        connect scanning** [opción `-sT`] para determinar que
        puertos están abiertos.

              observador:~# nmap -sT -v 192.168.100.11
              observador:~# nmap -sT -v 192.168.100.22


    3.  Repetir el escaneado sobre **interno1** (192.168.100.11), añadiendo
        la opción `-O` para que _nmap_ trate de
        identificar el Sistema Operativo que ejecuta y la opción
        `-sV` para determinar la versión concreta de los servicios
        que tiene activados.

              observador:~# nmap -sT -O -sV 192.168.100.11   (tarda unos segundos)


    Los escaneados anteriores dejan rastro. Comprobar los ficheros de
    log `tail /var/log/syslog` en las máquinas **interno1** e
    **interno2** y verificar que ha quedado constancia de las
    conexiones realizadas por _nmap_.

        interno1:~# tail /var/log/syslog

    **Nota:** El rastro del escaneo de tipo `-sT` que queda en
    `/var/log/syslog`

    *   Fue guardado por el servidor _telnet_ en el momento
        en que se estableció la conexión Telnet

    *   Es necesario haber arrancado previamente el servidor Telnet
        (`/etc/init.d/openbsd-inetd start`).

2.  Comprobar escaneos ”silenciosos”

    Evaluaremos el comportamiento de los distintos tipos de escaneo
    sobre la máquina **interno1** (192.168.100.11)

    1.  En la máquina **interno1** (192.168.100.11) se habilitará una regla
        del firewall *netfilter* para hacer log de los paquetes SYN con
        intentos de conexión TCP.

        *  Escribir el siguiente comando `iptables`

                interno1:~# iptables -A INPUT -i eth0 -p tcp \
                                     --tcp-flags SYN SYN -m state --state NEW \
                                     -j LOG --log-prefix "Inicio conex:"


        *   Monitorizar continuamente el fichero de logs
            `/var/log/syslog`, con el comando `tail -f`

                interno1:~# tail -f /var/log/syslog      
                                      (el terminal se libera con CONTROL+C)

    2.  Desde la máquina **observador* (192.168.100.33) lanzar 3 tipos
        de escaneos nmap y comprobar en **interno1** (192.168.100.11) como
        evoluciona el log.

        * **TCP connect scanning**   [opción `-sT`]: Escaneo con conexiones TCP completas (opción  por defecto)

                observador:~# nmap -sT 192.168.100.11

        * **SYN scanning**  [opción `-sS`]: Escaneo con paquetes SYN (conexiones
            parcialmente iniciadas)

                observador:~# nmap -sS 192.168.100.11

        * **NULL scanning**   [opción `-sN`]: Escaneo con paquetes ”nulos” (todos los flags TCP a 0)

                observador:~# nmap -sN 192.168.100.11

**Nota:** Existe un interfaz gráfico para _nmap_ que se
puede arrancar desde el entorno gráfico de
**observador** (192.168.100.33) para probar otras opciones del escaner.

*   Desde el menú principal: `[Inicio] > Internet > Zenmap`
*   Desde un terminal:

        observador:~# zenmap &

 

# Documentación y entrega

El material entregable de esta práctica constará de una pequeña memoria
documentando los ejercicios realizados y los resultados obtenidos en
cada paso realizado, junto con las conclusiones que se deriven de dichos
resultados.

-   Descripción de acciones realizadas y resultados obtenidos en
    ejercicio 1

-   Resultados de las tareas 1, 2 y 3

-   Conclusiones del ejercicio 1

-   Descripción de acciones realizadas y resultados obtenidos en
    ejercicio 2

-   Conclusiones del ejercicio 2

**ENTREGA:** en FAITIC, hasta **18/12/2015**
