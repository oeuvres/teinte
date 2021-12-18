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
use Oeuvres\Kit\{File,Xml};

/**
 * Export a TEI document as an html fragment <article>
 */

class Tei2split extends AbstractTei2
{
    const NAME = 'site';
    const EXT = '/';
    const LABEL = 'split tei chapters in <tei:div>';
    const XSL = "tei2site.xsl";

    /**
     * @ override
     */
    public function toUri(DOMDocument $dom, string $dstFile, ?array $pars=array())
    {
        if (!$pars) $pars = array();
        // mkdir to have realpath
        File::cleandir($dstFile);
        $dst_dir = realpath($dstFile) . '/';
        $dst_dir = "file:///" . str_replace(DIRECTORY_SEPARATOR, "/", $dst_dir);
        $pars = array_merge($pars, array("dst_dir" => $dst_dir));
        $this->logger->info("Tei2\033[92m" . static::NAME . "->toUri()\033[0m " . $dst_dir);
        return Xml::transformToXml(
            self::$xslDir.'tei2split.xsl',
            $dom,
            $pars,
        );
    }

    /**
     * @ override
     */
    public function toDoc(DOMDocument $dom, ?array $pars=null):?\DOMDocument
    {
        $this->logger->error(__METHOD__." dom export not relevant");
        return null;
    }
    /**
     * @ override
     */
    public function toXml(DOMDocument $dom, ?array $pars=null):?string
    {
        $this->logger->error(__METHOD__." string export not relevant");
        return null;
    }


}

// EOF