<?php
/**
 * code convention https://www.php-fig.org/psr/psr-12/
 */

declare(strict_types=1);

namespace Oeuvres\Kit;

use Psr\Log\AbstractLogger;
use Psr\Log\InvalidArgumentException;
use Psr\Log\LogLevel;

/**
 * A PSR-3 compliant logger as light as possible
 * Should 
 *
 * @see https://www.php-fig.org/psr/psr-3/
 */
class Logger extends AbstractLogger
{
    private  $ERR = STDERR;
    private  $OUT = STDOUT;

    /** Logging levels */
    private static $levelMapInt = [
        1 => LogLevel::EMERGENCY,
        2 => LogLevel::ALERT,
        3 => LogLevel::CRITICAL,
        4 => LogLevel::ERROR,
        5 => LogLevel::WARNING,
        6 => LogLevel::NOTICE,
        7 => LogLevel::INFO,
        8 => LogLevel::DEBUG,
    ];
    /** Logging level by name */
    private static $levelMapString;
    /** Default level of message to output */
    private int $verbosity;

    public static function init()
    {
        self::$levelMapString = array_flip(self::$levelMapInt);
    }

    public function __construct(string $level = LogLevel::ERROR)
    {
        self::checkLevel($level);
        $this->verbosity = self::$levelMapString[$level];
    }

    private static function checkLevel(string $level)
    {
        if (!isset(self::$levelMapString[$level])) {
            throw new InvalidArgumentException(
                sprintf('Unknown log level "%s"', $level)
            );
        }
    }

    private static function checkLevelInt(int $level)
    {
        if (!isset(self::$levelMapInt[$level])) {
            throw new InvalidArgumentException(
                sprintf('Unknown log level %d', $level)
            );
        }
    }

    /**
     * Get verbosity by string.
     */
    public function getVerbosity():string
    {
        return self::$levelMapInt[$this->verbosity];
    }

    /**
     * Set verbosity by log level.
     */
    public function setVerbosity(string $level)
    {
        self::checkLevel($level);
        $this->verbosity = self::$levelMapString[$level];
    }

    /**
     * {@inheritdoc}
     *
     * @return void
     */
    public function log($level, $message, array $context = []): bool
    {
        $this->checkLevel($level);
        $levelInt = self::$levelMapString[$level];
        if ($levelInt > $this->verbosity) return false;
        $out = STDERR;
        if ($levelInt > self::$levelMapString[LogLevel::ERROR]) {
            $out = STDOUT;
        }
        fwrite($out, $this->interpolate($message, $context) . "\n");
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

    /**
     * TO REWRITE
     * Custom error handler
     * Especially used for xsl:message coming from transform()
     * To avoid Apache time limit, php could output some bytes during long transformations
     */
    static function err(
        $errno, 
        $errstr=null, 
        $errfile=null, 
        $errline=null, 
        $errcontext=null
    ) {
        $errstr=preg_replace("/XSLTProcessor::transform[^:]*:/", "", $errstr, -1, $count);
        /** 
        if ($count) { // is an XSLT error or an XSLT message, reformat here
            if(strpos($errstr, 'error')!== false) {
                return false;
            }
            else if ($errno == E_WARNING) {
                $errno = E_USER_WARNING;
            }
        }
        // a debug message in normal mode, do nothing
        if ($errno == E_USER_NOTICE && !self::$debug) {
            return true;
        }
        // ?? not a user message, let work default handler
        // else if ($errno != E_USER_ERROR && $errno != E_USER_WARNING ) return false;

        if (!$errstr && $errno) {
            $errstr = $errno;
        }
        if (is_resource(self::$logger)) {
            fwrite(self::$logger, $errstr."\n");
        }
        else if (is_string(self::$logger) && function_exists(self::$logger)) {
            call_user_func(self::$logger, $errstr);
        } 
        */
    }

}
Logger::init();