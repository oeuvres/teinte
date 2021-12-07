<?php
/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 */

declare(strict_types=1);

namespace Oeuvres\Kit;

use Exception, DOMDocument, XSLTProcessor;
use Psr\Log\LoggerInterface;

/**
 * A set of well configured method for XML manipulation
 * with memory of some odd tricks.
 * code convention https://www.php-fig.org/psr/psr-12/
 */
class Xml
{
    /** XSLTProcessors */
    private static $transcache = array();
    /** get a temp dir */
    private static $tmpdir;
    /** libxml options for DOMDocument */
    const LIBXML_OPTIONS = 
          LIBXML_NOENT 
        | LIBXML_NONET 
        | LIBXML_NSCLEAN 
        | LIBXML_NOCDATA 
        | LIBXML_NOWARNING  // no warn for <?xml-model
    ;
    private static LoggerInterface $logger;

    public static function setLogger(LoggerInterface $logger) {
        self::$logger = $logger;
    }

    /**
     * Get a DOM document with best options from a file path
     */
    public static function dom(string $srcFile): DOMDocument
    {
        $dom = self::domSkel();
        // $dom->recover=true; // no recover, display errors
        if (!$dom->load($srcFile, self::LIBXML_OPTIONS)) {
            // display error here ?
            self::$logger->error("XML error " . $srcFile);
            return null;
        }
        $dom->documentURI = realpath($srcFile);

        return $dom;
    }

    /**
     * Get a DOM document with best options from an XML content
     */
    public static function domXml(string $xml, ?string $srcFile=""): DOMDocument
    {
        $dom = self::domSkel();
        if (!$dom->loadXML($xml, self::LIBXML_OPTIONS)) {
            // get error here ?
            self::$logger->error("XML error " . $srcFile);
            return null;
        }
        if ($srcFile) {
            $dom->documentURI = realpath($srcFile);
        }
        return $dom;
    }

    /**
     * Return an empty dom with options
     */
    private static function domSkel(): DOMDocument
    {
        $dom = new DOMDocument();
        $dom->preserveWhiteSpace = false;
        $dom->formatOutput = true;
        $dom->substituteEntities = true;
        return $dom;
    }
    /**
     * Xsl transform from xml file
     */
    static function transform(
        string $xslFile, 
        string $xmlFile, 
        $dst = null, 
        array $pars = null
    ) {
        return self::transformDoc($xslFile, self::dom($xmlFile), $dst, $pars);
    }

    static public function transformXml(
        string $xml, 
        string $xslfile, 
        $dst=null, 
        array $pars=null
    ) {
        $dom = new DOMDocument();
        $dom->preserveWhiteSpace = false;
        $dom->formatOutput=true;
        $dom->substituteEntities=true;
        $dom->loadXml($xml, LIBXML_NOENT | LIBXML_NONET | LIBXML_NSCLEAN | LIBXML_NOCDATA | LIBXML_NOWARNING);
        return self::transformDoc($xslfile, $dom, $dst, $pars);
    }

    /**
     * An xslt transformer with cache
     * TOTHINK : deal with errors
     */
    static public function transformDoc(
        string $xslfile, 
        object $dom, 
        $dst = null, 
        array $pars = null
    ) {
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
                $trans->setParameter("", $key, $value);
            }
        }
        // return a DOM document for efficient piping
        if (is_a($dst, 'DOMDocument')) {
            $ret = $trans->transformToDoc($dom);
        }
        else if ($dst != '') {
            File::mkdir(dirname($dst));
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
                $trans->removeParameter("", $key);
            }
        }
        return $ret;
    }
    /**
     * Replace tags of html file by spaces,
     * to get text with same offset index of words
     * allowing indexation and highlighting. Keep line breaks for line numbers.
     * Support of some html5 tag to strip not indexable content.
     * 2x faster than a char loop
     */
    static public function detag(string $html):string
    {
        // preg_replace_callback is safer and 2x faster than the /e modifier
        $html = preg_replace_callback(
            array(
                // s flag so that '.' could match \n
                // .*? ungreedy
                '@<!.*?>@s', // exclude doctype and comments
                '@<\?.*?\?>@s', // exclude PI
                '@<(head|header|footer|nav|noindex)[ >].*?</\1>@s', // suppress nav, let <aside> for notes
                '@<(small|tt|a)[^>]*>[0-9]+</\1>@', // line or note of number
                '@<a class="noteref".*?</a>@', // suppress footnote call
                '@<[^>]+>@' // wash tags
            ),
            array(__CLASS__, 'blank'),
            $html
        );
        return $html;
    }
    /**
     * blanking a string, keeping new lines
     */
    private static function blank(string $string):string
    {
        if (is_array($string)) $string = $string[0];
        // if (strpos($string, '<tt class="num')===0) return "_NUM_".str_repeat(" ", strlen($string) - 5);
        return preg_replace("/[^\n]/", " ", $string);
    }

}
