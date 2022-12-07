# Install

Teinte is a PHP webapp. Installation suppose an http server configured.

## Ubuntu server

This tutorial has been tested through SSH on a quite fresh linux box from a research organization. Usually, most of the steps are not needed on a server already installed for other PHP apps, *they appears italicized*. It does not cover network configuration over the Internet, nor right policies among users. It supposes administration rights to install packages.

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

```
* 