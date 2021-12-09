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

use Exception, DOMDocument, ZipArchive;
use Oeuvres\Kit\File;
use Oeuvres\Kit\Xml;
use Psr\Log\LoggerInterface;

/**
 * Output a MS.Word conmformat docx from TEI.
 * code convention https://www.php-fig.org/psr/psr-12/
 */

class Tei2docx extends Tei2
{
    /** A docx file used as a template */
    private string $template = "";
    protected $ext = '.docx';
    protected $name = 'docx';
    protected $label = 'Microsoft.Word 2007 format';


    /**
     * Set a docx file as a template,
     * usually the same for a collection of tei docs.
     */
    function template(?string $template = null):string
    {
        if (!$template && $this->template) {
            return $this->template;
        }
        if (!$template) {
            $template = self::$xslDir . '/docx/template.docx';
        }
        File::readable($template); // check if file exists
        // test if it’s a zip now ?
        $this->template = $template;
        return $this->template;
    }

    /**
     * @ override
     */
    function toDoc(DOMDocument $dom):?\DOMDocument
    {
        $this->logger->error(__METHOD__." dom export not relevant");
        return null;
    }
    /**
     * @ override
     */
    function toXml(DOMDocument $dom):?string
    {
        $this->logger->error(__METHOD__." dom export not relevant");
        return null;
    }

    /**
     * @ override
     */
    function toUri($dom, $dstFile)
    {
        $this->logger->info("Tei2\033[92m" . $this->name() ." \033[0m $dstFile");
        File::writable($dstFile);
        $name = pathinfo($dom->documentURI, PATHINFO_FILENAME);
        copy($this->template(), $dstFile);
        $zip = new ZipArchive();
        $zip->open($dstFile);

        $re_clean = array(
            '@(<w:rPr/>|<w:pPr/>)@' => '',
        );

        // a tmp file where to put files from template
        $templPath = tempnam(sys_get_temp_dir(), "teinte_docx_");
        $templPath = "file:///" 
            . str_replace(DIRECTORY_SEPARATOR, "/", $templPath);
        // $this->logger->debug(__METHOD__.' $templPath='.$templPath);

        $xml = Xml::transformToXml(
            self::$xslDir . '/docx/tei2docx-comments.xsl', 
            $dom,
        );
        $zip->addFromString('word/comments.xml', $xml);

        // generation of word/document.xml needs some links
        // from template, espacially for head and foot page.
        file_put_contents($templPath, $zip->getFromName('word/document.xml'));
        $xml = Xml::transformToXml(
            self::$xslDir . '/docx/tei2docx.xsl',
            $dom,
            array(
                'templPath' => $templPath,
            )
        );
        $xml = preg_replace(
            array_keys($re_clean), 
            array_values($re_clean), 
            $xml
        );
        $zip->addFromString('word/document.xml', $xml);

        // keep some relations in footnotes from temèplate
        file_put_contents(
            $templPath, 
            $zip->getFromName('word/_rels/document.xml.rels')
        );
        $xml = Xml::transformToXml(
            self::$xslDir . '/docx/tei2docx-rels.xsl',
            $dom,
            array(
                'templPath' => $templPath,
            )
        );
        $zip->addFromString('word/_rels/document.xml.rels', $xml);


        $xml = Xml::transformToXml(
            self::$xslDir . '/docx/tei2docx-fn.xsl',
            $dom,
        );
        $xml = preg_replace(
            array_keys($re_clean), 
            array_values($re_clean), 
            $xml
        );
        $zip->addFromString('word/footnotes.xml', $xml);


        $xml = Xml::transformToXml(
            self::$xslDir . '/docx/tei2docx-fnrels.xsl',
            $dom,
        );
        $zip->addFromString('word/_rels/footnotes.xml.rels', $xml);
        // 
        if (!$zip->close()) {
            $this->logger->error(
                "Tei2" . $this->name() ." ERROR writing \033[91m$dstFile\033[0m"
            );
        }
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
        // self::export($srcfile, $dstfile);
        header('Content-Length: ' . filesize($dstfile));
        ob_clean();
        flush();
        readfile($dstfile);
        unlink($dstfile);
        exit();
    }

}

// EOF