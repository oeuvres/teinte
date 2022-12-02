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

use Psr\Log\LogLevel;

/**
 * A PSR-3 compliant logger as light as possible
 * Used for CLI 
 *
 * @see https://www.php-fig.org/psr/psr-3/
 */
class LoggerCli extends Logger
{
    protected function write($level, $message)
    {
        $verbosity = parent::verbosity($level);
        if ($verbosity > 4) {
            $out = STDOUT;
        } else {
            $out = STDERR;
        }
        fwrite($out, $message . "\n");
    }

    public function __construct(
        ?string $level = LogLevel::INFO, 
        ?string $prefix = "{level} {duration} {lapse} — ",
        ?string $suffix = ""
    ) {
        parent::__construct($level, $prefix, $suffix);
    }

}
