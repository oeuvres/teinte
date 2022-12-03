<?php

/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 */

declare(strict_types=1);

namespace Oeuvres\Teinte\Tei2;

/**
 * Export a TEI document as an html fragment <article>
 */

class Tei2article extends Tei2simple
{
    const EXT = '_art.html';
    const XSL = "tei_html_article.xsl";
    const NAME = "article";
}

// EOF