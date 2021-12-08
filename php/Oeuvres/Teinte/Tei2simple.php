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
use Oeuvres\Kit\Xml;

/**
 * A sinmple Teidoc exporter, with only one xslt
 */
abstract class Tei2simple extends Tei2
{
    /** Path to the xslt file, relative to the xsl pack root */
    protected $xsl;

    /**
     * Returns xslt full path
     */
    public function xsl():string
    {
        return $this->xsl;
    }
    public function toUri(DOMDocument $dom, string $dstFile)
    {
        $this->logger->debug(__METHOD__." $dstFile");
        return Xml::transformToUri(
            self::$xslDir.$this->xsl,
            $dom,
            $dstFile,
        );
    }
    public function toXml(DOMDocument $dom):string
    {
        return Xml::transformToXml(
            self::$xslDir.$this->xsl,
            $dom,
        );

    }

    public function toDoc(DOMDocument $dom):DOMDocument
    {
        return Xml::transformToDoc(
            self::$xslDir.$this->xsl,
            $dom,
        );

    }

}