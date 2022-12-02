<?php
declare(strict_types=1);

include_once(__DIR__ . '/inc.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{I18n, Log, LoggerWeb, Parse, Web};
use Oeuvres\Teinte\Format\{File, Tei};
use Oeuvres\Teinte\Tei2\{Tei2toc,Tei2article};

// output ERRORS to http client
Log::setLogger(new LoggerWeb(LogLevel::ERROR));

// start session
session_start();
// nothing has been uploaded
if (!isset($_SESSION['tei'])) {
    http_response_code(404);
    echo "<h1>" . I18n::_('download.notei') . "</h1>";
    exit("\n");
}
$par_format = Web::par('format');
$src_filename = "";
if (isset($_SESSION['name'])) $src_filename = $_SESSION['name'];
$dst_name = pathinfo($src_filename, PATHINFO_FILENAME);
if (!$dst_name) $dst_name = I18n::_('book');


if (!$par_format) {
    http_response_code(400);
    echo "<h1>" . I18n::_('download.noformat', $src_filename) . "</h1>";
    exit("\n");
}
$format = File::path2format($par_format);
// exports supported
$supported = ['tei', 'html'];
if (!$format || !in_array($format, $supported)) {
    http_response_code(400);
    echo "<h1>" . I18n::_('download.format404', $par_format, $src_filename) . "</h1>";
    exit("\n");
}


header('Content-Type: ' . File::mime($format));
$dst_name .= File::ext($format);
header('Coucou: ' . $dst_name);
$contentDisposition = 'Content-Disposition: attachment; '
    . sprintf('filename="%s"; ', rawurlencode($dst_name))
    . sprintf("filename*=utf-8''%s", rawurlencode($dst_name));
header($contentDisposition);
header('Content-Description: File Transfer');
header('Expires: Thu, 19 Nov 1981 08:52:00 GMT');
header('Cache-Control: no-store, no-cache, must-revalidate');
header('Pragma: no-cache');

// Tei Export
if ($format == 'tei') {
    header("Content-Length: " . Web::length($_SESSION['tei']));
    flush();
    print($_SESSION['tei']);
    exit("\n");
}
$tei = new Tei();
$tei->loadXml($_SESSION['tei']);
// if tmp file needed
$tmp_file = tempnam(sys_get_temp_dir(), "teinte_");

// html Export
if ($format == 'html') {
    $html = $tei->toXml('html');
    header("Content-Length: " . Web::length($html));
    flush();
    print($html);
    exit("\n");
}


