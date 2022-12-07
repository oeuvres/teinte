<?php
/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 */

declare(strict_types=1);

namespace Oeuvres\Kit;

/**
 * Different checks before installation
 */
class Check
{
    /** Do not repeat extension alert */
    private static $ext_log = [];

    const EXTENSIONS = [
        'intl' => [
            'apt' => 'php-intl',
        ],
        'mbstring' => [
            'apt' => 'php-mbstring',
        ],
        'mysql' => [
            'apt' => 'php-mysql',
        ],
        'xsl' => [
            'apt' => 'php-xml',
        ],
        'zip' => [
            'apt' => 'php-zip',
        ],
    ];

    /**
     * Throw an exception if 
     */
    public static function extension(...$extensions)
    {
        foreach ($extensions as $ext) {
            if (isset(self::$ext_log[$ext])) {
                self::$ext_log[$ext]++;
                continue;
            }
            if (extension_loaded($ext)) continue;
            self::$ext_log[$ext] = 1;
            $m = "$ext extension required.\n    Check your php.ini.";
            if (isset(self::EXTENSIONS[$ext])) {
                $m .= "\n    On Ubuntu or Debian like systems: sudo apt install " . self::EXTENSIONS[$ext]['apt'];
            }
            Log::alert($m);
        }
    }

}
