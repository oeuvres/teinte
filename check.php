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
if (!Filesys::readable(__DIR__.'/pars.php')) {
    Log::warning("You have no parameters file, a default one has been created, find it in your webapp, feel free to modify");
    copy(__DIR__ . '/_pars.php', __DIR__ . '/pars.php');
}

$pars = include_once(__DIR__ . '/pars.php');

echo "<h1>Teinte should work, visit <a href=\".\">this link</a></h1>\n";
        ?>
    </body>
</html>
