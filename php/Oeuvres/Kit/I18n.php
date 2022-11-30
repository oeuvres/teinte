<?php

/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * MIT License https://opensource.org/licenses/mit-license.php
 * Copyright (c) 2022 frederic.Glorieux@fictif.org
 * Copyright (c) 2013 Frederic.Glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 Frederic.Glorieux@fictif.org
 * Copyright (c) 2010 Frederic.Glorieux@fictif.org
 *                    & École nationale des chartes
 */

declare(strict_types=1);

namespace Oeuvres\Kit;

use Psr\Log\{LoggerInterface, NullLogger};

mb_internal_encoding("UTF-8");
class I18n
{
    /** Messages */
    private static $messages = array();

    /**
     * Load an array of messages
     */
    public static function load($tsv_file)
    {
        $map = Misc::tsv_map($tsv_file);
        self::put($map);
    }

    /**
     * Put an array of messages, new value for same key overwrite old one
     */
    public static function put($messages)
    {
        self::$messages = array_merge(self::$messages, $messages);
    }

    /**
     * Return a formated message
     */
    public static function _(): string
    {
        $args = func_get_args();
        if (count($args) < 1) {
            Log::warning("No message requested");
            return ' ';
        }
        $key = $args[0];
        if (isset(self::$messages[$key])) {
            $args[0] = self::$messages[$key];
        } else {
            // test if capitalized key exists
            $keyuc1 = mb_strtoupper(mb_substr($key, 0, 1)) . mb_substr($key, 1);
            if (isset(self::$messages[$keyuc1])) {
                $args[0] = mb_strtolower(self::$messages[$keyuc1]);
            } else {
                Log::warning("No message found for the key=\"$key\"");
            }
        }
        // call sprintf 
        return forward_static_call_array('sprintf', $args);
    }

    /**
     * Format a stack trace, returned as an array of strings 
     */
    public static function trace(): array
    {
        $trace = debug_backtrace();
        $ret = array();
        for ($i = 0, $count = count($trace); $i < $count; $i++) {
            $ret[] = $trace[$i]['file']
                . '#'
                . $trace[$i]['line']
                . ' '
                . $trace[$i]['function']
                . '('
                . implode(', ', $trace[$i]['args'])
                . ')';
        }
        return $ret;
    }


}