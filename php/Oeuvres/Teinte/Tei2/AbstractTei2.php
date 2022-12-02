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
use Oeuvres\Kit\{Filesys, Log};

/**
 * A Tei document exporter.
 */
abstract class AbstractTei2
{
    /** Do init at startup */
    static private bool $init = false;
    /** Where is the xsl pack, set in one place, do not repeat */
    static protected ?string $xsl_dir = null;
    /** Parameters for the transformer */
    static protected array $pars = [];
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

    /**
     * Initialize static variable
     */
    static public function init()
    {
        if (self::$init) return;
        // TO THINK, good way to configure xsl pack
        self::$xsl_dir = dirname(__DIR__, 4) . "/xsl/";
        self::$init = true;
    }

    /**
     * Build a prefered file path from source path,
     * according to the preferred extension format,
     * and a destination directory if provided.
     */
    static public function destination(
        string $src_file,
        ?string $dst_dir = null
    ): string {
        if (!$dst_dir) {
            $dstDir = dirname($src_file) . DIRECTORY_SEPARATOR;
        } else {
            $dstDir = Filesys::normdir($dst_dir);
        }
        $dstName =  pathinfo($src_file, PATHINFO_FILENAME);
        $dstFile = $dstDir . $dstName . static::EXT;
        return $dstFile;
    }

    /**
     * get/set default parameters for all transformers
     */
    static public function pars(?array $pars = null)
    {
        if ($pars === null) return $pars;
        if (!is_array($pars)) {
            Log::warning(__FUNCTION__ . " \$pars not [] " . print_r($pars, true));
            return;
        }
        self::$pars = $pars;
    }

    /**
     * Allow to set a a template directory
     */
    static public function template(?string $dir = null)
    {
        if ($dir && !is_dir($dir)) {
            throw new \InvalidArgumentException(
                "Template: \"\033[91m$dir\033[0m\" is not a valid directory."
            );
        }
    }

    /**
     * Write transformation as an Uri, which is mainly, a file
     */
    static abstract public function toUri(DOMDocument $dom, string $dstFile, ?array $pars = null);
    /**
     * Export transformation as an XML string
     * (maybe not relevant for aggregated formats: docx, epub, site…)
     */
    static abstract public function toXml(DOMDocument $dom, ?array $pars = null): ?string;
    /**
     * Export transformation as a Dom
     * (maybe not relevant for aggregated formats: docx, epub, site…)
     */
    static abstract public function toDoc(DOMDocument $dom, ?array $pars = null): ?DOMDocument;
}
AbstractTei2::init();

// EOF