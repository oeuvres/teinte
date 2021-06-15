<?php
/**
 * This class should perform all that Hurlus want with XML/TEI source
 * with custom design
 */
include dirname(dirname(__FILE__)).'/latex/latex.php';
if (isset($argv[0]) && realpath($argv[0]) == realpath(__FILE__)) Rougemont::cli(); //direct CLI
class Rougemont {
  static $workdir;
  static $skeltex;

  public static function xslChapter($id, $meta, $text)
  {
    $texfile = self::$workdir.basename(self::$workdir).'_'.$id.'.tex';
    // echo $id, ' ', $texfile, "\n", $meta, "\n";
    $tex = str_replace(
      array('%meta%', '%text%'), 
      array($meta, $text),
      self::$skeltex,
    );
    file_put_contents($texfile, $tex);
    return "";
  }

  public static function cli() 
  {
    array_shift($_SERVER['argv']); // shift first arg, the script filepath
    if (!count($_SERVER['argv'])) exit("
usage    : php -f rougemont.php srcdir/*.xml\n");

    /* (dstdir/)? 
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
    $proc = new XSLTProcessor();
    $proc->registerPHPFunctions();
    $proc->importStyleSheet(DOMDocument::load(dirname(__FILE__).'/rougemont_latex.xsl'));
    while($glob = array_shift($_SERVER['argv']) ) {
      foreach(glob($glob) as $teifile) {
        $teiname = pathinfo($teifile, PATHINFO_FILENAME);
        list($teiname) = explode("_", $teiname);
        $teidom = Latex::dom($teifile); // escape for lATEX
        // set props before transformations
        self::$workdir = Latex::workdir($teiname);
        self::$skeltex = Latex::includes(dirname(__FILE__).'/rougemont.tex', self::$workdir, $teiname.'/');
        $proc->transformToXML($teidom);

        /*
        $latex->load($teifile); // load TEI/XML source
        $texfile = $latex->setup(dirname(__FILE__).'/rougemont.tex'); // setup the TEX template
        // copy alternate formats in the latex working directory
        foreach (glob(dirname(__FILE__)."/rougemont_*.tex") as $filename) {
          mv 
          // echo "$filename occupe " . filesize($filename) . "\n";
        }
        //  latexmk -xelatex -quiet -f vaneigem1967_savoir-vivre.tex 
        // lualatex a4v2_seq.tex labruyere1688_caracteres.pdf
        // chdir (dirname($texfile)); // change working directory
        // exec("latexmk -xelatex -quiet -f ".basename($texfile));
        */
      }
    }

  }
}

?>
