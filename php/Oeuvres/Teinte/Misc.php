<?php
/**
 * code convention https://www.php-fig.org/psr/psr-12/
 *
 */

declare(strict_types=1);

namespace Oeuvres\Teinte;

use DOMDocument, Exception, XSLTProcessor;

class Misc
{
    /** XSLTProcessors */
    private static $transcache = array();
    /** get a temp dir */
    private static $tmpdir;
    /** A logger, maybe a stream or a callable, used by Tools::log() */
    private static $logger;
    /** Log level */
    public static $debug = false;

    static function logger($logger=null) {
        if ($logger != null) {
            self::$logger = $logger;
        }
        return self::$logger;
    }

    static function mois($num)
    {
        $mois = array(
            1 => 'janvier',
            2 => 'février',
            3 => 'mars',
            4 => 'avril',
            5 => 'mai',
            6 => 'juin',
            7 => 'juillet',
            8 => 'août',
            9 => 'septembre',
            10 => 'octobre',
            11 => 'novembre',
            12 => 'décembre',
        );
        return $mois[(int)$num];
    }

    /**
     * Get a DOM document with best options
     */
    static function dom($xmlfile) {
        $dom = new DOMDocument();
        $dom->preserveWhiteSpace = false;
        $dom->formatOutput = true;
        $dom->substituteEntities = true;
        $dom->load($xmlfile, LIBXML_NOENT | LIBXML_NONET | LIBXML_NSCLEAN | LIBXML_NOCDATA | LIBXML_NOWARNING);
        return $dom;
    }
    /**
     * Xsl transform from xml file
     */
    static function transform($xmlfile, $xslfile, $dst=null, $pars=null)
    {
        return self::transformDoc(self::dom($xmlfile), $xslfile, $dst, $pars);
    }

    static public function transformXml($xml, $xslfile, $dst=null, $pars=null)
    {
        $dom = new DOMDocument();
        $dom->preserveWhiteSpace = false;
        $dom->formatOutput=true;
        $dom->substituteEntities=true;
        $dom->loadXml($xml, LIBXML_NOENT | LIBXML_NONET | LIBXML_NSCLEAN | LIBXML_NOCDATA | LIBXML_NOWARNING);
        return self::transformDoc($dom, $xslfile, $dst, $pars);
    }

    /**
     * An xslt transformer with cache
     * TOTHINK : deal with errors
     */
    static public function transformDoc($dom, $xslfile, $dst=null, $pars=null)
    {
        if (!is_a($dom, 'DOMDocument')) {
            throw new Exception('Source is not a DOM document, use transform() for a file, or transformXml() for an xml as a string.');
        }
        $key = realpath($xslfile);
        // cache compiled xsl
        if (!isset(self::$transcache[$key])) {
            $trans = new XSLTProcessor();
            $trans->registerPHPFunctions();
            // allow generation of <xsl:document>
            if (defined('XSL_SECPREFS_NONE')) {
                $prefs = constant('XSL_SECPREFS_NONE');
            } 
            else if (defined('XSL_SECPREF_NONE')) {
                $prefs = constant('XSL_SECPREF_NONE');
            }
            else {
                $prefs = 0;
            }

            if(method_exists($trans, 'setSecurityPrefs')) {
                $oldval = $trans->setSecurityPrefs($prefs);
            } /* historic
            else if (method_exists($trans, 'setSecurityPreferences')) {
                $oldval = $trans->setSecurityPreferences($prefs);
            } */
            else {
                ini_set("xsl.security_prefs",  $prefs);
            }
            $xsldom = new DOMDocument();
            $xsldom->load($xslfile);
            $trans->importStyleSheet($xsldom);
            self::$transcache[$key] = $trans;
        }
        $trans = self::$transcache[$key];
        // add params
        if(isset($pars) && count($pars)) {
            foreach ($pars as $key => $value) {
                $trans->setParameter(null, $key, $value);
            }
        }
        // return a DOM document for efficient piping
        if (is_a($dst, 'DOMDocument')) {
            $ret = $trans->transformToDoc($dom);
        }
        else if ($dst != '') {
            self::mkdir(dirname($dst));
            $trans->transformToURI($dom, $dst);
            $ret = $dst;
        }
        // no dst file, return String
        else {
            $ret =$trans->transformToXML($dom);
        }
        // reset parameters ! or they will kept on next transform if transformer is reused
        if(isset($pars) && count($pars)) {
            foreach ($pars as $key => $value) {
                $trans->removeParameter(null, $key);
            }
        }
        return $ret;
    }

    /**
     * A safe mkdir dealing with rights
     */
    static function mkdir($dir)
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
    static public function dirclean($dir, $depth=0)
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
    static function rmdir($dir, $keep = false) {
        $dir = rtrim($dir, "/\\").DIRECTORY_SEPARATOR;
        if (!is_dir($dir)) {
            return $dir; // maybe deleted
        }
        if (!($handle = opendir($dir))) {
            throw new Exception("Read impossible ".$file);
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

    /**
     * Custom error handler
     * Especially used for xsl:message coming from transform()
     * To avoid Apache time limit, php could output some bytes during long transformations
     */
    static function log(
        $errno, 
        $errstr=null, 
        $errfile=null, 
        $errline=null, 
        $errcontext=null
    ) {
        if (!self::$logger) {
            self::$logger = STDERR;
        }
        $errstr=preg_replace("/XSLTProcessor::transform[^:]*:/", "", $errstr, -1, $count);
        if ($count) { // is an XSLT error or an XSLT message, reformat here
            if(strpos($errstr, 'error')!== false) {
                return false;
            }
            else if ($errno == E_WARNING) {
                $errno = E_USER_WARNING;
            }
        }
        // a debug message in normal mode, do nothing
        if ($errno == E_USER_NOTICE && !self::$debug) {
            return true;
        }
        // ?? not a user message, let work default handler
        // else if ($errno != E_USER_ERROR && $errno != E_USER_WARNING ) return false;

        if (!$errstr && $errno) {
            $errstr = $errno;
        }
        if (is_resource(self::$logger)) {
            fwrite(self::$logger, $errstr."\n");
        }
        else if (is_string(self::$logger) && function_exists(self::$logger)) {
            call_user_func(self::$logger, $errstr);
        } 
    }


}
