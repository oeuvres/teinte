<?php
set_time_limit(-1);
// included file, do nothing
if (isset($_SERVER['SCRIPT_FILENAME']) && basename($_SERVER['SCRIPT_FILENAME']) != basename(__FILE__));
else if (isset($_SERVER['ORIG_SCRIPT_FILENAME']) && realpath($_SERVER['ORIG_SCRIPT_FILENAME']) != realpath(__FILE__));
// direct command line call, work
else if (php_sapi_name() == "cli") Teinte_Doc::cli();

/**
 Sample pilot for Teinte transformations of XML/TEI

 */
class Teinte_Doc {
  /** TEI/XML DOM Document to process */
  public $dom;
  /** Xpath processor */
  public $xpath;
  /** filepath */
  public $file;
  /** filename without extension */
  public $filename;
  /** file freshness */
  public $filemtime;
  /** XSLTProcessor */
  private $_trans;
  /** XSL DOM document */
  private $_xsldom;
  /** Keep memory of last xsl, to optimize transformations */
  private $_xslfile;
  /** formats */
  static $_formats = array(
    'article' => '.html',
    'html' => '.html',
    'markdown' => '.md',
    'iramuteq' => '.txt',

  );
  /**
   * Constructor, load file and prepare work
   */
  public function __construct($teifile) {
    $this->_xsldom = new DOMDocument();
    if (is_a($teifile, 'DOMDocument') ) {
      $this->dom = $teifile;
      return;
    }
    $this->file = $teifile;
    $this->filemtime = filemtime($teifile);
    $this->filename = pathinfo($teifile, PATHINFO_FILENAME);
    $this->load($teifile);
  }
  /**
   *
   */
  public function export($format, $destfile=null) {
    if (isset(self::$_formats[$format])) return call_user_func(array($this, $format), $destfile);
    else if (STDERR) fwrite(STDERR, $format." ? format not yet implemented\n");
  }
  /**
   * Output toc
   */
   public function toc($root) {
     return $this->transform(
       dirname(__FILE__).'/tei2toc.xsl',
       null,
       array(
         'root'=> $root,
       )
     );
   }

  /**
   * Output an html fragment
   */
  public function article($destfile=null) {
    return $this->transform(
      dirname(__FILE__).'/tei2html.xsl',
      $destfile,
      array(
        'root'=> 'article',
      )
    );
  }
  /**
   * Output html
   */
  public function html($destfile=null, $theme = null) {
    if (!$theme) $theme = 'http://oeuvres.github.io/Teinte/'; // where to find web assets like css and js for html file
    return $this->transform(
      dirname(__FILE__).'/tei2html.xsl',
      $destfile,
      array(
        'theme'=> $theme,
      )
    );
  }
  /**
   * Output markdown
   */
  public function markdown($destfile=null) {
    return $this->transform(dirname(__FILE__).'/tei2md.xsl', $destfile);
  }
  /**
   * Output iramuteq text
   */
  public function iramuteq($destfile=null) {
    return $this->transform(dirname(__FILE__).'/tei2iramuteq.xsl', $destfile);
  }
  /**
   * Zip multipage ?
   */

  /**
   * An xslt transformer
   * TOTHINK : deal with errors
   */
  public function transform($xslfile, $destfile=null, $pars=null) {
    // allow reuse of same xsl for performances
    if ($this->_xslfile != $xslfile) {
      // load xsl file
      $this->_xsldom->load($xslfile);
      // renew the processor
      $this->_trans = new XSLTProcessor();
      $this->_trans->importStyleSheet($this->_xsldom);
    }
    // add params
    if(isset($pars) && count($pars)) {
      foreach ($pars as $key => $value) {
        $this->_trans->setParameter(null, $key, $value);
      }
    }
    if ($destfile) {
      $this->_trans->transformToURI($this->dom, $destfile);
      $ret = $destfile;
    }
    // no dst file, return dom, so that piping can continue
    else {
      $ret = $this->_trans->transformToXML($this->dom);
    }
    // reset parameters ! or they will kept on next transform if transformer is reused
    if(isset($pars) && count($pars)) {
      foreach ($pars as $key => $value) $this->_trans->removeParameter('', $key);
    }
    return $ret;
  }
  /**
   * load an XML/TEI document
   */
  public function load($xmlfile) {
    $this->dom = new DOMDocument();
    $this->dom->preserveWhiteSpace = false;
    $this->dom->formatOutput=true;
    $this->dom->substituteEntities=true;
    $this->dom->load($xmlfile, LIBXML_NOENT | LIBXML_NONET | LIBXML_NSCLEAN | LIBXML_NOCDATA | LIBXML_COMPACT | LIBXML_PARSEHUGE | LIBXML_NOERROR | LIBXML_NOWARNING);
    $this->xpath = new DOMXpath($this->dom);
    $this->xpath->registerNamespace('tei', "http://www.tei-c.org/ns/1.0");
  }
  /**
   * Command line transform
   */
  public static function cli() {
    $formats=implode('|', array_keys(self::$_formats));
    array_shift($_SERVER['argv']); // shift first arg, the script filepath
    if (!count($_SERVER['argv'])) exit('
    usage    : php -f Doc.php ($formats)? "*.xml" destdir/?
    format?  : optional dest format, default is html
    *.xml    : glob patterns are allowed, but in quotes, to not be expanded by shell
    destdir? : optional destdir
  ');
    $format="html";
    while ($arg=array_shift($_SERVER['argv'])) {
      if ($arg[0]=='-') $format=substr($arg,1);
      if(preg_match("/^($formats)\$/",$arg)) {
        $format=$arg;
      }
      else if(!isset($srcglob)) {
        $srcglob=$arg;
      }
      else if(!isset($destdir)) {
        $destdir=rtrim($arg, '\\/').'/';
        if (!file_exists($destdir)) mkdir($destdir, true);
      }
    }
    $count = 0;
    foreach(glob($srcglob) as $srcfile) {
      $count++;
      $destname = pathinfo($srcfile, PATHINFO_FILENAME).self::$_formats[$format];
      if (isset($destdir)) $destfile = $destdir.$destname;
      else $destfile=dirname($srcfile).'/'.$destname;
      if (STDERR) fwrite(STDERR, "$count. $srcfile > $destfile\n");
      $doc=new Teinte_Doc($srcfile);
      $doc->export($format, $destfile);
    }
  }

}
?>
