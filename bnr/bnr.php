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
    $name = basename($dstdir);
    Tools::mkdir($dstdir);
    $dstpath = $dstdir.$name;

    if (!file_exists($teifile)) {
      echo "404 not found \"$teifile\"\n";
      return;
    }

    // actions
    $todo = array();
    foreach (array('epub', 'html', 'txt', 'docx') as $ext) {
      $dstfile = $dstpath.".$ext";
      if (file_exists($dstfile) && filemtime($teifile) < filemtime($dstfile)) continue;
      $todo[$ext] = $dstfile;
    }
    if (count($todo) < 1) return;

    echo "teifile=",$teifile,"… ";


    if (isset($todo['epub'])) {
      echo "EPUB ";
      $dstfile = $todo['epub'];
      $livre = new Epub($teifile, STDERR);
      $livre->export($dstfile);
      $cmd = dirname(dirname(__FILE__))."/epub/kindlegen"." ".$dstfile;
      $output = '';
      $last = exec($cmd, $output, $status);
      if (!file_exists($dstpath.".mobi")) {
        self::log(E_USER_ERROR, "\n".$status."\n".join("\n", $output)."\n".$last."\n");
      }
    }

    $dom = Tools::dom($teifile);
    if (isset($todo['html'])) {
      echo "HTML ";
      $dstfile = $todo['html'];
      $theme = 'https://oeuvres.github.io/teinte/'; // where to find web assets like css and js for html file
      $xsl = dirname(dirname(__FILE__)).'/tei2html.xsl';
      $pars = array(
        'theme' => $theme,
      );
      Tools::transformDoc($dom, $xsl, $dstfile, $pars);
    }

    if (isset($todo['txt'])) {
      echo "MARKDOWN ";
      $dstfile = $todo['txt'];
      $xsl = dirname(dirname(__FILE__)).'/xsl/tei2md.xsl';
      Tools::transformDoc($dom, $xsl, $dstfile);
    }

    if (isset($todo['docx'])) {
      echo "DOCX ";
      Docx::export($teifile, $todo['docx']);
    }


    echo "…done\n";

  }

  public static function pdf($teifile, $dstdir='', $force=false)
  {

    if (!file_exists($teifile)) {
      echo "404 not found \"$teifile\"\n";
      return;
    }


    if ($dstdir) {
      $dstdir = rtrim($dstdir, '/\\').'/';
      if (!file_exists($dstdir)) {
        mkdir($dstdir, 0775, true);
        @chmod($dstdir, 0775);  // let @, if www-data is not owner but allowed to write
      }
    }
    $texname = basename($dstdir);
    $dstfile = $dstdir.$texname.'.pdf';
    if (file_exists($dstfile) && filemtime($teifile) < filemtime($dstfile)) return;

    $latex = new Latex();
    $latex->load($teifile);
    $texfile = $latex->setup(self::$skeltex, $texname); // get the texfile installed with its resources
    $workdir = dirname($texfile).'/';
    $cwd = getcwd();
    chdir($workdir); // change working directory
    exec("latexmk -xelatex -quiet -f ".$texname.'.tex');
    $tex = file_get_contents($texfile);
    if ($dstdir) {
      $src = $workdir.$texname.'.pdf';
      // echo $src,' -',file_exists($src), '- ', $dst, "\n";
      rename($src, $dstfile);
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
    $basedir = dirname(dirname(dirname(__FILE__))).'/bnr-obtic/';
    /*
    while($glob = array_shift($_SERVER['argv']) ) {
      foreach(glob($glob) as $teifile) {
        $name = pathinfo($teifile, PATHINFO_FILENAME);
        self::pdf(realpath($teifile), $basedir.$name);
        self::export(realpath($teifile), $basedir.$name);
      }
    }
    */
    $handle = fopen(dirname(__FILE__)."/corpus.tsv", "r");
    fgetcsv($handle, 0, "\t"); // passer la 1e ligne
    while (($data = fgetcsv($handle, 0, "\t")) !== FALSE) {
      $teifile = $data[0];
      $name = $data[1];
      if (!file_exists($teifile)) {
        echo "404 not found \"$teifile\"\n";
        continue;
      }
      self::export($teifile, $basedir.$name);
      self::pdf($teifile, $basedir.$name);
    }
  }
}

?>
