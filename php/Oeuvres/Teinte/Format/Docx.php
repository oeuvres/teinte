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

use Exception, ZipArchive;
use Psr\Log\LogLevel;

/**
 * A wrapper around docx document for export to semantic formats.
 * For now, mostly tested on:
 *  — Abbyy Finereader docx export
 */
class Docx extends Zip
{

    /**
     * Get an XML concatenation of content
     */
    function package(): string
    {
        if (null === $this->zip) $this->open();
        // concat XML files sxtracted, without XML prolog
        $xml = '<?xml version="1.0" encoding="UTF-8"?>
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
                if ($name === 'word/document.xml') $this->logger->error($m);
                else $this->logger->warning($m);
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
            $xml .= "
  <pkg:part pkg:contentType=\"$type\" pkg:name=\"/$name\">
    <pkg:xmlData>\n" . substr($content, $offset) . "\n    </pkg:xmlData>
  </pkg:part>
";
        }
        $xml .= "\n</pkg:package>\n";
        return $xml;
    }

}

