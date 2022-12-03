<?php
declare(strict_types=1);

require_once(__DIR__ . '/inc.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{I18n, Log, LoggerTxt, Parse, Web};
use Oeuvres\Teinte\Format\{File, Tei};
use Oeuvres\Teinte\Tei2\{Tei2toc,Tei2article};

// start session
session_start();

// output ERRORS to http client
Log::setLogger(new LoggerTxt(LogLevel::WARNING, 'Teinte, download [{datetime}] '));


function attach($dst_name) {
    $contentDisposition = 'Content-Disposition:  attachment; '
        . sprintf('filename="%s"; ', rawurlencode($dst_name))
        // . sprintf("filename*=utf-8''%s", rawurlencode($dst_name))
    ;
    header($contentDisposition);
}


// do not output response code for download
header('Content-Description: File Transfer');
header('Content-Type: application/octet-stream');
header('Content-Transfer-Encoding: binary');
header('Connection: Keep-Alive');
header('Expires: 0');
header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
header('Pragma: public');
ob_clean();

// nothing has been uploaded
if (!isset($_SESSION['teinte_tei_file'])) {
    attach("Teinte, " . I18n::_("ERROR_NO_UPLOAD") . '.txt');
    Log::error(I18n::_('download.notei'));
    print_r($_SESSION);
    exit();
}
$dst_name = I18n::_('book');
if (isset($_SESSION['teinte_name'])) {
    $upload_name =  $_SESSION['teinte_upload_name'];
    $dst_name = $_SESSION['teinte_name'];
}

$par_format = Web::par('format');
if (!$par_format) {
    attach("Teinte, " . I18n::_("ERROR_NO_FORMAT") . '.txt');
    Log::error(I18n::_('download.noformat', $upload_name));
    print_r($_SESSION);
    exit();
}
$format = File::path2format($par_format);
// exports supported
$supported = [DOCX, HTML, TEI, MARKDOWN];
if (!in_array($format, $supported)) {
    attach("Teinte, " . I18n::_("ERROR_UNKNOWN_FORMAT"). '.txt');
    echo I18n::_('download.format404', $par_format, $upload_name);
    exit("\n");
}

// Let binary and Google.Chrome is happy
// header('Content-Type: ' . File::mime($format));
$dst_file = $dst_name . File::ext($format);
attach($dst_file);


$tei_file = $_SESSION['teinte_tei_file'];
// Tei Export
if ($format == TEI) {
    $length = filesize($tei_file);
    header("Content-Length: $length");
    header("Accept-Ranges: $length");
    readfile($tei_file);
    die();
}
$tei = new Tei();
$tei->load($tei_file);

// html Export
if ($format == HTML) {
    $content = ltrim($tei->toXml('html', ['theme' => 'https://oeuvres.github.io/teinte/theme/']));
    $length = Web::length($content);
    header("Content-Length: $length", true);
    header("Accept-Ranges: $length", true);
    echo $content;
    die();
}
else if ($format == MARKDOWN) {
    $content = ltrim($tei->toXml(MARKDOWN));
    $length = Web::length($content);
    header("Content-Length: $length", true);
    header("Accept-Ranges: $length", true);
    echo $content;
    die();
}
else if ($format == DOCX) {
    $dst_file = Tei::destination($tei_file, DOCX);
    $tei->toUri(DOCX, $dst_file);
    $length = filesize($dst_file);
    header("Content-Length: $length");
    header("Accept-Ranges: $length");
    readfile($dst_file);
}
else {
    echo "GROS BUG";
}