<?php
/**
 * A simple command line for Teinte output formats
 */
declare(strict_types=1);

include_once(__DIR__ . '/php/autoload.php');

use Oeuvres\Kit\File;

Teinte::cli();

class Teinte {
    /** formats */
    public static $ext = array(
        'html' => '.html',
        'iramuteq' => '.txt',
        'markdown' => '.txt',
        'naked' => '.txt',
        'article' => '_art.html',
        'toc' => '_toc.html',
        'detag' => '.txt',
    );
    public static function help():string 
    {
        $formats = implode(' | ', array_keys(self::$ext));
        return '
Tranform your tei files in different formats
    php teinte.php -f -d output/dir/  format "teidir/*.xml"
    -f         : ? no test of freshness, force deletion of destination file
    -d destdir : ? destination directory for generated files
    format     : ! ' . $formats . '
    globs      : + parameters, files or globs
';
    }
    public static function cli() {
        global $argv;
        $shortopts = "";
        $shortopts .= "h";
        $shortopts .= "f"; // force transformation
        $shortopts .= "d:"; // output directory
        $options = getopt($shortopts);
        // no args, probably not correct 
        if (count($argv) < 2) exit(self::help());
        // first arg will be strip, is script name
        reset($argv);
        while(($format = next($argv)) !== false) {
            if (isset(self::$ext[$format])) {
                break;
            }
        }
        if (!$format) {
            exit("\nNo available format found for transform\n" . self::help());
        }
        $force = isset($options['f']);
        $dstDir = "";
        if (isset($options['d'])) {
            $dstDir = $options['d'];
            File::mkdir($dstDir);
        }
        $dstDir = File::dirnorm($dstDir);
        while ($glob = next($argv)) {
            foreach (glob($glob) as $srcFile) {
                $dstName =  pathinfo($srcFile, PATHINFO_FILENAME);
                $dstFile = $dstDir . $dstName . '.docx';
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
                echo "$srcFile > $dstFile\n";
                // self::export($srcfile, $dst);
            }
        }
    }
    
}
