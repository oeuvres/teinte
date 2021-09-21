<?php
/**
 *Testing TEI > latex > pdf conversion
 */
include dirname(dirname(__FILE__)).'/latex/latex.php';
if (isset($argv[0]) && realpath($argv[0]) == realpath(__FILE__)) Rougemont::cli(); //direct CLI
class Rougemont {
  static $workdir;
  static $skeltex;

  public static function xslChapter($id, $meta, $text)
  {
    $texfile = self::$workdir.basename(self::$workdir).'_'.$id.'.tex';
    $workdir = dirname($texfile).'/';
    chdir($workdir); // change working directory
    // echo $id, ' ', $texfile, "\n", $meta, "\n";
    $tex = str_replace(
      array('%meta%', '%text%'),
      array($meta, $text),
      self::$skeltex,
    );
    file_put_contents($texfile, $tex);
    exec("latexmk -xelatex -interaction=nonstopmode -f ".$texfile); //
    // exec("xelatex -interaction=nonstopmode --halt-on-error ".$texfile); //
    // exec("xelatex -interaction=nonstopmode --halt-on-error ".$texfile); //
    // exec("xelatex -interaction=nonstopmode --halt-on-error ".$texfile); //
    // rename(self::$workdir.basename(self::$workdir).'.tex', self::$workdir.basename(self::$workdir).'_'.$id.'.tex');
    // rename(self::$workdir.basename(self::$workdir).'.pdf', self::$workdir.basename(self::$workdir).'_'.$id.'.pdf');
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
        $dstdir = dirname(dirname(dirname(__FILE__))).'/ddr-pdf/'.$teiname.'/';
        $dstfiles = glob($dstdir.'*.pdf');
        if (!count($dstfiles));
        else if (filemtime($dstfiles[0]) > filemtime($teifile)) continue;
        Tools::dirclean($dstdir);


        $bookurl = "https://unige.ch/rougemont/";
        $path = realpath($teifile);
        $folder = basename(dirname($path));
        if (strpos($folder, 'livres') !== false) {
          $bookurl .= "livres/".$teiname.'/';
        }
        else if (strpos($folder, 'articles') !== false) {
          $journal = explode('ddr-', $teiname, 2)[1];
          $bookurl .= "articles/".$journal.'/';
        }
        else if (strpos($folder, 'corr') !== false) {
          $bookurl .= "correspondances/".$teiname.'/';
        }
        $bookurl = preg_replace(array_keys(Latex::$latex_esc), array_values(Latex::$latex_esc), $bookurl);
        echo $bookurl,"\n";
        $proc->setParameter('',
          array(
            'bookurl' => $bookurl,
          )
        );

        // set props before transformations
        self::$workdir = Latex::workdir($teiname);
        self::$skeltex = Latex::includes(dirname(__FILE__).'/rougemont.tex', self::$workdir, $teiname.'/');
        $latex = new Latex();
        $latex->load($teifile);

        $grafhref = 'ill/';
        $grafdir = self::$workdir.$grafhref;
        Tools::dirclean($grafdir); // empty graf dir
        $latex->teigraf($grafdir, $grafhref);

        $proc->transformToXML($latex->dom);

        echo self::$workdir,"\n";
        foreach (glob(self::$workdir."*.pdf") as $srcfile) {
          copy($srcfile, $dstdir.basename($srcfile));
        }

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
