<?php
set_time_limit(-1);
// included file, do nothing
if (isset($_SERVER['SCRIPT_FILENAME']) && basename($_SERVER['SCRIPT_FILENAME']) != basename(__FILE__));
else if (isset($_SERVER['ORIG_SCRIPT_FILENAME']) && realpath($_SERVER['ORIG_SCRIPT_FILENAME']) != realpath(__FILE__));
// direct command line call, work
else if (php_sapi_name() == "cli") Teinte_Doc::cli();

/**
 * Sample pilot for Teinte transformations of XML/TEI
 */
class Teinte_Doc {
  /** TEI/XML DOM Document to process */
  private $_dom;
  /** Xpath processor */
  private $_xpath;
  /** filepath */
  private $_file;
  /** filename without extension */
  private $_filename;
  /** file freshness */
  private $_filemtime;
  /** XSLTProcessor */
  private $_trans;
  /** XSL DOM document */
  private $_xsldom;
  /** Keep memory of last xsl, to optimize transformations */
  private $_xslfile;
  /** formats */
  public static $ext = array(
    'article' => '.html',
    'html' => '.html',
    'markdown' => '.txt',
    'iramuteq' => '.txt',
    'naked' => '.txt',
  );
  /**
   * Constructor, load file and prepare work
   */
  public function __construct($tei) {
    if (is_a($tei, 'DOMDocument') ) {
      $this->_dom = $tei;
    }
    else if( is_string( $tei ) ) { // maybe file or url
      $this->_file = $tei;
      $this->_filemtime = filemtime($tei);
      $this->_filename = pathinfo($tei, PATHINFO_FILENAME);
      $this->_dom( $tei );
    }
    else {
      throw new Exception('Teinte, what is it? '.print_r($tei, true));
    }
    $this->_xsldom = new DOMDocument();
    $this->xpath();
  }

 /**
  * Set and return an XPath processor
  */
  public function xpath()
  {
    if ($this->_xpath) return $this->_xpath;
    $this->_xpath = new DOMXpath($this->_dom);
    $this->_xpath->registerNamespace('tei', "http://www.tei-c.org/ns/1.0");
    return $this->_xpath;
  }
  /**
   * Get the filename (with no extention)
   */
   public function filename( $filename=null )
   {
     if ( $filename ) $this->_filename = $filename;
     return $this->_filename;
   }
   /**
    * Read a readonly property
    */
    public function filemtime( $filemtime=null )
    {
      if ( $filemtime ) $this->_filemtime = $filemtime;
      return $this->_filemtime;
    }
  /**
   * Book metadata
   */
  public function meta() {
    $meta = array();
    $meta['code'] = pathinfo($this->_file, PATHINFO_FILENAME);

    $nl = $this->_xpath->query("/*/tei:teiHeader//tei:author");
    if (!$nl->length)
      $meta['creator'] = null;
    else if ($nl->item(0)->hasAttribute("key"))
      $meta['creator'] = $nl->item(0)->getAttribute("key");
    else
      $meta['creator'] = $nl->item(0)->textContent;
    if (($pos = strpos($meta['creator'], '('))) $meta['creator'] = trim(substr($meta['creator'], 0, $pos));
    // title
    $nl = $this->_xpath->query("/*/tei:teiHeader//tei:title");
    if ($nl->length) $meta['title'] = $nl->item(0)->textContent;
    else $meta['title'] = null;
    // publisher
    $nl = $this->_xpath->query("/*/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:publisher");
    if ($nl->length) $meta['publisher'] = $nl->item(0)->textContent;
    else $meta['publisher'] = null;
    // identifier
    $nl = $this->_xpath->query("/*/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno");
    if ($nl->length) $meta['identifier'] = $nl->item(0)->textContent;
    else $meta['identifier'] = null;
    // dates
    $nl = $this->_xpath->query("/*/tei:teiHeader/tei:profileDesc/tei:creation/tei:date");
    // loop on dates
    $meta['created'] = null;
    $meta['issued'] = null;
    $meta['date'] = null;
    foreach ($nl as $date) {
      $value = $date->getAttribute ('when');
      if (!$value) $value = $date->nodeValue;
      $value = substr(trim($value), 0, 4);
      if (!is_numeric($value)) {
        $value = null;
        continue;
      }
      if (!$meta['date']) $meta['date'] = $value;
      if ($date->getAttribute ('type') == "created" && !$meta['created']) $meta['created'] = $value;
      else if ($date->getAttribute ('type') == "issued" && !$meta['issued']) $meta['issued'] = $value;
    }
    if (!$meta['issued'] && isset($value) && is_numeric($value)) $meta['issued'] = $value;
    $meta['source'] = null;
    $meta['filename'] = $this->filename();
    $meta['filemtime'] = $this->filemtime();


    return $meta;
  }
  /**
   *
   */
  public function export($format, $destfile=null) {
    if (isset(self::$ext[$format])) return call_user_func(array($this, $format), $destfile);
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
  public function markdown( $destfile=null )
  {
    return $this->transform(dirname(__FILE__).'/tei2md.xsl', $destfile, array('filename' => $this->_filename));
  }
  /**
   * Output iramuteq text
   */
  public function iramuteq( $destfile=null )
  {
    return $this->transform(dirname(__FILE__).'/tei2iramuteq.xsl', $destfile);
  }
  /**
   * Output txm XML
   */
  public function txm( $destfile=null )
  {
    return $this->transform(dirname(__FILE__).'/tei4txm.xsl', $destfile);
  }
  /**
   * Output naked text
   */
  public function naked( $destfile=null )
  {
    $txt = $this->transform(dirname(__FILE__).'/tei2naked.xsl' );
    /* TRÈS MAUVAISE IDÉE
    $txt = preg_replace(
      array(
        "@([\s\(\[])(c|C|d|D|j|J|usqu|Jusqu|l|L|lorsqu|m|M|n|N|puisqu|Puisqu|qu|Qu|quoiqu|Quoiqu|s|S|t|T)['’]@u",
      ),
      array(
        '$1$2e '
      ),
      $txt
    );
    */
    if ( !$destfile ) return $txt;
    file_put_contents( $destfile, $txt );
    return $destfile;
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
  public function transform($xslfile, $dest=null, $pars=null)
  {
    // allow reuse of same xsl for performances
    if ( $this->_xslfile != $xslfile ) {
      // load xsl file
      $this->_xsldom->load( $xslfile );
      // renew the processor
      $this->_trans = new XSLTProcessor();
      $this->_trans->importStyleSheet( $this->_xsldom );
    }
    // add params
    if(isset($pars) && count($pars)) {
      foreach ($pars as $key => $value) {
        $this->_trans->setParameter( null, $key, $value );
      }
    }
    // return a DOM document for efficient piping
    if (is_a($dest, 'DOMDocument') ) {
      $ret = $this->_trans->transformToDoc( $this->_dom );
    }
    else if ($dest) {
      if (!is_dir(dirname($dest))) {
        mkdir(dirname($dest), 0775, true);
        @chmod(dirname($dest), 0775);  // let @, if www-data is not owner but allowed to write
      }
      $this->_trans->transformToURI( $this->_dom, $dest );
      $ret = $dest;
    }
    // no dst file, return String
    else {
      $ret = $this->_trans->transformToXML( $this->_dom );
    }
    // reset parameters ! or they will kept on next transform if transformer is reused
    if(isset($pars) && count($pars)) {
      foreach ( $pars as $key => $value ) $this->_trans->removeParameter(null, $key);
    }
    return $ret;
  }
  /**
   * Set and build a dom privately
   */
  private function _dom( $xmlfile ) {
    $this->_dom = new DOMDocument();
    $this->_dom->preserveWhiteSpace = false;
    $this->_dom->formatOutput=true;
    $this->_dom->substituteEntities=true;
    $this->_dom->load($xmlfile, LIBXML_NOENT | LIBXML_NONET | LIBXML_NSCLEAN | LIBXML_NOCDATA | LIBXML_COMPACT | LIBXML_PARSEHUGE | LIBXML_NOWARNING);
    return $this->_dom;
  }
  /**
   * Get the dom
   */
  public function dom() {
    return $this->_dom;
  }

  /**
   * Command line transform
   */
  public static function cli() {
    $formats=implode( '|', array_keys( self::$ext ) );
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
        $destname = pathinfo($srcfile, PATHINFO_FILENAME).self::$ext[$format];
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
