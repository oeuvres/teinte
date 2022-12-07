# Install

Teinte is a PHP webapp. Installation suppose an http server configured.

## Ubuntu server over SSH

This tutorial has been tested through SSH on a quite fresh linux box from a research organization. Usually, most of those steps are not needed on a server already installed for other PHP apps, *they appears italicized*. It does not cover network configuration over the Internet, nor right policies among users. It supposes administration rights to install packages.

* checkout app where you have room and rights, this way allow to manage multiple versions of an app
```
/data$ git clone https://github.com/oeuvres/teinte.git
/data$ cd teinte
/data/teinte$
```
* *install a web server apache*
```
/data/teinte$ sudo apt update
/data/teinte$ sudo apt install apache2
```
* *install a command line browser usable through ssh*
```
/data/teinte$ sudo apt install lynx
```
* *check if Apache is started*
```
/data/teinte$ lynx http://localhost
   Ubuntu Logo
   Apache2 Default Page
   It works! […]
# Q to quit
```
* make your app visible from your web server as a symbolic link
```
/data/teinte$ sudo ln -s $(pwd) /var/www/html/teinte
/data/teinte$ ls -alh /var/www/html/
    drwxr-xr-x 6 root root 4.0K Dec  7 13:24 .
    drwxr-xr-x 3 root root 4.0K Dec  6 11:40 ..
    -rw-r--r-- 1 root root  11K Dec  6 11:40 index.html
    lrwxrwxrwx 1 root root   16 Dec  7 13:24 teinte -> /data/app/teinte
    […]
```
* *check if your app is visible for static files (dynamic php files may not work)*
```
/data/teinte$ lynx http://localhost/teinte/README.md
    # Teinte
    […]
# Q to quit
/data/teinte$ lynx localhost/teinte/check.php
    […]
    If you see this, php is no working properly on this server
    […]
# Q to quit
```
* *install php*
```
/data/teinte$ sudo apt install php
/data/teinte$ lynx localhost/teinte/check.php
        PHP is working
    […]
```
* *Ensure that .htaccess are handled and apache mod_rewrite is installed, check it for http:// but also for ssl https://*
```
/data/teinte$ lynx localhost/teinte/check.php
    [error] Apache mod_rewrite is not enabled, and/or .htaccess files are not read
/data/teinte$ sudo a2enmod rewrite
/data/teinte$ sudo nano /etc/apache2/sites-enabled/000-default.conf
    # find <Directory> AllowOverride All 
/data/teinte$ sudo apachectl configtest
/data/teinte$ sudo service apache2 restart
```
* *Check required PHP extensions, and install them (do not forget to restart Apache after installation)*
```
/data/teinte$ lynx localhost/teinte/check.php
        PHP is working
   [alert] xsl extension required.
   Check your php.ini.
   On Ubuntu or Debian like systems: sudo apt install php-xml

   [alert] mbstring extension required.
   Check your php.ini.
   On Ubuntu or Debian like systems: sudo apt install php-mbstring

   [alert] zip extension required.
   Check your php.ini.
   On Ubuntu or Debian like systems: sudo apt install php-zip

   Fatal error: Uncaught Error: Call to undefined function Oeuvres\Kit\mb_internal_encoding() in /data/app/teinte/php/Oeuvres/Kit/I18n.php:19 Stack trace: #0 /data/app/teinte/php/autoload.php(6):
   include_once() #1 /data/app/teinte/php/Oeuvres/Kit/Filesys.php(151): {closure}() #2 /data/app/teinte/_check.php(25): Oeuvres\Kit\Filesys::readable() #3 {main} thrown in
   /data/app/teinte/php/Oeuvres/Kit/I18n.php on line 19 
# Q to quit
/data/teinte$ sudo apt install php-xml php-mbstring php-zip
/data/teinte$ sudo service apache2 restart
```
* create the local parameter file teinte/pars.php, app will try to create one from a model (_pars.php) but could fail according to your rights policy
```
/data/teinte$ lynx localhost/teinte/check.php
        PHP is working

   [warning] “/data/app/teinte/pars.php”, path not found

    [warning] “/data/app/teinte/pars.php”, impossible to write, “/data/app/teinte” owned by “1001” exists but is not writable by www-data

   [error] You have to create pars.php file by yourself, see the model file, _pars.php

/data/teinte$ cp _pars.php pars.php
/data/teinte$ lynx localhost/teinte/check.php
        PHP is working
        Teinte should work, visit this link
```
