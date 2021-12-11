<?php
/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 */

declare(strict_types=1);

include_once(__DIR__ . '/php/autoload.php');

use Psr\Log\{LogLevel};
use Oeuvres\Kit\{File, Logger};
use Oeuvres\Teinte\{TeiSource, TeiExportFactory};

/**
 * A simple command line for Teinte output formats
 */
Teinte::cli();
class Teinte {
    public static function help():string 
    {
        return '
php teinte.php -f -d output/dir/  format "teidir/*.xml"
Tranform your tei files in different formats

-f         : 0-1 force deletion of destination file (no test of freshness)
-d destdir : 0-1 destination directory for generated files
format     : 1 or more among

' . TeiExportFactory::help() . '
globs      : 1-n parameters, files or globs

';
    }
    public static function cli() {
        global $argv;
        $shortopts = "";
        $shortopts .= "h";
        $shortopts .= "f"; // force transformation
        $shortopts .= "d:"; // output directory
        $options = getopt($shortopts);
        $count = count($argv); 
        // no args, probably not correct
        if ($count < 2) exit(self::help());
        // loop on args to find first format
        for ($i = 1; $i < $count; $i++) {
            if (TeiExportFactory::has($argv[$i])) break;
        }
        if ($i == $count) {
            exit("\nNo available format found for transform\n" . self::help());
        }
        $formats = array();
        for (; $i < $count; $i++) {
            if (!TeiExportFactory::has($argv[$i])) break;
            $formats[$argv[$i]] = null;
        }
        if ($i == $count) {
            exit("\nNo files found to transform\n" . self::help());
        }
        $formats = array_keys($formats);
        $force = isset($options['f']);
        $dstDir = "";
        if (isset($options['d'])) {
            $dstDir = $options['d'];
            File::mkdir($dstDir);
        }
        $dstDir = File::dirnorm($dstDir);
        // loop on globs
        for (; $i < $count; $i++) {
            self::export (
                $argv[$i],
                $formats,
                $dstDir,
                $force
            );
        }
    }
    public static function export(
        string $glob, 
        array $formats,
        ?string $dstDir = "",
        ?bool $force = false
    ) {
        $logger = new Logger(LogLevel::INFO);
        $source = new TeiSource($logger);
        foreach (glob($glob) as $srcFile) {
            $nodone = true;
            foreach($formats as $format) {
                $dstFile = $source->dstFile($srcFile, $format, $dstDir);
                if ($force); // overwrite
                else if (!file_exists($dstFile)); // do not exist
                else if (filemtime($srcFile) <= filemtime($dstFile)) {
                    continue;
                }
                if ($nodone) {
                    echo "$srcFile\n";
                    $source->load($srcFile);
                    $nodone = false;
                }
                $source->toUri($format, $dstFile);
           }
        }
    }
}

// EOL
