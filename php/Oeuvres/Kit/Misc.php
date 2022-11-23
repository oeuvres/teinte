<?php

/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 */

declare(strict_types=1);

namespace Oeuvres\Kit;

/**
 * code convention https://www.php-fig.org/psr/psr-12/
 */
class Misc
{

    static function mois($num)
    {
        $mois = array(
            1 => 'janvier',
            2 => 'février',
            3 => 'mars',
            4 => 'avril',
            5 => 'mai',
            6 => 'juin',
            7 => 'juillet',
            8 => 'août',
            9 => 'septembre',
            10 => 'octobre',
            11 => 'novembre',
            12 => 'décembre',
        );
        return $mois[(int)$num];
    }

    /**
     * Build a search/replace regexp table from a sed script
     */
    public static function sed_preg($script)
    {
        $search = array();
        $replace = array();
        $lines = explode("\n", $script);
        $lines = array_filter($lines, 'trim');
        foreach ($lines as $l) {
            $l = trim($l);
            if ($l[0] != 's') continue;
            $delim = $l[1];
            list($a, $re, $rep, $flags) = explode($delim, $l);
            $mod = 'u';
            if (strpos($flags, 'i') !== FALSE) $mod .= "i"; // ignore case ?
            $search[] = $delim . $re . $delim . $mod;
            $replace[] = preg_replace(
                array('/\\\\([0-9]+)/', '/\\\\n/', '/\\\\t/'),
                array('\\$$1', "\n", "\t"),
                $rep
            );
        }
        return array($search, $replace);
    }

    /**
     * Build a search/replace regexp table from a two colums table
     */
    public static function pcre_tsv($script, $sep = "\t")
    {
        $search = [];
        $replace = [];

        $var_search = [];
        $var_replace = [];

        $lines = explode("\n", $script);
        $l = 0;
        foreach ($lines as $l) {
            if ($l[0] != 's') continue;
            $delim = $l[1];
            list($a, $re, $rep, $flags) = explode($delim, $l);
            $mod = 'u';
            if (strpos($flags, 'i') !== FALSE) $mod .= "i"; // ignore case ?
            $search[] = $delim . $re . $delim . $mod;
            $replace[] = preg_replace(
                array('/\\\\([0-9]+)/', '/\\\\n/', '/\\\\t/'),
                array('\\$$1', "\n", "\t"),
                $rep
            );
        }
        return array($search, $replace);
    }

    /**
     * Build a map from tsv file where first col is the key.
     */
    static function tsv_map($tsvfile, $sep = "\t")
    {
        $ret = array();
        $handle = fopen($tsvfile, "r");
        $l = 0;
        while (($data = fgetcsv($handle, 0, $sep)) !== FALSE) {
            $l++;
            if (!$data || !count($data) || !$data[0]) {
                continue; // empty lines
            }
            /* Log ?
            if (isset($ret[$data[0]])) {
                echo $tsvfile,'#',$l,' not unique key:', $data[0], "\n";
            }
            */
            if (!isset($data[1])) {  // shall we log for user
                continue;
            }

            $ret[$data[0]] = stripslashes($data[1]);
        }
        fclose($handle);
        return $ret;
    }
}
