# Install

Teinte is a PHP webapp. Installation suppose an http server configured.

## Ubuntu server over SSH

This tutorial has been tested through SSH on a quite fresh linux box from a research organization. Usually, most of those steps are not needed on a server already installed for other PHP apps. It does not cover network configuration over the Internet, nor right policies among users. It supposes administration rights to install packages.

```sh
# install a command line browser usable through ssh
sudo apt install lynx
# [apache] install a web server with required modules and conf
sudo apt update
sudo apt install apache2
sudo a2enmod rewrite
# allow .htaccess, find <Directory> AllowOverride All, check also ssl
sudo nano /etc/apache2/sites-enabled/000-default.conf
# install php and required module
sudo apt install php php-xml php-mbstring php-zip
sudo service apache2 restart
# install teinte
cd /var/www/html
git clone https://github.com/oeuvres/teinte.git
# check install
lynx localhost/teinte/check.php
# Q to quit
```

Possible error messages from the check page

* Alert!: Unable to connect to remote host.
    * error in the the link\
    `localhost/teinte/check.php`
    * Apache server is not started\
    `sudo service apache start`
* […] If you see this, php is no working properly on this server […]
    * `sudo apt install php php-xml php-mbstring php-zip`
* [alert] xsl extension required.
* [alert] mbstring extension required.
* [alert] zip extension required.
    * `sudo apt install php-xml php-mbstring php-zip`
* [error] Apache mod_rewrite is not enabled, and/or .htaccess files are not read
    * see [apache] upper in tuto
* [warning] “…/teinte/pars.php”, path not found
* [warning] “…/teinte/pars.php”, impossible to write, “…/teinte” owned by “1001” exists but is not writable by www-data
* [error] You have to create pars.php file by yourself, see the model file, _pars.php
    * `cp _pars.php pars.php`
* Teinte should work, visit this link
    * open your graphic browser

