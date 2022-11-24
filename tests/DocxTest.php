<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Filesys, Log, LoggerCli};
use Oeuvres\Teinte\Format\{Docx};


Log::setLogger(new LoggerCli(LogLevel::DEBUG, "[{level}] {datetime} "));

$source = new Docx();
$source->template(dirname(__DIR__).'/templates/jamesfr');
$docx_file = __DIR__ . '/data/ocr.docx';
$src_name = pathinfo($docx_file, PATHINFO_FILENAME);

$source->load($docx_file);
$dst_dir = __DIR__ . "/out/";
Filesys::mkdir(dirname($dst_dir));
$source->docx_pkg();
file_put_contents($dst_dir. $src_name .'_1.xml', $source->xml());
$source->docx_tei();
file_put_contents($dst_dir. $src_name .'_2.xml', $source->xml());
$source->tei_pcre();
file_put_contents($dst_dir. $src_name .'_3.xml', $source->xml());

