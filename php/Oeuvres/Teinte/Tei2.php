<?php
/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 */

declare(strict_types=1);

namespace Oeuvres\Teinte;

use DOMDocument, InvalidArgumentException;
use Psr\Log\LoggerInterface;
use Psr\Log\LoggerAwareInterface;
use Psr\Log\NullLogger;
use Oeuvres\Kit\File;

/**
 * A Teidoc exporter.
 */
abstract class Tei2 implements LoggerAwareInterface
{
    /** Where is the xsl pack, set in one place, do not repeat */
    static protected $xslDir;
    /** output extension */
    protected $ext;
    /** Should be the same as in the class name Tei2{NAME} */
    protected $name;
    /** A more human name for this exporter */
    protected $label;
    /** Some description */
    protected $desc;
    /** A mime type for serving */
    protected $mime;
    /** Somewhere to log in  */
    protected LoggerInterface $logger;

    public static function init()
    {
        // TO THINK, good way to configure with packages
        self::$xslDir = dirname(dirname(dirname(__DIR__))) . "/xsl/";
    }

    /**
     * Set logger
     */
    public function __construct(?LoggerInterface $logger = null)
    {
        if ($logger == null) $logger = new NullLogger();
        $this->setLogger($logger);
    }


    public function setLogger(LoggerInterface $logger)
    {
        $this->logger = $logger;
    }

    public function ext():string
    {
        return $this->ext;
    }

    public function name():string
    {
        return $this->name;
    }

    public function label():string
    {
        return $this->label;
    }

    public function desc():string
    {
        return $this->desc;
    }

    public function dstFile(string $srcFile, ?string $dstDir = null):string
    {
        if ($this->ext == null) {
            throw new InvalidArgumentException(static::class . "->ext undefined" );
        }
        if(!$dstDir) {
            $dstDir = dirname($srcFile) . DIRECTORY_SEPARATOR;
        }
        else {
            $dstDir = File::dirnorm($dstDir);
        }
        $dstName =  pathinfo($srcFile, PATHINFO_FILENAME);
        $dstFile = $dstDir . $dstName . $this->ext;
        return $dstFile;
    }

    /**
     * Write transformation as an Uri, which is mainly, a file
     */
    abstract public function toUri(DOMDocument $dom, string $dstFile);
    /**
     * Export transformation as an XML string
     * (maybe not relevant for aggregated formats: docx, epub, site…)
     */
    abstract public function toXml(DOMDocument $dom):?string;
    /**
     * Export transformation as a Dom
     * (maybe not relevant for aggregated formats: docx, epub, site…)
     */
    abstract public function toDoc(DOMDocument $dom):?DOMDocument;
}
Tei2::init();

// EOF