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

use DOMDocument;
use Psr\Log\LoggerInterface;
use Oeuvres\Kit\{Xml, File};

/**
 * A sinmple Teidoc exporter, with only one xslt
 */
abstract class AbstractTei2simple extends AbstractTei2
{
    /** Path to the xslt file, relative to the xsl pack root */
    const XSL = null;
    /** Build the transformer with a logger and check mandatory params */
    public function __construct(?LoggerInterface $logger = null)
    {
        parent::__construct(...func_get_args());
        assert(static::XSL != null, static::class . "::XSL must be defined from an XSL file to apply for this export format");
        assert(
            File::readable(
                self::$xslDir.static::XSL, 
                static::class . "::XSL file is required"
            ), 
            "::XSL, path resolved is not a readable file\n".self::$xslDir.static::XSL
        );
    }

    public function toUri(DOMDocument $dom, string $dstFile, ?array $pars=null)
    {
        $this->logger->info("Tei2\033[92m" . static::NAME . "->toUri()\033[0m " . $dstFile);
        return Xml::transformToUri(
            self::$xslDir.static::XSL,
            $dom,
            $dstFile,
            $pars,
        );
    }
    public function toXml(DOMDocument $dom, ?array $pars=null):string
    {
        return Xml::transformToXml(
            self::$xslDir.static::XSL,
            $dom,
            $pars,
        );

    }

    public function toDoc(DOMDocument $dom, ?array $pars=null):DOMDocument
    {
        return Xml::transformToDoc(
            self::$xslDir.static::XSL,
            $dom,
            $pars,
        );

    }

}