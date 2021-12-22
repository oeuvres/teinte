<?php

/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 * Copyright (c) 2021 frederic.glorieux@fictif.org
 */

declare(strict_types=1);

namespace Oeuvres\Teinte;

/**
 * Export a TEI document as an html fragment <article>
 */

class Tei2elements extends Tei2split
{
    const NAME = 'elements';
    const EXT = '_els/';
    const LABEL = 'Split tei chapters in elements to build a site';
    const XSL = "tei2elements.xsl";

}

// EOF
