<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{LoggerCli};
use Oeuvres\Teinte\Format\{Docx};


$logger = new LoggerCli(LogLevel::DEBUG);
$source = new Docx($logger);
$docx_file = __DIR__ . '/data/test.docx';
$source->load($docx_file);
echo $source->docxlite();
