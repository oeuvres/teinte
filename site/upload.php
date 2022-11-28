<?php
declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Log, LoggerWeb, Web};
use Oeuvres\Teinte\Format\{Docx};

// output ERRORS to http client
Log::setLogger(new LoggerWeb(LogLevel::ERROR, "[{level}] {datetime} "));


// get file
$upload = Web::upload();
// web upload should log more
if (!$upload || !count($upload) && !isset($upload['tmp_name'])) {
    http_response_code(400 );
    exit();
}
// file should be OK here, start session
session_start();
$src_file = $upload['tmp_name'];
$_SESSION["teinte:file"] = $upload['name'];
// check if docx ?
$source = new Docx();
$source->load($src_file);

$source->docx_pkg();
$source->pkg_tei();
$source->tei_pcre();
echo $source->xml();
