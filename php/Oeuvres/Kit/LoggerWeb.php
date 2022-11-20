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
class LoggerWeb extends Log
{
    protected function write($level, $message)
    {
        $message = preg_replace('/\n/', "\n<br/>", $message);
        echo "<p class=\"log $level\">[$level] $message</p>\n";
    }

    public function __construct(
        ?string $level = LogLevel::ERROR,
        ?string $prefix = "",
        ?string $suffix = ""
    ) {
        $this->level($level);
        $this->prefix($prefix);
        $this->suffix($suffix);
    }

}
