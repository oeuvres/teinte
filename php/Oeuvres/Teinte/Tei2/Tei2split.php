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
 * Export a TEI document as an html fragment <article>
 */

class Tei2split extends AbstractTei2
{
    const NAME = 'split';
    const EXT = '_xml/';
    const LABEL = 'split chapters in <tei:div>';
    const XSL = "tei_split.xsl";

    /**
     * @ override
     */
    static public function toUri(DOMDocument $dom, string $dstFile, ?array $pars=array())
    {
        if (!$pars) $pars = array();
        $dst_dir = Filesys::cleandir($dstFile) . "/";
        if (DIRECTORY_SEPARATOR == "\\") {
            $dst_dir = "file:///" . str_replace('\\', '/', $dst_dir);
        }
        $pars = array_merge($pars, array("dst_dir" => $dst_dir));
        Log::info("Tei2\033[92m" . static::NAME . "->toUri()\033[0m " . $dst_dir);
        return Xsl::transformToXml(
            self::$xsl_dir.static::XSL,
            $dom,
            $pars,
        );
    }

    /**
     * @ override
     */
    static public function toDoc(DOMDocument $dom, ?array $pars=null):?\DOMDocument
    {
        Log::error(__METHOD__." dom export not relevant");
        return null;
    }
    /**
     * @ override
     */
    static public function toXml(DOMDocument $dom, ?array $pars=null):?string
    {
        Log::error(__METHOD__." string export not relevant");
        return null;
    }

}

// EOF