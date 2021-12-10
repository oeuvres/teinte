<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Oeuvres\Teinte\TeiExportFactory;


$formats = array(
    "NOT A FORMAT",
    "dc",
    "iramuteq",
    "markdown",
    "toc",
);

foreach ($formats as $format){
    echo $format . "?\t" . var_export(TeiExportFactory::has($format), true)."\n";
}

// EOF