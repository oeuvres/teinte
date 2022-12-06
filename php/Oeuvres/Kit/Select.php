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
 * Helper class to print a select with correct value for parameters
 */
class Select
{
    /** Name of the select, required */
    private $name;
    /** Id of the element, optional */
    private $id;
    /** The values */
    private $options = array();
    /** Default values */
    private $default;

    /** Construct a radio set */
    function __construct($name, $id=null)
    {
        $this->name = $name;
        if ($id !== null) $this->id = $id;
    }
    /** Add a value */
    function add(string $value, ?string $label=null, ?bool $default=false): Select
    {
        // if value contains bad chars for html attribute or regex, let it go ?
        if ($label === null) {
            $label = $value;
        }
        $this->options[$value] = $label;
        return $this;
    }
    /**
     * Return html to display with correct params
     */
    function __toString(): string
    {
        // Warn developper here ?
        if (!count($this->options)) {
            return '';
        }
        // ensure param values
        $values = array_keys($this->options);
        $pattern = '@' . implode('|', $values) . '@u';
        if (!$this->default) {
            $this->default = $values[0];
        }
        $check = Http::par($this->name, $this->default, $pattern);
        $html = '<select name="' . $this->name .'"';
        if ($this->id != null) $html .= ' id="' . $this->id . '"';
        $html .= '>';
        foreach($this->options as $value => $label) {
            $checked = '';
            if ($value == $check) $checked = ' selected="selected"';
            $html .= '
    <option value="' . $value . '"' . $checked . '>' . $label . '</option>';
        }
        $html .= '
</select>';
        return $html;
    }
}