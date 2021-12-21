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

use Psr\Log\LoggerInterface;

/**
 * Tei exports are designed as a Strategy pattern
 * {@see \Oeuvres\Teinte\AbstractTei2}
 * This class is the Factory providing strategies.
 */
class TeiExportFactory 
{
    /** Static list of available formats, populated on demand */
    private static $transfo = array(
        'article' => null,
        'dc' => null,
        'docx' => null,
        'html' => null,
        'iramuteq' => null,
        // 'detag' => null,
        'markdown' => null,
        // 'naked' => '.txt',
        'site' => null,
        'split' => null,
        'toc' => null,
    );

    /**
     * List available formats 
     */
    public static function help(): string
    {
        $help = "";
        foreach(array_keys(self::$transfo) as $format) {
            $class = "Oeuvres\\Teinte\\Tei2".$format;
            $help .= "    " . $class::NAME. "  \t" . $class::LABEL."\n";
        }
        return $help;
    }

    /**
     * Test if a format is supported
     */
    public static function has(string $format): bool
    {
        return array_key_exists($format, self::$transfo);
    }

    /**
     * Get a named transformer, lazily
     */
    public static function get(
        string $format, 
        ?LoggerInterface $logger = null
    ):AbstractTei2 {
        if (!array_key_exists($format, self::$transfo)) {
            throw new \InvalidArgumentException(
                "\"\033[91m$format\033[0m\" is not yet supported. Choices supported: \n". implode(array_keys(self::$transfo, ", "))
            );
        }
        if (!self::$transfo[$format]) {
            $class = "Oeuvres\\Teinte\\Tei2" . $format;
            self::$transfo[$format] = new $class($logger);
        }
        return self::$transfo[$format];
    }

}

// eol