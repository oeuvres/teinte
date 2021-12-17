<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Logger,Xml};
use Oeuvres\Teinte\TeiSource;

/**
 * This is not a kind of unit test, because human evaluation of
 * a good export requires for now a lot more than some 
 * automated assertions.
 */
Tei2split4articleTest::run();
class Tei2split4articleTest
{
    static public function run()
    {
        $logger = new Logger(LogLevel::DEBUG);
        Xml::setLogger($logger);
        $source = new TeiSource($logger);
        $logger->info("Test TEI export as a set of articles by chapter");
        $srcFile = __DIR__.'/hugo1862_miserables.xml';
        $source->load($srcFile);
        $source->toUri("split", __DIR__.'/out/hugo1862_miserables.xml');
        $source->toUri("site", __DIR__.'/out/hugo1862_miserables');
    }
}

// EOF