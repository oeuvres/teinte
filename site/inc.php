<?php
include_once(dirname(__DIR__) . '/php/autoload.php');
// messages
use Oeuvres\Kit\{Route, I18n, Web};
$lang = Web::par('lang', 'fr', '/en|fr/', 'lang');
I18n::load(__DIR__ . "/$lang.tsv");

const DOCX = "docx";
const HTML = "html";
const TEI = "tei";
const MARKDOWN = "markdown";

