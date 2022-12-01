<?php
declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Log, LoggerWeb, Web};
use Oeuvres\Teinte\Format\{Tei};
use Oeuvres\Teinte\Tei2\{Tei2toc,Tei2article};

// output ERRORS to http client
Log::setLogger(new LoggerWeb(LogLevel::ERROR));
header("Content-Type: text/plain");

const DOCX = "docx";
const TEI = "tei";

// start session
session_start();
print_r($_SESSION);
// A TEI should have been done before by upload
// echo $_SESSION['tei'];