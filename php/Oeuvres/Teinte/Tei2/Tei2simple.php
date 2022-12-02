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
abstract class Tei2simple extends AbstractTei2
{
    /** Path to the xslt file, relative to the xsl pack root */
    const XSL = null;

    // static abstract public function toUri(DOMDocument $dom, string $dstFile, ?array $pars = null): void;
    static public function toUri(DOMDocument $dom, string $dstFile, ?array $pars = null): void
    {
        Log::info("Tei2\033[92m" . static::NAME . "->toUri()\033[0m " . $dstFile);
        if ($pars === null) $pars = self::$pars;
        Xsl::transformToUri(
            self::$xsl_dir . static::XSL,
            $dom,
            $dstFile,
            $pars,
        );
    }

    static public function toXml(DOMDocument $dom, ?array $pars = null): string
    {
        if ($pars === null) $pars = self::$pars;
        return Xsl::transformToXml(
            self::$xsl_dir . static::XSL,
            $dom,
            $pars,
        );
    }

    static public function toDoc(DOMDocument $dom, ?array $pars = null): DOMDocument
    {
        if ($pars === null) $pars = self::$pars;
        return Xsl::transformToDoc(
            self::$xsl_dir . static::XSL,
            $dom,
            $pars,
        );
    }
}
Tei2simple::init();
