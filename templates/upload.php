<?php declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Filesys, Http, I18n, Log, LoggerWeb};
use Oeuvres\Teinte\Format\{Docx, File, Markdown, Tei};
use Oeuvres\Teinte\Tei2\{Tei2article};



// output ERRORS to http client
Log::setLogger(new LoggerWeb(LogLevel::ERROR));
// get workdir from params
$pars = require(dirname(__DIR__).'/pars.php');
if (!isset($pars['workdir']) || !$pars['workdir']) {
    // tmp maybe highly volatil on some servers
    $pars['workdir'] = session_save_path();
} 
I18n::load(__DIR__ . "/messages.tsv");

Http::session_before(); // needed for some oddities before session_start()
// clean even with error
session_start();
$_SESSION = [];
/*
// onload, destroy session, 
session_start();
$_SESSION = [];
// destroy session cookie
if (ini_get("session.use_cookies")) {
    $params = session_get_cookie_params();
    setcookie(session_name(), '', time() - 42000,
        $params["path"], $params["domain"],
        $params["secure"], $params["httponly"]
    );
}
session_destroy();
$lang = Http::lang();
*/


// get file
$upload = Http::upload();
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
$teinte_dir = $pars['workdir'] . "/" . $sessid . "/";
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
echo  $upload['name'] . "<br/>";


if ($format === "docx") {
    // check if docx ?
    $docx = new Docx();
    $docx->load($src_file);
    $docx->tei();
    file_put_contents($tei_file, $docx->xml());
    $_SESSION['teinte_tei_file'] = $tei_file;
    $_SESSION['teinte_docx_file'] = $src_file;
    echo Tei2article::toXml($docx->dom());
    die();
}
else if ($format === "tei") {
    // check if docx ?
    $tei = new Tei();
    $tei->load($src_file);
    $_SESSION['teinte_tei_file'] = $src_file;
    echo $tei->toXml('article');
    die();
}
else if ($format === "markdown") {
    $source = new Markdown();
    $source->load($src_file);
    $html = "<article>";
    $html .= $source->html();
    $html .= "</article>";
    echo $html;
    flush();
    $_SESSION['teinte_markdown_file'] = $src_file;

    $_SESSION['teinte_tei_file'] = $tei_file;
}
else {
    echo I18n::_('upload.format404', $upload["name"],  $format);
    die();
}

