<?php
declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Filesys, I18n, Log, LoggerWeb, Web};
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


// make a session dir
$sessid = session_id();
if (!$sessid) $sessid = "teinte";
$teinte_dir = sys_get_temp_dir() . "/" . $sessid . "/";
if (isset($_SESSION['teinte_dir'])) {
    if($_SESSION['teinte_dir'] != $teinte_dir) {
        // where to log that ? something is going wrong
        Filesys::rmdir($_SESSION['teinte_dir']);
    } 
}
$_SESSION['teinte_dir'] = $teinte_dir;
Filesys::mkdir($teinte_dir);
if (!isset($upload['name']) || !$upload['name']) {
    // Shout something here
    echo I18n::_('upload.noname');
    die();
}
$src_file = $teinte_dir .$upload['name'];
if (!move_uploaded_file($upload["tmp_name"], $src_file)) {
    echo I18n::_('upload.nomove', $upload["tmp_name"],  $src_file);
    // upload went wrong, we should shout something here
    die();
}
$src_name =  pathinfo($src_file, PATHINFO_FILENAME);


$tei_file = $teinte_dir . $src_name . ".xml"; 
$_SESSION['teinte_name'] =  $src_name;
$_SESSION['teinte_upload_name'] = $upload['name'];
$format = File::path2format($upload['name']);
echo  $upload['name'] . "  $format<br/>";


if ($format === DOCX) {
    // check if docx ?
    $docx = new Docx();
    $docx->load($src_file);
    $docx->tei();
    file_put_contents($tei_file, $docx->xml());
    $_SESSION['teinte_tei_file'] = $tei_file;
    $_SESSION['teinte_docx_file'] = $src_file;
    echo Tei2article::toXml($docx->dom());
    return;
}
else if ($format === TEI) {
    // check if docx ?
    $tei = new Tei();
    $tei->load($src_file);
    $_SESSION['teinte_tei_docx'] = $src_file;
    echo $tei->toXml('article');
}
else {
    $_SESSION['tei'] = null;
    echo I18n::_('upload.format404', $upload["tmp_name"],  $format);
}

