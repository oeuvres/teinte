<?php
declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Log, LoggerWeb, Misc, Web};
use Oeuvres\Teinte\Format\{Docx, File, Tei};
use Oeuvres\Teinte\Tei2\{Tei2toc,Tei2article};

// output ERRORS to http client
Log::setLogger(new LoggerWeb(LogLevel::ERROR));


const DOCX = "docx";
const TEI = "tei";

// clean even with error
session_start();
$_SESSION = [];

// get file
$upload = Web::upload();
// web upload should log more
if (!$upload || !count($upload) && !isset($upload['tmp_name'])) {
    // TODO, better messages here
    http_response_code(400 );
    exit();
}

$src_file = $upload['tmp_name'];
// orginal name
$file_name = $upload['name'];
$_SESSION['name'] = $file_name;
// $ext = pathinfo($filename, PATHINFO_EXTENSION);
$format = File::path2format($file_name);


if ($format === DOCX) {
    // check if docx ?
    $source = new Docx();
    $source->load($src_file);
    $source->tei();
    $_SESSION['tei'] = $source->xml();
    echo Tei2article::toXml($source->dom());
    return;
}
else if ($format === TEI) {
    // check if docx ?
    $source = new Tei();
    $source->load($src_file);
    $_SESSION['tei'] = $source->xml();
    echo $source->toXml('article');
}
else {
    $_SESSION['tei'] = null;
}
