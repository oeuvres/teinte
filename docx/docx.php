<?php
/**
 * Class adhoc pour générer un docx à partir d’un XML/TEI
 */

set_time_limit(-1);
// included file, do nothing
if (isset($_SERVER['SCRIPT_FILENAME']) && basename($_SERVER['SCRIPT_FILENAME']) != basename(__FILE__));
else if (isset($_SERVER['ORIG_SCRIPT_FILENAME']) && realpath($_SERVER['ORIG_SCRIPT_FILENAME']) != realpath(__FILE__));
// direct command line call, work
else if (php_sapi_name() == "cli") Docx::cli();


class Docx {

  static function export($src, $dst) {
    $filename = pathinfo ($src, PATHINFO_FILENAME);
    $dom=self::dom($src);
    copy(dirname(__FILE__).'/template.docx', $dst);
    $zip = new ZipArchive;
    $zip->open($dst);

    $xml=self::xsl(dirname(__FILE__).'/tei2docx-comments.xsl', $dom, null, array('filename'=>$filename));
    $zip->addFromString('word/comments.xml', $xml);

    $xml=self::xsl(dirname(__FILE__).'/tei2docx.xsl', $dom, null, array('filename'=>$filename));
    $zip->addFromString('word/document.xml', $xml);

    $xml=self::xsl(dirname(__FILE__).'/tei2docx-fn.xsl', $dom, null, array('filename'=>$filename));
    $zip->addFromString('word/footnotes.xml', $xml);

    $xml=self::xsl(dirname(__FILE__).'/tei2docx-rels.xsl', $dom, null, array('filename'=>$filename));
    $zip->addFromString('word/_rels/document.xml.rels', $xml);

    $xml=self::xsl(dirname(__FILE__).'/tei2docx-fnrels.xsl', $dom, null, array('filename'=>$filename));
    $zip->addFromString('word/_rels/footnotes.xml.rels', $xml);

    $zip->close();

  }

  public static function cli() {
    array_shift($_SERVER['argv']); // shift first arg, the script filepath
    if (!count($_SERVER['argv'])) exit('
usage    : php -f docx.php (dstdir/)? srcdir/*.xml
    ');

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

    while($glob = array_shift($_SERVER['argv']) ) {
      foreach(glob($glob) as $srcfile) {
        $dstname = $dstdir . pathinfo( $srcfile, PATHINFO_FILENAME);
        $dst = $dstname.'.docx';
        $i = 0;
        $rename = $dst;
        while ( file_exists( $rename ) ) {
          if ( !$i ) echo "File $rename already exists, ";
          $i++;
          $rename = $dstname . '_' . $i . '.docx';
        }
        if ( $i ) {
          rename( $dst, $rename );
          echo "renamed to $rename\n";
        }
        echo "$srcfile > $dst\n";
        self::export($srcfile, $dst);
      }
    }

  }

  /**
   *  Apply code to an uploaded file
   */
  public static function doPost( $download=true ) {
    if( !count($_FILES) ) return false;
    reset($_FILES);
    $tmp=current($_FILES);
    if ( $tmp['name'] && !$tmp['tmp_name'] ) {
      echo $tmp['name'],' seems bigger than allowed size for upload in your php.ini : upload_max_filesize=',ini_get('upload_max_filesize'),', post_max_size=',ini_get('post_max_size');
      return false;
    }
    $srcfile=$tmp['tmp_name'];
    if ( $tmp['name'] ) $dstname=substr($tmp['name'], 0, strrpos($tmp['name'], '.')).".docx";
    else $dstname="tei.docx";
    header('Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document');
    header('Content-Disposition: attachment; filename="'.$dstname );
    header('Content-Description: File Transfer');
    header('Expires: 0');
    header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
    header('Pragma: public');

    $dstfile = tempnam( dirname( $tmp['tmp_name'] ), "Reteint");
    self::docx( $srcfile, $dstfile );
    header('Content-Length: ' . filesize( $dstfile ) );
    ob_clean();
    flush();
    readfile( $dstfile );
    unlink( $dstfile );
    exit();
  }


  static function dom($src, $xml="") {
    $dom = new DOMDocument("1.0", "UTF-8");
    $dom->preserveWhiteSpace = false;
    $dom->formatOutput=true;
    $dom->substituteEntities=true;
    if ($xml) $dom->loadXML($xml,  LIBXML_NOENT | LIBXML_NONET | LIBXML_NOWARNING ); // no warn for <?xml-model
    else $dom->load($src,  LIBXML_NOENT | LIBXML_NONET | LIBXML_NOWARNING );
    return $dom;
  }

  /**
   * Transformation xsl
   */
  static function xsl($xslFile, $dom, $dst=null, $pars=null) {
    $xsl = new DOMDocument("1.0", "UTF-8");
    $xsl->load($xslFile);
    $proc = new XSLTProcessor();
    $proc->importStyleSheet($xsl);
    // transpose params
    if($pars && count($pars)) foreach ($pars as $key => $value) $proc->setParameter('', $key, $value);
    // we should have no errors here
    if ($dst) $proc->transformToUri($dom, $dst);
    else return $proc->transformToXML($dom);
  }
}

?>
