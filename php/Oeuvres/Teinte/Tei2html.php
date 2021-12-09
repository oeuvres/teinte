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

class Tei2html extends Tei2simple
{
    protected $ext = '.html';
    protected $name = 'html';
    protected $label = '<html> full document';
    protected $xsl = "tei2html.xsl";
    // TODO parameters for XSLT 

    /**
     * // where to  * find web assets like css and jslog for html file
     * if (!$theme) $theme = 'http://oeuvres.github.io/teinte/'; 
     * find a good way to guess that
     */
}

// EOF