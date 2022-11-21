<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Filesys, LoggerCli};

$logger = new LoggerCli(LogLevel::DEBUG);

$logger->info(Filesys::rmdir("/lexiste/pas"));

