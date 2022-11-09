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
use Psr\Log\{LoggerAwareInterface, LoggerInterface, NullLogger};
use Oeuvres\Kit\File;
use Oeuvres\Kit\Xml;

/**
 * Load a TEI document and perform an url check on //ref/@target
 */
class Tei2urlcheck extends AbstractTei2
{
    /** Do init at startup */
    static private $init; 
    /** Somewhere to log in  */
    protected LoggerInterface $logger;
    const NAME = 'urlcheck';
    const EXT = '.xml';
    const LABEL = 'Check url in //ref/@target';

    /**
     * Write transformation as an Uri, which is mainly, a file
     */
    public function toUri(DOMDocument $dom, string $dst_file, ?array $pars=null) {
        $dom = self::toDoc($dom, $pars);
        if ($dom) $dom->save($dst_file);
    }
    /**
     * Export transformation as an XML string
     * (maybe not relevant for aggregated formats: docx, epub, site…)
     */
    public function toXml(DOMDocument $dom, ?array $pars=null):?string
    {
        $dom = self::toDoc($dom, $pars);
        return $dom->saveXML();
    }
    /**
     * Verify DOM
     */
    public function toDoc(DOMDocument $dom, ?array $pars=null):?DOMDocument 
    {
        $context = stream_context_create(
            array(
                'http' => array(
                    'method' => 'HEAD',
                    'timeout' => 2
                )
            )
        );
        $nl = $dom->getElementsByTagNameNS('http://www.tei-c.org/ns/1.0', 'ref');
        $att = "target";
        foreach ($nl as $link) {
            if (!$link->hasAttribute($att)) {
                $this->logger->warning(
                    "\033[91m@target\033[0m attribute missing "
                    . self::message($link, $att, null)
                );
                continue;
            }
            $target = trim($link->getAttribute($att));
            // anchor link @xml:id, check dest
            if (substr($target, 0, 1) == '#') {
                $id = substr($target, 1);
                $el = $dom->getElementById($id);
                if ($el) continue;
                $this->logger->info(
                    "\033[91mxml:id=\"$id\"\033[0m target element not found "
                    . self::message($link, $att, $target)
                );
                continue;
            }
            // absolute file link, bad
            else if (File::isabs($target)) {
                $this->logger->info(
                    "\033[91mabsolute file path\033[0m "
                    . self::message($link, $att, $target)
                );
                continue;
            }
            // url, test it (may be slow ?)
            else if (substr(trim($target), 0, 4) == 'http') {
                $headers = @get_headers($target);
                if (!$headers) {
                    $this->logger->info(
                        "\033[91murl lost\033[0m "
                        . self::message($link, $att, $target)
                    );
                    continue;
                }
                preg_match("@\d\d\d@", $headers[0], $matches);
                $code = $matches[0];
                if ($code == '200' || $code == '302') continue;
                $this->logger->info(
                    "\033[91m" . substr($headers[0], 9) . "\033[0m "
                    . self::message($link, $att, $target)
                );
                continue;
            }
            // relative link
            else { 
                $this->logger->info(
                    "\033[91mfile not found\033[0m "
                    . self::message($link, $att, $target)
                );
                continue;
            }
        }
        return null;
    }
    /**
     * Format log message
     */
    private static function message($src_node, $att, $value)
    {
        $m = "";
        $m .= "l. {$src_node->getLineNo()} <{$src_node->nodeName}";
        if ($att && $value) $m .= " $att=\"$value\"";
        $m .= ">";
        return $m;
    }
}
Tei2urlcheck::init();

// EOF