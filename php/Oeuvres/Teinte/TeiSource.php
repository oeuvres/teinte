<?php
/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 */

declare(strict_types=1);

namespace Oeuvres\Teinte;

use Exception, DOMDocument, DOMXpath;
use Psr\Log\{LoggerInterface, LoggerAwareInterface, NullLogger};
use Oeuvres\Kit\Xml;
use Oeuvres\Teinte\{TeiExportFactory};

/**
 * Tei exports are designed as a Strategy pattern
 * {@see \Oeuvres\Teinte\AbstractTei2}
 * This class is the Context to use the different strategies.
 * All initialisations are as lazy as possible
 * to scan fast big directories.
 */
class TeiSource implements LoggerAwareInterface
{
    /** Somewhere to log in  */
    private LoggerInterface $logger;
    /** TEI/XML DOM Document to process */
    private $dom;
    /** Xpath processor for the doc */
    private $xpath;
    /** filepath */
    private $file;
    /** filename without extension */
    private $filename;
    /** file freshness */
    private $filemtime;
    /** file size */
    private $filesize;
    /**
     * Start with an empty object
     */
    public function __construct(LoggerInterface $logger = null)
    {
        if ($logger == null) $logger = new NullLogger();
        $this->setLogger($logger);
    }

    public function setLogger(LoggerInterface $logger)
    {
        $this->logger = $logger;
        Xml::setLogger($this->logger);
    }

    /**
     * Transform current dom and write to file.
     */
    public function toUri(string $format, String $uri)
    {
        $transfo = TeiExportFactory::get($format, $this->logger);
        $transfo->toUri($this->dom, $uri);
    }

    /**
     * Transform current dom and returns XML
     * (when relevant)
     */
    public function toXml(string $format): string
    {
        $transfo = TeiExportFactory::get($format, $this->logger);
        return $transfo->toXml($this->dom);
    }

    /**
     * Transform current and returns result as dom
     * (when relevant)
     */
    public function toDoc(string $format): DOMDocument
    {
        $transfo = TeiExportFactory::get($format, $this->logger);
        return $transfo->toDoc($this->dom);
    }

    /**
     * Build a destination file path according to a preferred format
     * extnsion. Nothing is supposed to be loaded, such path is used
     * for testing.
     */
    function dstFile(string $srcFile, string $format, ?string $dstDir):string
    {
        $transfo = TeiExportFactory::get($format, $this->logger);
        return $transfo->dstFile($srcFile, $dstDir);
    }

    public function isEmpty()
    {
        return !$this->dom;
    }

    /**
     * Load XML/TEI as a file (preferred way).
     */
    public function load(string $teiFile): DOMDocument
    {
        $this->file = $teiFile;
        $this->filename = pathinfo($teiFile, PATHINFO_FILENAME);
        $this->filemtime = filemtime($teiFile);
        $this->filesize = filesize($teiFile); // ?? if URL ?
        return $this->loadXml(file_get_contents($teiFile));
    }

    /**
     * Load XML/TEI as string, normalize and load it as DOM
     */
    public function loadXml(string $xml):DOMDocument
    {
        // should we keep here original XML to replay chain ?
        $xml = self::normTei($xml);
        $this->dom = Xml::loadXml($xml);
        // spaces are normalized upper, keep them
        $this->dom->preserveWhiteSpace = true;
        return $this->dom;
    }

    /**
     * Load a TEI string, and normalize things, especially 
     * spaces, for docx (bad indent produce bad spacing)
     */
    public static function normTei(string $srcXml):string
    {
        $block = "(ab|bibl|byline|dateline|desc|head|l|label|lb|p|signed|salute)";
        $re_norm = array(
            '@\r\n?@' => "\n", // normalize EOL
            '@[ \t]*\n[ \t]*@' => "\n", // suppress trailing spaces
            "@\n([,.)\]}])@u" => "$1", // bad indent may have broke some pun
            "@(<$block(>| [^>]*>))\s+@" => "$1", // spaces at start of para
            "@\s+(</$block>)@" => '$1', // space before end of para
            /* Something have to be done with <pb/>
            '@(<(ab|head|l|p|stage)( [^>]*)?>)\s*(<pb( [^>]*)?/>)\s+@' => '$1$4',
            */
        );
        $xml = preg_replace(
            array_keys($re_norm),
            array_values($re_norm),
            $srcXml
        );
        /* libxml indent is quite nice, 
        but may produce undesired line break for some inlines containing inlines
        */
        return $xml;
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
     * For a readonly property
     */
    public function file()
    {
        return $this->file;
    }
    /**
     * Get the filename (with no extention)
     */
    public function filename()
    {
        return $this->filename;
    }
    /**
     * Read a readonly property
     */
    public function filemtime()
    {
        return $this->filemtime;
    }
    /**
     * For a readonly property
     */
    public function filesize()
    {
        return $this->filesize;
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
     * Output a txt fragment with no html tags for full-text searching
     */
    /*
    public function ft($destfile = null)
    {
        $html = $this->article();
        $html = self::detag($html);
        if ($destfile) file_put_contents($destfile, $html);
        return $html;
    }
    */

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
            $this->img($el->getAttributeNode("url"), str_pad(strval($count), $pad, '0', STR_PAD_LEFT), $hrefdir, $dstdir);
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
        if (!isset($att) || !$att || !$att->value) {
            return;
        }
        $src = $att->value;
        // do not modify data image
        if (strpos($src, 'data:image') === 0) {
            return;
        }
        // test if coming fron the internet
        if (substr($src, 0, 4) == 'http');
        // test if relative file path
        else if (file_exists($test = dirname($this->file) . '/' . $src)) {
            $src = $test;
        }
        /*
        // vendor specific etc/filename.jpg
        else if (isset(self::$pars['srcdir']) 
            && file_exists($test = self::$pars['srcdir'] . self::$pars['filename'] . '/' . substr($src, strpos($src, '/') + 1))
        ) $src = $test;
        */
        // if not file exists, escape and alert (?)
        else if (!file_exists($src)) {
            $this->logger->warning("Image not found: " . $src);
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


}

// EOF