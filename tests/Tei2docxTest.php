<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Oeuvres\Teinte\{Tei2docx, TeiExporter};
use Oeuvres\Kit\Xml;
use Oeuvres\Kit\LoggerCli;
use Oeuvres\Teinte\TeiSource;
use Psr\Log\LogLevel;


$logger = new LoggerCli(LogLevel::DEBUG);
$source = new TeiSource($logger);
$srcFile = __DIR__.'/blanqui1866_prise-armes.xml';
$dom = $source->load($srcFile);
$tei2docx = new Tei2docx($logger);
$tei2docx->toUri(
    $dom,
    $tei2docx->dstFile($srcFile, __DIR__ . "/out")
);
