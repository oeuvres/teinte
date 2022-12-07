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
use Psr\Log\{AbstractLogger, InvalidArgumentException, LogLevel, LoggerInterface, NullLogger};

/**
 * A static logger
 *
 * @see https://www.php-fig.org/psr/psr-3/
 */
abstract class Logger extends AbstractLogger
{
    /** Logging level by name */
    private const LEVEL_VERBOSITY = [
        LogLevel::EMERGENCY => 1,
        LogLevel::ALERT => 2,
        LogLevel::CRITICAL => 3,
        LogLevel::ERROR => 4,
        LogLevel::WARNING => 5,
        LogLevel::NOTICE => 6,
        LogLevel::INFO => 7,
        LogLevel::DEBUG => 8,
    ];
    /** Init counters */
    private const COUNTS_INIT = [0,0,0,0,0,0,0,0,0];
    /** Couters to record numbers of errors */
    private array $counts = self::COUNTS_INIT;
    /** Last message */
    private string $last = "";
    /** Default prefix for message */
    private string $prefix = "[{level}] "; 
    /** Default suffix for message (ex: clossing tag forr html) */
    private string $suffix = ""; 
    /** Default level of message to output */
    private int $verbosity = 4;
    /** Global duration */
    private $time_start = 0;
    /** Elapsed between log message */
    private $time_lapse = 0;

    public function __construct(
        ?string $level = LogLevel::ERROR, 
        ?string $prefix = "[{level}] ",
        ?string $suffix = ""
    ) {
        $this->level($level);
        $this->prefix($prefix);
        $this->suffix($suffix);
        $this->time_start = $this->time_lapse = microtime(true);

    }

    /**
     * Get/Set level
     */
    public function level(?string $level = null)
    {
        if (!$level) {
            $key = array_search ($this->verbosity, self::LEVEL_VERBOSITY);
            return $key;
        }
        $verbosity = self::verbosity($level);
        $this->verbosity = $verbosity;
    }

    /**
     * Get a verbosity int from a string level 
     */
    protected static function verbosity(string $level):int
    {
        if (!isset(self::LEVEL_VERBOSITY[$level])) {
            // :o) impossible to log 
            throw new InvalidArgumentException(
                sprintf('Unknown log level "%s"', $level)
            );
            return self::LEVEL_VERBOSITY[LogLevel::ERROR];
        }
        return self::LEVEL_VERBOSITY[$level];
    }

    /**
     * {@inheritdoc}
     *
     * @return void
     */
    public function log($level, $message, array $context = []): bool
    {
        // if message is empty, do nothing
        if($message === true) return false;
        if($message === null) return false;
        if(is_string($message) && trim($message) === '') return false;

        $verbosity = self::verbosity($level);
        // log counters
        $this->inc($verbosity);
        if ($verbosity > $this->verbosity) return false;

        $date = new DateTime();
        $context['whoami'] = getenv('APACHE_RUN_USER');
        $context['level'] = str_pad($level, 8, ' ', STR_PAD_LEFT);
        $context['date'] = $date->format('Y-m-d');
        $context['datetime'] = $date->format('Y-m-d H:i:s');
        $context['time'] = $date->format('H:i:s');
        $context['duration'] = number_format(microtime(true) - $this->time_start, 3) . "s.";
        $context['lapse'] = "+" . (number_format(microtime(true) - $this->time_lapse, 3)) . "s.";
        $this->time_lapse = microtime(true);
        $mess = $this->interpolate($this->prefix . $message . $this->suffix, $context);
        $this->last = $mess;
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
        // limit message size (in case of bad param)
        $message = substr($message, 0, 512);
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

    /**
     * Get/Set prefix for log message
     */
    public function prefix(?string $prefix = null)
    {
        if ($prefix === null) {
            return $this->prefix;
        }
        $this->prefix = $prefix;
    }

    /**
     * Set suffix for log message
     */
    public function suffix(?string $suffix = null)
    {
        if ($suffix === null) {
            return $this->suffix;
        }
        $this->suffix = $suffix;
    }

    /**
     * Reset error counters
     */
    public function reset()
    {
        $this->counts = self::COUNTS_INIT;
        $this->start_time = microtime(true);
    }

    /**
     * Increment 
     */
    protected function inc($verbosity)
    {
        if ($verbosity < 1) return;
        for($i = $verbosity; $i < 9; $i++) {
            $this->counts[$i]++;
        }
    }

    /**
     * Return last nmessage (nice for debug)
     */
    public function last():string
    {
        return $this->last;
    }

    /**
     * Where to write log message ?
     */
    abstract protected function write($level, string $message);

}