<?php
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
  /** 
   * Constructor, load file and prepare work
   */
  public function __construct($teifile) {
    $this->file = $teifile;
    $this->filemtime = filemtime($teifile);
    $this->filename = pathinfo($teifile, PATHINFO_FILENAME);
    $this->load($teifile);
    $this->_xsldom = new DOMDocument();
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
  public function md($destfile=null) {
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
      $ret = $this->_trans->transformToDoc($this->dom);
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
}
?>
