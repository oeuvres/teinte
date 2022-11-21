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

use Exception, ZipArchive;
use Oeuvres\Kit\{Check};
// required extension
Check::extension('zip');




/**
 * A Teidoc exporter.
 */
class Zip extends File
{
    /** zip object opened */
    protected ?ZipArchive $zip = null;

    /**
     * Open zip archive with tests
     */
    public function open(): void
    {
        $this->zip = new ZipArchive();
        if (!($this->zip->open($this->file) === TRUE)) {
            throw new Exception ($this->file . ' seems not a valid zip archive');
        }
    }


    /**
     * Check if a zip file contains an entry by regex pattern
     * Extract it to a dest dir.
     * Ex : check if an epub collection contains a kind of entry
     * and show it
     */
    static function select($file, $pattern, $dst_dir)
    {
        echo $file;
        $epub_name = pathinfo($file, PATHINFO_FILENAME);
        $zip = new ZipArchive();
        if (($err = $zip->open($file)) !== TRUE) {
            // http://php.net/manual/fr/ziparchive.open.php
            if ($err == ZipArchive::ER_NOZIP) {
                // log
                // $this->log(E_USER_ERROR, $this->_basename . " is not a zip file");
                return;
            }
            // $this->log(E_USER_ERROR, $this->_basename . " impossible ton open");
            return;
        }
        $found = false;
        for ($i = 0; $i < $zip->numFiles; $i++) {
            $zip_entry = $zip->getNameIndex($i);
            $basename = basename($zip_entry);
            if (!preg_match($pattern, $basename)) continue;
            $dst_file = $dst_dir . '/' . $epub_name . '_' . basename($zip_entry);
            $cont = $zip->getFromName($zip_entry);
            file_put_contents($dst_file, $cont);
            $found= true;
        }
        $zip->close();
        if (!$found) echo " 404";
        echo "\n";
    }


}

