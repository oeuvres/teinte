<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Filesys, Log, LoggerCli};
use Oeuvres\Teinte\Format\{Docx};

$docx_file = __DIR__ . '/data/test.docx';

Log::setLogger(new LoggerCli(LogLevel::DEBUG));

$source = new Docx();
$source->template(dirname(__DIR__).'/templates/jamesfr');
$src_name = pathinfo($docx_file, PATHINFO_FILENAME);

$source->load($docx_file);
$dst_dir = __DIR__ . "/out/";
Filesys::mkdir(dirname($dst_dir));
$source->pkg();
file_put_contents($dst_dir. $src_name .'_1.xml', $source->xml());
$source->teilike();
file_put_contents($dst_dir. $src_name .'_2.xml', $source->xml());
$source->pcre();
file_put_contents($dst_dir. $src_name .'_3.xml', $source->xml());
$source->tmpl();
file_put_contents($dst_dir. $src_name .'_4.xml', $source->xml());
Log::info("Done");
