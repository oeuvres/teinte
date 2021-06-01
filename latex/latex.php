<?php 
include dirname(dirname(__FILE__)).'/teidoc.php';
set_time_limit(-1);
// included file, do nothing
if (isset($_SERVER['SCRIPT_FILENAME']) && basename($_SERVER['SCRIPT_FILENAME']) != basename(__FILE__));
else if (isset($_SERVER['ORIG_SCRIPT_FILENAME']) && realpath($_SERVER['ORIG_SCRIPT_FILENAME']) != realpath(__FILE__));
// direct command line call, work
else if (php_sapi_name() == "cli") Latex::cli();

/**
 * Transform a 
 */
class Latex {
  protected $dom;
  protected $srcfile;
  static protected $template;
  static protected $latex_xsl;
  static protected $latex_meta_xsl;
  // escape all text nodes 
  static protected $latex_esc = array(
    '@\s+@u' => ' ',
    '@\\\@u' => '\textbackslash', // avant les échappements
    '@(&amp;)@u' => '\\\$1',
    '@([%\$#_{}])@u' => '\\\$1',
    '@~@u' => '\textasciitilde',
    '@\^@u' => '\textasciicircum',
  );
  
  public function __construct() {
    $this->dom = new DOMDocument("1.0", "UTF-8");
    $this->dom->preserveWhiteSpace = false;
    $this->dom->formatOutput=true;
    $this->dom->substituteEntities=true;
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
    if (!self::$template) {
      self::$template = file_get_contents(dirname(__FILE__)."/template.tex");
    }
  }
  
  function load($srcfile)
  {
    $this->srcfile = $srcfile;
    $xml = file_get_contents($srcfile);
    $this->loadXML($xml);
  }
  function loadXML($xml)
  {
    $xml = preg_replace(array_keys(self::$latex_esc), array_values(self::$latex_esc), $xml);
    $this->dom->loadXML($xml,  LIBXML_NOENT | LIBXML_NONET | LIBXML_NOWARNING ); // no warn for <?xml-model
  }
  function dom($dom)
  {
    $xpath = new DOMXPath($dom);
    $textnodes = $xpath->query('//text()');
    // TODO, replace text nodes
    $this->dom = $dom;
  }
  /** generate tex and pdf */
  function export($dstfile) 
  {
    $meta = self::$latex_meta_xsl->transformToXml($this->dom);
    $tei = self::$latex_xsl->transformToXml($this->dom);
    $tex = str_replace(
      array('%meta%', '%tei%'), 
      array($meta, $tei),
      self::$template
    );
    file_put_contents($dstfile, $tex);
    //  latexmk -xelatex -quiet -f vaneigem1967_savoir-vivre.tex 
  }
  
  public static function cli() 
  {
    array_shift($_SERVER['argv']); // shift first arg, the script filepath
    if (!count($_SERVER['argv'])) exit("
usage    : php -f latex.php (dstdir/)? srcdir/*.xml\n");

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
      foreach(glob($glob) as $srcfile) {
        $filename = pathinfo($srcfile, PATHINFO_FILENAME);
        if ($dstdir) $dstname = $dstdir.$filename;
        else $dstname = dirname($srcfile).'/'.$filename;
        $latex->load($srcfile);
        echo "$srcfile > $dstname(.tex|.pdf)\n";
        $latex->export($dstname.'.tex');
      }
    }

  }

}
?>
