<?php declare(strict_types=1);

/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 */



namespace Oeuvres\Kit;

use ZipArchive;

/**
 * code convention https://www.php-fig.org/psr/psr-12/
 */

class Filesys
{

    /**
     * Normalize a directory filepath with a last /
     */
    static function normdir($dir)
    {
        if (!$dir) return $dir;
        $dir = rtrim(trim($dir), "\\/");
        if (!$dir) {
            return "";
        }
        return $dir . DIRECTORY_SEPARATOR;
    }

    /**
     * Check if a file is writable, if it does not exists
     * go to the parent folder to test if it is possible to create.
     * 
     * @param string  $path
     *
     * @return mixed true if Yes, "message" if not
     */
    public static function writable(string $path):bool
    {
        if (is_writable($path)) return true;
        // if not file exists, go up to parents
        $parent = $path;
        while (!file_exists($parent)) {
            $parent = dirname($parent);
        }
        if (is_link($parent)) {
            Log::warning(I18n::_('Filesys.writable.is_link', $path, $parent));
            return false;
        }
        if (is_writable($parent)) return true;
        if (is_readable($parent)) {
            Log::warning(I18n::_('Filesys.writable.is_readable', $path, $parent, self::owner($parent) ));
            return false;
        }
        return self::readable($parent);
    }

    /**
     * Is a file path absolute ?
     */
    public static function isabs(string $path): bool
    {
        // true if file exists
        if (realpath($path) == $path) {
            return true;
        }
        // ./* relpath
        if (strlen($path) == 0 || '.' === $path[0]) {
            return false;
        }
        // url protocol
        if (preg_match('#^file:#', $path)) {
            return true;
        }
        // Windows drive pattern
        if (preg_match('#^[a-zA-Z]:\\\\#', $path)) {
            return true;
        }
        // A path starting with / or \ is absolute
        return ('/' === $path[0] || '\\' === $path[0]);
    }

    /**
     * Get relative path between 2 absolute file path
     */
    public static function relpath(string $from, string $to): string
    {
        // some compatibility fixes for Windows paths
        $from = is_dir($from) ? rtrim($from, '\/') . '/' : $from;
        $to   = is_dir($to)   ? rtrim($to, '\/') . '/'   : $to;
        // normalize paths
        $from = preg_replace('@[\\\\/]+@', '/', $from);
        $to   = preg_replace('@[\\\\/]+@', '/', $to);

        $from     = explode('/', $from);
        $to       = explode('/', $to);
        $relpath  = $to;

        foreach ($from as $depth => $dir) {
            // find first non-matching dir
            if ($dir === $to[$depth]) {
                // ignore this directory
                array_shift($relpath);
            } else {
                // get number of remaining dirs to $from
                $remaining = count($from) - $depth;
                if ($remaining > 1) {
                    // add traversals up to first matching dir
                    $padLength = (count($relpath) + $remaining - 1) * -1;
                    $relpath = array_pad($relpath, $padLength, '..');
                    break;
                } else {
                    $relpath[0] =  $relpath[0];
                }
            }
        }
        $href =  implode('/', $relpath);
        // if path with ../
        // we can have things like galenus/../verbatim/verbatim.css
        // is it safe ? let’s try
        $re = '@\w[^/]*/\.\./@';
        while (preg_match($re, $href)) {
            $href = preg_replace($re, '', $href);
        }
        return $href;
    }

    /**
     * Check existence of a file to read.
     *
     * @return mixed true if Yes, "message" on error
     */
    public static function readable(string $file):bool
    {
        if (is_readable($file)) return true;
        if (is_file($file)) {
            Log::warning(I18n::_('Filesys.readable.is_file', $file));
            return false;
        }
        if (file_exists($file)) {
            Log::warning(I18n::_('Filesys.readable.exists', $file));
            return false;
        }
        Log::warning(I18n::_('Filesys.readable.404', $file));
        return false;
    }
    /**
     * A safe mkdir dealing with rights
     * 
     * @return mixed true if done, "message" on error
     */
    static function mkdir(string $dir):bool
    {
        $pref = __CLASS__ . "::" . __FUNCTION__ . "  ";

        // nothing done, ok.
        if (is_dir($dir)) {
            return false;
        }
        if (!self::writable($dir)) return false;
        if (!mkdir($dir, 0775, true)) {
            Log::warning(I18n::_('Filesys.mkdir.error', $dir));
            return false;
        }
        // let @, if www-data is not owner but allowed to write
        @chmod($dir, 0775);  
        return true;
    }

    /**
     * Ensure an empty dir with no contents, create it if not exist
     *
     * @return mixed true if done, "message" on error
     */
    static public function cleandir(string $dir)
    {
        $ret = self::writable($dir);
        if ($ret !== true) return $ret;
        // attempt to create the folder we want empty
        if (!file_exists($dir)) {
            return self::mkdir($dir);
        }
        $ret = self::rmdir($dir, true);
        if ($ret !== true) return $ret;

        touch($dir); // change timestamp
        return true;
    }

    /**
     * Recursive deletion of a directory
     * If $keep = true, base directory is kept with its acl
     * Return true if OK,
     * or an informative message if not.
     */
    static public function rmdir(string $dir, bool $keep = false)
    {
        $pref = __CLASS__ . "::" . __FUNCTION__ . "  ";
        // nothing to delete, go away
        if (!file_exists($dir)) {
            return $pref . "Path not found, remove impossible:\n\"$dir\"";
        }
        if (is_file($dir)) {
            return $pref . "Path is a file, not a directory to remove:\n\"$dir\"";
        }

        if (!($handle = opendir($dir))) {
            return $pref . "Dir impossible to open for remove:\n\"$dir\"";
        }
        $log = [];
        while (false !== ($entry = readdir($handle))) {
            if ($entry == "." || $entry == "..") {
                continue;
            }
            $path = $dir . DIRECTORY_SEPARATOR . $entry;
            if (is_link($path) || is_file($path)) {
                if (!unlink($path)) {
                    $log[] = $pref . "Dir impossible to delete:\n\"$dir\"";
                }
            } else if (is_dir($path)) {
                if (true !== ($ret = self::rmdir($path))) $log[] = $ret;
            } else {
                $log[] = $pref . "Path not file nor dir:\n\"$dir\"";
            }
        }
        closedir($handle);
        if (!$keep) {
            if (true !== rmdir($dir)) $log[] = $pref . "Dir empty but impossible to remove:\n\"$dir\"";
        }
        if (count($log) > 0) return implode("\n", $log);
        // everything has been OK
        return true;
    }


    /**
     * Recursive copy of folder
     */
    public static function rcopy(
        string $src_dir,
        string $dst_dir
    ) {
        $pref = __CLASS__ . "::" . __FUNCTION__ . "  ";
        $src_dir = rtrim($src_dir, "/\\") . DIRECTORY_SEPARATOR;
        $dst_dir = rtrim($dst_dir, "/\\") . DIRECTORY_SEPARATOR;
        if (true !== ($ret = self::mkdir($dst_dir))) return $ret;
        $dir = opendir($src_dir);
        $log = [];
        while (false !== ($src_name = readdir($dir))) {
            // no copy of hidden files (what about .htaccess ?)
            if ($src_name[0] == '.') {
                continue;
            }
            $src_path = $src_dir . $src_name;
            $dst_path = $dst_dir . $src_name;
            if (is_dir($src_path)) {
                $ret = self::rcopy($src_path, $dst_path);
                if (true !== $ret) $log[] = $ret;
            } else {
                $ret = copy($src_path, $dst_path);
                if (true !== $ret) {
                    $log[] = $pref . "copy failed \"$src_path\" X \"$dst_path\"";
                }
            }
        }
        closedir($dir);
        if (count($log) > 0) return implode("\n", $log);
        // everything has been OK
        return true;
    }

    /**
     * Zip folder to a zip file
     */
    static public function zip(
        string $zipFile,
        string $srcDir
    ) {
        $zip = new ZipArchive();
        if (!file_exists($zipFile)) {
            $zip->open($zipFile, ZIPARCHIVE::CREATE);
        } else {
            $zip->open($zipFile);
        }
        self::zipDir($zip, $srcDir);
        $zip->close();
    }


    /**
     * The recursive method to zip dir
     * start with files (especially for mimetype epub)
     */
    static private function zipDir(
        object $zip,
        string $srcDir,
        string $entryDir = ""
    ) {
        $srcDir = rtrim($srcDir, "/\\") . '/';
        // files
        foreach (array_filter(glob($srcDir . '/*'), 'is_file') as $srcPath) {
            $srcName = basename($srcPath);
            if ($srcName == '.' || $srcName == '..') continue;
            $entryPath = $entryDir . $srcName;
            $zip->addFile($srcPath, $entryPath);
        }
        // dirs
        foreach (glob($srcDir . '/*', GLOB_ONLYDIR) as $srcPath) {
            $srcName = basename($srcPath);
            if ($srcName == '.' || $srcName == '..') continue;
            $entryPath = $entryDir . $srcName;
            $zip->addEmptyDir($entryPath);
            self::zipDir($zip, $srcPath, $entryPath);
        }
    }

    /**
     * Is file path absolute ?
     */
    static function isPathAbs($path)
    {
        if (!$path) return false;
        if ($path[0] === DIRECTORY_SEPARATOR || preg_match('~\A[A-Z]:(?![^/\\\\])~i', $path) > 0) return true;
        return false;
    }

    /**
     * Get owner of a file by name
     */
    static public function owner(string $file):?string
    {
        if (self::readable($file)) return null;
        $userinfo = posix_getpwuid(fileowner($file));
        return $userinfo['name'];
    }

}
