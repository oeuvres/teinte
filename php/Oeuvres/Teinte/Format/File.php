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

use Oeuvres\Kit\Filesys;
use Psr\Log\{LoggerInterface, LoggerAwareInterface, NullLogger};

/**
 * A file, tools to read and write
 */
class File implements LoggerAwareInterface
{
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
        if (true !== ($ret = Filesys::readable($file))) {
            $this->logger->warning($ret);
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