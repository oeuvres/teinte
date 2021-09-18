<?php
include_once(dirname(dirname(__FILE__)).'/teidoc.php');
include_once(dirname(dirname(__FILE__)).'/php/tools.php');
set_time_limit(-1);
if (isset($argv[0]) && realpath($argv[0]) == realpath(__FILE__)) Latex::cli(); // direct CLI

/**
 * Transform an XML/TEI file in LaTeX
 */
class Latex {
  public $dom; // dom prepared for TeX (escapings, images)
  protected $srcfile;
  static protected $latex_xsl;
  static protected $latex_meta_xsl;
  // escape all text nodes
  static public $latex_esc = array(
    '@\\\@u' => '\textbackslash', //before adding \ for escapings
    '@(&amp;)@u' => '\\\$1',
    '@([%\$#_{}])@u' => '\\\$1',
    '@~@u' => '\textasciitilde',
    '@\^@u' => '\textasciicircum',
    '@(<pb[^>]*>)\s+@' => '$1', // page breaks may add unwanted space
    '@(\p{Han}[\p{Han} ]+)@u' => '\zh{$1}',
    '@\s+@' => ' ', // not unicode \s, keep unbreakable space
  );

  public function __construct() {
    if (!self::$latex_xsl) {
      $xsl = new DOMDocument("1.0", "UTF-8");
      $xsl->load(dirname(__FILE__).'/latex.xsl');
      self::$latex_xsl = new XSLTProcessor();
      self::$latex_xsl->importStyleSheet($xsl);
    }
    if (!self::$latex_meta_xsl) {
      $xsl = new DOMDocument("1.0", "UTF-8");
      $xsl->load(dirname(__FILE__).'/latex_meta.xsl');
      self::$latex_meta_xsl = new XSLTProcessor();
      self::$latex_meta_xsl->importStyleSheet($xsl);
    }
  }

  static function isPathAbs($path)
  {
    if (!$path) return false;
    if ($path[0] === DIRECTORY_SEPARATOR || preg_match('~\A[A-Z]:(?![^/\\\\])~i',$path) > 0) return true;
    return false;
  }

  /**
   * resolve tex inclusions and image links
   *
   * $texfile: ! path to a tex file
   * $workdir: ? destination dir place where the tex will be processed.
   * $grafdir: ? a path where to put graphics, relative to workdir or absolute.
   *
   * If resources are found, they are copied in grafdir, and tex is rewrite in consequence.
   * No suport for \graphicspath{⟨dir⟩+}
   */
  static function includes($texfile, $workdir=null, $grafdir="")
  {
    $srcdir = dirname($texfile);
    if ($srcdir) $srcdir = rtrim($srcdir, '/\\').'/';
    if ($workdir) $workdir = rtrim($workdir, '/\\').'/';
    if ($grafdir) $grafdir = rtrim($grafdir, '/\\').'/';
    $tex = file_get_contents($texfile);

    // rewrite graphix links and copy resources
    // \includegraphics[width=\columnwidth]{bandeau.pdf}
    $grafabs = null;
    if ($workdir) {
      // same folder
      if (!$grafdir);
      // absolute path
      else if (self::isPathAbs($grafdir)){
        $grafabs = $grafdir;
      }
      else {
        $grafabs = $workdir.$grafdir;
      }
    }
    $tex = preg_replace_callback(
      '@(\\\includegraphics[^{]*){(.*?)}@',
      function($matches) use($srcdir, $workdir, $grafdir, $grafabs) {
        $imgfile = $matches[2];
        if (!self::isPathAbs($grafdir)) $imgfile = $srcdir.$imgfile;
        $imgbname = basename($imgfile);
        $replace = $matches[0];
        if (!file_exists($imgfile)) {
          fwrite(STDERR, "graphics not found: $imgfile\n");
        }
        else if ($workdir) {
          if (!is_dir($grafabs)) mkdir($grafabs, 0777, true); // create img folder only if needed
          copy($imgfile, $grafabs.$imgbname);
          $replace = $matches[1].'{'.$grafdir.$imgbname.'}';
        }
        return $replace;
      },
      $tex
    );
    // \input{../latex/teinte}
    $tex = preg_replace_callback(
      '@\\\input *{(.*?)}@',
      function($matches) use($srcdir, $workdir, $grafdir) {
        $inc = $srcdir.$matches[1].'.tex';
        return self::includes($inc, $workdir, $grafdir);
      },
      $tex
    );

    return $tex;
  }

  /**
   * Escape XML/TEI for LaTeX
   */
  static function dom($teifile)
  {
    $dom = new DOMDocument("1.0", "UTF-8");
    $dom->preserveWhiteSpace = true;
    // $dom->formatOutput=true; // bug on some nodes LIBERTÉ 9 mai. ÉGALITÉ
    $dom->substituteEntities=true;
    $xml = file_get_contents($teifile);
    $xml = preg_replace(array_keys(self::$latex_esc), array_values(self::$latex_esc), $xml);
    $dom->loadXML($xml,  LIBXML_NOENT | LIBXML_NONET | LIBXML_NOWARNING ); // no warn for <?xml-model
    return $dom;
  }

    /**
   * Extract <graphic> elements from a DOM doc, copy images in a flat dstdir
   * $dom : a TEI dom doc, image links will be modified
   * $dstdir : a folder where to copy images
   * $basehref : a basehref prefix to rewrite image link, user knows how to resolve links to image
   * return : a doc with updated links to image
   */
  public function teigraf($grafdir=null, $grafhref=null)
  {
    if ($grafdir) $grafdir=rtrim($grafdir, '/\\').'/';
    // copy linked images in an images folder, and modify relative link
    // $dom=$dom->cloneNode(true); // if we want to keep original dom
    foreach ($this->dom->getElementsByTagNameNS('http://www.tei-c.org/ns/1.0', 'graphic') as $el) {
      $this->teigrafatt($el->getAttributeNode("url"), $grafdir, $grafhref);
    }
    /*
    do not store images of pages, especially in tif
    foreach ($doc->getElementsByTagNameNS('http://www.tei-c.org/ns/1.0', 'pb') as $el) {
      $this->img($el->getAttributeNode("facs"), $hrefTei, $dstdir, $hrefSqlite);
    }
    */
  }
  /**
   * Process one image
   */
  public function teigrafatt($att, $grafdir=null, $grafhref="")
  {
    if (!isset($att) || !$att || !$att->value) return;
    $url=$att->value;
    $url=str_replace('\\', '', $url);
    // image data, do nothing
    if (strpos($url, 'data:image') === 0) return;

    // if abolute url, OK
    if (strpos($url, 'http') === 0) {

    }
    // test if relative file path
    else if (file_exists($test=dirname($this->srcfile).'/'.$url)) {
      $url=$test;
    }
    /*
      // vendor specific etc/filename.jpg
    else if ( $this->p['srcdir']
      && file_exists( $test = $this->p['srcdir'].$this->p['filename'].'/'.substr($src, strpos($src, '/')+1) )
    ) $src = $test;
    */
    // if not file exists, escape and alert (?)
    else if ( !file_exists( $url ) ) {
      Tools::log( "Image not found: ".$url );
      return;
    }
    $srcParts=pathinfo($url);
    // if dstdir requested, copy
    if (isset($grafdir)) {
      // destination
      $i=2;
      // avoid duplicated files
      while (file_exists($grafdir.$srcParts['basename'])) {
        $srcParts['basename']=$srcParts['filename'].'-'.$i.'.'.$srcParts['extension'];
        $i++;
      }
      copy($url, $grafdir.$srcParts['basename']);
    }
    // changes links in TEI so that straight transform will point on the right files
    $att->value=$grafhref.$srcParts['basename'];
    // resize ?
    // NO delete of <graphic> element if broken link
  }


  function load($srcfile)
  {
    $this->srcfile = $srcfile;
    $this->dom = self::dom($srcfile);
  }

  static function workdir($teifile)
  {
    // tmp directory, will be kept for a while for debug
    // temp_name is unique by file, avoid parallel
    $filename = pathinfo($teifile, PATHINFO_FILENAME);
    $workdir = sys_get_temp_dir().'/teinte/'.$filename.'/';
    if (!is_dir($workdir)) mkdir($workdir, 0777, true);
    return $workdir;
  }

  /**
   * Setup pdf compilation : generate a tex from tei
   * $skelfile is a requested tex template
   */
  function setup($skelfile)
  {
    $filename = pathinfo($this->srcfile, PATHINFO_FILENAME);
    $workdir = self::workdir($this->srcfile);

    $grafdir = $workdir.$filename.'/';
    Tools::dirclean($grafdir); // empty graf dir

    // resolve includes and graphics of tex template
    $tex = Latex::includes($skelfile, $workdir, $grafdir);
    // resolve image links in tei source
    $this->teigraf($grafdir, $filename.'/');
    $this->dom->save($workdir.$filename.'.xml'); // for debug, save a copy of XML


    $meta = self::$latex_meta_xsl->transformToXml($this->dom);
    $text = self::$latex_xsl->transformToXml($this->dom);


    $texfile = $workdir.$filename.'.tex';
    file_put_contents(
      $texfile,
      str_replace(
        array('%meta%', '%text%'),
        array($meta, $text),
        $tex,
      )
    );
    // create a special tex with meta only ?
    file_put_contents(
      $workdir.$filename.'_cover.tex',
      str_replace('%meta%', $meta, $tex),
    );
    return $texfile;
  }

  public static function cli()
  {
    array_shift($_SERVER['argv']); // shift first arg, the script filepath
    if (!count($_SERVER['argv'])) exit("
usage    : php -f latex.php teidir/*.xml\n");

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

    $latex = new Latex();
    while($glob = array_shift($_SERVER['argv']) ) {
      foreach(glob($glob) as $teifile) {
        $latex->load($teifile); // load tei
        $texfile = $latex->setup(dirname(__FILE__).'/test.tex'); // install tex template
        $texname = pathinfo($texfile, PATHINFO_FILENAME);
        $workdir = dirname($texfile).'/';
        echo "$teifile > $workdir/$texname(.tex|.pdf)\n";
        chdir($workdir); // change working directory
        // exec CLI xelatex
        exec("latexmk -xelatex -quiet -f ".$texname.'.tex');
      }
    }

  }

}
?>
