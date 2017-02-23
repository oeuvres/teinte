<?php
/**
 * Pilot to generate different formats
 */
// cli usage
Teinte_Build::deps();
set_time_limit(-1);


if (realpath($_SERVER['SCRIPT_FILENAME']) != realpath(__FILE__)) {
  // file is included do nothing
}
else if (php_sapi_name() == "cli") {
  Teinte_Build::cli();
}
class Teinte_Build
{
  static private $_kindlegen;
  static private $_formats = array(
    'tei' => '.xml',
    'epub' => '.epub',
    'kindle' => '.mobi',
    'markdown' => '.md',
    'iramuteq' => '.txt',
    'html' => '.html',
    'article' => '.html',
    'toc' => '.html',
    // 'docx' => '.docx',
  );
  /** Columns reference to build queries */
  static $coldoc = array("code", "filemtime", "filesize", "deps", "title", "byline", "date", "source", "identifier", "publisher" );
  /** Sqlite persistency */
  static $create = "
PRAGMA encoding = 'UTF-8';
PRAGMA page_size = 8192;

CREATE table doc (
  -- an indexed HTML document
  id          INTEGER, -- rowid auto
  code        TEXT UNIQUE NOT NULL,   -- source filename without extension, unique for base
  filemtime   INTEGER NOT NULL, -- ! modified time
  filesize    INTEGER, -- ! filesize
  deps        TEXT,    -- ? generated files, useful for deletion
  title       TEXT NOT NULL,    -- ! html, for a structured short result
  byline      TEXT,    -- ? authors… text, searchable
  date        INTEGER, -- ? favorite date for chronological sort
  start       INTEGER, -- ? creation, start year, when chronological queries are relevant
  end         INTEGER, -- ? creation, end year, when chronological queries are relevant
  issued      INTEGER, -- ? publication year of the text
  bibl        TEXT,    -- ? publication year of the text
  source      TEXT,    -- ? URL of source file (ex: XML/TEI)
  publisher   TEXT,    -- ? Name of the original publisher of the file in case of compilation
  identifier  TEXT,    -- ? URL of the orginal publication in case of compilation
  PRIMARY KEY(id ASC)
);
CREATE UNIQUE INDEX IF NOT EXISTS doc_code ON doc( code );
CREATE INDEX IF NOT EXISTS doc_byline_date ON doc( byline, date, title );
CREATE INDEX IF NOT EXISTS doc_date_byline ON doc( date, byline, title );

CREATE VIRTUAL TABLE search USING FTS3 (
  -- table of searchable articles, with same rowid as in article
  text        TEXT  -- exact text
);

CREATE TRIGGER IF NOT EXISTS docDel
  -- on book deletion, delete full text index
  BEFORE DELETE ON doc
  FOR EACH ROW BEGIN
    DELETE FROM search WHERE search.docid=OLD.id;
END;

  ";
  /** SQLite link, maybe useful outside */
  public $pdo;
  /** Stored queries */
  private $_q = array();
  /** Processeur xslt */
  private $_xslt;
  /** A logger, maybe a stream or a callable, used by $this->log() */
  private $_logger;
  /** Vrai si dépendances vérifiées et chargées */
  private static $_deps;
  /** Log level */
  public $loglevel = E_ALL;

  /**
   * Constructeur de la base
   */
  public function __construct($sqlite, $logger="php://output")
  {
    if (is_string($logger)) $logger = fopen($logger, 'w');
    $this->_logger = $logger;
    $this->connect( $sqlite );
  }
  /**
   * Efficient truncate table
   */
  public function clean()
  {
    // TODO, delete created folders
    $this->pdo->exec("DROP TABLE doc; DROP TABLE search; ");
    $this->pdo->exec(self::$create);
  }

  /**
   * Delete exports of a file
   */
  public function delete( $code, $basedir="", $formats=null )
  {
    if ( !$formats ) $formats=array_keys( self::$_formats );
    $echo = "";
    $this->_q['del']->execute( array( $code ) );
    foreach ( $formats as $format ) {
      $extension = self::$_formats[$format];
      $destfile = $basedir.'/'.$format.'/'.$code.$extension;
      if ( !file_exists($destfile)) continue;
      unlink($destfile);
      $echo .= " ".basename( $destfile );
    }
    if ( $echo ) $this->log( E_USER_NOTICE, $echo );
  }

  /**
   * Produire les exports depuis le fichier XML
   */
  public function export( $teinte, $basedir="", $formats=array( "article", "toc" ), $force=false)
  {
    $echo = "";
    foreach ( $formats as $format ) {
      if ( !isset( self::$_formats[$format] ) ) {
        $this->log( E_USER_WARNING, $format." format non supporté" );
        continue;
      }
      $extension = self::$_formats[$format];
      $destfile = $basedir.'/'.$format.'/'.$teinte->filename().$extension;
      // delete destfile if exists
      if (file_exists($destfile)) unlink($destfile);
      $echo .= " ".$format;
      // TODO git $destfile
      if ($format == 'html') $teinte->html($destfile, 'http://oeuvres.github.io/Teinte/');
      else if ($format == 'article') $teinte->article($destfile);
      else if ($format == 'toc') $teinte->toc($destfile);
      else if ($format == 'markdown') $teinte->markdown($destfile);
      else if ($format == 'iramuteq') $teinte->iramuteq($destfile);
      else if ($format == 'epub') {
        $livre = new Livrable_Tei2epub($srcfile, self::$_logger);
        $livre->epub($destfile);
        // transform for kindle if cmd present
        if (self::$_kindlegen) {
          $cmd = self::$_kindlegen.' '.$destfile;
          $last = exec ($cmd, $output, $status);
          $mobi = dirname(__FILE__).'/'.$format.'/'.$teinte->filename.".mobi";
          // error ?
          if (!file_exists($mobi)) {
            $this->log(E_USER_ERROR, "\n".$status."\n".join("\n", $output)."\n".$last."\n");
          }
          else {
            rename( $mobi, dirname(__FILE__).'/kindle/'.$teinte->filename.".mobi");
            $echo .= " kindle";
          }
        }
      }
      else if ($format == 'docx') {
        $echo .= " docx";
        Toff_Tei2docx::docx($srcfile, $destfile);
      }
    }
    if ($echo) $this->log( E_USER_NOTICE, $echo );
  }

  /**
   * Insert a record in the database about a Teinte document
   * Return rowid inserted
   */
  private function record( $teinte, $props=null )
  {
    $meta = $teinte->meta();
    // supprimer la pièce, des triggers doivent normalement supprimer la cascade.
    $this->_q['del']->execute( array( $meta['code'] ) );
    $values = array_fill_keys( self::$coldoc, null );
    // replace in values, but do not add new keys from meta (intersect)
    $values = array_replace( $values, array_intersect_key($meta, $values) );
    // replace in values, but do not add keys, and change their order
    if ( is_array( $props ) ) $values = array_replace( $values, array_intersect_key( $props, $values ) );
    $this->_q['record']->execute( array_values( $values ) ); // no keys for values
    return $this->pdo->lastInsertId() ;
  }

  /**
   * Add a full text row, with the rowid given by record()
   */
  private function ft ( $docid, $text )
  {


    /*
    self::$stmt['insSearch']=self::$pdo->prepare("
      INSERT INTO search (docid, text, omni) VALUES (?, ?, ?);
    ");

    // do not (?) search for notes
    if ($pos=strpos($body, '<section class="footnotes">')) {
      $body = substr($body, 0, $pos - 1);
    }
    // wash html from tags
    $body=self::detag($body);
    // one sentence by line, clean unbreakable space
    $body=preg_replace(self::$re['sSearch'], self::$re['sReplace'], $body);
    // echo $body; // debug sentences ?
    if (self::$debug) echo "\n$href";
    // do not index non significant nav
    self::$stmt['insSearch']->execute(array(
      self::$pars['articleId'],
      $body,
      '€€€',
    ));
    if (self::$debug && self::$logStream) fwrite(self::$logStream, "\n".$name.round(microtime(true) - self::$time, 4)." s. ");

    */

  }

  /**
   * Build a site from a list of TEI files
   */
  public function site( $srclist, $destdir, $sep=";" )
  {
    $this->_q['mtime'] = $this->pdo->prepare("SELECT filemtime FROM doc WHERE code = ?");
    $oldlog = $this->loglevel;
    $this->loglevel = $this->loglevel|E_USER_NOTICE;
    $this->log( E_USER_NOTICE, $srclist." lecture de la liste de fichiers à publier" );
    $cods = array(); // store the codes of each file in the srclist to delete some files
    $handle = fopen( $srclist, "r" );
    $keys = fgetcsv( $handle, 0, $sep ); // first line, column names
    $srcdir = dirname( $srclist );
    if ( $srcdir == "." ) $srcdir = "";
    else $srcdir .= "/";
    $line = 1;
    $this->pdo->beginTransaction();
    while ( ($values = fgetcsv( $handle, 0, $sep )) !== FALSE) {
      $line++;
      if ( count( $values ) < 1 ) continue;
      if ( !$values[0] ) continue;
      if ( substr ( trim( $values[0] ), 0) == '#'  ) continue;
      if ( count( $keys ) > count( $values ) ) // less values than keys, fill for a good combine
        $values = array_merge( $values, array_fill( 0, count( $keys ) - count( $values ), null ) ) ;
      $row = array_combine($keys, $values);
      $srcfile = $srcdir.current($row);
      $code = pathinfo( $srcfile, PATHINFO_FILENAME );
      $cods[] = $code;
      if ( !file_exists( $srcfile ) ) {
        $this->log( E_USER_NOTICE, $srcfile." fichier non trouvé (".$srclist." l. ".$line.")" );
        continue;
      }
      $srcmtime = filemtime( $srcfile );
      $this->_q['mtime']->execute( array( $code) );
      list( $basemtime ) = $this->_q['mtime']->fetch();
      if ( $basemtime >= $srcmtime ) continue;
      $this->log( E_USER_NOTICE, $srcfile );
      $teinte = new Teinte_Doc( $srcfile );
      $this->record( $teinte );
      $this->export( $teinte, $destdir, array( "article", "toc" ) );
    }
    fclose($handle);
    $this->pdo->commit();
    // Check for deteleted files
    $q = $this->pdo->query("SELECT * FROM doc WHERE code NOT IN ( '".implode( "', '", $cods )."' )");
    $del = array();
    foreach (  $q as $row ) {
      $this->log( E_USER_NOTICE, "\nSUPPRESSION ".$row['code'] );
      $this->delete( $row['code'], $destdir );
    }
    // $this->pdo->exec( "VACUUM" );
    $this->pdo->exec( "INSERT INTO  search(search) VALUES( 'optimize' ); -- optimize fulltext index " );
    $this->loglevel = $oldlog;
  }

  /**
   * Sortir le catalogue en table html
   */
  public function table($cols=array("no", "publisher", "creator", "date", "title", "downloads"))
  {
    $labels = array(
      "no"=>"N°",
      "publisher" => "Éditeur",
      "creator" => "Auteur",
      "date" => "Date",
      "title" => "Titre",
      "tei" => "Titre",
      "downloads" => "Téléchargements",
      "relation" => "Téléchargements",
    );
    echo '<table class="sortable">'."\n  <tr>\n";
    foreach ( $cols as $code ) {
      echo '    <th>'.$labels[$code]."</th>\n";
    }
    echo "  </tr>\n";
    $i = 1;
    foreach ($this->pdo->query("SELECT * FROM oeuvre ORDER BY code") as $oeuvre) {
      echo "  <tr>\n";
      foreach ( $cols as $code ) {
        if (!isset($labels[$code])) continue;
        echo "    <td>";
        if ("no" == $code) {
          echo $i;
        }
        else if ("publisher" == $code) {
          if ($oeuvre['identifier']) echo '<a href="'.$oeuvre['identifier'].'">'.$oeuvre['publisher']."</a>";
          else echo $oeuvre['publisher'];
        }
        else if("creator" == $code || "author" == $code) {
          echo $oeuvre['author'];
        }
        else if("date" == $code || "year" == $code) {
          echo $oeuvre['year'];
        }
        else if("title" == $code) {
          if ($oeuvre['identifier']) echo '<a href="'.$oeuvre['identifier'].'">'.$oeuvre['title']."</a>";
          else echo $oeuvre['title'];
        }
        else if("tei" == $code) {
          echo '<a href="'.$oeuvre['code'].'.xml">'.$oeuvre['title'].'</a>';
        }
        else if("relation" == $code || "downloads" == $code) {
          if ($oeuvre['source']) echo '<a href="'.$oeuvre['source'].'">TEI</a>';
          $sep = ", ";
          foreach ( self::$formats as $label=>$extension) {
            if ($label == 'article') continue;
            echo $sep.'<a href="'.$label.'/'.$oeuvre['code'].$extension.'">'.$label.'</a>';
          }
        }
        echo "</td>\n";
      }
      echo "  </tr>\n";
      $i++;
    }
    echo "\n</table>\n";
  }


  /**
   * Connexion à la base
   */
  private function connect($sqlite)
  {
    $dsn = "sqlite:" . $sqlite;
    // si la base n’existe pas, la créer
    if (!file_exists($sqlite)) {
      if (!file_exists($dir = dirname($sqlite))) {
        mkdir($dir, 0775, true);
        @chmod($dir, 0775);  // let @, if www-data is not owner but allowed to write
      }
      $this->pdo = new PDO($dsn);
      $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );
      @chmod($sqlite, 0775);
      $this->pdo->exec(self::$create);
    }
    else {
      $this->pdo = new PDO($dsn);
      $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );
    }
    // table temporaire en mémoire
    $this->pdo->exec("PRAGMA temp_store = 2;");
    $sql = "INSERT INTO doc (".implode( self::$coldoc, ", " ).") VALUES ( ?".str_repeat(", ?", count( self::$coldoc ) -1 )." );";
    $this->_q['record'] = $this->pdo->prepare($sql);
    $this->_q['del'] = $this->pdo->prepare("DELETE FROM doc WHERE code = ?");
  }

  /**
   * Check dependencies
   */
  static function deps()
  {
    if(self::$_deps) return;
    // Deps
    $inc = dirname(__FILE__).'/../Livrable/Tei2epub.php';
    if (!file_exists($inc)) {
      echo "Impossible de trouver ".realpath(dirname(__FILE__).'/../')."/Livrable/
    Vous pouvez le télécharger sur https://github.com/oeuvres/Livrable\n";
      exit();
    }
    else {
      include_once($inc);
    }
    $inc = dirname(__FILE__).'/../Livrable/kindlegen';
    if (!file_exists($inc)) $inc = dirname(__FILE__).'/../Livrable/kindlegen.exe';
    if (!file_exists($inc)) {
      echo "Si vous souhaitez la conversion de vos epubs pour Kindle, il faut télécharger chez Amazon
      le programme kindlegen pour votre système http://www.amazon.fr/gp/feature.html?ie=UTF8&docId=1000570853
      à placer dans le dossier Livrable : ".dirname($inc);
    }
    if (file_exists($inc)) self::$_kindlegen = realpath($inc);


    $inc = dirname(__FILE__).'/Doc.php';
    if (!file_exists($inc)) {
      echo "Impossible de trouver ".dirname(__FILE__)."/Teinte/Doc.php
    Vous pouvez le télécharger sur https://github.com/oeuvres/Teinte\n";
      exit();
    }
    else {
      include_once($inc);
    }
    /*
    $inc = dirname(__FILE__).'/../Toff/Tei2docx.php';
    if (!file_exists($inc)) {
      echo "Impossible de trouver ".realpath(dirname(__FILE__).'/../')."/Toff/
    Vous pouvez le télécharger sur https://github.com/oeuvres/Toff\n";
      exit();
    }
    else {
      include_once($inc);
    }
    */
    self::$_deps=true;
  }

  /**
   * Custom error handler
   * May be used for xsl:message coming from transform()
   * To avoid Apache time limit, php could output some bytes during long transformations
   */
  function log( $errno, $errstr, $errfile=null, $errline=null, $errcontext=null)
  {
    if ( !$this->loglevel & $errno ) return false;
    $errstr=preg_replace("/XSLTProcessor::transform[^:]*:/", "", $errstr, -1, $count);
    /* ?
    if ( $count ) { // is an XSLT error or an XSLT message, reformat here
      if ( strpos($errstr, 'error') !== false ) return false;
      else if ( $errno == E_WARNING ) $errno = E_USER_WARNING;
    }
    */
    if ( !$this->_logger );
    else if ( is_resource($this->_logger) ) fwrite( $this->_logger, $errstr."\n");
    else if ( is_string($this->_logger) && function_exists( $this->_logger ) ) call_user_func( $this->_logger, $errstr );
  }

  /**
   * Check epub
   */
  static function epubcheck($glob)
  {
    echo "epubcheck epub/*.epub\n";
    foreach(glob($glob) as $file) {
      echo $file;
      // validation
      $cmd = "java -jar ".dirname(__FILE__)."/epubcheck/epubcheck.jar ".$file;
      $last = exec ($cmd, $output, $status);
      echo ' '.$status."\n";
      if ($status) rename($file, dirname($file).'/_'.basename($file));
    }
  }

  /**
   * Command line API
   */
  static function cli()
  {
    $timeStart = microtime(true);
    $usage = "\nusage    : php -f ".basename(__FILE__).' base.sqlite action "dir/*.xml"'."\n\n";
    array_shift($_SERVER['argv']); // shift first arg, the script filepath
    if (count($_SERVER['argv']) < 2) exit($usage);
    $sqlite = array_shift($_SERVER['argv']);
    $action = array_shift($_SERVER['argv']);
    $base = new Teinte_Build($sqlite, STDERR);
    while($glob = array_shift($_SERVER['argv']) ) {
      foreach(glob($glob) as $srcfile) {
        fwrite (STDERR, $srcfile);
        if ("insert" == $action) {
          $base->insert($srcfile);
        }

        // $base->add($file, $setcode);
        fwrite(STDERR, "\n");
      }
    }
    /*
    $ext = pathinfo ($file, PATHINFO_EXTENSION);
    // seems a list of uri
    if ($ext == 'csv' || $ext == "txt") { // ? }
    */
  }
}
?>
