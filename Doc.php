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
  public function __construct($tei) {
    if (is_a($tei, 'DOMDocument') ) {
      $this->dom = $tei;
    }
    else if(file_exists($tei)) {
      $this->file = $tei;
      $this->filemtime = filemtime($tei);
      $this->filename = pathinfo($tei, PATHINFO_FILENAME);
      $this->dom = self::dom($tei);
    }
    else {
      throw new Exception('Teinte, what is it? '.print_r($tei, true));
    }
    $this->_xsldom = new DOMDocument();
    $this->xpath = new DOMXpath($this->dom);
    $this->xpath->registerNamespace('tei', "http://www.tei-c.org/ns/1.0");
  }
  /**
   * Book metadata
   */
  public function meta() {
    $meta = array();
    $meta['code'] = pathinfo($this->file, PATHINFO_FILENAME);

    $nl = $this->xpath->query("/*/tei:teiHeader//tei:author");
    if (!$nl->length)
      $meta['author'] = null;
    else if ($nl->item(0)->hasAttribute("key"))
      $meta['author'] = $nl->item(0)->getAttribute("key");
    else
      $meta['author'] = $nl->item(0)->textContent;
    if (($pos = strpos($meta['author'], '('))) $meta['author'] = trim(substr($meta['author'], 0, $pos));

    $nl = $this->xpath->query("/*/tei:teiHeader//tei:title");
    if ($nl->length) $meta['title'] = $nl->item(0)->textContent;
    else $meta['title'] = null;


    $nl = $this->xpath->query("/*/tei:teiHeader/tei:profileDesc/tei:creation/tei:date");
    // loop on dates
    $meta['created'] = null;
    $meta['issued'] = null;
    $meta['year'] = null;
    foreach ($nl as $date) {
      $value = $date->getAttribute ('when');
      if (!$value) $value = $date->nodeValue;
      $value = substr(trim($value), 0, 4);
      if (!is_numeric($value)) continue;
      if ($date->getAttribute ('type') == "created" && !$meta['created']) $meta['created'] = $value;
      else if ($date->getAttribute ('type') == "issued" && !$meta['issued']) $meta['issued'] = $value;
      $value = null;
    }
    // dates with no attribute
    if (!$meta['created'] && isset($value) && is_numeric($value)) $meta['created'] = $value;




    return $meta;
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
    return $this->transform(dirname(__FILE__).'/tei2md.xsl', $destfile, array('filename' => $this->filename));
  }
  /**
   * Output iramuteq text
   */
  public function iramuteq($destfile=null) {
    return $this->transform(dirname(__FILE__).'/tei2iramuteq.xsl', $destfile);
  }
  /**
   * Preprocess TEI with a transformation
   */
   public function pre($xslfile, $pars=null) {
     $this->dom = $this->transform($xslfile, new DOMDocument(), $pars);
   }

  /**
   * An xslt transformer
   * TOTHINK : deal with errors
   */
  public function transform($xslfile, $dest=null, $pars=null) {
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
    if (is_a($dest, 'DOMDocument') ) {
      $ret = $this->_trans->transformToDoc($this->dom);
    }
    else if ($dest) {
      if (!is_dir(dirname($dest))) {
        mkdir(dirname($dest), 0775, true);
        @chmod(dirname($dest), 0775);  // let @, if www-data is not owner but allowed to write
      }
      $this->_trans->transformToURI($this->dom, $dest);
      $ret = $dest;
    }
    // no dst file, return dom, so that piping can continue
    else {
      $ret = $this->_trans->transformToXML($this->dom);
    }
    // reset parameters ! or they will kept on next transform if transformer is reused
    if(isset($pars) && count($pars)) {
      foreach ($pars as $key => $value) $this->_trans->removeParameter(null, $key);
    }
    return $ret;
  }
  public static function dom($xmlfile) {
    $dom = new DOMDocument();
    $dom->preserveWhiteSpace = false;
    $dom->formatOutput=true;
    $dom->substituteEntities=true;
    $dom->load($xmlfile, LIBXML_NOENT | LIBXML_NONET | LIBXML_NSCLEAN | LIBXML_NOCDATA | LIBXML_COMPACT | LIBXML_PARSEHUGE | LIBXML_NOWARNING);
    return $dom;
  }

  /**
   * Command line transform
   */
  public static function cli() {
    $formats=implode('|', array_keys(self::$_formats));
    array_shift($_SERVER['argv']); // shift first arg, the script filepath
    if (!count($_SERVER['argv'])) exit('
    usage     : php -f Doc.php ('.$formats.')? destdir/? "*.xml"
    format?   : optional dest format, default is html
    destdir/? : optional destdir
    *.xml     : glob patterns are allowed, with or without quotes, to not be expanded by shell

');

    $format="html";
    if( preg_match( "/^($formats)\$/", trim($_SERVER['argv'][0], '- ') )) {
      $format = array_shift($_SERVER['argv']);
      $format = trim($format, '- ');
    }

    $lastc = substr($_SERVER['argv'][0], -1);
    if ('/' == $lastc || '\\' == $lastc) {
      $destdir = array_shift($_SERVER['argv']);
      $destdir = rtrim($destdir, '/\\').'/';
      if (!file_exists($destdir)) {
        mkdir($destdir, 0775, true);
        @chmod($dir, 0775);  // let @, if www-data is not owner but allowed to write
      }
    }


    $count = 0;
    foreach ($_SERVER['argv'] as $glob) {
      foreach(glob($glob) as $srcfile) {
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
}
?>
