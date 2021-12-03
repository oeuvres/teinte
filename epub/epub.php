<?php  // encoding="UTF-8"
/**
 *
 * © 2013–2017 frederic.glorieux@fictif.org et LABEX OBVIL
 * © 2012–2013 frederic.glorieux@fictif.org
 * LGPL http://www.gnu.org/licenses/lgpl.html
 *
 */
include_once(dirname(dirname(__FILE__)).'/php/tools.php');

/**
 * Transform TEI in epub
 */
// cli usage
set_time_limit(-1);
if(ini_get('date.timezone')) date_default_timezone_set(ini_get('date.timezone'));
else date_default_timezone_set("Europe/Paris");

if (realpath($_SERVER['SCRIPT_FILENAME']) != realpath(__FILE__)); // file is include do nothing
else if (php_sapi_name() == "cli") {
  Epub::cli();
}

class Epub
{
  /** Static parameters, used for example to communicate between XSL tests and calls */
  public $p=array(
    "workdir" => null, // where to produce genrated files
    "srcdir" => null, // the folder of the source TEI file if XML given by file
    "filename" => null, // the name of the file to output
  );
  /** file path of source document, used to resolve relative links accros methods */
  private $_srcfile;
  /** Source DOM document for TEI file */
  private $_dom;
  /** Xpath processor */
  private $_xpath;
  /** Log level, should be static for the xsl callback */
  private static $debug;
  /** time counter, should be static for the xsl callback */
  private static $_time;
  /** A logger, maybe a stream or a callable, used by self::log() */
  private static $_logger;
  /** XSLT transformer */
  private $_trans;
  /** DOM of an XSLT sheet */
  private $_xsl;
  /** Different predefined sizes for covers  */
  private static $_size=array(
    "small"=>array(150,200),
    "medium"=>array(500,700),
  );



  /**
   * Constructor, initialize what is needed
   */
  public function __construct($srcfile, $logger=null, $pars=array())
  {
    if ( !is_array($pars) ) $pars=array();
    $this->p = array_merge( $this->p, $pars);
    if ( is_a( $srcfile, 'DOMDocument' ) ) {
      $this->_dom = $srcfile;
    }
    else {
      $this->_srcfile=$srcfile;
      $this->p['srcdir'] = dirname( $srcfile ).'/';
      if ( !$this->p['filename'] ) $this->p['filename'] = pathinfo( $srcfile, PATHINFO_FILENAME );
    }
    // if ( $this->p['srcdir'] && is_writable( $this->p['srcdir'] ) ) $this->p['workdir'] = $this->p['srcdir'];
    $this->p['workdir'] = sys_get_temp_dir().'/Livrable/';
    if ( !file_exists( $this->p['workdir'] ) ) {
      if ( !@mkdir( $this->p['workdir'], 0777, true ) ) exit( $dir." impossible à créer.\n");
      @chmod( $this->p['workdir'], 0777 );  // let @, if www-data is not owner but allowed to write
    }

    self::$_time = microtime(true);
    self::$_logger=$logger;
    $this->_xsl = new DOMDocument();
    // inialize an XSLTProcessor
    $this->_trans = new XSLTProcessor();
    $this->_trans->registerPHPFunctions();
    // allow generation of <xsl:document>
    if (defined('XSL_SECPREFS_NONE')) $prefs = XSL_SECPREFS_NONE;
    else if (defined('XSL_SECPREF_NONE')) $prefs = XSL_SECPREF_NONE;
    else $prefs = 0;
    if(method_exists($this->_trans, 'setSecurityPreferences')) $oldval = $this->_trans->setSecurityPreferences( $prefs);
    else if(method_exists($this->_trans, 'setSecurityPrefs')) $oldval = $this->_trans->setSecurityPrefs( $prefs);
    else ini_set("xsl.security_prefs",  $prefs);
  }
  /**
   * Load sourceFile
   */
  public function load()
  {
    if ($this->_srcfile) {
      // for the source doc
      $this->_dom=new DOMDocument("1.0", "UTF-8");
      // normalize indentation of XML before all processing
      $xml=file_get_contents($this->_srcfile);
      $xml=preg_replace(array('@\r\n@', '@\r@', '@\n[ \t]+@'), array("\n", "\n", "\n"), $xml);
      // $this->doc->recover=true; // no recover, display errors
      // LIBXML_PARSEHUGE inconnu en Centos 5.1
      if(!$this->_dom->loadXML($xml, LIBXML_NOENT | LIBXML_NONET | LIBXML_NOWARNING | LIBXML_NSCLEAN |  LIBXML_COMPACT  )) {
         self::log("XML error ".$this->_srcfile."\n");
         return false;
      }
    }
    // load
    $this->_dom->preserveWhiteSpace = false;
    $this->_dom->formatOutput = true;
    if ($this->_srcfile) $this->_dom->documentURI = realpath($this->_srcfile);
    // should resolve xinclude
    $this->_dom->xinclude(LIBXML_NOENT | LIBXML_NONET | LIBXML_NOWARNING | LIBXML_NOERROR | LIBXML_NSCLEAN | LIBXML_PARSEHUGE); //

    self::log(E_USER_NOTICE, 'load '. round(microtime(true) - self::$_time, 3)." s.");
    // @xml:id may be used as a href path, example images
    $this->p['xmlid'] = $this->_dom->documentElement->getAttributeNS( 'http://www.w3.org/XML/1998/namespace', 'id' );
    $this->p['n'] = $this->_dom->documentElement->getAttribute( 'n' );
    if ( $this->p['filename'] ); // OK
    else if ( $this->p['n'] ) $this->p['filename'] = $this->p['n'];
    else if ( $this->p['xmlid'] ) $this->p['filename'] = $this->p['xmlid'];
    else $this->p['filename'] = "unlivre";
    return $this->_dom;
  }

  /**
   * Generate an epub from a TEI file
   */
  public function export($dstfile=null, $template=null)
  {
    if ( $dstfile );
    // if no dstfile and srcfile, build aside srcfile
    else if ( $this->p['srcdir'] && $this->p['filename'] && is_writable( $this->p['srcdir'] ) ) $dstfile=$this->p['srcdir'].$this->p['filename'].'.epub';
    // in tmp dir
    else  if ( $this->p['filename'] ) $dstfile = $this->p['workdir'].$this->p['filename'].'.epub';
    if( !$template ) $template = dirname(__FILE__).'/template-epub/';
    $imagesdir = 'Images/';
    $timeStart = microtime(true);
    if ( !$this->_dom ) $this->load(); // srcdoc may have been modified before (ex: naked version)
    // loading problem
    if ( !$this->_dom ) return false;
    $dstinfo = pathinfo( $dstfile );
    // for multi user rights and name collision, a random name ?
    $dstdir = $this->p['workdir'].'/'.$dstinfo['filename'].'-epub/';
    Tools::dirclean($dstdir); // create a clean directory
    $dstdir=str_replace('\\', '/', realpath( $dstdir ) . '/'); // absolute path needed for xsl

    // copy the template folder
    Tools::rcopy($template, $dstdir);
    // check if there is a colophon where to write a date
    if (file_exists($f = $dstdir.'OEBPS/colophon.xhtml')) {
      $cont = file_get_contents($f);
      /*
      $xpath = $this->xpath();
      $nl = $xpath->query("/"."*"."/tei:teiHeader//tei:idno");
      if (!$nl->length) $idno = '';
      else $idno = $nl->item(0)->textContent;
      $cont = str_replace("%idno%", $idno, $cont);
      */
      $cont = str_replace("%date%", strftime("%d/%m/%Y"), $cont);
      file_put_contents($f, $cont);
    }

    // get the content.opf template
    $opf =  $template . 'OEBPS/.content.opf';
    if (file_exists($f = $template . 'OEBPS/content.opf')) $opf = $f;
    $opf = str_replace('\\', '/', realpath($opf));

    // copy source Dom to local, before modification by images
    // copy referenced images (received modified doc after copy)
    $doc=$this->images( $this->_dom, $imagesdir, $dstdir.'OEBPS/' . $imagesdir );
    self::log(E_USER_NOTICE, 'epub, images '. round(microtime(true) - self::$_time, 3)." s.\n");
    // cover logic, before all generators
    $params['cover'] = null;
    $cover=false;
    if ( !$this->p['srcdir'] || !$this->p['filename'] );
    else if ( file_exists( $this->p['srcdir'].$this->p['filename'].'.png' )) $cover = $this->p['filename'].'.png';
    else if ( file_exists( $this->p['srcdir'].$this->p['filename'].'.jpg' )) $cover = $this->p['filename'].'.jpg';
    if ( $cover ) {
      Tools::dirclean( $dstdir.'OEBPS/' . $imagesdir );
      copy( $this->p['srcdir'].$cover, $dstdir.'OEBPS/'.$imagesdir.$cover);
    }
    if ($cover) $params['cover'] = $imagesdir.$cover;
    $params['_html'] = '.xhtml';
    // create xhtml pages
    $report = self::transform(
      dirname(__FILE__).'/tei2epub.xsl',
      $doc,
      null,
      array(
        'dstdir' => $dstdir.'OEBPS/',
        '_html' => $params['_html'],
        'opf' => $opf,
        "cover" => $params['cover'],
      )
    );
    // opf file
    self::transform(
      dirname(__FILE__).'/tei2opf.xsl',
      $doc,
      $dstdir.'OEBPS/content.opf',
      array(
        '_html' => $params['_html'],
        'opf' => $opf,
        "cover" => $params['cover'],
        // 'filename' => $this->p['filename'],
      )
    );
    self::log( E_USER_NOTICE, 'epub, opf '. round(microtime(true) - self::$_time, 3)." s." );
    /* ncx not needed in epub3 but useful under firefox epubreader */
    self::transform(
      dirname(__FILE__).'/tei2ncx.xsl',
      $doc,
      $dstdir.'OEBPS/toc.ncx',
      array(
        '_html'=> $params['_html'],
        'opf' => $opf,
        "cover" => $params['cover'],
        // 'filename' => $this->p['filename'],
      )
    );
    self::log( E_USER_NOTICE, 'epub, ncx '. round(microtime(true) - self::$_time, 3)." s." );
    // because PHP zip do not yet allow store without compression (PHP7)
    // an empty epub is prepared with the mimetype
    copy( realpath(dirname(__FILE__)).'/mimetype.epub', $dstfile );

    // zip the dir content
    $dir = dirname( $dstfile );
    if ( !file_exists( $dir ) ) {
      if ( !@mkdir( $dir, 0775, true ) ) exit( $dir." impossible à créer.\n");
      @chmod( $dir, 0775 );  // let @, if www-data is not owner but allowed to write
    }
    self::zip($dstfile, $dstdir);
    if ( !self::$debug ) { // delete tmp dir if not debug
      Tools::dirclean($dstdir); // this is a strange behaviour, new dir will empty dir
      rmdir( $dstdir );
    }
    // shall we return entire content of the file ?
    return $dstfile;
  }
  /**
   * Extract <graphic> elements from a DOM doc, copy images in a flat dstdir
   * $soc : a TEI dom doc, retruned with modified image links
   * $href : a href prefix to redirest generated links
   * $dstdir : a folder if images should be copied
   * return : a doc with updated links to image
   */
  public function images($doc, $href=null, $dstdir=null)
  {
    if ($dstdir) $dstdir=rtrim($dstdir, '/\\').'/';
    // copy linked images in an images folder, and modify relative link
    // take $doc by reference
    $doc=$doc->cloneNode(true);
    foreach ($doc->getElementsByTagNameNS('http://www.tei-c.org/ns/1.0', 'graphic') as $el) {
      $this->img($el->getAttributeNode("url"), $href, $dstdir);
    }
    /*
    do not store images of pages, especially in tif
    foreach ($doc->getElementsByTagNameNS('http://www.tei-c.org/ns/1.0', 'pb') as $el) {
      $this->img($el->getAttributeNode("facs"), $hrefTei, $dstdir, $hrefSqlite);
    }
    */
    return $doc;
  }
  /**
   * Process one image
   */
  public function img($att, $hrefdir="", $dstdir=null)
  {
    if (!isset($att) || !$att || !$att->value) return;
    $src=$att->value;
    // return if data image
    if (strpos($src, 'data:image') === 0) return;

    // test if relative file path
    if (file_exists($test=dirname($this->_srcfile).'/'.$src)) $src=$test;
    // vendor specific etc/filename.jpg
    else if ( $this->p['srcdir']
      && file_exists( $test = $this->p['srcdir'].$this->p['filename'].'/'.substr($src, strpos($src, '/')+1) )
    ) $src = $test;
    // if not file exists, escape and alert (?)
    else if ( !file_exists( $src ) ) {
      $this->log( "Image not found: ".$src );
      return;
    }
    $srcParts=pathinfo($src);
    // test first if dst dir (example, epub for sqlite)
    if (isset($dstdir)) {
      // create images folder only if images detected
      if (!file_exists($dstdir)) Tools::dirclean($dstdir);
      // destination
      $i=2;
      // avoid duplicated files
      while (file_exists($dstdir.$srcParts['basename'])) {
        $srcParts['basename']=$srcParts['filename'].'-'.$i.'.'.$srcParts['extension'];
        $i++;
      }
      copy( $src, $dstdir.$srcParts['basename']);
    }
    // changes links in TEI so that straight transform will point on the right files
    $att->value=$hrefdir.$srcParts['basename'];
    // resize ?
    // NO delete of <graphic> element if broken link
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
   * Transform a doc with the provided xslt
   */
  public function transform($xsl, $doc=null, $dst=null, $pars=array())
  {
    if (!is_array($pars)) $pars=array();
    if (!isset($pars['debug'])) $pars['debug'] = self::$debug;
    if (!$doc && isset($this)) {
      $this->load();
      $doc = $this->_dom;
    }
    $this->_trans->removeParameter('', '_html');
    $this->_xsl->load($xsl);
    $this->_trans->importStyleSheet($this->_xsl);
    // transpose params
    if(isset($pars) && count($pars)) {
      foreach ($pars as $key => $value) {
        if (!$value) $value = "";
        $this->_trans->setParameter(null, $key, $value);
      }
    }
    $ret=true;
    // changing error_handler allow redirection of <xsl:message>, default behavior is output lines to workaround apache timeout
    $oldError=set_error_handler(array(__CLASS__,"log"));
    // one output
    if ($dst) $this->_trans->transformToURI($doc, $dst);
    // no dst file, return dom, so that piping can continue
    else {
      $ret=$this->_trans->transformToDoc($doc);
      // will we have problem here ?
      $ret->formatOutput=true;
      $ret->substituteEntities=true;
    }
    restore_error_handler();
    // reset parameters ! or they will kept on next transform
    if(isset($pars) && count($pars)) foreach ($pars as $key => $value) $this->_trans->removeParameter('', $key);
    return $ret;
  }
  /**
   * Custom error handler
   * Especially used for xsl:message coming from transform()
   * To avoid Apache time limit, php could output some bytes during long transformations
   */
  static function log($errno, $errstr=null, $errfile=null, $errline=null, $errcontext=null)
  {
    $errstr=preg_replace("/XSLTProcessor::transform[^:]*:/", "", $errstr, -1, $count);
    if ($count) { // is an XSLT error or an XSLT message, reformat here
      if(strpos($errstr, 'error')!== false) return false;
      else if ($errno == E_WARNING) $errno = E_USER_WARNING;
    }
    // a debug message in normal mode, do nothing
    if ($errno == E_USER_NOTICE && !self::$debug) return true;
    // not a user message, let work default handler
    else if ($errno != E_USER_ERROR && $errno != E_USER_WARNING ) return false;
    if (!self::$_logger);
    else if (is_resource(self::$_logger)) fwrite(self::$_logger, $errstr."\n");
    else if ( is_string(self::$_logger) && function_exists(self::$_logger)) call_user_func(self::$_logger, $errstr);
  }
  /**
   * Zip folder to a zip file
   */
  static public function zip($zipfile, $srcdir)
  {
    $zip = new ZipArchive;
    if(!file_exists($zipfile)) $zip->open($zipfile, ZIPARCHIVE::CREATE);
    else $zip->open($zipfile);
    self::zipdir($zip, $srcdir);
    $zip->close();
  }
  /**
   * The recursive method to zip dir
   * start with files (especially for mimetype epub)
   */
  static private function zipdir( $zip, $srcdir, $localdir="" )
  {
    $srcdir=rtrim($srcdir, "/\\").'/';
    // files
    foreach( array_filter(glob($srcdir . '/*'), 'is_file') as $path ) {
      $name = basename($path);
      if ($name == '.' || $name == '..') continue;
      $localname = $localdir . $name;
      $zip->addFile($path, $localname);
    }
    // dirs
    foreach( glob($srcdir . '/*', GLOB_ONLYDIR) as $path ) {
      $name = basename($path) . '/';
      if ($name == '.' || $name == '..') continue;
      $localname = $localdir . $name;
      $zip->addEmptyDir($localname);
      self::zipdir($zip, $path, $localname);
    }
  }
  /**
   * Transform an epub file in mobi with the kindlegen program
   */
  public static function mobi($epubfile, $mobifile)
  {
    $kindlegen = dirname(__FILE__)."/kindlegen";
    if (!file_exists($kindlegen)) $kindlegen = dirname(__FILE__)."/kindlegen.exe";
    if (!file_exists($kindlegen)) {
      exit("
To obtain mobi format, you should install the kindlegen program from Amazon
https://www.amazon.com/gp/feature.html?docId=1000765211
in ".dirname(__FILE__)."
      ");
    }
    $cmd = $kindlegen." ".$epubfile;
    $last = exec ($cmd, $output, $status);
    // error ?
    $tmpfile = dirname($epubfile).'/'.pathinfo($epubfile, PATHINFO_FILENAME).".mobi";
    if (!file_exists($tmpfile)) {
      self::log(E_USER_ERROR, "\n".$status."\n".join("\n", $output)."\n".$last."\n");
      return;
    }
    // create directories if necessary
    if (!is_dir(dirname($mobifile))) {
      mkdir(dirname($mobifile), 0775, true);
      @chmod(dirname($mobifile), 0775);
    }
    rename($tmpfile, $mobifile);
  }

  /**
   * Command line interface for the class
   */
  public static function cli()
  {
    $timeStart = microtime(true);
    array_shift($_SERVER['argv']); // shift first arg, the script filepath
    $options = "force|mobi";
    if (!count($_SERVER['argv'])) exit("
    usage    : php epub.php ($options)? dstdir/? *.xml

    option *   : force, to overwrite all generated epub
    dstdir/ ? : optional destination directory, ending by slash
    *.xml      : glob patterns are allowed, with or without quotes

");
    $opt = array();
    if( preg_match( "/^($options)\$/", trim($_SERVER['argv'][0], '- ') )) {
      $arg = trim(array_shift($_SERVER['argv']), '- ');
      $opt[$arg] = true;
    }

    $lastc = substr($_SERVER['argv'][0], -1);
    if ('/' == $lastc || '\\' == $lastc) {
      $dstdir = array_shift($_SERVER['argv']);
      $dstdir = rtrim($dstdir, '/\\').'/';
      if (!file_exists($dstdir)) {
        mkdir($dstdir, 0775, true);
        @chmod($dir, 0775);  // let @, if www-data is not owner but allowed to write
      }
    }
    $count = 0;
    $ext = ".epub";
    if(isset($opt['mobi'])) $ext = ".mobi";
    foreach ($_SERVER['argv'] as $glob) {
      foreach(glob($glob) as $srcfile) {
        $count++;
        if (isset($dstdir) ) $dstfile = $dstdir.pathinfo($srcfile,  PATHINFO_FILENAME).$ext;
        else $dstfile = pathinfo($srcfile,  PATHINFO_FILENAME).$ext;
        if (isset($opt['force'])); // overwrite
        else if (!file_exists($dstfile)); // do not exist
        else if (filemtime($srcfile) <= filemtime($dstfile)) continue; // epub is newer
        fwrite(STDERR, "$count. $srcfile > $dstfile\n");
        // work
        if(isset($opt['mobi'])) {
          self::mobi($srcfile, $dstfile);
        }
        else {
          $livre = new Epub( $srcfile, STDERR );
          $livre->export( $dstfile );
        }
      }
    }
    fwrite(STDERR, (number_format(microtime(true) - $timeStart, 3))." s.\n");
    exit;
  }

}
