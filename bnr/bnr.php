<?php
/**
 * From an XML/TEI source, this class should perform desired transformation
 * for the BNR lib https://ebooks-bnr.com/
 * with custom design
 */
include dirname(dirname(__FILE__)).'/latex/latex.php';
include_once(dirname(dirname(__FILE__)).'/docx/docx.php');
include_once(dirname(dirname(__FILE__)).'/epub/epub.php');
include_once(dirname(dirname(__FILE__)).'/php/tools.php');
Bnr::$skeltex = dirname(__FILE__).'/bnr.tex';

if (isset($argv[0]) && realpath($argv[0]) == realpath(__FILE__)) Bnr::cli(); //direct CLI
class Bnr {

  static $skeltex;

  public static function export($teifile, $dstdir='', $force=true)
  {
    if ($dstdir) {
      $dstdir = rtrim($dstdir, '/\\').'/';
      if (!file_exists($dstdir)) {
        mkdir($dstdir, 0775, true);
        @chmod($dstdir, 0775);  // let @, if www-data is not owner but allowed to write
      }
    }
    $name = pathinfo($teifile,  PATHINFO_FILENAME);
    Tools::mkdir($dstdir);
    $dstpath = $dstdir.$name;
    echo "teifile=",$teifile,"\n";

    $dstepub = $dstpath.".epub";
    $livre = new Epub($teifile, STDERR);
    $livre->export($dstepub);
    $cmd = dirname(dirname(__FILE__))."/epub/kindlegen"." ".$dstepub;
    $output = '';
    $last = exec($cmd, $output, $status);

    $dstmobi = $dstpath.".mobi";
    if (!file_exists($dstmobi)) {
      self::log(E_USER_ERROR, "\n".$status."\n".join("\n", $output)."\n".$last."\n");
    }

    $dom = Tools::dom($teifile);
    $dstfile = $dstpath.".html";
    $theme = 'https://oeuvres.github.io/teinte/'; // where to find web assets like css and js for html file
    $xsl = dirname(dirname(__FILE__)).'/tei2html.xsl';
    $pars = array(
      'theme' => $theme,
    );
    Tools::transformDoc($dom, $xsl, $dstfile, $pars);

    $dstfile = $dstpath.".txt";
    $xsl = dirname(dirname(__FILE__)).'/xsl/tei2md.xsl';
    Tools::transformDoc($dom, $xsl, $dstfile);

    $dstfile = $dstpath.".docx";
    Docx::export($teifile, $dstfile);




  }

  public static function pdf($teifile, $dstdir='')
  {
    if ($dstdir) {
      $dstdir = rtrim($dstdir, '/\\').'/';
      if (!file_exists($dstdir)) {
        mkdir($dstdir, 0775, true);
        @chmod($dstdir, 0775);  // let @, if www-data is not owner but allowed to write
      }
    }
    $latex = new Latex();
    $latex->load($teifile);
    $texfile = $latex->setup(self::$skeltex); // get the texfile installed with its resources
    $texname = pathinfo($texfile, PATHINFO_FILENAME);
    $workdir = dirname($texfile).'/';
    $cwd = getcwd();
    chdir($workdir); // change working directory
    // default is a4 2 cols, transform to pdf
    exec("latexmk -xelatex -quiet -f ".$texname.'.tex');
    $tex = file_get_contents($texfile);
    if ($dstdir) {
      $src = $workdir.$texname.'.pdf';
      $dst = $dstdir.$texname.'.pdf';
      // echo $src,' -',file_exists($src), '- ', $dst, "\n";
      rename($src, $dst);
    }

    // A5
    $tex = preg_replace('@\\\\def\\\\mode\{[^\}]*\}@', '\\def\\mode{a5}', $tex);
    $texsrc = $texname.'_a5.tex';
    file_put_contents($texsrc, $tex);
    exec("latexmk -xelatex -quiet -f ".$texsrc); //
    if ($dstdir) rename($workdir.$texname.'_a5.pdf', $dstdir.$texname.'_a5.pdf');
    chdir($cwd);

  }

  public static function cli()
  {
    array_shift($_SERVER['argv']); // shift first arg, the script filepath
    if (!count($_SERVER['argv'])) exit("
usage    : php bnr.php srcdir/*.xml\n");
    $dstdir = dirname(__FILE__).'/work/';
    while($glob = array_shift($_SERVER['argv']) ) {
      foreach(glob($glob) as $teifile) {
        self::pdf(realpath($teifile), $dstdir);
        self::export(realpath($teifile), $dstdir);
      }
    }

  }
}

?>
