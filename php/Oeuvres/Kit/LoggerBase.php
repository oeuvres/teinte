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

use \DateTime;
use Psr\Log\AbstractLogger;
use Psr\Log\InvalidArgumentException;
use Psr\Log\LogLevel;

/**
 * A base for a PSR-3 compliant logger as light as possible
 * Used for Cli or File
 *
 * @see https://www.php-fig.org/psr/psr-3/
 */
abstract class LoggerBase extends AbstractLogger
{
    /** Default prefix for message */
    private $prefix = "[{level}] {time} "; 
    /** Logging level by name */
    private static $level_verbosity = array(
        LogLevel::EMERGENCY => 1,
        LogLevel::ALERT => 2,
        LogLevel::CRITICAL => 3,
        LogLevel::ERROR => 4,
        LogLevel::WARNING => 5,
        LogLevel::NOTICE => 6,
        LogLevel::INFO => 7,
        LogLevel::DEBUG => 8,
    );
    /** Default level of message to output */
    private $verbosity = 4;

    /**
     * Where to write log message ?
     */
    abstract protected function write($level, string $message);


    public static function init()
    {
        // ensure timezone ()
        if(ini_get('date.timezone')) {
            date_default_timezone_set(ini_get('date.timezone'));
        }
        else {
            date_default_timezone_set("Europe/Paris");
        }
    }

    /**
     * Get a verbosity int from a string level 
     */
    protected static function verbosity(string $level):int
    {
        if (!isset(self::$level_verbosity[$level])) {
            throw new InvalidArgumentException(
                sprintf('Unknown log level "%s"', $level)
            );
            return self::$level_verbosity[LogLevel::ERROR];
        }
        return self::$level_verbosity[$level];
    }

    /**
     * Set/get level
     */
    public function level(?string $level = null)
    {
        if (!$level) {
            $key = array_search ($this->verbosity, self::$level_verbosity);
            return $key;
        }
        $verbosity = self::verbosity($level);
        $this->verbosity = $verbosity;
    }

    /**
     * Set prefix for log message
     */
    public function prefix(string $prefix)
    {
        $this->prefix = $prefix;
    }

    /**
     * {@inheritdoc}
     *
     * @return void
     */
    public function log($level, $message, array $context = []): bool
    {
        $verbosity = self::verbosity($level);
        if ($verbosity > $this->verbosity) return false;

        $date = new DateTime();
        $context['level'] = $level;
        $context['datetime'] = $date->format('Y-m-d H:i:s');
        $context['time'] = $date->format('H:i:s');
        $mess = $this->interpolate($this->prefix.$message, $context);
        
        $this->write($level, $mess);
        return true;
    }

    /**
     * Interpolates context values into the message placeholders.
     *
     * @author PHP Framework Interoperability Group
     */
    private function interpolate(string $message, array $context): string
    {
        if (\strpos($message, '{') === false) {
            return $message;
        }

        $replacements = [];
        foreach ($context as $key => $val) {
            if (null === $val || is_scalar($val) || (\is_object($val) && \method_exists($val, '__toString'))) {
                $replacements["{{$key}}"] = $val;
            } elseif ($val instanceof \DateTimeInterface) {
                $replacements["{{$key}}"] = $val->format(\DateTime::RFC3339);
            } elseif (\is_object($val)) {
                $replacements["{{$key}}"] = '[object '.\get_class($val).']';
            } else {
                $replacements["{{$key}}"] = '['.\gettype($val).']';
            }
        }

        return strtr($message, $replacements);
    }


}
LoggerBase::init();