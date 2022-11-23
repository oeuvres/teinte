<?php
/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 */

declare(strict_types=1);

namespace Oeuvres\Teinte\Tei2;

use DOMDocument;
use Oeuvres\Kit\{Filesys, Log, Xsl};

/**
 * A sinmple Teidoc exporter, with only one xslt
 */
abstract class Tei2simple extends Tei2
{
    /** Path to the xslt file, relative to the xsl pack root */
    const XSL = null;
    /** Build the transformer with a logger and check mandatory params */
    public function __construct()
    {
        parent::__construct(...func_get_args());
        assert(static::XSL != null, static::class . "::XSL must be defined from an XSL file to apply for this export format");
        assert(
            Filesys::readable(
                self::$xsl_dir.static::XSL, 
                static::class . "::XSL file is required"
            ), 
            "::XSL, path resolved is not a readable file\n".self::$xsl_dir.static::XSL
        );
    }

    public function toUri(DOMDocument $dom, string $dstFile, ?array $pars=null)
    {
        Log::info("Tei2\033[92m" . static::NAME . "->toUri()\033[0m " . $dstFile);
        return Xsl::transformToUri(
            self::$xsl_dir.static::XSL,
            $dom,
            $dstFile,
            $pars,
        );
    }
    public function toXml(DOMDocument $dom, ?array $pars=null):string
    {
        return Xsl::transformToXml(
            self::$xsl_dir.static::XSL,
            $dom,
            $pars,
        );

    }

    public function toDoc(DOMDocument $dom, ?array $pars=null):DOMDocument
    {
        return Xsl::transformToDoc(
            self::$xsl_dir.static::XSL,
            $dom,
            $pars,
        );

    }

}