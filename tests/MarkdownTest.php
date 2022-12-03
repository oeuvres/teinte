<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Filesys, Log, LoggerCli};
use Oeuvres\Teinte\Format\{Markdown};

Log::setLogger(new LoggerCli(LogLevel::DEBUG));

$src_file = __DIR__ . '/data/marx1848_manifeste1886.md';
if (isset($argv[1])) {
    $src_file = $argv[1];
}
// $docx_file = __DIR__ . '/data/test.docx';


$source = new Markdown();
$source->load($src_file);
echo $source->html();
