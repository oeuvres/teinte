<?php
declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Oeuvres\Kit\Xml;
use Oeuvres\Kit\LoggerCli;
use Psr\Log\LogLevel;

/**
 * Test if new ZipArchive() is expensive
 * Answer: negligible compared to open a file
 */

$logger = new LoggerCli(LogLevel::DEBUG);
$zip_file = __DIR__ . '/data/ocr.docx';

echo "Check if everything is OK before massive load\n";
$start_time = microtime(true);
$zip = new ZipArchive();
echo "new()\t" . 1000 * (microtime(true) - $start_time), "ms\n";
if (!($zip->open($zip_file) === TRUE)) {
    throw new Exception ($this->file . ' seems not a valid zip archive');
}
echo "open()\t" . 1000 * (microtime(true) - $start_time), "ms\n";
$zip->close();
echo "close()\t" . 1000 * (microtime(true) - $start_time), "ms\n";

$loops = 1000;
for ($heat = 0; $heat < 10; $heat++)
{
    $start_time = microtime(true);
    for ($i = 0; $i < $loops; $i++) {
        $zip = new ZipArchive();
        $zip->open($zip_file);
        $zip->close();
    }
    echo "$loops new()->open()\t" . 1000 * (microtime(true) - $start_time), "ms\n";
    $start_time = microtime(true);
    $dom = new DOMDocument();
    for ($i = 0; $i < $loops; $i++) {
        $zip->open($zip_file);
        $zip->close();
    }
    echo "$loops ->open()\t" . 1000 * (microtime(true) - $start_time), "ms\n";
    $start_time = microtime(true);
    for ($i = 0; $i < $loops; $i++) {
        $zip = new ZipArchive();
        $zip = null;
    }
    echo "$loops new()\t" . 1000 * (microtime(true) - $start_time), "ms\n";
}
