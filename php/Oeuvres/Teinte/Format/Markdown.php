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

use ParsedownExtra;
use Oeuvres\Kit\{Filesys, Log, Parse};

/**
 * An Html text for content import
 */
class Markdown extends File
{
    static $init = false;
    static private ParsedownExtra $parser;
    /**
     * Get an md parser
     */
    static public function init():void
    {
        if (self::$init) return;
        self::$parser = new ParsedownExtra();
        self::$init = true;
    }

    /**
     * Output html from content
     */
    public function html():string
    {
        return self::$parser->text($this->contents());
    }

}
Markdown::init();