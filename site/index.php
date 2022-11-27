<?php
declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use \Oeuvres\Kit\{Route, Web};

error_reporting(E_ALL);

$format = "html";
if ( isset( $_REQUEST['format'] ) ) $format = $_REQUEST['format'];
// A file is submited, work
$upload = Web::upload();
if ($upload) {
    // TODO
    /*
    $teinte = new Teinte_Doc( $upload['tmp_name'] );
    $teinte->filename( $upload['filename'] );
    $content = $teinte->export($format, null, array('theme'=>'../theme/'));
    header( 'Content-Type: '.Teinte_Web::$mime[$format] );
    if ( isset( $_REQUEST['download'] ) ) {
      header('Content-Disposition: attachment; filename="'.$upload['filename'].Teinte_Doc::$ext[$format].'"');
    }
    echo $content;
    */
    exit();
}
$lang = Web::lang();


?><!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8"/>
    <link rel="stylesheet"  href="<?= Route::home_href() ?>site/teinte_site.css"/>

    <script type="text/javascript">
function dropFile(e) {
  e.preventDefault();
  console.log(e.dataTransfer);
  if (e.dataTransfer.items) {
    // Use DataTransferItemList interface to access the file(s)
    [...e.dataTransfer.items].forEach((item, i) => {
      // If dropped items aren't files, reject them
      if (item.kind === 'file') {
        const file = item.getAsFile();
        console.log(`… file[${i}].name = ${file.name}`);
      }
    });
  } else {
    // Use DataTransfer interface to access the file(s)
    [...e.dataTransfer.files].forEach((file, i) => {
      console.log(`… file[${i}].name = ${file.name}`);
    });
  }
}

function dropDrag(e) {
  e.preventDefault();
}


    </script>
    <title><?php
if ($lang=='fr') echo'Teinte, transformer du TEI (HTML, txt…)';
else echo 'Teinte, transform TEI (HTML, txt…)'
    ?></title>
    </head>
  <body>
    <div id="win">
      <header id="header">
        <h1>Teinte, la conversion des livres (tei, docx, html, epub, txt)</h1>
      </header>
      <div id="row">
        <div id="upload">
          <header>
            <img width="64" src="<?=Route::home_href()?>site/img/icon_upload.svg"/>
            <h2>Votre fichier</h2>
          </header>
          <div
            id="drop_zone"
            ondrop="dropFile(event);"
            ondragover="dropDrag(event);">
            <p>Déposez un document (tei, docx, html, epub, txt)</p>
          </div>
        </div>
        <div id="html">
          <img id="banner" src="<?=Route::home_href()?>site/img/teinte.png"/>
        </div>
        <div id="download">
          <header>
            <h2>Téléchargements</h2>
            <img  width="64" src="<?=Route::home_href()?>site/img/icon_download.svg"/>
          </header>
          (formats)
        </div>
      </div>
     </div>
  </body>
</html>


<?php
/*
      <form class="center"
        enctype="multipart/form-data" method="POST" name="upload" target="_blank"
        onsubmit="
var filename=this.tei.value;
var pos=filename.lastIndexOf('.');
if(pos>0) filename=filename.substring(0, pos);
var radios = document.getElementsByName('format');
var format = 'html';
for ( var i = 0, length = radios.length; i < length; i++) {
  if (radios[i].checked) format = radios[i].value;
  break;
}
var ext = '.html';
if ( format == 'markdown' ) ext = '.md';
else if ( format == 'iramuteq' ) ext = '.txt';
else if ( format == 'naked' ) ext = '.txt';
this.action = 'index.php/'+filename+ext;
      ">
        <?php
if ($lang=='fr') {
echo '<p>Choisir un fichiers XML/TEI
<input type="file" size="70" name="tei"/>
</p>

<p>Choisir un format :
<label><input name="format" type="radio" value="html"'.( ($format == 'html')?' checked="checked"':'' ).'/> HTML</label>
<label><input name="format" type="radio" value="markdown"'.( ($format == 'markdown')?' checked="checked"':'' ).'/> Markdown</label>
<label><input name="format" type="radio" value="iramuteq"'.( ($format == 'iramuteq')?' checked="checked"':'' ).'/> Iramuteq</label>
<label><input name="format" type="radio" value="naked"'.( ($format == 'naked')?' checked="checked"':'' ).'/> Texte nu</label>
</p>
<p>
<button name="view">Voir</button> ou
<button name="download">Télécharger</button>
</p>
';} else {
echo '<p>Choose an XML/TEI file
<input type="file" size="70" name="tei"/>
</p>
<p>Choose a format
<label><input name="format" type="radio" value="html"'.( ($format == 'html')?' checked="checked"':'' ).'/> HTML</label>
<label><input name="format" type="radio" value="markdown"'.( ($format == 'markdown')?' checked="checked"':'' ).'/> Markdown</label>
<label><input name="format" type="radio" value="iramuteq"'.( ($format == 'iramuteq')?' checked="checked"':'' ).'/> Iramuteq</label>
<label><input name="format" type="radio" value="naked"'.( ($format == 'naked')?' checked="checked"':'' ).'/> Texte nu</label>
</p>
<p>
<button name="view">See</button> or
<button name="download">Download</button>
</p>
';
}
        ?>
      </form>
      <?php
if ($lang=='fr') echo '
<div class="small">
      <p>
Teinte est une librairie XSLT1+php qui peut s‘intégrer à plus d’un contexte, par exemple <a href="https://github.com/oeuvres/Bookmeka">Omeka</a>.
Cette transformation est générique, elle ne supporte qu’une partie des balises TEI,
      dite “<a href="http://obvil-dev.paris-sorbonne.fr/developpements/teibook/">Teibook</a>”.
Si vous trouvez que vos balises ne sont pas transformées à votre convenance,
<a href="#" onmouseover="if(this.ok)return; this.href=\'mai\'+\'lt\'+\'o:frederic.glorieux\'+\'\\u0040\'+\'fictif.org\'; this.ok=true">écrivez-moi</a> (avec un fichier exemple).
      </p>
</div>
      ';
else echo '
<div class="small">
      <p>
Teinte is an XSLT1-php lib, free to embed in different contexts, for example <a href="https://github.com/oeuvres/Bookmeka">Omeka</a>.
We do not claim to support all TEI, but a profile called “<a href="http://obvil-dev.paris-sorbonne.fr/developpements/teibook/">Teibook</a>”.
If you think that your tags are not well rendered, fill free to <a href="#" onmouseover="if(this.ok)return; alert(\'\u064\'); this.href=\'mai\'+\'lt\'+\'o:frederic.glorieux\'+\'\\u0040\'+\'fictif.org\'; this.ok=true">send me a mail</a> (with a sample file).
      </p>
</div>
      ';


      ?>
*/