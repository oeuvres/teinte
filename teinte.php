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
use Oeuvres\Kit\{File, LoggerCli};
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
-d dst_dir : 0-1 destination directory for generated files
format     : 1-n among

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
        $dst_dir = "";
        if (isset($options['d'])) {
            $dst_dir = $options['d'];
            File::mkdir($dst_dir);
        }
        $dst_dir = File::normdir($dst_dir);
        // loop on globs
        for (; $i < $count; $i++) {
            self::export (
                $argv[$i],
                $formats,
                $dst_dir,
                $force
            );
        }
    }
    public static function export(
        string $glob, 
        array $formats,
        ?string $dst_dir = "",
        ?bool $force = false
    ) {
        $logger = new LoggerCli(LogLevel::INFO);
        $source = new TeiSource($logger);
        foreach (glob($glob) as $src_file) {
            $nodone = true; // for lazy load
            foreach($formats as $format) {
                // calculate $dst_file according to format
                $dst_file = $source->dst_file($src_file, $format, $dst_dir);
                // change inplace ? search/replace, reports…
                $inplace = (realpath($src_file) === realpath($dst_file));
                if ($force); // overwrite
                else if ($inplace); // always do something, for reports
                else if (!file_exists($dst_file)); // do not exist
                else if (filemtime($src_file) <= filemtime($dst_file)) {
                    continue;
                }
                if ($nodone) { // nothing done yet, load source
                    $logger->info($src_file);
                    $source->load($src_file);
                    $nodone = false;
                }
                // for reports, no output if no force
                if (!$force && $inplace) {
                    $source->toDoc($format);
                }
                else {
                    $source->toUri($format, $dst_file);
                }
           }
        }
    }
}

// EOL
