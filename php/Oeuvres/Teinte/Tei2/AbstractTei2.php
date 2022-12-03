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
use Oeuvres\Kit\{Filesys, Log, Parse};

/**
 * A Tei document exporter.
 */
abstract class AbstractTei2
{
    /** Do init at startup */
    static private bool $init = false;
    /** Where is the xsl pack, set in one place, do not repeat */
    static protected ?string $xsl_dir = null;
    /** Parameters for all (?) transformers */
    static protected array $pars = [];
    /** Prefered extension for exported files */
    const EXT = null;
    /** Name of the transo for logging */
    const NAME = null;
    /** List of registred transfos */
    static private array $transfos = [];

    /**
     * Initialize static variable
     */
    static public function init()
    {
        if (self::$init) return;
        echo "class = " .get_called_class() . "\n";
        // TO THINK, good way to configure xsl pack
        self::$xsl_dir = dirname(__DIR__, 4) . "/xsl/";
        self::$transfos = Parse::json(file_get_contents(__DIR__ . '/tei2.json'));
        self::$init = true;
    }

    /**
     * Test if a format is supported
     */
    public static function has(string $format): bool
    {
        return array_key_exists($format, self::$transfos);
    }

    /**
     * Return the static class for a transfo
     */
    public static function transfo(string $format):?string 
    {
        if (!self::has($format)) {
            Log::warning($format . " format not yet available as a TEI export");
            return null;
        }
        $class = "Oeuvres\\Teinte\\Tei2\\Tei2" . $format;
        return $class;
    }

    /**
     * Show some help 
     */
    public static function help(): string
    {
        $help = "";
        foreach(self::$transfos as $format => $doc) {
            $help .= "    " . $format. "  \t" . $doc['label']."\n";
        }
        return $help;
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