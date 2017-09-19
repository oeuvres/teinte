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
class Teinte_Doc
{
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
  /** file size */
  private $_filesize;
  /** XSLTProcessor */
  private $_trans;
  /** XSL DOM document */
  private $_xsldom;
  /** Keep memory of last xsl, to optimize transformations */
  private $_xslfile;
  /** formats */
  public static $ext = array(
    'article' => '_art.html',
    'detag' => '.txt',
    'html' => '.html',
    'iramuteq' => '.txt',
    'markdown' => '.txt',
    'naked' => '.txt',
    'toc' => '_toc.html',
  );
  /**
   * Constructor, load file and prepare work
   */
  public function __construct($tei)
  {
    if (is_a( $tei, 'DOMDocument' ) ) {
      $this->_dom = $tei;
    }
    else if( is_string( $tei ) ) { // maybe file or url
      $this->_file = $tei;
      $this->_filemtime = filemtime( $tei );
      $this->_filesize = filesize( $tei ); // ?? URL ?
      $this->_filename = pathinfo( $tei, PATHINFO_FILENAME );
      // loading error, do something ?
      if ( !$this->_dom( $tei ) ) throw new Exception("BAD XML");
    }
    else {
      throw new Exception('Teinte, what is it? '.print_r($tei, true));
    }
    $this->_xsldom = new DOMDocument();
    $this->xpath();
  }

  public function isEmpty()
  {
    return !$this->_dom;
  }

 /**
  * Set and return an XPath processor
  */
  public function xpath()
  {
    if ($this->_xpath) return $this->_xpath;
    $this->_xpath = new DOMXpath($this->_dom);
    $this->_xpath->registerNamespace( 'tei', "http://www.tei-c.org/ns/1.0" );
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
   * For a readonly property
   */
  public function filesize( $filesize=null )
  {
    if ( $filesize ) $this->_filesize = $filesize;
    return $this->_filesize;
  }
  /**
   * For a readonly property
   */
  public function file( )
  {
    return $this->_file;
  }
  /**
   * Book metadata
   */
  public function meta()
  {
    $meta = array();
    $meta['code'] = pathinfo($this->_file, PATHINFO_FILENAME);
    $nl = $this->_xpath->query("/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author");
    $meta['creator'] = array();
    $meta['byline'] = null;
    $first = true;
    foreach ($nl as $node) {
      $value = $node->getAttribute("key");
      if ( !$value ) $value = $node->textContent;
      if (($pos = strpos($value, '('))) $value = trim( substr( $value, 0, $pos ) );
      $meta['creator'][] = $value;
      if ( $first ) $first = false;
      else $meta['byline'] .= " ; ";
      $meta['byline'] .= $value;
    }
    // editors
    $meta['editby'] = null;
    $nl = $this->_xpath->query("/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor");
    $first = true;
    foreach ($nl as $node) {
      $value = $node->getAttribute("key");
      if ( !$value ) $value = $node->textContent;
      if (($pos = strpos($value, '('))) $value = trim( substr( $value, 0, $pos ) );
      if ( $first ) $first = false;
      else $meta['editby'] .= " ; ";
      $meta['editby'] .= $value;
    }
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
      if ( !$value ) $value = $date->getAttribute ('notAfter');
      if ( !$value ) $value = $date->nodeValue;
      $value = substr(trim($value), 0, 4);
      if ( !is_numeric($value) ) {
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
    $meta['filesize'] = $this->filesize();


    return $meta;
  }
  /**
   *
   */
  public function export($format, $destfile=null)
  {
    if (isset(self::$ext[$format])) return call_user_func(array($this, $format), $destfile);
    else if (STDERR) fwrite(STDERR, $format." ? format not yet implemented\n");
  }
  /**
   * Output toc
   */
  public function toc( $destfile=null, $root = "ol")
  {
    return $this->transform(
      dirname(__FILE__).'/tei2toc.xsl',
      $destfile,
      array(
        'root'=> $root,
      )
    );
  }

  /**
   * Output an html fragment
   */
  public function article( $destfile=null )
  {
    return $this->transform(
      dirname(__FILE__).'/tei2html.xsl',
      $destfile,
      array(
        'root'=> 'article',
        'folder' => basename( dirname( $this->_file) ),
      )
    );
  }

  /**
   * Output a txt fragment with no html tags for full-text searching
   */
  public function ft( $destfile=null )
  {
    $html = $this->article();
    $html = self::detag( $html );
    if ( $destfile ) file_put_contents( $destfile, $html );
    return $html;
  }

  /**
   * Output html
   */
  public function html($destfile=null, $theme = null)
  {
    if (!$theme) $theme = 'http://oeuvres.github.io/Teinte/'; // where to find web assets like css and js for html file
    return $this->transform(
      dirname(__FILE__).'/tei2html.xsl',
      $destfile,
      array(
        'theme'=> $theme,
        'folder' => basename( dirname( $this->_file) ),
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
   * Output a split version of book
   */
  public function site( $destdir=null )
  {
    // create dest folder
    // if none given, use filename
    // collect images pointed by xml file and copy them in the folder
  }
  /**
   * Extract <graphic> elements from a DOM doc, copy linked images in a flat destdir
   * $href : a href prefix to redirest generated links
   * $destdir : a folder if images should be copied
   * return : a doc with updated links to image
   */
  private function images( $href=null, $destdir=null)
  {
    if ($destdir) $destdir=rtrim($destdir, '/\\').'/';
    // copy linked images in an images folder, and modify relative link
    // clone the original doc, links to picture will be modified
    $doc=$doc->cloneNode(true);
    foreach ($doc->getElementsByTagNameNS('http://www.tei-c.org/ns/1.0', 'graphic') as $el) {
      $this->img($el->getAttributeNode("url"), $href, $destdir);
    }
    /*
    do not store images of pages, especially in tif
    foreach ($doc->getElementsByTagNameNS('http://www.tei-c.org/ns/1.0', 'pb') as $el) {
      $this->img($el->getAttributeNode("facs"), $hrefTei, $destdir, $hrefSqlite);
    }
    */
    return $doc;
  }
  /**
   * Process one image
   */
  public function img($att, $hrefdir="", $destdir=null)
  {
    if (!isset($att) || !$att || !$att->value) return;
    $src=$att->value;
    // return if data image
    if (strpos($src, 'data:image') === 0) return;

    // test if relative file path
    if (file_exists($test=dirname($this->_srcfile).'/'.$src)) $src=$test;
    // vendor specific etc/filename.jpg
    else if (isset(self::$_pars['srcdir']) && file_exists($test=self::$_pars['srcdir'].self::$_pars['filename'].'/'.substr($src, strpos($src, '/')+1))) $src=$test;
    // if not file exists, escape and alert (?)
    else if (!file_exists($src)) {
      $this->log("Image not found: ".$src);
      return;
    }
    $srcParts=pathinfo($src);
    // test first if dst dir (example, epub for sqlite)
    if (isset($destdir)) {
      // create images folder only if images detected
      if (!file_exists($destdir)) self::dirclean($destdir);
      // destination
      $i=2;
      // avoid duplicated files
      while (file_exists($destdir.$srcParts['basename'])) {
        $srcParts['basename']=$srcParts['filename'].'-'.$i.'.'.$srcParts['extension'];
        $i++;
      }
      copy( $src, $destdir.$srcParts['basename']);
    }
    // changes links in TEI so that straight transform will point on the right files
    $att->value=$hrefdir.$srcParts['basename'];
    // resize ?
    // NO delete of <graphic> element if broken link
  }

  /**
   * Preprocess TEI with a transformation
   */
   public function pre( $xslfile, $pars=null )
   {
     $this->dom = $this->transform($xslfile, new DOMDocument(), $pars);
   }

   /**
    * Replace tags of html file by spaces, to get text with same offset index of words
    * allowing indexation and highlighting. Keep line breaks for line numbers.
    * Support of some html5 tag to strip not indexable content.
    * 2x faster than a char loop
    */
   static public function detag( $html )
   {
     // preg_replace_callback is safer and 2x faster than the /e modifier
     $html=preg_replace_callback(
       array(
         // s flag so that '.' could match \n
         // .*? ungreedy
         '@<!.*?>@s', // exclude doctype and comments
         '@<\?.*?\?>@s', // exclude PI
         '@<(head|header|footer|nav|noindex)[ >].*?</\1>@s', // suppress nav, let <aside> for notes
         '@<(small|tt|a)[^>]*>[0-9]+</\1>@' ,// line or note of number
         '@<a class="noteref".*?</a>@', // suppress footnote call
         '@<[^>]+>@' // wash tags
       ),
       array(__CLASS__, 'blank'),
       $html
     );
     return $html;
   }
   /**
    * blanking a string, keeping new lines
    */
   static public function blank($string)
   {
     if(is_array($string)) $string=$string[0];
     // if (strpos($string, '<tt class="num')===0) return "_NUM_".str_repeat(" ", strlen($string) - 5);
     return preg_replace("/[^\n]/", " ", $string);
   }

  /**
   * An xslt transformer
   * TOTHINK : deal with errors
   */
  public function transform( $xslfile, $dest=null, $pars=null )
  {
    if ( !$this->_trans ) {
      // renew the processor
      $this->_trans = new XSLTProcessor();
      $this->_trans->registerPHPFunctions();
      // allow generation of <xsl:document>
      if ( defined( 'XSL_SECPREFS_NONE' ) ) $prefs = XSL_SECPREFS_NONE;
      else if ( defined( 'XSL_SECPREF_NONE' ) ) $prefs = XSL_SECPREF_NONE;
      else $prefs = 0;
      if( method_exists( $this->_trans, 'setSecurityPreferences' ) ) $oldval = $this->_trans->setSecurityPreferences( $prefs );
      else if( method_exists( $this->_trans, 'setSecurityPrefs' ) ) $oldval = $this->_trans->setSecurityPrefs( $prefs );
      else ini_set( "xsl.security_prefs",  $prefs );
    }
    // allow reuse of same xsl for performances
    if ( $this->_xslfile != $xslfile ) {
      // load xsl file
      $this->_xsldom->load( $xslfile );
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
        if ( !@mkdir(dirname($dest), 0775, true) ) exit( dirname($dest)." impossible à créer.\n");
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
  private function _dom( $xmlfile )
  {
    $this->_dom = new DOMDocument();
    $this->_dom->preserveWhiteSpace = false;
    $this->_dom->formatOutput=true;
    $this->_dom->substituteEntities=true;
    $ret = $this->_dom->load($xmlfile, LIBXML_NOENT | LIBXML_NONET | LIBXML_NSCLEAN | LIBXML_NOCDATA | LIBXML_NOWARNING);
    return $ret;
  }
  /**
   * Get the dom
   */
  public function dom()
  {
    return $this->_dom;
  }

  /**
   * Command line transform
   */
  public static function cli()
  {
    $formats=implode( '|', array_keys( self::$ext ) );
    array_shift($_SERVER['argv']); // shift first arg, the script filepath
    if (!count($_SERVER['argv'])) exit('
    usage     : php -f Doc.php ('.$formats.')? destdir/? "*.xml"
    format?   : optional dest format, default is html
    destdir/? : optional destdir
    *.xml     : glob patterns are allowed, with or without quotes, win or nix

');

    $format="html";
    if( preg_match( "/^($formats)\$/", trim($_SERVER['argv'][0], '- ') )) {
      $format = array_shift($_SERVER['argv']);
      $format = trim($format, '- ');
    }

    $destdir = ""; // default is transform here
    $lastc = substr($_SERVER['argv'][0], -1);
    if ('/' == $lastc || '\\' == $lastc) {
      $destdir = array_shift($_SERVER['argv']);
      $destdir = rtrim($destdir, '/\\').'/';
      if (!file_exists($destdir)) {
        mkdir($destdir, 0775, true);
        @chmod($dir, 0775);  // let @, if www-data is not owner but allowed to write
      }
    }


    $count = 1;
    echo "code\tbyline\tdate\ttitle\n";
    foreach ($_SERVER['argv'] as $glob) {
      foreach(glob($glob) as $srcfile) {
        $destname = pathinfo($srcfile, PATHINFO_FILENAME).self::$ext[$format];
        if (isset($destdir)) $destfile = $destdir.$destname;
        else $destfile=dirname($srcfile).'/'.$destname;
        if ( file_exists($destfile) && filemtime( $srcfile ) < filemtime( $destfile ) ) continue;
        if (STDERR) fwrite(STDERR, "$count. $srcfile > $destfile\n");
        $count++;
        try {
          $doc=new Teinte_Doc($srcfile);
          $meta = $doc->meta();
          $doc->export($format, $destfile);
          echo $meta['code']."\t".$meta['byline']."\t".$meta['date']."\t".$meta['title']."\n";
        }
        catch ( Exception $e ) {
          if (STDERR) fwrite(STDERR, $e );
        }
      }
    }
  }
}
?>
