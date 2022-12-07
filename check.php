<html>
    <head>
        <title>Check php</title>
    </head>
    <body>
        <?php 
$text = <<<EOT
<h1>If you see this, php is no working  properly on this server</h1>
EOT;
// <!--
echo "<h1>PHP is working</h1>";
// -->
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include_once(__DIR__ . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Check, Filesys, Log, LoggerWeb};

Log::setLogger(new LoggerWeb(LogLevel::DEBUG));

Check::extension('xsl', 'mbstring', 'zip');

// verify .htaccess
$htaccess = __DIR__ . "/.htaccess";
if (!Filesys::readable($htaccess)) {
    Log::error(".htaccess is required");
    die();
}
if (!isset($_GET['rewrite'])) {
    Log::error("Apache mod_rewrite is not enabled, and/or .htaccess files are not read
sudo a2enmod rewrite
sudo nano /etc/apache2/sites-enabled/000-default.conf
# find AllowOverride, set to All
$ sudo service apache2 restart
    ");
    die();
}

$pars_file = __DIR__ . '/pars.php';
if (!Filesys::readable($pars_file)) {
    Log::warning("You have no parameters file, attempt to create a default one");
    $from = __DIR__ . '/_pars.php';
    if (!copy($from, $pars_file)) { // probably writes problem
        Filesys::writable($pars_file);
        Log::error("You have to create pars.php file by yourself, see the model file, _pars.php
".dirname($pars_file)."$ cp _pars.php pars.php
        ");
        die();
    }
}

$pars = include_once(__DIR__ . '/pars.php');

echo "<h1>Teinte should work, visit <a href=\".\">this link</a></h1>\n";
        ?>
    </body>
</html>
