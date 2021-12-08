<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Oeuvres\Kit\Logger;
use Psr\Log\LogLevel;


$logger = new Logger(LogLevel::ERROR);
echo "LogLevel=",LogLevel::ERROR,"\n";
logs();
echo "\n\nLogLevel=",LogLevel::DEBUG,"\n";
$logger->setLevel(LogLevel::DEBUG);
logs();


function logs() {
    global $logger;
    echo "error() ";
    $logger->error("Une erreur !");
    echo "warning() ";
    $logger->warning("Un avertissement…");
    echo "debug() ";
    $logger->debug("Du débogage.");
        
}
