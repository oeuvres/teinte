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

use Oeuvres\Kit\File;

/**
 * A simple command line for Teinte output formats
 */
Teinte::init();
Teinte::cli();
class Teinte {
    /** formats */
    public static $transfos = array();
    public static function init() {
        self::$transfos['docx'] = array(
            'ext' => '.docx', 
            'function' => function($srcFile, $dstFile) {
                return Oeuvres\Teinte\Docx::export($srcFile, $dstFile);
            }
        );
        self::$transfos['html'] = array(
            'ext' => '.html', 
            /*
            'function' => function($srcFile, $dstFile) {
                return Oeuvres\Teinte\Docx::export($srcFile, $dstFile);
            }
            */
        );

        /*
        'html' => '.html',
        'docx' => 
        'iramuteq' => '.txt',
        'markdown' => '.txt',
        'naked' => '.txt',
        'article' => '_art.html',
        'toc' => '_toc.html',
        'detag' => '.txt',
        */
    }
    public static function help():string 
    {
        $formats = implode('  ', array_keys(self::$transfos));
        return '
Tranform your tei files in different formats
    php teinte.php -f -d output/dir/  format "teidir/*.xml"
    -f         : 0-1 no test of freshness, force deletion of destination file
    -d destdir : 0-1 destination directory for generated files
    format     : 1-n ' . $formats . '
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
            if (isset(self::$transfos[$argv[$i]])) break;
        }
        if ($i == $count) {
            exit("\nNo available format found for transform\n" . self::help());
        }
        $formats = array();
        for (; $i < $count; $i++) {
            if (!isset(self::$transfos[$argv[$i]])) break;
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
        foreach (glob($glob) as $srcFile) {
            $dstName =  pathinfo($srcFile, PATHINFO_FILENAME);
            $nodone = true;
            foreach($formats as $format) {
                $dstFile = $dstDir . $dstName . self::$transfos[$format]['ext'];
                if ($force); // overwrite
                else if (!file_exists($dstFile)); // do not exist
                else if (filemtime($srcFile) <= filemtime($dstFile)) {
                    continue;
                }
                if ($nodone) {
                    echo "$srcFile\n";
                    $nodone = false;
                }
                echo "[$format]\t";
                self::$transfos[$format]['function']($srcFile, $dstFile);
                echo "$dstFile\n";
           }

            /*
            if (!$force) {
                $i = 0;
                $rename = $dst;
                while (file_exists($rename)) {
                    if (!$i) echo "File $rename already exists, ";
                    $i++;
                    $rename = $dstname . '_' . $i . '.docx';
                }
                if ($i) {
                    rename($dst, $rename);
                    echo "renamed to $rename\n";
                }
            }
            */
            // self::export($srcfile, $dst);
        }
    }
    
}
