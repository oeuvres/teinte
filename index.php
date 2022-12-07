<?php

include_once(__DIR__ . '/php/autoload.php');
$pars = include_once(__DIR__ . '/pars.php');

use Oeuvres\Kit\{Filesys, Route};

$template = realpath($pars['template']);
// a template folder maybe providen without an index.php
if (!Filesys::readable("$template/index.php")) {
    $template = __DIR__ . "/templates/default";
}

// welcome page
Route::get('/', "$template/index.php");
// maybe get, post or put
Route::route('/upload', "templates/upload.php");
Route::get('/download', "templates/download.php");
Route::get('^(.*)\.(css|png|jpg|js|svg)$', "$template/$1.$2");
http_response_code(404);
echo "404";
