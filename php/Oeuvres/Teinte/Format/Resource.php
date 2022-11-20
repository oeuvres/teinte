<?php
/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 */

declare(strict_types=1);

namespace Oeuvres\Teinte\Format;

use Psr\Log\{LoggerInterface, LoggerAwareInterface, NullLogger};

/**
 * A Resource, usually a file, tools to read and write
 */
class Resource implements LoggerAwareInterface
{
    /** init done ? */
    
    /** Somewhere to log in  */
    protected LoggerInterface $logger;
    /** filepath */
    protected $file;
    /** filename without extension */
    protected $filename;
    /** file freshness */
    protected $filemtime;
    /** file size */
    protected $filesize;

    /**
     * Inialize static variables, one is enough
     */
    static function init()
    {

    }
    /**
     * Start with an empty object
     */
    public function __construct(LoggerInterface $logger = null)
    {
        if ($logger == null) $logger = new NullLogger();
        $this->setLogger($logger);
    }

    /**
     * See LoggerAwareInterface
     */
    public function setLogger(LoggerInterface $logger)
    {
        $this->logger = $logger;
    }

    /**
     * Load a file, return nothing, used by child classes.
     */
    public function load(string $file)
    {
        $this->file = $file;
        $this->filename = pathinfo($file, PATHINFO_FILENAME);
        $this->filemtime = filemtime($file);
        $this->filesize = filesize($file); // ?? if URL ?
    }

    /**
     * For a readonly property
     */
    public function file()
    {
        return $this->file;
    }
    /**
     * Get the filename (with no extention)
     */
    public function filename()
    {
        return $this->filename;
    }
    /**
     * Read a readonly property
     */
    public function filemtime()
    {
        return $this->filemtime;
    }
    /**
     * For a readonly property
     */
    public function filesize()
    {
        return $this->filesize;
    }

}