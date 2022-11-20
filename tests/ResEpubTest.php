<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{File, LoggerCli};
use Oeuvres\Teinte\{SourceEpub};



/*

$logger = new LoggerCli(LogLevel::DEBUG);
$source = new SourceHtml($logger);
$css_file = __DIR__ . '/html_dirty/epub_mscalibre.css';
$css = file_get_contents($css_file);
print_r(SourceHtml::css_semantic($css));
$src_glob = "C:/src/ricardo/epub_DIgEco/*.epub";
$dst_dir = "C:/src/ricardo/opf/";
File::mkdir($dst_dir);
foreach(glob($src_glob) as $epub_file)
{
    SourceHtml::unzip_glob($epub_file, "/\.ncx$/", $dst_dir);
}
*/