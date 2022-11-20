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

include(dirname(__DIR__, 2) . "/autoload.php");

use ZipArchive;
use Psr\Log\{LoggerInterface, LoggerAwareInterface, NullLogger};
use Oeuvres\Kit\{File, Xml};

/**
 * A Teidoc exporter.
 */
class Html extends Resource
{

    /**
     * parse a css content
     */
    static function css_semantic($css_string, $append=null)
    {
        $include = [
            "text-align" => [
                "center" => "center",
                "right" => "right",
            ],
            "font-style:italic" => "italic",
        ];

        preg_match_all( '/(?ims)([a-z0-9\s\.\:#_\-@,]+)\{([^\}]*)\}/', $css_string, $arr);
        $result = array();
        foreach ($arr[0] as $i => $x){
            $selector = trim($arr[1][$i]);
            $rules = explode(';', trim($arr[2][$i]));
            $rules_arr = array();
            foreach ($rules as $strRule){
                if (!empty($strRule)){
                    $rule = explode(":", $strRule);
                    $rules_arr[trim($rule[0])] = trim($rule[1]);
                }
            }
    
            $selectors = explode(',', trim($selector));
            foreach ($selectors as $strSel){
                $result[$strSel] = $rules_arr;
            }
        }
        return $result;
    } 

}

