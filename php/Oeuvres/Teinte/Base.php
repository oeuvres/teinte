<?php
umask(0002);
include_once( dirname(dirname(__FILE__))."/teinte/Web.php" );
class Teinte_Base
{
  /** sqlite File  */
  private $_sqlitefile;
  /** A text to snip */
  private $_text;
  /** Lien */
  public $pdo;
  /** Query params for search */
  public $p = array();
  /** Is search done ? */
  public $search;
  /** Search results, total docs */
  public $docsTotal;
  /** Search results, docs selected */
  public $docsFound;
  /** Search results, occs found */
  public $occsFound;
  /**
   * Constructor with a Sqlite base and a path
   */
  public function __construct( $sqlitefile = null, $lang = null, $path="", $pars = array() )
  {
    if ( !file_exists( $sqlitefile ) ) {
      echo '<h1>Première installation ? Allez voir la page <a href="pull.php">pull.php</a> pour transformer vos fichiers XML.</h1>';
      exit();
    }
    $this->_sqlitefile = $sqlitefile;
    $this->pdo = new PDO("sqlite:".$sqlitefile);
    $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_WARNING ); // get error as classical PHP warn
    $this->pdo->exec("PRAGMA temp_store = 2;"); // store temp table in memory (efficiency)
    $this->_p();
  }

  /**
   * Populate parameters for search
   */
  private function _p()
  {
    if ( !isset( $_COOKIE['lastsearch'] ) ) $_COOKIE['lastsearch'] = null;
    $search = false;
    $lastsearch = "";
    $this->p['q'] = "";
    // set query params
    if ( isset($_REQUEST['q']) && $_REQUEST['q'] ) {
      $this->p['q'] = trim(
        strtr(
          $_REQUEST['q'],
          array('’' => ' ', 'œ'=>'oe', "'"=>' ', '>' => ' ', '<' => ' ')
         )
      );
      // ??? hack for negative query
      // if ($this->q[0] == '-') $this->qmatch = "€€€ " . $this->q;
      // else $this->qmatch =  $this->q;
      $search = true;
      $lastsearch .= "&q=".str_replace( '"', '&quot;', $this->p['q'] );
    }
    $this->p['start'] = "";
    $this->p['end'] = "";
    if ( isset($_REQUEST['start'] ) && is_numeric( $_REQUEST['start'] ) ) {
      $this->p['start'] = intval( $_REQUEST['start'] );
      if ( $this->p['start'] ) $lastsearch .= "&start=".$this->p['start'];
      $search = true;
    }
    if ( isset($_REQUEST['end'] ) && $this->p['start'] && $_REQUEST['end'] > $this->p['start'] ) {
      $this->p['end'] = intval( $_REQUEST['end'] );
      if ( $this->p['end'] ) $lastsearch .= "&end=".$this->p['end'];
    }
    if ( $this->p['start'] && !$this->p['end'] ) $this->p['end'] = $this->p['start'];
    // TODO, by and notby (authors) or file prefix ?
    if ( $search ) {
      $this->search();
      $this->search = true;
      $lastsearch = trim( $lastsearch, '&' );
      setcookie ( "lastsearch", $lastsearch );
    }
  }

  public function search( )
  {
    $timeStart = microtime(true);
    $pars = array();
    $where = "";
    if ( $this->p['start'] ) {
      $where.=" AND ( doc.date >= ? AND doc.date <= ?) ";
      $pars = array_merge( $pars, array( $this->p['start'], $this->p['end'] ) );
    }
    if ( isset( $this->p['q'] ) ) {
      // matchinfo not available on centOs 5.5
      // TODO test if matchinfo available
      // $this->pdo->sqliteCreateFunction('matchinfo2occs', 'Sqlite::matchinfo2occs', 1);
      $this->pdo->sqliteCreateFunction( 'offsets2occs', 'Teinte_Base::offsets2occs', 1 );
      $pars = array_merge( (array)$this->p['q'], $pars );
      $sql="INSERT INTO found ( id, code, title, byline, date, class, occs ) SELECT id, code, title, byline, date, class, offsets2occs(offsets(search)) AS occs FROM doc, search WHERE search.docid=doc.id AND search MATCH ? ".$where;
    }
    else $sql="INSERT INTO found ( id, code, title, byline, date, class ) SELECT id, code, title, byline, date, class FROM doc WHERE 1 AND ".$where;

    $this->pdo->beginTransaction();
    // create a temp table with matche docs
    $this->pdo->exec("CREATE TEMP TABLE found (id INTEGER, code STRING, title STRING, byline STRING, date INTEGER, class STRING, occs INTEGER DEFAULT 0, PRIMARY KEY(id ASC) );");
    $req = $this->pdo->prepare($sql);
    $req->execute($pars);
    $this->pdo->exec("CREATE INDEX foundOccs ON found(occs);");
    $this->docsTotal = current($this->pdo->query("SELECT COUNT(*) FROM doc")->fetch());
    $this->docsFound = current($this->pdo->query("SELECT COUNT(*) FROM found")->fetch());
    $this->occsFound = current($this->pdo->query("SELECT SUM(occs) FROM found")->fetch());
    $this->pdo->commit(); // temp tables only available now
    // echo (microtime(true)-$timeStart).' s. ';
  }

  /**
   *
   */
  public function hilite( $docid, $q, $body )
  {
    // tag links of toc of
    $search = array();
    $replace = array();
    // hilite (use a tricky indexation in teipub to get correct positions)
    // this tricky query is the right one on some flavours of sqlite 3
    $query = $this->pdo->prepare( 'SELECT text, offsets(search) AS offsets FROM search, doc WHERE doc.id=search.docid AND doc.id=? AND text MATCH ?' ) ;
    $query->execute( array( $docid, $q ) );
    // TODO, join quote expressions
    $mark = 0;
    $html = array();
    $rule = array();
    $rule[] = '<div id="ruloccs">';
    while ($row = $query->fetch(PDO::FETCH_ASSOC)) {
      $len = strlen( $row['text'] );
      $offsets = explode( ' ',$row['offsets'] );
      $count = count($offsets);
      $pointer = 0;
      $start = true;
      for ($i = 0; $i<$count; $i = $i+4) {

        $html[] = substr( $body, $pointer, $offsets[$i+2]-$pointer );

        if ($start) {
          $mark++; // increment only when a <mark> is openened
          $html[] = '<b class="mark" id="mark'.$mark.'">';
          $dest = $mark-1;
          if($dest>0) $html[] = '<a href="#mark'.$dest.'" onclick="document.location.replace(this.href); return false;" class="prev">◀</a>';
          $start = false;
        }
        $html[] = substr( $body, $offsets[$i+2], $offsets[$i+3] );
        $pointer = $offsets[$i+2]+$offsets[$i+3];
        $rule[] = '<a href="#mark'.$mark.'" onclick="document.location.replace(this.href); return false;" style="top:'.number_format( 100.0*$pointer/$len, 1, '.', '').'%"> </a>';
        // no letters before the next mark
        if ($i+6 < $count) {
          $length = $offsets[$i+6] - $pointer;
          $inter = substr( $body, $pointer, $length );
          if(!preg_match('/\pL/', $inter)) continue;
        }
        $dest = $mark+1;
        if($i<$count-5) $html[] = '<a href="#mark'.$dest.'" onclick="document.location.replace(this.href); return false;" class="next">▶</a>';
        $html[] = '</b>';
        $start = true;
      }
      $html[] = substr( $body, $pointer );
      // focus sur la première occurrence
      $html[] = '<script type="text/javascript"> location.replace("#mark1"); </script>';
      $rule[] = '</div>';
      $html[] = implode( "\n", $rule );
      return implode( "", $html ); // keep original spaces
    }
    return $body;
  }

  function biblio( $cols=array("no", "creator", "date", "title", "occs"), $search=false ) {

    $order = $cols;
    if ( $order[0] == "no" ) array_shift( $order );
    if ( $search ) $sql = "SELECT * FROM found ORDER BY occs DESC, code";
    else if ( $order[0] == "creator" || $order[0] == "author" || $order[0] == "byline" )  $sql = "SELECT * FROM doc ORDER BY byline, date, code";
    else $sql = "SELECT * FROM doc ORDER BY date, code";
    $labels = array(
      "author" => "Auteur",
      "authors" => "Auteurs",
      "byline" => "Auteur(s)",
      "creator" => "Auteur",
      "editor" => "Éditeur",
      "editby" => "Éditeur(s)",
      "date" => "Date",
      "downloads" => "Téléchargements",
      "no"=>"N°",
      "publisher" => "Éditeur",
      "occs" => "Occurrences",
      "title" => "Titre",
    );
    echo '<table class="sortable">'."\n";
    if ( $search ) {
      echo "  <caption>";
      if ( $this->occsFound ) {
        echo $this->occsFound." occurrences trouvées dans ".$this->docsFound." document";
        if ( $this->docsFound > 1 ) echo "s";
        if ( $this->docsFound != $this->docsTotal ) echo "/".$this->docsTotal;
        echo ".";
      }
      // no results
      else if ( $this->p['q'] ) echo "Pas d’occurrence trouvée.";
      else if ( $this->docsFound != $this->docsTotal ) echo $this->docsFound." documents filtrés (/".$this->docsTotal.").";
      echo "  </caption>";
    }
    echo "  <tr>\n";
    foreach ($cols as $code) {
      echo '    <th>'.$labels[$code]."</th>\n";
    }
    echo "  </tr>\n";
    $i = 1;
    foreach ( $this->pdo->query( $sql ) as $row ) {
      echo '  <tr class="'.$row['class'].'">'."\n";
      foreach ($cols as $code) {
        if (!isset($labels[$code])) continue;
        if ( $code == 'occs' && !$search && !$this->p['q'] ) continue;
        echo "    <td>";
        if ("no" == $code) {
          echo $i;
        }
        else if( "creator" == $code || "author" == $code || "authors" == $code || "byline" == $code ) {
          echo $row['byline'];
        }
        else if( "occs" == $code ) {
          echo $row['occs'];
        }
        else if( "editby" == $code || "editor" == $code ) {
          echo $row['editby'];
        }
        else if( "date" == $code || "year" == $code ) {
          echo $row['date'];
        }
        else if( "downloads" == $code ) {
          // caller should implement global function to list downloads, according to its policy
          echo @downloads( $row['code'] );
        }
        else if( "title" == $code ) {
          echo '<a href="'.$row['code'];
          if ( $this->p['q'] ) echo "?q=".str_replace( '"', '&quot;', $this->p['q'] );
          echo '">'.$row['title']."</a>";
        }
        echo "</td>\n";
      }
      echo "  </tr>\n";
      $i++;
    }
    echo "\n</table>\n";
  }

  /**
   * Sqlite FTS3
   * Output a concordance from a search row with a text field, and an offset string pack
   * @param string $text The text from which to extract snippets
   * @param string $offsets A paack of integer in Sqlite format http://www.sqlite.org/fts3.html#section_4_1
   * @return null
   */
  public function conc($text, $offsets, $field=null, $chars=75)
  {
    $snip = array();
    if (!$field) $field = 0;
    $this->_text = $text; // for efficiency, set text at class level
    $offsets = explode(' ',$offsets);
    $mark = 0; // occurrence hilite counter
    $start = null;
    $count = count($offsets);
    for ($i = 0; $i<$count; $i = $i+4) {
      if($offsets[$i] != $field) continue; // match in another column
      // first index
      if ($start === null) $start = $offsets[$i+2];
      // if it is a phrase query continuing on next token, go next
      if ($i+6 < $count) {
        $from = $offsets[$i+2]+$offsets[$i+3];
        $length = $offsets[$i+6] - $from;
        $inter = substr($this->_text, $from, $length);
        if(!preg_match('/\pL/', $inter)) continue;
      }
      $mark++; // increment only when a <mark> is openened
      $size = $offsets[$i+2]+$offsets[$i+3]-$start;
      $snip[] = $this->snip($start, $size, $chars);
      /* TODO limit
      $start = null;
      $this->hitsCount++;
      if (($occBookMax && $mark >= $occBookMax)) {
        echo "\n     ".$this->msg('occbookmax', array($mark, ($basehref . $article['articleName'] . '?q=' .$qHref.'#mark1')));
        break;
      }
      if ($this->hitsCount >= $this->hitsMax) break;
      */
      $start = null;
    }
    return $snip;
  }
  function snip2div($snip, $href=null) {
    $width = 50; // kwic width
    echo "\n        " . '<div class="snip">';
    if ($href) echo "\n        " . '<a class="snip" href="' . $href.'#mark'.$mark.'">';
    echo '<span class="left">';
    if (mb_strlen($snip['left']) > $width + 5) {
      $pos = mb_strrpos($snip['left'], " ", 0 - $width);
      echo '<span class="exleft">' . mb_substr($snip['left'], 0, $pos) . '</span>' . mb_substr($snip['left'], $pos);
    }
    else echo $snip['left'];
    echo ' </span><span class="right"><mark>'.$snip['center'].'</mark>';
    if (mb_strlen($snip['right']) > $width + 5) {
      $pos = mb_strpos($snip['right']. ' ', " ", $width);
      echo mb_substr($snip['right'], 0, $pos) . '<span class="exright">' . mb_substr($snip['right'], $pos) . '</span>';
    }
    else echo $snip['right'];
    echo '</span>';
    if ($href) echo '</a>';
    echo '</div>';
  }
  function snip2array() {

  }

  /**
   * For a fulltext search result.
   * Snip a sentence in plain-text according to a byte offset
   * Dependant of a formated text with one sentence by line
   * return is an array with three components : left, center, right
   * reference text is set as a class field
   */
  public function snip($offset, $size, $chars=100)
  {
    $snip = array();
    $start = $offset-$chars;
    $length = $chars;
    if($start < 0) {
      $start = 0;
      $length = $offset-1;
    }
    if ($length) {
      $left = substr($this->_text, $start, $length);
      // cut at last line break
      if ($pos = strrpos($left, "\n")) $left = substr($left, $pos);
      // if no cut at a space
      else if ($pos = strpos($left, ' ')) $left = '… '.substr($left, $pos+1);
      $snip['left'] = ltrim(preg_replace('@[  \t\n\r]+@u', ' ', $left));
    }
    $snip['center'] = preg_replace('@[  \t\n\r]+@u', ' ', substr($this->_text, $offset, $size));
    $start = $offset+$size;
    $length = $chars;
    $len = strlen($this->_text);
    if ($start + $length - 1 > $len) $length = $len-$start;
    if($length) {
      $right = substr($this->_text, $start, $length);
      // cut at first line break
      if ($pos = strpos($right, "\n")) $right = substr($right,0, $pos);
      // or cut at last space
      else if ($pos = strrpos($right, ' ')) $right = substr($right, 0, $pos).' …';
      $snip['right'] = rtrim(preg_replace('@[  \t\n\r]+@u', ' ', $right));
    }
    return $snip;
  }

  /**
   * Infer occurrences count from a matchinfo SQLite byte blob
   * Is a bit slower than offsets, unavailable in sqlite 3.6.20 (CentOS6)
   * but more precise with phrase query
   *
   * $db->sqliteCreateFunction('matchinfo2occs', 'Sqlite::matchinfo2occs', 1);
   * $res = $db->prepare("SELECT matchinfo2occs(matchinfo(search, 'x')) AS occs , text FROM search  WHERE text MATCH ? ");
   * $res->execute(array('"Felix the cat"'));
   *
   * « Felix the cat, Felix the cat »
   * the cat felix       = 6
   * "felix the cat"     = 2
   * "felix the cat" the = 4
   *
   * matchinfo(?, 'x')
   * 32-bit unsigned integers in machine byte-order
   * 3 * cols * phrases
   * 1) In the current row, the number of times the phrase appears in the column.
   * 2) The total number of times the phrase appears in the column in all rows in the FTS table.
   * 3) The total number of rows in the FTS table for which the column contains at least one instance of the phrase.
  */
  static function matchinfo2occs($matchinfo)
  {
    $ints = unpack('L*', $matchinfo);
    $occs = 0;
    $max = count($ints)+1;
    for($a = 1; $a <$max; $a = $a+3 ) {
      $occs += $ints[$a];
    }
    return $occs;
  }
  /**
   * Infer occurrences count from an offsets() result
   * A bit faster than matchinfo, available in sqlite 3.6.20 (CentOS6)
   * but less precise for phrase query,
   *
   * $db->sqliteCreateFunction('offsets2occs', 'Sqlite::offsets2occs', 1);
   * $res = $db->prepare("SELECT offsets2occs(offsets(search))AS occs , text FROM search  WHERE text MATCH ? ");
   * $res->execute(array('"Felix the cat"'));
   *
   * « Felix the cat, Felix the cat »
   * felix the cat       = 6
   * "felix the cat"     = 6
   * "felix the cat" the = 8
   *
   * space-separated integers, 4 for each term in text
   *
   * 0   The column number that the term instance occurs in (0 for the leftmost column of the FTS table, 1 for the next leftmost, etc.).
   * 1   The term number of the matching term within the full-text query expression. Terms within a query expression are numbered starting from 0 in the order that they occur.
   * 2   The byte offset of the matching term within the column.
   * 3   The size of the matching term in bytes.
   */
  static function offsets2occs($offsets)
  {
    $occs = (1+substr_count($offsets, ' '))/4 ;
    // result from hidden field
    if ($occs == 1 && $offsets[0] == 1) return 0;
    return $occs;
  }
  /**
   * TODO, Repack a matchinfo array to hilite properly phrase query
   */
  static function offsetsRepack($offsets) {
    return $offsets;
  }

}
?>
