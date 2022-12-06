<?php

/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * MIT License https://opensource.org/licenses/mit-license.php
 * Copyright (c) 2020 frederic.Glorieux@fictif.org
 * Copyright (c) 2013 Frederic.Glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 Frederic.Glorieux@fictif.org
 * Copyright (c) 2010 Frederic.Glorieux@fictif.org 
 *                    & École nationale des chartes
 */

declare(strict_types=1);

namespace Oeuvres\Kit;

use Oeuvres\Kit\{Http};

/**
 * Helper class to print radio button with correct value for parameters
 */
class Radio
{
    /** Name of the radio button set, required */
    private $name;
    /** The values */
    private $buts = array();
    /** Default values */
    private $default;

    /** Construct a radio set */
    function __construct($name)
    {
        $this->name = $name;
    }
    /** Add a value */
    function add(string $value, ?string $label=null, ?bool $default=false): Radio
    {
        // if value contains bad chars for html attribute or regex, let it go ?
        if ($label === null) {
            $label = $value;
        }
        $this->buts[$value] = $label;
        return $this;
    }
    /**
     * Return html to display with correct params
     */
    function __toString(): string
    {
        // Warn developper here ?
        if (!count($this->buts)) {
            return '';
        }
        // ensure param values
        $values = array_keys($this->buts);
        $pattern = '@' . implode('|', $values) . '@u';
        if (!$this->default) {
            $this->default = $values[0];
        }
        $check = Http::par($this->name, $this->default, $pattern);
        $n = 0;
        $html = '';
        foreach($this->buts as $value => $label) {
            $id = $this->name . $n;
            $n++;
            $checked = '';
            if ($value == $check) $checked = ' checked="checked"';
            $html .= '
    <span class="radio">
        <input onchange="this.form.submit()" type="radio" id="' . $id . '" name="' . $this->name 
            . '" value="' . $value . '"' 
            . $checked . '/>
        <label class="radio" for="' . $id . '">' . $label . '</label>
    </span>
';
        }
        return $html;
    }
}