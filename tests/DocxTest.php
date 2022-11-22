<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Filesys, LoggerCli};
use Oeuvres\Teinte\Format\{Docx};


$logger = new LoggerCli(LogLevel::DEBUG);
$source = new Docx($logger);
$docx_file = __DIR__ . '/data/ocr.docx';
$source->load($docx_file);
$dst_dir = __DIR__ . "/out/";
$logger->error(Filesys::mkdir(dirname($dst_dir)));
file_put_contents($dst_dir.'ocr_tml.xml', $source->docxlite());

