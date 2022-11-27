<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Filesys, Log, LoggerCli};
use Oeuvres\Teinte\Format\{Docx};

$logger = new LoggerCli(LogLevel::DEBUG, "[{level}] {datetime} ");
Log::setLogger($logger);

$source = new Docx();
$source->template(dirname(__DIR__).'/templates/jamesfr');
$glob = dirname(__DIR__, 2) . '/medict_xml/jamesfr-docx/*.docx';
$dst_dir = dirname(__DIR__, 2) . '/medict_xml/xml';
$teiHeader = file_get_contents(__DIR__ . '');

$cote = '';
foreach (glob($glob) as $docx_file) {

}
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


