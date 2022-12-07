<?php declare(strict_types=1);
/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 */

namespace Oeuvres\Teinte\Format;

use Exception, DOMDocument, DOMXpath;
use Psr\Log\{LoggerInterface, LoggerAwareInterface, NullLogger};
use Oeuvres\Kit\{Xsl};
use Oeuvres\Teinte\Tei2\{TeiExportFactory};

/**
 * Tei exports are designed as a Strategy pattern
 * {@see \Oeuvres\Teinte\AbstractTei2}
 * This class is the Context to use the different strategies.
 * All initialisations are as lazy as possible
 * to scan fast big directories.
 */
class Xml extends File
{
    /** Store XML as a string, maybe reused */
    protected ?string $xml = null;
    /** DOM Document to process */
    protected $dom;
    /** Xpath processor for the doc */
    protected $xpath;

    /**
     * Is there a dom loaded ?
     */
    public function isEmpty()
    {
        return ($this->dom === null);
    }

    /**
     * Load XML/TEI as a file (preferred way to hav some metas).
     */
    public function load(string $src_file): DOMDocument
    {
        parent::{__FUNCTION__}(...func_get_args());
        $this->xpath = null;
        $dom = $this->loadXml(file_get_contents($src_file));
        return $dom;
    }

    /**
     * Load XML/TEI as string, normalize and load it as DOM
     */
    public function loadXml(string $xml):DOMDocument
    {
        $xml = static::lint($xml);
        $this->xml = $xml;
        $this->dom = Xsl::loadXml($this->xml);
        if (!$this->dom) {
            throw new Exception("XML malformation");
        }
        // spaces are normalized upper, keep them
        $this->dom->preserveWhiteSpace = true;
        return $this->dom;
    }

    /**
     * Some formats may override
     */
    static public function lint(string $xml):string
    {
        return $xml;
    }

    /**
     * Set and return an XPath processor
     */
    public function xpath()
    {
        if ($this->xpath) return $this->xpath;
        $this->xpath = Xsl::xpath($this->dom);
        return $this->xpath;
    }

    /**
     * Return xml as loaded
     */
    public function xml(): string
    {
        return $this->xml;
    }
}
// EOF
