<?php
declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Oeuvres\Kit\Xml;
use Oeuvres\Kit\LoggerCli;
use Psr\Log\LogLevel;

/**
 * Test if DOMDocuemt() creation is expensive
 * Answer: negligible compared to load of textual document
 */

$logger = new LoggerCli();
Xml::setLogger($logger);
$xml = file_get_contents(__DIR__.'/blanqui1866_prise-armes.xml');
echo "Check if everything is OK before massive load\n";
$dom = new DOMDocument();
$dom->loadXML($xml);

$loops = 1000;
for ($heat = 0; $heat < 10; $heat++)
{
    $start_time = microtime(true);
    for ($i = 0; $i < $loops; $i++) {
        $dom = new DOMDocument();
        $dom->loadXML($xml);
    }
    echo "$loops new()->load()\t" . 1000 * (microtime(true) - $start_time), "ms\n";
    $start_time = microtime(true);
    $dom = new DOMDocument();
    for ($i = 0; $i < $loops; $i++) {
        $dom->loadXML($xml);
    }
    echo "$loops ->load()\t" . 1000 * (microtime(true) - $start_time), "ms\n";
    $start_time = microtime(true);
    for ($i = 0; $i < $loops; $i++) {
        $dom = new DOMDocument();
    }
    echo "$loops new  dom()\t" . 1000 * (microtime(true) - $start_time), "ms\n";
}
