<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Oeuvres\Teinte\Tei2dc;
use Oeuvres\Kit\Xml;
use Oeuvres\Kit\Logger;
use Psr\Log\LogLevel;


$logger = new Logger(LogLevel::DEBUG);
Xml::setLogger($logger);
$srcFile = __DIR__.'/blanqui1866_prise-armes.xml';
$dom = Xml::dom($srcFile);
$tei2dc = new Tei2dc($logger);
echo "Label: " . $tei2dc->label()."\n";
$tei2dc->toUri($dom, $tei2dc->dstFile($srcFile, __DIR__ . "/out"));
// echo $tei2dc->toXml($dom);
