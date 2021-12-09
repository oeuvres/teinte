<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Oeuvres\Teinte\{Tei2docx, TeiExporter};
use Oeuvres\Kit\Xml;
use Oeuvres\Kit\Logger;
use Oeuvres\Teinte\Teidoc;
use Psr\Log\LogLevel;


$logger = new Logger(LogLevel::DEBUG);
Xml::setLogger($logger);
$srcFile = __DIR__.'/blanqui1866_prise-armes.xml';
$xml = file_get_contents($srcFile);
$xml = TeiExporter::normTei($xml); // normalize spaces for docx
$dom = Xml::domXml($xml);
$tei2docx = new Tei2docx($logger);
$tei2docx->toUri(
    $dom, 
    $tei2docx->dstFile($srcFile, __DIR__ . "/out")
);
