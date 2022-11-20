<?php

/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 * Copyright (c) 2021 frederic.glorieux@fictif.org
 */

declare(strict_types=1);

namespace Oeuvres\Teinte\Tei2;

/**
 * Export a TEI document as an html fragment <article>
 */

class Tei2elements extends Tei2split
{
    const NAME = 'elements';
    const EXT = '/';
    const LABEL = 'Split tei chapters in elements to build a site';
    const XSL = "tei_elements.xsl";

}

// EOF
