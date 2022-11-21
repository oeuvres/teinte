<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Filesys, LoggerCli};
use Oeuvres\Teinte\Format\{Css};


$logger = new LoggerCli(LogLevel::DEBUG);
$source = new Css($logger);
$css_file = __DIR__ . '/html_dirty/epub_mscalibre.css';
$css = file_get_contents($css_file);
print_r(css::parse($css));

