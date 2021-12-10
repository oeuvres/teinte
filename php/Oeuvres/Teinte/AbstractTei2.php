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
abstract class AbstractTei2 implements LoggerAwareInterface
{
    /** Where is the xsl pack, set in one place, do not repeat */
    static protected $xslDir;
    /** Do init at startup */
    static private $init; 
    /** Should be the same as in the class name Tei2{NAME} */
    const NAME = null;
    /** Prefered extension for exported files */
    const EXT = null;
    /** A more human name for this exporter */
    const LABEL = null;
    /** Some description */
    const DESC = null;
    /** A mime type for serving */
    const MIME = null;
    /** Somewhere to log in  */
    protected LoggerInterface $logger;

    public static function init()
    {
        if (self::$init) return;
        self::$init = true;
        // TO THINK, good way to configure xsl pack
        self::$xslDir = dirname(dirname(dirname(__DIR__))) . "/xsl/";
    }

    /**
     * Set logger
     */
    public function __construct(?LoggerInterface $logger = null)
    {
        // check the required constant for newly instantiate format
        assert(static::NAME != null, static::class . "::NAME must be defined");
        assert( static::EXT != null, static::class . "::EXT must be defined as prefered file extension for this format");
        if ($logger == null) $logger = new NullLogger();
        $this->setLogger($logger);
    }


    public function setLogger(LoggerInterface $logger)
    {
        $this->logger = $logger;
    }

    /**
     * Build a prefered file path from source path,
     * according to the preferred extension format,
     * and a destination directory if provided.
     */
    public static function dstFile(
        string $srcFile, 
        ?string $dstDir = null
    ):string {
        if(!$dstDir) {
            $dstDir = dirname($srcFile) . DIRECTORY_SEPARATOR;
        }
        else {
            $dstDir = File::dirnorm($dstDir);
        }
        $dstName =  pathinfo($srcFile, PATHINFO_FILENAME);
        $dstFile = $dstDir . $dstName . static::EXT;
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
AbstractTei2::init();

// EOF