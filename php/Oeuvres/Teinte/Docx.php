<?php
/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 */

declare(strict_types=1);

namespace Oeuvres\Teinte;

use Exception, ZipArchive;
use Oeuvres\Kit\Xml;
use Psr\Log\LoggerInterface;


/**
 * Class adhoc pour générer un docx à partir d’un XML/TEI
 * code convention https://www.php-fig.org/psr/psr-12/
 */

set_time_limit(-1);
Docx::init();
class Docx
{
    private static LoggerInterface $logger;
    private static $xslDir;

    public static function init()
    {
        self::$xslDir = dirname(dirname(dirname(__DIR__))) . "/xsl";
    }

    public static function setLogger(LoggerInterface $logger) {
        self::$logger = $logger;
    }

    static function export($srcFile, $dstFile, $template = null)
    {
        if (!$template) $template = self::$xslDir . '/docx/template.docx';
        if (!file_exists($template)) {
            throw new Exception("Template not found: " . $template);
        }
        $teidoc = new Teidoc(self::$logger);
        $dom = $teidoc->load($srcFile);
        copy($template, $dstFile);
        $zip = new ZipArchive();
        $zip->open($dstFile);

        $re_clean = array(
            '@(<w:rPr/>|<w:pPr/>)@' => '',
        );

        // a tmp file where to put files from template
        $templPath = tempnam(sys_get_temp_dir(), "teinte_docx_");
        $templPath = "file:///" 
            . str_replace(DIRECTORY_SEPARATOR, "/", $templPath);

        $xml = Xml::transformDoc(
            self::$xslDir . '/docx/tei2docx-comments.xsl', 
            $dom,
            null, 
            array('filename' => $teidoc->name())
        );
        $zip->addFromString('word/comments.xml', $xml);

        file_put_contents($templPath, $zip->getFromName('word/document.xml'));
        $xml = Xml::transformDoc(
            self::$xslDir . '/docx/tei2docx.xsl',
            $dom,
            null,
            array(
                'filename' => $teidoc->name(),
                'templPath' => $templPath,
            )
        );
        $xml = preg_replace(
            array_keys($re_clean), 
            array_values($re_clean), 
            $xml
        );
        $zip->addFromString('word/document.xml', $xml);

        file_put_contents($templPath, $zip->getFromName('word/_rels/document.xml.rels'));
        $xml = Xml::transformDoc(
            self::$xslDir . '/docx/tei2docx-rels.xsl',
            $dom,
            null,
            array(
                'filename' => $teidoc->name(),
                'templPath' => $templPath,
            )
        );
        $zip->addFromString('word/_rels/document.xml.rels', $xml);


        $xml = Xml::transformDoc(
            self::$xslDir . '/docx/tei2docx-fn.xsl',
            $dom,
            null, 
            array('filename' => $teidoc->name())
        );
        $xml = preg_replace(
            array_keys($re_clean), 
            array_values($re_clean), 
            $xml
        );
        $zip->addFromString('word/footnotes.xml', $xml);


        $xml = Xml::transformDoc(
            self::$xslDir . '/docx/tei2docx-fnrels.xsl',
            $dom,
            null,
            array('filename' => $teidoc->name())
        );
        $zip->addFromString('word/_rels/footnotes.xml.rels', $xml);

        $zip->close();
    }


    /**
     *  Apply code to an uploaded file
     */
    public static function doPost($download = true)
    {
        if (!count($_FILES)) return false;
        reset($_FILES);
        $tmp = current($_FILES);
        if ($tmp['name'] && !$tmp['tmp_name']) {
            echo $tmp['name'], ' seems bigger than allowed size for upload in your php.ini: upload_max_filesize=', ini_get('upload_max_filesize'), ', post_max_size=', ini_get('post_max_size');
            return false;
        }
        $srcfile = $tmp['tmp_name'];
        if ($tmp['name']) $dstname = substr($tmp['name'], 0, strrpos($tmp['name'], '.')) . ".docx";
        else $dstname = "tei.docx";
        header('Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document');
        header('Content-Disposition: attachment; filename="' . $dstname);
        header('Content-Description: File Transfer');
        header('Expires: 0');
        header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
        header('Pragma: public');

        $dstfile = tempnam(dirname($tmp['tmp_name']), "Reteint");
        self::export($srcfile, $dstfile);
        header('Content-Length: ' . filesize($dstfile));
        ob_clean();
        flush();
        readfile($dstfile);
        unlink($dstfile);
        exit();
    }

}
