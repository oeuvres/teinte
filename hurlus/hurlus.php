<?php
/**
 * This class should perform all that Hurlus want with XML/TEI source
 * with custom design
 */
include dirname(dirname(__FILE__)).'/latex/latex.php';

if (isset($argv[0]) && realpath($argv[0]) == realpath(__FILE__)) Hurlus::cli(); //direct CLI
class Hurlus {

  public static function cli() 
  {
    array_shift($_SERVER['argv']); // shift first arg, the script filepath
    if (!count($_SERVER['argv'])) exit("
usage    : php -f hurlus.php (dstdir/)? srcdir/*.xml\n");

    /*
    $dstdir = "";
    $lastc = substr($_SERVER['argv'][0], -1);
    if ('/' == $lastc || '\\' == $lastc) {
      $dstdir = array_shift($_SERVER['argv']);
      $dstdir = rtrim($dstdir, '/\\').'/';
      if (!file_exists($dstdir)) {
        mkdir($dstdir, 0775, true);
        @chmod($dir, 0775);  // let @, if www-data is not owner but allowed to write
      }
    }
    */

    $latex = new Latex();
    while($glob = array_shift($_SERVER['argv']) ) {
      foreach(glob($glob) as $teifile) {
        $latex->load($teifile);
        $texfile = $latex->setup(dirname(__FILE__).'/hurlus_a4v2.tex'); // get the texfile installed with its template
        //  latexmk -xelatex -quiet -f vaneigem1967_savoir-vivre.tex 
        // lualatex a4v2_seq.tex labruyere1688_caracteres.pdf
        chdir (dirname($texfile)); // change working directory
        exec("latexmk -xelatex -quiet -f ".basename($texfile));
      }
    }

  }
}

?>
