<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\LoggerCli;
use Oeuvres\Teinte\{SourceTei, TeiExportFactory};

$logger = new LoggerCli(LogLevel::DEBUG);
$logger->info("Test all available TEI export formats");
$srcFile = __DIR__.'/blanqui1866_prise-armes.xml';
$source = new SourceTei();
$source->load($srcFile);
$dstDir = __DIR__.'/out/';

foreach (TeiExportFactory::list() as $format){
    $logger->info($format);
    $dstFile = $source->destination($srcFile, $format, $dstDir);
    $source->toUri($format, $dstFile);
}

// EOF