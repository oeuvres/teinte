<?php
/**
 * Different tools to build html sites
 */
class Tools
{
  /** XSLTProcessors */
  private static $transcache = array();
  /** get a temp dir */
  private static $tmpdir;


  static function mois($num)
  {
    $mois = array(
      1 => 'janvier',
      2 => 'février',
      3 => 'mars',
      4 => 'avril',
      5 => 'mai',
      6 => 'juin',
      7 => 'juillet',
      8 => 'août',
      9 => 'septembre',
      10 => 'octobre',
      11 => 'novembre',
      12 => 'décembre',
    );
    return $mois[(int)$num];
  }

  /**
   * get a pdo link to an sqlite database with good options
   */
  static function pdo($file, $sql)
  {
    $dsn = "sqlite:".$file;
    // if not exists, create
    if (!file_exists($file)) return self::sqlcreate($file, $sql);
    else return self::sqlopen($file, $sql);
  }

  /**
   * Open a pdo link
   */
  static private function sqlopen($file)
  {
    $dsn = "sqlite:".$file;
    $pdo = new PDO($dsn);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->exec("PRAGMA temp_store = 2;");
    return $pdo;
  }

  /**
   * Renew a database with an SQL script to create tables
   */
  static function sqlcreate($file, $sql)
  {
    if (file_exists($file)) unlink($file);
    self::mkdir(dirname($file));
    $pdo = self::sqlopen($file);
    @chmod($sqlite, 0775);
    $pdo->exec($sql);
    return $pdo;
  }

  /**
   * Get a DOM document with best options
   */
  static function dom($xmlfile) {
    $dom = new DOMDocument();
    $dom->preserveWhiteSpace = false;
    $dom->formatOutput = true;
    $dom->substituteEntities = true;
    $dom->load($xmlfile, LIBXML_NOENT | LIBXML_NONET | LIBXML_NSCLEAN | LIBXML_NOCDATA | LIBXML_NOWARNING);
    return $dom;
  }
  /**
   * Xsl transform from xml file
   */
  static function transform($xmlfile, $xslfile, $dst=null, $pars=null)
  {
    return self::transformDoc(self::dom($xmlfile), $xslfile, $dst, $pars);
  }

  static public function transformXml($xml, $xslfile, $dst=null, $pars=null)
  {
    $dom = new DOMDocument();
    $dom->preserveWhiteSpace = false;
    $dom->formatOutput=true;
    $dom->substituteEntities=true;
    $dom->loadXml($xml, LIBXML_NOENT | LIBXML_NONET | LIBXML_NSCLEAN | LIBXML_NOCDATA | LIBXML_NOWARNING);
    return self::transformDoc($dom, $xslfile, $dst, $pars);
  }

  /**
   * An xslt transformer with cache
   * TOTHINK : deal with errors
   */
  static public function transformDoc($dom, $xslfile, $dst=null, $pars=null)
  {
    if (!is_a($dom, 'DOMDocument')) {
      throw new Exception('Source is not a DOM document, use transform() for a file, or transformXml() for an xml as a string.');
    }
    $key = realpath($xslfile);
    // cache compiled xsl
    if (!isset(self::$transcache[$key])) {
      $trans = new XSLTProcessor();
      $trans->registerPHPFunctions();
      // allow generation of <xsl:document>
      if (defined('XSL_SECPREFS_NONE')) $prefs = XSL_SECPREFS_NONE;
      else if (defined('XSL_SECPREF_NONE')) $prefs = XSL_SECPREF_NONE;
      else $prefs = 0;
      if(method_exists($trans, 'setSecurityPreferences')) $oldval = $trans->setSecurityPreferences($prefs);
      else if(method_exists($trans, 'setSecurityPrefs')) $oldval = $trans->setSecurityPrefs($prefs);
      else ini_set("xsl.security_prefs",  $prefs);
      $xsldom = new DOMDocument();
      $xsldom->load($xslfile);
      $trans->importStyleSheet($xsldom);
      self::$transcache[$key] = $trans;
    }
    $trans = self::$transcache[$key];
    // add params
    if(isset($pars) && count($pars)) {
      foreach ($pars as $key => $value) {
        $trans->setParameter(null, $key, $value);
      }
    }
    // return a DOM document for efficient piping
    if (is_a($dst, 'DOMDocument')) {
      $ret = $trans->transformToDoc($dom);
    }
    else if ($dst != '') {
      self::mkdir(dirname($dst));
      $trans->transformToURI($dom, $dst);
      $ret = $dst;
    }
    // no dst file, return String
    else {
      $ret =$trans->transformToXML($dom);
    }
    // reset parameters ! or they will kept on next transform if transformer is reused
    if(isset($pars) && count($pars)) {
      foreach ($pars as $key => $value) $trans->removeParameter(null, $key);
    }
    return $ret;
  }

  /**
   * A safe mkdir dealing with rights
   */
  static function mkdir($dir)
  {
    if (is_dir($dir)) return $dir;
    if (!mkdir($dir, 0775, true)) throw new Exception("Directory not created: ".$dir);
    @chmod(dirname($dir), 0775);  // let @, if www-data is not owner but allowed to write
    return $dir;
  }

  /**
   * Recursive deletion of a directory
   * If $keep = true, keep directory with its acl
   */
  static function rmdir($dir, $keep = false) {
    $dir = rtrim($dir, "/\\").DIRECTORY_SEPARATOR;
    if (!is_dir($dir)) return $dir; // maybe deleted
    if(!($handle = opendir($dir))) throw new Exception("Read impossible ".$file);
    while(false !== ($filename = readdir($handle))) {
      if ($filename == "." || $filename == "..") continue;
      $file = $dir.$filename;
      if (is_link($file)) throw new Exception("Delete a link? ".$file);
      else if (is_dir($file)) self::rmdir($file);
      else unlink($file);
    }
    closedir($handle);
    if (!$keep) rmdir($dir);
    return $dir;
  }


  /**
   * Recursive copy of folder
   */
  static function rcopy($srcdir, $dstdir) {
    $srcdir = rtrim($srcdir, "/\\").DIRECTORY_SEPARATOR;
    $dstdir = rtrim($dstdir, "/\\").DIRECTORY_SEPARATOR;
    self::mkdir($dstdir);
    $dir = opendir($srcdir);
    while(false !== ($filename = readdir($dir))) {
      if ($filename[0] == '.') continue;
      $srcfile = $srcdir.$filename;
      if (is_dir($srcfile)) self::rcopy($srcfile, $dstdir.$filename);
      else copy($srcfile, $dstdir.$filename);
    }
    closedir($dir);
  }

}
