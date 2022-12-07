<?php declare(strict_types=1);

include_once(__DIR__ . '/inc.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Filesys, Http, I18n, Log, LoggerWeb};
use Oeuvres\Teinte\Format\{Docx, File, Markdown, Tei};
use Oeuvres\Teinte\Tei2\{Tei2article};

function cookie($cookie)
{
    $cookie_options = [
        'expires' => time() + (3600), // 1 hour
        // 'path' => '/', local path should be OK
        // 'secure' => false,
        'httponly' => true,
        'samesite' => 'Strict',
    ];
    setcookie(TEINTE, json_encode($cookie), $cookie_options);
}

// output ERRORS to http client
Log::setLogger(new LoggerWeb(LogLevel::ERROR));
// default options for created cookie


// get file
$upload = Http::upload();
// web upload should log more
if (!$upload || !count($upload) && !isset($upload['tmp_name'])) {
    // TODO, better messages here
    http_response_code(400 );
    exit();
}

// make a session dir
$cookie = [];
if (isset($_COOKIE[TEINTE])) {
    $cookie = json_decode($_COOKIE[TEINTE], true);
}
if (!isset($cookie_teinte['id'])) {
    $cookie['id'] = uniqid();
}


$tmp_dir = $pars['workdir'] . $cookie['id'] . "/";
Filesys::mkdir($tmp_dir);
// TODO log if something went wrong in tmp dir creation

if (!isset($upload['name']) || !$upload['name']) {
    // no original name ? 
    echo I18n::_('upload.noname');
    die();
}

$src_file = $tmp_dir .$upload['name'];
if (!move_uploaded_file($upload["tmp_name"], $src_file)) {
    // upload went wrong
    echo I18n::_('upload.nomove', $upload["tmp_name"],  $src_file);
    die();
}
$cookie['src_basename'] = $upload['name'];
$src_name =  pathinfo($upload['name'], PATHINFO_FILENAME);
$cookie['name'] =  $src_name;


// tei_file TODO
$tei_file = $tmp_dir . $src_name . ".xml"; 
$format = File::path2format($upload['name']);


// stict elsif, do no forget to write cookie at the end
if ($format === "docx") {
    // check if docx ?
    $docx = new Docx();
    $docx->load($src_file);
    $docx->tei();
    file_put_contents($tei_file, $docx->xml());
    $cookie['tei_basename'] = basename($tei_file);
    $cookie['docx_basename'] = basename($src_file);
    cookie($cookie);
    flush();
    echo  $upload['name'] . "<br/>";
    echo Tei2article::toXml($docx->dom());
}
else if ($format === "tei") {
    // check if xml ?
    $tei = new Tei();
    $tei->load($src_file);
    $cookie['tei_basename'] = basename($src_file);
    cookie($cookie);
    flush();
    echo  $upload['name'] . "<br/>";
    echo $tei->toXml('article');
}
else if ($format === "markdown") {
    $cookie['markdown_basename'] = basename($src_file);
    $cookie['tei_basename'] = basename($tei_file);
    cookie($cookie);
    flush();
    $source = new Markdown();
    $source->load($src_file);
    $html = "<article>";
    $html .= $source->html();
    $html .= "</article>";
    echo  $upload['name'] . "<br/>";
    echo $html;
}
else {
    echo I18n::_('upload.format404', $upload["name"],  $format);
    die();
}


