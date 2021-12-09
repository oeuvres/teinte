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

/**
 * Export a TEI document as an html fragment <article>
 */

class Tei2toc extends Tei2simple
{
    protected $ext = '_toc.html';
    protected $name = 'toc';
    protected $label = '<nav> table of contents';
    protected $xsl = "tei2toc.xsl";
}

// EOF