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
use Oeuvres\Kit\{Filesys, Log, LoggerCli};
use Oeuvres\Teinte\Format\{Tei};
use Oeuvres\Teinte\Tei2\{AbstractTei2};

/**
 * A simple command line for Tei output formats
 */
Teinte::cli();
class Teinte {
    public static function help():string 
    {
        $help = '
Tranform tei files in different formats
    php teinte.php (options)* (format)+ "teidir/*.xml"

PARAMETERS
format      : + among
' . AbstractTei2::help() .
'globs       : + files or globs

OPTIONS
-f          : ? force deletion of destination file (no test of freshness)
-d dst_dir  : ? destination directory for generated files
-t tmpl_dir : ?  a specific template directory, known ones here';
$templates = "templates/";
$glob = glob(__DIR__ . "/templates/*", GLOB_ONLYDIR | GLOB_MARK);
foreach ($glob as $dir) {
    $help .= "\n    " . Filesys::relpath(getcwd(), $dir);
}
        return $help . "\n";
    }
    public static function cli() {
        global $argv;
        $shortopts = "";
        $shortopts .= "h"; // help message
        $shortopts .= "f"; // force transformation
        $shortopts .= "d:"; // output directory
        $shortopts .= "t:"; // template directory
        $options = getopt($shortopts);
        $count = count($argv); 
        // no args, probably not correct
        if ($count < 2) exit(self::help());
        // loop on args to find first format
        for ($i = 1; $i < $count; $i++) {
            if (AbstractTei2::has($argv[$i])) break;
        }
        if ($i == $count) {
            exit("\nNo available format found for transform\n" . self::help());
        }
        $formats = array();
        for (; $i < $count; $i++) {
            if (!AbstractTei2::has($argv[$i])) break;
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
            Filesys::mkdir($dst_dir);
        }
        $dst_dir = Filesys::normdir($dst_dir);
        $tmpl_dir = null;
        if (isset($options['t'])) $tmpl_dir = $options['t'];
        // loop on globs
        for (; $i < $count; $i++) {
            self::export (
                $argv[$i],
                $formats,
                $dst_dir,
                $tmpl_dir,
                $force
            );
        }
    }
    public static function export(
        string $glob, 
        array $formats,
        ?string $dst_dir = "",
        ?string $tmpl_dir = null,
        ?bool $force = false
    ) {
        Log::setLogger(new LoggerCli(LogLevel::INFO));

        $source = new Tei();
        $source->template($tmpl_dir); // set template dir
        foreach (glob($glob) as $src_file) {
            $nodone = true; // for lazy load
            foreach($formats as $format) {
                // calculate $dst_file according to format
                $dst_file = $source->destination($src_file, $format, $dst_dir);
                // change inplace ? search/replace, reports…
                $inplace = (realpath($src_file) === realpath($dst_file));
                if ($force); // overwrite
                else if ($inplace); // always do something, for reports
                else if (!file_exists($dst_file)); // do not exist
                else if (filemtime($src_file) <= filemtime($dst_file)) {
                    continue;
                }
                if ($nodone) { // nothing done yet, load source
                    Log::info($src_file);
                    try {
                        $source->load($src_file);
                    } 
                    catch (Exception $e) {
                        // nothing could be done with this file
                        break;
                    }
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
