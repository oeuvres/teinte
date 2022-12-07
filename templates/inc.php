<?php declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Oeuvres\Kit\{I18n};

I18n::load(__DIR__ . "/messages.tsv");
// get workdir from params
$pars = require(dirname(__DIR__).'/pars.php');
if (!isset($pars['workdir']) || !$pars['workdir']) {
    $pars['workdir'] = sys_get_temp_dir();
}
$pars['workdir'] = rtrim($pars['workdir'], '\/') . '/'; 

const TEINTE = "teinte";
