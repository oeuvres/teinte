<?php
/**
 * code convention https://www.php-fig.org/psr/psr-12/
 *
 */

declare(strict_types=1);

namespace Oeuvres\Teinte;

use Exception;

class File
{

    /**
     * A safe mkdir dealing with rights
     */
    static function mkdir(string $dir)
    {
        if (is_dir($dir)) {
            return $dir;
        }
        if (!mkdir($dir, 0775, true)) {
            throw new Exception("Directory not created: ".$dir);
        }
        @chmod($dir, 0775);  // let @, if www-data is not owner but allowed to write
        return $dir;
    }

    /**
     * Delete all files in a directory, create it if not exist
     */
    static public function dirclean(string $dir, int $depth = 0)
    {
        if (is_file($dir)) {
            return unlink($dir);
        }
        // attempt to create the folder we want empty
        if (!$depth && !file_exists($dir)) {
            if (!mkdir($dir, 0775, true)) {
                throw new Exception("Directory not created: ".$dir);
            }
            @chmod($dir, 0775);  // let @, if www-data is not owner but allowed to write
            return;
        }
        // should be dir here
        if (is_dir($dir)) {
            $handle=opendir($dir);
            while (false !== ($entry = readdir($handle))) {
                if ($entry == "." || $entry == "..") {
                    continue;
                }
                self::dirclean($dir.'/'.$entry, $depth+1);
            }
            closedir($handle);
            // do not delete the root dir
            if ($depth > 0) {
                rmdir($dir);
            }
            // timestamp newDir
            else {
                touch($dir);
            }
            return;
        }
    }


    /**
     * Recursive deletion of a directory
     * If $keep = true, keep directory with its acl
     */
    static function rmdir(string $dir, bool $keep = false) {
        $dir = rtrim($dir, "/\\").DIRECTORY_SEPARATOR;
        if (!is_dir($dir)) {
            return $dir; // maybe deleted
        }
        if (!($handle = opendir($dir))) {
            throw new Exception("Read impossible " . $dir);
        }
        while(false !== ($filename = readdir($handle))) {
            if ($filename == "." || $filename == "..") {
                continue;
            }
            $file = $dir.$filename;
            if (is_link($file)) {
                throw new Exception("Delete a link? ".$file);
            }
            else if (is_dir($file)) {
                self::rmdir($file);
            }
            else {
                unlink($file);
            }
        }
        closedir($handle);
        if (!$keep) {
            rmdir($dir);
        }
        return $dir;
    }


    /**
     * Recursive copy of folder
     */
    public static function rcopy($srcdir, $dstdir) 
    {
        $srcdir = rtrim($srcdir, "/\\").DIRECTORY_SEPARATOR;
        $dstdir = rtrim($dstdir, "/\\").DIRECTORY_SEPARATOR;
        self::mkdir($dstdir);
        $dir = opendir($srcdir);
        while(false !== ($filename = readdir($dir))) {
            if ($filename[0] == '.') {
                continue;
            }
            $srcfile = $srcdir.$filename;
            if (is_dir($srcfile)) {
                self::rcopy($srcfile, $dstdir.$filename);
            }
            else {
                copy($srcfile, $dstdir.$filename);
            }
        }
        closedir($dir);
    }

    /**
     * Build a hash from tsv file where first col is the key.
     */
    static function tsvhash($tsvfile, $sep="\t")
    {
        $ret = array();
        $handle = fopen($tsvfile, "r");
        $l = 1;
        while (($data = fgetcsv($handle, 0, $sep)) !== FALSE) {
            if (!$data || !count($data)) {
                continue;
            }
            if (isset($ret[$data[0]])) {
                echo $tsvfile,'#',$l,' not unique key:', $data[0], "\n";
            }
            $ret[$data[0]] = $data;
        }
        return $ret;
    }

}
