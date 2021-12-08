<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Oeuvres\Teinte\Teidoc;
use Oeuvres\Kit\Xml;
use Oeuvres\Kit\Logger;
use Psr\Log\LogLevel;


$logger = new Logger();
Xml::setLogger($logger);
$xml = file_get_contents(__DIR__.'/blanqui1866_prise-armes.xml');

// echo Teidoc::normTei($xml);

echo "Log level: Error\n";
Xml::transformToXML(
    __DIR__ . "/tei2dc.xsl",
    Xml::domXml($xml)
);
echo "Log level: Info\n";
$logger->setLevel(LogLevel::INFO);
Xml::transformToXML(
    __DIR__ . "/tei2dc.xsl",
    Xml::domXml($xml)
);