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
 * Export a Teidoc as a Dublic Core record (for OAI)
 */
class Tei2dc extends AbstractTei2simple
{
    const EXT = '_dc.xml';
    const NAME = 'dc';
    const LABEL = 'Dublin Core (metadata)';
    const XSL = "misc/tei2dc.xsl";
}

// EOF