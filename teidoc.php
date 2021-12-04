<?php
set_time_limit(-1);
// included file, do nothing
if (isset($_SERVER['SCRIPT_FILENAME']) && basename($_SERVER['SCRIPT_FILENAME']) != basename(__FILE__));
else if (isset($_SERVER['ORIG_SCRIPT_FILENAME']) && realpath($_SERVER['ORIG_SCRIPT_FILENAME']) != realpath(__FILE__));
// direct command line call, work
else if (php_sapi_name() == "cli") Teidoc::cli();


/**
 * Sample pilot for Teinte transformations of XML/TEI
 */
class Teidoc
{
    /** TEI/XML DOM Document to process */
    private $dom;
    /** Xpath processor */
    private $xpath;
    /** filepath */
    private $file;
    /** filename without extension */
    private $filename;
    /** file freshness */
    private $filemtime;
    /** file size */
    private $filesize;
    /** XSLTProcessors */
    private static $trans = array();
    /** A file where  */
    private $logger;
    /** formats */
    public static $ext = array(
        'article' => '_art.html',
        'detag' => '.txt',
        'html' => '.html',
        'iramuteq' => '.txt',
        'markdown' => '.txt',
        'naked' => '.txt',
        'toc' => '_toc.html',
    );
    /**
     * Constructor, load file and prepare work
     */
    public function __construct($tei, $logger = null)
    {
        if (is_a($tei, 'DOMDocument')) {
            $this->dom = $tei;
        } else if (is_string($tei)) { // maybe file or url
            $this->file = $tei;
            $this->filemtime = filemtime($tei);
            $this->filesize = filesize($tei); // ?? URL ?
            $this->filename = pathinfo($tei, PATHINFO_FILENAME);
            // loading error, do something ?
            if (!$this->load($tei)) throw new Exception("BAD XML: " . $tei . "\n");
        } else {
            throw new Exception('Teinte, what is it? ' . print_r($tei, true));
        }
        $this->logger = $logger;
        $this->xpath();
    }

    public function isEmpty()
    {
        return !$this->dom;
    }

    /**
     * Set and return an XPath processor
     */
    public function xpath()
    {
        if ($this->xpath) return $this->xpath;
        $this->xpath = new DOMXpath($this->dom);
        $this->xpath->registerNamespace('tei', "http://www.tei-c.org/ns/1.0");
        return $this->xpath;
    }
    /**
     * Get the filename (with no extention)
     */
    public function filename($filename = null)
    {
        if ($filename) $this->filename = $filename;
        return $this->filename;
    }
    /**
     * Read a readonly property
     */
    public function filemtime($filemtime = null)
    {
        if ($filemtime) $this->filemtime = $filemtime;
        return $this->filemtime;
    }
    /**
     * For a readonly property
     */
    public function filesize($filesize = null)
    {
        if ($filesize) $this->filesize = $filesize;
        return $this->filesize;
    }
    /**
     * For a readonly property
     */
    public function file()
    {
        return $this->file;
    }
    /**
     * Book metadata
     */
    public function meta()
    {
        $meta = self::metaDom(null, $this->xpath);
        $meta['code'] = pathinfo($this->file, PATHINFO_FILENAME);
        $meta['filename'] = $this->filename();
        $meta['filemtime'] = $this->filemtime();
        $meta['filesize'] = $this->filesize();
        return $meta;
    }

    /**
     * Return an array of metadata from a dom document
     */
    public static function metaDom($dom, $xpath = null)
    {
        if ($xpath == null) $xpath = new DOMXpath($dom);
        $xpath->registerNamespace('tei', "http://www.tei-c.org/ns/1.0");

        $meta = array();
        $nl = $xpath->query("/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author");
        $meta['author'] = array();
        $meta['byline'] = null;
        $first = true;
        foreach ($nl as $node) {
            $value = $node->getAttribute("key");
            $text = preg_replace('@\s+@', ' ', trim($node->textContent));
            if (!$value) $value = $text;
            if (($pos = strpos($value, '('))) $value = trim(substr($value, 0, $pos));
            $meta['author'][] = $value;
            if ($first) {
                $meta['author1'] = $value;
                $first = false;
            } else $meta['byline'] .= " ; ";
            // prefer text value to att value
            if ($text) $meta['byline'] .= $text;
            else $meta['byline'] .= $value;
        }
        // editors
        $meta['editby'] = null;
        $nl = $xpath->query("/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor");
        $first = true;
        foreach ($nl as $node) {
            $value = $node->getAttribute("key");
            if (!$value) $value = $node->textContent;
            if (($pos = strpos($value, '('))) $value = trim(substr($value, 0, $pos));
            if ($first) $first = false;
            else $meta['editby'] .= " ; ";
            $meta['editby'] .= $value;
        }
        // title
        $nl = $xpath->query("/*/tei:teiHeader//tei:title");
        if ($nl->length) $meta['title'] = $nl->item(0)->textContent;
        else $meta['title'] = null;
        // publisher
        $nl = $xpath->query("/*/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:publisher");
        if ($nl->length) $meta['publisher'] = $nl->item(0)->textContent;
        else $meta['publisher'] = null;
        // identifier
        $nl = $xpath->query("/*/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno");
        if ($nl->length) $meta['identifier'] = $nl->item(0)->textContent;
        else $meta['identifier'] = null;
        // dates
        $nl = $xpath->query("/*/tei:teiHeader/tei:profileDesc/tei:creation/tei:date");
        // loop on dates
        $meta['created'] = null;
        $meta['issued'] = null;
        $meta['date'] = null;
        foreach ($nl as $date) {
            $value = $date->getAttribute('when');
            if (!$value) $value = $date->getAttribute('to');
            if (!$value) $value = $date->getAttribute('notAfter');
            if (!$value) $value = $date->nodeValue;
            $value = substr(trim($value), 0, 4);
            if (!is_numeric($value)) {
                $value = null;
                continue;
            }
            if (!$meta['date']) $meta['date'] = $value;
            if ($date->getAttribute('type') == "created" && !$meta['created']) $meta['created'] = $value;
            else if ($date->getAttribute('type') == "issued" && !$meta['issued']) $meta['issued'] = $value;
        }
        if (!$meta['issued'] && isset($value) && is_numeric($value)) $meta['issued'] = $value;
        $meta['source'] = null;


        return $meta;
    }
    /**
     *
     */
    public function export($format, $destfile = null)
    {
        if (isset(self::$ext[$format])) return call_user_func(array($this, $format), $destfile);
        else if (STDERR) fwrite(STDERR, $format . " ? format not yet implemented\n");
    }
    /**
     * Output toc
     */
    public function toc($destfile = null, $root = "ol")
    {
        return $this->transform(
            dirname(__FILE__) . '/xsl/tei2toc.xsl',
            $destfile,
            array(
                'root' => $root,
            )
        );
    }

    /**
     * Output an html fragment
     */
    public function article($destfile = null)
    {
        return $this->transform(
            dirname(__FILE__) . '/tei2html.xsl',
            $destfile,
            array(
                'root' => 'article',
                'folder' => basename(dirname($this->file)),
            )
        );
    }

    /**
     * Output a txt fragment with no html tags for full-text searching
     */
    public function ft($destfile = null)
    {
        $html = $this->article();
        $html = self::detag($html);
        if ($destfile) file_put_contents($destfile, $html);
        return $html;
    }

    /**
     * Output html
     */
    public function html($destfile = null, $theme = null)
    {
        if (!$theme) $theme = 'http://oeuvres.github.io/teinte/'; // where to find web assets like css and jslog for html file
        return $this->transform(
            dirname(__FILE__) . '/tei2html.xsl',
            $destfile,
            array(
                'theme' => $theme,
                'folder' => basename(dirname($this->file)),
            )
        );
    }
    /**
     * Output markdown
     */
    public function markdown($destfile = null)
    {
        return $this->transform(dirname(__FILE__) . '/xsl/tei2md.xsl', $destfile, array('filename' => $this->filename));
    }
    /**
     * Output iramuteq text
     */
    public function iramuteq($destfile = null)
    {
        return $this->transform(dirname(__FILE__) . '/xsl/tei2iramuteq.xsl', $destfile, array('filename' => $this->filename));
    }
    /**
     * Output txm XML
     */
    public function txm($destfile = null)
    {
        return $this->transform(dirname(__FILE__) . '/xsl/tei4txm.xsl', $destfile, array('filename' => $this->filename));
    }
    /**
     * Output naked text
     */
    public function naked($destfile = null)
    {
        $txt = $this->transform(dirname(__FILE__) . '/xsl/tei2naked.xsl', null, array('filename' => $this->filename));
        /* TRÈS MAUVAISE IDÉE
    $txt = preg_replace(
      array(
        "@([\s\(\[])(c|C|d|D|j|J|usqu|Jusqu|l|L|lorsqu|m|M|n|N|puisqu|Puisqu|qu|Qu|quoiqu|Quoiqu|s|S|t|T)['’]@u",
     ),
      array(
        '$1$2e '
     ),
      $txt
   );
    */
        if (!$destfile) return $txt;
        file_put_contents($destfile, $txt);
        return $destfile;
    }
    /**
     * Output a split version of book
     */
    public function site($dstdir = null)
    {
        // create dest folder
        // if none given, use filename
        // collect images pointed by xml file and copy them in the folder
    }
    /**
     * Extract <graphic> elements from a DOM doc, copy linked images in a flat dstdir
     * copy linked images in an images folder $dstdir, and modify relative link
     *
     * $hrefdir : a href prefix to redirest generated links
     * $dstdir : a folder if images should be copied
     * return : a doc with updated links to image
     */
    public function images($hrefdir = null, $dstdir = null)
    {
        if ($dstdir) $dstdir = rtrim($dstdir, '/\\') . '/';
        // $dom = $this->dom->cloneNode(true); // do not clone, keep the change of links
        $dom = $this->dom;
        $count = 1;
        $nl = $dom->getElementsByTagNameNS('http://www.tei-c.org/ns/1.0', 'graphic');
        $pad = strlen('' . $nl->count());
        foreach ($nl as $el) {
            $this->img($el->getAttributeNode("url"), str_pad($count, $pad, '0', STR_PAD_LEFT), $hrefdir, $dstdir);
            $count++;
        }
        /*
    do not store images of pages, especially in tif
    foreach ($doc->getElementsByTagNameNS('http://www.tei-c.org/ns/1.0', 'pb') as $el) {
      $this->img($el->getAttributeNode("facs"), $hrefTei, $dstdir, $hrefSqlite);
    }
    */
        return $dom;
    }
    /**
     * Process one image
     */
    public function img($att, $count, $hrefdir = "", $dstdir = null)
    {
        if (!isset($att) || !$att || !$att->value) return;
        $src = $att->value;
        // do not modify data image
        if (strpos($src, 'data:image') === 0) return;

        // test if coming fron the internet
        if (substr($src, 0, 4) == 'http');
        // test if relative file path
        else if (file_exists($test = dirname($this->file) . '/' . $src)) $src = $test;
        // vendor specific etc/filename.jpg
        else if (isset(self::$pars['srcdir']) && file_exists($test = self::$pars['srcdir'] . self::$pars['filename'] . '/' . substr($src, strpos($src, '/') + 1))) $src = $test;
        // if not file exists, escape and alert (?)
        else if (!file_exists($src)) {
            $this->log("Image not found: " . $src);
            return;
        }
        $srcparts = pathinfo($src);
        // check if image name starts by filename, if not, force it
        if (substr($srcparts['filename'], 0, strlen($this->filename)) !== $this->filename) $srcparts['filename'] = $this->filename . '_' . $count;

        // test first if dst dir provides for copy
        if (isset($dstdir)) {
            if (!file_exists($dstdir)) {
                mkdir($dstdir, 0775, true);
                @chmod($dstdir, 0775);
            }
            $dst = $dstdir . $srcparts['filename'] . '.' . $srcparts['extension'];
            if (!copy($src, $dst)) return false; // bad copy
        }
        // changes links in TEI so that straight transform will point on the right files
        $att->value = $hrefdir . $srcparts['filename'] . '.' . $srcparts['extension'];
        // resize image before copy ?
        // NO delete of <graphic> element if broken link
    }

    /**
     * Preprocess TEI with a transformation
     */
    public function pre($xslfile, $pars = null)
    {
        $this->dom = $this->transform($xslfile, new DOMDocument(), $pars);
    }

    /**
     * Replace tags of html file by spaces, to get text with same offset index of words
     * allowing indexation and highlighting. Keep line breaks for line numbers.
     * Support of some html5 tag to strip not indexable content.
     * 2x faster than a char loop
     */
    static public function detag($html)
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
    static public function blank($string)
    {
        if (is_array($string)) $string = $string[0];
        // if (strpos($string, '<tt class="num')===0) return "_NUM_".str_repeat(" ", strlen($string) - 5);
        return preg_replace("/[^\n]/", " ", $string);
    }

    /**
     * An xslt transformer
     * TOTHINK : deal with errors
     */
    public function transform($xslfile, $dest = null, $pars = null)
    {
        $key = realpath($xslfile);
        // cache compiled xsl
        if (!isset(self::$trans[$key])) {
            // renew the processor
            self::$trans[$key] = new XSLTProcessor();
            $trans = self::$trans[$key];
            $trans->registerPHPFunctions();
            // allow generation of <xsl:document>
            if (defined('XSL_SECPREFS_NONE')) $prefs = XSL_SECPREFS_NONE;
            else if (defined('XSL_SECPREF_NONE')) $prefs = XSL_SECPREF_NONE;
            else $prefs = 0;
            if (method_exists($trans, 'setSecurityPreferences')) $oldval = $trans->setSecurityPreferences($prefs);
            else if (method_exists($trans, 'setSecurityPrefs')) $oldval = $trans->setSecurityPrefs($prefs);
            else ini_set("xsl.security_prefs",  $prefs);
            $dom = new DOMDocument();
            $dom->load($xslfile);
            $trans->importStyleSheet($dom);
        }
        $trans = self::$trans[$key];
        // add params
        if (isset($pars) && count($pars)) {
            foreach ($pars as $key => $value) {
                $trans->setParameter(null, $key, $value);
            }
        }
        // return a DOM document for efficient piping
        if (is_a($dest, 'DOMDocument')) {
            $ret = $trans->transformToDoc($this->dom);
        } else if ($dest) {
            if (!is_dir(dirname($dest))) {
                if (!@mkdir(dirname($dest), 0775, true)) exit(dirname($dest) . " impossible à créer.\n");
                @chmod(dirname($dest), 0775);  // let @, if www-data is not owner but allowed to write
            }
            $trans->transformToURI($this->dom, $dest);
            $ret = $dest;
        }
        // no dst file, return String
        else {
            $ret = $trans->transformToXML($this->dom);
        }
        // reset parameters ! or they will kept on next transform if transformer is reused
        if (isset($pars) && count($pars)) {
            foreach ($pars as $key => $value) $trans->removeParameter(null, $key);
        }
        return $ret;
    }
    /**
     * Set and build a dom privately
     */
    private function load($xmlfile)
    {
        $this->dom = new DOMDocument();
        $this->dom->preserveWhiteSpace = false;
        $this->dom->formatOutput = true;
        $this->dom->substituteEntities = true;
        $ret = $this->dom->load($xmlfile, LIBXML_NOENT | LIBXML_NONET | LIBXML_NSCLEAN | LIBXML_NOCDATA | LIBXML_NOWARNING);
        return $ret;
    }
    /**
     * Get the dom
     */
    public function dom()
    {
        return $this->dom;
    }

    /**
     *
     */
    public function log($errstr)
    {
        if (is_resource($this->logger)) fwrite($this->logger, htmlspecialchars($errstr) . "\n");
    }

    /**
     * Command line transform
     */
    public static function cli()
    {
        $formats = implode('|', array_keys(self::$ext));
        array_shift($_SERVER['argv']); // shift first arg, the script filepath
        if (!count($_SERVER['argv'])) exit('
    usage     : php -f Doc.php force? (' . $formats . ')? dstdir/? "*.xml"
    format?   : optional dest format, default is html
    dstdir/? : optional dstdir
    *.xml     : glob patterns are allowed, with or without quotes, win or nix

');

        $force = false;
        if (trim($_SERVER['argv'][0], '- ') == "force") {
            array_shift($_SERVER['argv']);
            $force = true;
        }


        $format = "html";
        if (preg_match("/^($formats)\$/", trim($_SERVER['argv'][0], '- '))) {
            $format = array_shift($_SERVER['argv']);
            $format = trim($format, '- ');
        }

        $dstdir = ""; // default is transform here
        $lastc = substr($_SERVER['argv'][0], -1);
        if ('/' == $lastc || '\\' == $lastc) {
            $dstdir = array_shift($_SERVER['argv']);
            $dstdir = rtrim($dstdir, '/\\') . '/';
            if (!file_exists($dstdir)) {
                mkdir($dstdir, 0775, true);
                @chmod($dstdir, 0775);  // let @, if www-data is not owner but allowed to write
            }
        }


        $count = 1;
        echo "code\tbyline\tdate\ttitle\n";
        foreach ($_SERVER['argv'] as $glob) {
            foreach (glob($glob) as $srcfile) {
                $destname = pathinfo($srcfile, PATHINFO_FILENAME) . self::$ext[$format];
                if (isset($dstdir)) $destfile = $dstdir . $destname;
                else $destfile = dirname($srcfile) . '/' . $destname;
                if ($force); // force overwrite
                else if (file_exists($destfile) && filemtime($srcfile) < filemtime($destfile)) continue;
                if (STDERR) fwrite(STDERR, "$count. $srcfile > $destfile\n");
                $count++;
                try {
                    $doc = new Teidoc($srcfile);
                    $meta = $doc->meta();
                    $doc->export($format, $destfile);
                    echo $meta['code'] . "\t" . $meta['byline'] . "\t" . $meta['date'] . "\t" . $meta['title'] . "\n";
                } catch (Exception $e) {
                    if (STDERR) fwrite(STDERR, $e);
                }
            }
        }
    }
}
