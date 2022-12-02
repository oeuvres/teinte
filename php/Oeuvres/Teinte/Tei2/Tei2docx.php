<?php
/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 */

declare(strict_types=1);

namespace Oeuvres\Teinte\Tei2;

use Exception, DOMDocument, ZipArchive;
use Oeuvres\Kit\{Check, Log, Filesys, Xsl};
Check::extension('zip');

/**
 * Output a MS.Word docx document from TEI.
 * code convention https://www.php-fig.org/psr/psr-12/
 */
class Tei2docx extends AbstractTei2
{
    /** A docx file used as a template */
    static private string $template;
    const NAME = 'docx';
    const EXT = '.docx';
    const LABEL = 'Microsoft.Word 2007 format';
    /** Some mapping between 3 char iso languange code to 2 char */
    const ISO639_3char = [
        'eng' => 'en',
        'fra' => 'fr',
        'lat' => 'la',    
    ];

    public function __construct()
    {
        // set default template
        $this->template = self::$xsl_dir . '/tei_docx/template.docx';
    }


    /**
     * Set a docx file as a template,
     * usually the same for a collection of tei docs.
     */
    static function template(?string $dir = null):string
    {
        $dir = Filesys::normdir($dir);
        $template = null;
        if ($dir && is_dir($dir)) {
            $template =  $dir . basename($dir) . ".docx";
            // first doc of dir ?
            if (!is_file($template)) {
                $glob = glob($dir . "*.docx");
                if (!$glob || count($glob) < 1) {
                    $template = null;
                } else {
                    $template = $glob[0];
                }
            }
        }
        if ($template) {
            Log::info(__CLASS__ . "::" . __FUNCTION__ . " $template");
            $this->template = $template;
        }
        // ask for template, maybe set before
        else if(!$dir && $this->template) {
        }
        else {
            $this->template = self::$xsl_dir . '/tei_docx/template.docx';
        }
        return $this->template;
    }

    /**
     * @ override
     */
    static function toDoc(DOMDocument $dom, ?array $pars=null):?\DOMDocument
    {
        Log::error(__METHOD__." dom export not relevant");
        return null;
    }
    /**
     * @ override
     */
    static function toXml(DOMDocument $dom, ?array $pars=null):?string
    {
        Log::error(__METHOD__." xml export not relevant");
        return null;
    }

    /**
     * @ override
     */
    static function toUri($dom, $dst_file, ?array $pars=null)
    {
        Log::info("Tei2\033[92m" . static::NAME ." \033[0m $dst_file");
        Filesys::writable($dst_file);
        $name = pathinfo($dom->documentURI, PATHINFO_FILENAME);
        $template = $this->template; // should have been set
        copy($template, $dst_file);
        $zip = new ZipArchive();
        $zip->open($dst_file);

        // get a default lang from the source TEI, set it in the style.xml
        $xpath = Xsl::xpath($dom);
        $entries = $xpath->query("/*/@xml:lang");
        $lang = null;
        foreach ($entries as $node) {
            $lang = $node->value;
        }
        // template is supposed to have a default language
        if ($lang) {
            if (isset(self::ISO639_3char[$lang])) $lang = self::ISO639_3char[$lang];
            $name = 'word/styles.xml';
            $xml = $zip->getFromName($name);
            $xml = preg_replace(
                '@<w:lang[^>]*/>@', 
                '<w:lang w:val="'. $lang . '"/>', 
                $xml
            );
            $zip->deleteName($name);
            $zip->addFromString( $name, $xml);
        }


        $re_clean = array(
            '@(<w:rPr/>|<w:pPr/>)@' => '',
        );

        // extract template to 
        $templPath = tempnam(sys_get_temp_dir(), "teinte_docx_");
        $templPath = "file:///" 
            . str_replace(DIRECTORY_SEPARATOR, "/", $templPath);
        // $this->logger->debug(__METHOD__.' $templPath='.$templPath);

        $xml = Xsl::transformToXml(
            self::$xsl_dir . '/tei_docx/tei_docx_comments.xsl', 
            $dom,
        );
        $zip->addFromString('word/comments.xml', $xml);

        // generation of word/document.xml needs some links
        // from template, espacially for head and foot page.
        file_put_contents($templPath, $zip->getFromName('word/document.xml'));
        $xml = Xsl::transformToXml(
            self::$xsl_dir . '/tei_docx/tei_docx.xsl',
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
        $xml = Xsl::transformToXml(
            self::$xsl_dir . '/tei_docx/tei_docx_rels.xsl',
            $dom,
            array(
                'templPath' => $templPath,
            )
        );
        $zip->addFromString('word/_rels/document.xml.rels', $xml);


        $xml = Xsl::transformToXml(
            self::$xsl_dir . '/tei_docx/tei_docx_fn.xsl',
            $dom,
        );
        $xml = preg_replace(
            array_keys($re_clean), 
            array_values($re_clean), 
            $xml
        );
        $zip->addFromString('word/footnotes.xml', $xml);


        $xml = Xsl::transformToXml(
            self::$xsl_dir . '/tei_docx/tei_docx_fnrels.xsl',
            $dom,
        );
        $zip->addFromString('word/_rels/footnotes.xml.rels', $xml);
        // 
        if (!$zip->close()) {
            Log::error(
                "Tei2" . static::NAME ." ERROR writing \033[91m$dst_file\033[0m\nMaybe an app has an handle on this file. Is this docx open in MS.Word or LibreO.Writer?"
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
        header('Content-Type: ');
        header('Content-Disposition: attachment; filename="' . $dstname);
        header('Content-Description: File Transfer');
        header('Expires: 0');
        header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
        header('Pragma: public');

        $dst_file = tempnam(dirname($tmp['tmp_name']), "Reteint");
        // self::export($srcfile, $dst_file);
        header('Content-Length: ' . filesize($dst_file));
        ob_clean();
        flush();
        readfile($dst_file);
        unlink($dst_file);
        exit();
    }

}
// EOF