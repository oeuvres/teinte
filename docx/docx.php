<?php
/**
 * Class adhoc pour générer un docx à partir d’un XML/TEI
 */
include_once(dirname(dirname(__FILE__)).'/php/tools.php');

set_time_limit(-1);
// included file, do nothing
if (isset($_SERVER['SCRIPT_FILENAME']) && basename($_SERVER['SCRIPT_FILENAME']) != basename(__FILE__));
else if (isset($_SERVER['ORIG_SCRIPT_FILENAME']) && realpath($_SERVER['ORIG_SCRIPT_FILENAME']) != realpath(__FILE__));
// direct command line call, work
else if (php_sapi_name() == "cli") Docx::cli();


class Docx {

  static function export($src, $dst, $template=null) {
    if (!$template) $template = dirname(__FILE__).'/template.docx';
    if (!file_exists($template)) {
      throw new Exception("Template not found: ".$template);
    }
    $filename = pathinfo ($src, PATHINFO_FILENAME);
    $dom=self::dom($src);
    copy($template, $dst);
    $zip = new ZipArchive;
    $zip->open($dst);

    $re_clean = array(
      '@(<w:rPr/>|<w:pPr/>)@' => '',
    );

    // a tmp file where to put files from template
    $templPath = tempnam(sys_get_temp_dir(), "teinte_docx_");


    $xml=self::xsl(dirname(__FILE__).'/tei2docx-comments.xsl', $dom, null, array('filename'=>$filename));
    $zip->addFromString('word/comments.xml', $xml);

    file_put_contents($templPath, $zip->getFromName('word/document.xml'));
    $xml=self::xsl(dirname(__FILE__).'/tei2docx.xsl', $dom, null,
      array(
        'filename'=>$filename,
        'templPath' => $templPath,
      )
    );
    $xml = preg_replace(array_keys($re_clean), array_values($re_clean), $xml);
    $zip->addFromString('word/document.xml', $xml);

    file_put_contents($templPath, $zip->getFromName('word/_rels/document.xml.rels'));
    $xml=self::xsl(dirname(__FILE__).'/tei2docx-rels.xsl', $dom, null,
     array(
       'filename'=>$filename,
       'templPath' => $templPath,
      )
    );
    $zip->addFromString('word/_rels/document.xml.rels', $xml);


    $xml=self::xsl(dirname(__FILE__).'/tei2docx-fn.xsl', $dom, null, array('filename'=>$filename));
    $xml = preg_replace(array_keys($re_clean), array_values($re_clean), $xml);
    $zip->addFromString('word/footnotes.xml', $xml);


    $xml=self::xsl(dirname(__FILE__).'/tei2docx-fnrels.xsl', $dom, null, array('filename'=>$filename));
    $zip->addFromString('word/_rels/footnotes.xml.rels', $xml);

    $zip->close();

  }

  public static function cli() {
    array_shift($_SERVER['argv']); // shift first arg, the script filepath
    if (!count($_SERVER['argv'])) exit('
usage    : php -f docx.php (dstdir/)? srcdir/*.xml
    ');
    $force = false;
    $arg0 = $_SERVER['argv'][0];
    if ($arg0 == '-f' || $arg0 == '-force'  || $arg0 == 'force') {
      $force = true;
      array_shift($_SERVER['argv']);
    }


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
        if (!$force) {
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


  static function dom($teifile) {
    $xml = file_get_contents($teifile);
    $re_norm = array(
      '@\s\s+@' => ' ',
      '@\s*(<pb[^>]*/>)\s*@' => '$1 ',
      '@\s*(<lb( [^>]*)?/>)\s*@' => '$1',
      '@(<(ab|head|l|note|p|stage)( [^>]*)?>)\s+@' => '$1',
      '@\s+(</(ab|head|l|note|p|stage)>)@' => '$1',
      '@(<(ab|head|l|p|stage)( [^>]*)?>)\s*(<pb( [^>]*)?/>)\s+@' => '$1$4',
    );
    $xml = preg_replace(
      array_keys($re_norm),
      array_values($re_norm),
      $xml
    );
    // echo $xml;
    $dom = new DOMDocument("1.0", "UTF-8");
    $dom->preserveWhiteSpace = true; // spaces are normalized upper, keep them
    $dom->formatOutput=true;
    $dom->substituteEntities=true;
    $dom->loadXML($xml,  LIBXML_NOENT | LIBXML_NONET | LIBXML_NOWARNING ); // no warn for <?xml-model
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
