<?php
/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * Copyright (c) 2022 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 */

declare(strict_types=1);

namespace Oeuvres\Teinte\Format;

use DOMDocument, Exception, ZipArchive;
use Oeuvres\Kit\{Filesys, Log, Misc, Xsl};


/**
 * A wrapper around docx document for export to semantic formats.
 * For now, mostly tested on:
 *  — Abbyy Finereader docx export
 */
class Docx extends Zip
{
    /** Where is the xsl pack, set in one place, do not repeat */
    static protected ?string $xsl_dir;
    /** A search replace program */
    static protected ?array $preg;
    /** A user searc replace program */
    static protected ?array $user_preg;
    /** An XML string to process */
    protected ?string $xml;

    /**
     * Inialize static variables
     */
    static function init()
    {
        self::$xsl_dir = dirname(__DIR__, 4) . '/xsl/';
        $pcre_tsv = self::$xsl_dir . 'docx/docx_pcre.tsv';
        self::$preg = Misc::pcre_tsv($pcre_tsv);
    }

    function xml(): string
    {
        return $this->xml;
    }

    /**
     * Get an XML concatenation of docx content
     */
    function docx_pkg(): void
    {
        if (null === $this->zip) $this->open();
        // concat XML files sxtracted, without XML prolog
        $this->xml = '<?xml version="1.0" encoding="UTF-8"?>
<pkg:package xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage">
';
        // list of entries 
        $entries = [
            // styles 
            'word/styles.xml' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml',
            // main content
            'word/document.xml' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml',
            // links target in main content
            'word/_rels/document.xml.rels' => 'application/vnd.openxmlformats-package.relationships+xml',
            // footnotes
            'word/footnotes.xml' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml',
            // links in footnotes
            'word/_rels/footnotes.xml.rels' => 'application/vnd.openxmlformats-package.relationships+xml',
            // endnotes
            'word/endnotes.xml' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.endnotes+xml',
            // link in endnotes
            'word/_rels/endnotes.xml.rels' => 'application/vnd.openxmlformats-package.relationships+xml',
        ];
        foreach($entries as $name => $type) {
            // check error here ?
            $content = $this->zip->getFromName($name);
            if ($content === false) {
                $m = "$name not found in docx " . $this->file;
                if ($name === 'word/document.xml') Log::error($m);
                else Log::debug($m);
                continue;
            }
            // strip xml prolog
            $offset = 0;
            if(preg_match(
                "/\s*<\?xml[^\?>]*\?>\s*/",
                $content, 
                $matches, 
                PREG_OFFSET_CAPTURE
            )) {
                $offset = $matches[0][1] + strlen($matches[0][0]);
            }
            $this->xml .= "
  <pkg:part pkg:contentType=\"$type\" pkg:name=\"/$name\">
    <pkg:xmlData>\n" . substr($content, $offset) . "\n    </pkg:xmlData>
  </pkg:part>
";
        }
        $this->xml .= "\n</pkg:package>\n";
    }

    /**
     * Build a lite TEI with some custom tags like <i> or <sc>, esier to clean
     * with regex
     */
    function docx_tei():void
    {
        $dom = Xsl::loadXml($this->xml);
        // xsl, DO NOT indent 
        $this->xml = Xsl::transformToXml(self::$xsl_dir . 'docx/docx_tei.xsl', $dom);
    }

    /**
     * Clean XML with pcre regex
     */
    function tei_pcre(): void
    {
        // clean xml oddities
        $this->xml = preg_replace(self::$preg[0], self::$preg[1], $this->xml);
        // custom patterns
        if (isset(self::$user_preg)) {
            $this->xml = preg_replace(self::$user_preg[0], self::$user_preg[1], $this->xml);
        }
    }


    /**
     * Set a template directory
     * usually the same for a collection of docs.
     */
    function template(?string $dir = null)
    {
        $dir = Filesys::normdir($dir);
        if (!$dir) return;
        // try to load custom regex
        $pcre_tsv = $dir . basename($dir) . "_pcre.tsv";
        // be nice take first file in folder
        if (!is_file($pcre_tsv)) {
            $glob = glob($dir . "*_pcre.tsv");
            if (!$glob || count($glob) < 1) {
                $pcre_tsv = null;
            }
            else {
                $pcre_tsv = $glob[0];
            }
        }
        if ($pcre_tsv) {
            Log::info("Docx => TEI, user pattern loading: $pcre_tsv");
            self::$user_preg = Misc::pcre_tsv($pcre_tsv);
        }
    }



}

Docx::init();
