<?php declare(strict_types=1);
/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 */

namespace Oeuvres\Teinte\Format;

use Oeuvres\Kit\{Filesys, Log, Parse};

/**
 * A file, tools to read and write
 */
class File
{
    /** Avoid multiple initialisation */
    static private bool $init = false;
    /** Convert extension to a format known here */
    private static array $ext2format = [];
    /** Properties for a format */
    private static array $formats = [];
    /** filepath */
    protected ?string $file;
    /** filename without extension */
    protected ?string $filename;
    /** file freshness */
    protected int $filemtime;
    /** file size */
    protected int $filesize;
    /** file content if has been loaded */
    protected ?string $contents = null;

    static function init(): void
    {
        if (self::$init) return;
        self::$ext2format = Parse::json(file_get_contents(__DIR__ . '/ext2format.json'));
        self::$formats = Parse::json(file_get_contents(__DIR__ . '/formats.json'));
        Log::debug(__METHOD__);
        self::$init = true;
    }

    /**
     * Get a normalized known format from extension
     */
    static public function path2format(?string $file): ?string
    {
        if (!$file) return null;
        $ext = pathinfo('.' . $file, PATHINFO_EXTENSION);
        $ext = strtolower($ext);
        if (!isset(self::$ext2format[$ext])) return null;
        return self::$ext2format[$ext];
    }

    /**
     * Mime for a known format
     */
    static public function mime(?string $format): ?string
    {
        if (!$format) return null;
        if (!isset(self::$formats[$format])) return null;
        return self::$formats[$format]['mime'];
    }

    /**
     * Extension for a known format
     */
    static public function ext(?string $format): ?string
    {
        if (!$format) return null;
        if (!isset(self::$formats[$format])) return null;
        return self::$formats[$format]['ext'];
    }
    
    /**
     * Get a class 
     */
    static public function path2class(?string $file): ?string
    {
        if (!$file) return null;
        $format = self::path2format($file);
        if (!$format) return null;
        $format = ucfirst($format);
        $class = "Oeuvres\\Teinte\\Format\\" . $format;
        return $class;
    }

    /**
     * Load a file lazily, return nothing, used by child classes.
     */
    public function load(string $file)
    {
        if (true !== ($ret = Filesys::readable($file))) {
            Log::warning($ret);
            // shall we send exception here ?
            return false;
        }
        // if file does not exists do something ?
        $this->file = $file;
        $this->filename = pathinfo($file, PATHINFO_FILENAME);
        $this->filemtime = filemtime($file);
        $this->filesize = filesize($file); // ?? if URL ?
    }

    /**
     * Return path for this file
     */
    public function file(): string
    {
        return $this->file;
    }
    /**
     * Get the filename (with no extention)
     */
    public function filename(): string
    {
        return $this->filename;
    }
    /**
     * Read a readonly property
     */
    public function filemtime(): int
    {
        return $this->filemtime;
    }
    /**
     * For a readonly property
     */
    public function filesize(): int
    {
        return $this->filesize;
    }

    /*
    * Return content if loaded or load it
    */
    public function contents(): string
    {
        if ($this->contents === null) {
            $this->contents = file_get_contents($this->file);
        }
        return  $this->contents;
    }
}
File::init();
