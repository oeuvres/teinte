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
use Oeuvres\Kit\{Filesys};

/**
 * A Tei document exporter.
 */
abstract class Tei2
{    
    /** Do init at startup */
    static private $init;
    /** Where is the xsl pack, set in one place, do not repeat */
    static protected $xsl_dir;
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
    /** Static list of available formats, populated on demand */
    private static $transfo = [
        'article' => null,
        'dc' => null,
        'docx' => null,
        'elements' => null,
        'html' => null,
        'iramuteq' => null,
        // 'detag' => null,
        'markdown' => null,
        // 'naked' => '.txt',
        'site' => null,
        'split' => null,
        'toc' => null,
        'urlcheck' => null,
    ];

    /**
     * Initialize static variable
     */
    public static function init()
    {
        if (self::$init) return;
        self::$init = true;
        // TO THINK, good way to configure xsl pack
        self::$xsl_dir = dirname(__DIR__, 4) . "/xsl/";
    }

    /**
     * Quite empty constructor, ensure some constants
     */
    public function __construct()
    {
        // check the required constant for newly instantiate format
        assert(static::NAME != null, static::class . "::NAME must be defined");
        assert( static::EXT != null, static::class . "::EXT must be defined as prefered file extension for this format");
    }

    /**
     * List available formats 
     */
    public static function list(): array
    {
        return array_keys(self::$transfo);
    }

    /**
     * Test if a format is supported
     */
    public static function has(string $format): bool
    {
        return array_key_exists($format, self::$transfo);
    }

    /**
     * Show some help 
     */
    public static function help(): string
    {
        $help = "";
        foreach(array_keys(self::$transfo) as $format) {
            $class = "Oeuvres\\Teinte\\Tei2\\Tei2".$format;
            $help .= "    " . $class::NAME. "  \t" . $class::LABEL."\n";
        }
        return $help;
    }

    /**
     * Get a named transformer, lazily
     */
    public static function get(string $format):?self 
    {
        if (!array_key_exists($format, self::$transfo)) {
            throw new \InvalidArgumentException(
                "\"\033[91m$format\033[0m\" is not yet supported. Choices supported: \n". implode(array_keys(self::$transfo, ", "))
            );
        }
        if (!self::$transfo[$format]) {
            $class = "Oeuvres\\Teinte\\Tei2\\Tei2" . $format;
            self::$transfo[$format] = new $class();
        }
        return self::$transfo[$format];
    }
    
    /**
     * Build a prefered file path from source path,
     * according to the preferred extension format,
     * and a destination directory if provided.
     */
    public static function destination(
        string $src_file, 
        ?string $dst_dir = null
    ):string {
        if(!$dst_dir) {
            $dstDir = dirname($src_file) . DIRECTORY_SEPARATOR;
        }
        else {
            $dstDir = Filesys::normdir($dst_dir);
        }
        $dstName =  pathinfo($src_file, PATHINFO_FILENAME);
        $dstFile = $dstDir . $dstName . static::EXT;
        return $dstFile;
    }

    /**
     * Allow to set a a template directory, usually not useful
     */
    public function template(?string $dir = null) {
        if ($dir && !is_dir($dir)) {
            throw new \InvalidArgumentException(
                "Template: \"\033[91m$dir\033[0m\" is not a valid directory."
            );
        }
    }

    /**
     * Write transformation as an Uri, which is mainly, a file
     */
    abstract public function toUri(DOMDocument $dom, string $dstFile, ?array $pars=null);
    /**
     * Export transformation as an XML string
     * (maybe not relevant for aggregated formats: docx, epub, site…)
     */
    abstract public function toXml(DOMDocument $dom, ?array $pars=null):?string;
    /**
     * Export transformation as a Dom
     * (maybe not relevant for aggregated formats: docx, epub, site…)
     */
    abstract public function toDoc(DOMDocument $dom, ?array $pars=null):?DOMDocument;
}
Tei2::init();

// EOF