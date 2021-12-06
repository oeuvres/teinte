<?php
/**
 * code convention https://www.php-fig.org/psr/psr-12/
 *
 */

declare(strict_types=1);

namespace Oeuvres\Teinte;

use DOMDocument, Exception, XSLTProcessor;
use Psr\Log\LoggerInterface as LoggerInterface;

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
    private static $logger;

    public static function setLogger(LoggerInterface $logger) {
        self::$logger = $logger;
    }

    /**
     * Get a DOM document with best options from a file path
     */
    public static function dom(string $xmlFile): DOMDocument
    {
        $dom = self::domSkel();
        $dom->load($xmlFile, self::LIBXML_OPTIONS);
        return $dom;
    }

    /**
     * Get a DOM document with best options from an XML content
     */
    public static function domXml(string $xml): DOMDocument
    {
        $dom = self::domSkel();
        $dom->loadXML($xml, self::LIBXML_OPTIONS);
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
        string $xmlFile, 
        string $xslFile, 
        $dst = null, 
        array $pars = null
    ) {
        return self::transformDoc(self::dom($xmlFile), $xslFile, $dst, $pars);
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
        return self::transformDoc($dom, $xslfile, $dst, $pars);
    }

    /**
     * An xslt transformer with cache
     * TOTHINK : deal with errors
     */
    static public function transformDoc(
        object $dom, 
        string $xslfile, 
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

}
