<?php

include_once(__DIR__ . '/php/autoload.php');
$pars = include_once(__DIR__ . '/pars.php');

use Oeuvres\Kit\{Filesys, Route};

// here is a light router for teinte

$template = realpath($pars['template']);
$default =  __DIR__ . "/templates/default";
$index_php = "$template/index.php";
// a template folder maybe providen without an index.php
if (!Filesys::readable($index_php)) {
    $index = "$default/index.php";
}

// welcome page
Route::get('/', "$template/index.php");
// could be get, post or put
Route::route('/upload', "templates/upload.php");
Route::get('/download', "templates/download.php");
// if file exists in template, serve it
Route::get('^(.*)$', "$template$1");
// if file exists in default, serve it
Route::get('^(.*)$', "$default$1");

http_response_code(404);
echo "404";
