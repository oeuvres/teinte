<?php

/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 */

declare(strict_types=1);

namespace Oeuvres\Teinte;

use DOMDocument;
use Oeuvres\Kit\{File,Xml};

/**
 * Export a TEI document as an html fragment <article>
 */

class Tei2site extends Tei2split
{
    const NAME = 'site';
    const EXT = '/';
    const LABEL = 'Split tei chapters in a browsable html site';
    const XSL = "tei2site.xsl";

}

// EOF