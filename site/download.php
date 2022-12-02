<?php
declare(strict_types=1);

include_once(__DIR__ . '/inc.php');

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
if (!isset($_SESSION['tei'])) {
    attach("Teinte, " . I18n::_("ERROR_NO_UPLOAD") . '.txt');
    Log::error(I18n::_('download.notei'));
    exit();
}
$dst_name = I18n::_('book');
$src_file = ""; 
if (isset($_SESSION['name'])) {
    $src_file =  $_SESSION['name'];
    $dst_name = pathinfo($src_file, PATHINFO_FILENAME);
}

$par_format = Web::par('format');
if (!$par_format) {
    attach("Teinte, " . I18n::_("ERROR_NO_FORMAT") . '.txt');
    Log::error(I18n::_('download.noformat', $src_file));
    exit();
}
$format = File::path2format($par_format);
// exports supported
$supported = ['tei', 'html'];
if (!in_array($format, $supported)) {
    attach("Teinte, " . I18n::_("ERROR_UNKNOWN_FORMAT"). '.txt');
    echo I18n::_('download.format404', $par_format, $src_file);
    exit("\n");
}

// Let binary and Google.Chrome is happy
// header('Content-Type: ' . File::mime($format));
$dst_file = $dst_name . File::ext($format);
attach($dst_file);


// Tei Export
if ($format == 'tei') {
    // erro length ?
    $content = ltrim($_SESSION['tei']);
    $length = Web::length($content);
    header("Content-Length: $length", true);
    header("Accept-Ranges: $length");
    echo $content;
    die();
}
$tei = new Tei();
$tei->loadXml($_SESSION['tei']);
// if tmp file needed
$tmp_file = tempnam(sys_get_temp_dir(), "teinte_");

// html Export
if ($format == 'html') {
    $content = ltrim($tei->toXml('html', ['theme' => 'https://oeuvres.github.io/teinte/theme/']));
    $length = Web::length($content);
    header("Content-Length: $length", true);
    header("Accept-Ranges: $length", true);
    echo $content;
    die();
}


